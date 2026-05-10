import { createHash } from "node:crypto";
import { badRequestError, externalServiceError } from "../../lib/app-error";
import { logger } from "../../lib/logger";
import type { PaymentProviderAdapter } from "./provider";

interface BepusdtConfig {
  baseUrl: string;
  appId?: string;
  appSecret?: string;
  merchantId?: string;
  paymentType?: string;
  notifyUrl?: string;
  returnUrl?: string;
}

function normalizeBaseUrl(value: string) {
  return value.replace(/\/+$/, "");
}

function signSortedPayload(payload: Record<string, string | number>, secret: string) {
  const base = Object.entries(payload)
    .filter(([, value]) => value !== "" && value !== undefined && value !== null)
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([key, value]) => `${key}=${value}`)
    .join("&");

  return createHash("md5").update(`${base}${secret}`).digest("hex");
}

function signCreateOrder(payload: {
  type: string;
  amount: number;
  notify_url: string;
  order_id: string;
  redirect_url: string;
}, secret: string) {
  return signSortedPayload(payload, secret);
}

function signCallback(payload: Record<string, string | number>, secret: string) {
  return signSortedPayload(payload, secret);
}

export function createBepusdtAdapter(config: BepusdtConfig): PaymentProviderAdapter {
  return {
    async createPayment(input) {
      if (!config.baseUrl || !config.appSecret || !config.paymentType) {
        throw badRequestError("BEpusdt 配置不完整", "BEPUSDT_CONFIG_INCOMPLETE");
      }

      const payload = {
        type: config.paymentType,
        order_id: input.orderNo,
        amount: Number((input.amount / 100).toFixed(2)),
        notify_url: input.notifyUrl,
        redirect_url: input.returnUrl,
      };
      const merchantId = (config.merchantId || config.appId || "default").trim() || "default";

      const signature = signCreateOrder(payload, config.appSecret);

      type BepusdtResponse = {
        status_code?: number;
        message?: string;
        data?: {
          trade_id?: string;
          payment_url?: string;
        };
      };

      let json: BepusdtResponse;
      try {
        const response = await fetch(`${normalizeBaseUrl(config.baseUrl)}/api/create_order`, {
          method: "POST",
          headers: { "content-type": "application/json" },
          body: JSON.stringify({ ...payload, merchant_id: merchantId, signature }),
        });
        const text = (await response.text()).replace(/^\uFEFF/, "");
        json = JSON.parse(text) as BepusdtResponse;
      } catch (err) {
        throw externalServiceError(
          `BEpusdt 请求失败: ${err instanceof Error ? err.message : String(err)}`,
          "BEPUSDT_INVALID_RESPONSE"
        );
      }

      if (json.status_code !== 200 || !json.data?.payment_url) {
        throw externalServiceError(json.message || "BEpusdt 创建支付失败", "BEPUSDT_CREATE_PAYMENT_FAILED");
      }

      return {
        payUrl: json.data.payment_url,
        paymentOrderNo: json.data.trade_id,
        raw: json,
      };
    },

    async verifyNotify(payload) {
      if (!config.appSecret) {
        return {
          isValid: false,
          raw: payload,
          message: "missing app secret",
        };
      }

      logger.info("bepusdt.verify_notify", { payload });
      const signature = payload.signature || "";
      const unsignedPayload = { ...payload };
      delete unsignedPayload.signature;
      const expected = signCallback(unsignedPayload, config.appSecret);
      const statusVal = String(payload.status);
      const status = statusVal === "2" ? "PAID" : statusVal === "3" ? "FAILED" : "PENDING";

      return {
        isValid: signature === expected,
        orderNo: payload.order_id,
        paymentOrderNo: payload.trade_id,
        amount: payload.amount ? Math.round(Number(payload.amount) * 100) : undefined,
        status,
        raw: payload,
        message: signature === expected ? "ok" : "invalid signature",
      };
    },
  };
}
