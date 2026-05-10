import { badRequestError, externalServiceError } from "../../lib/app-error";
import type { TelegramConfigValue, TelegramProviderAdapter, TelegramSendInput } from "./types";

function normalizeBaseUrl(value: string) {
  return value.trim().replace(/\/+$/, "") || "https://api.telegram.org";
}

async function parseJsonSafely(response: Response) {
  try {
    return (await response.json()) as Record<string, unknown>;
  } catch {
    return null;
  }
}

function trimMessage(text: string) {
  if (text.length <= 3900) return text;
  return `${text.slice(0, 3880)}\n...\n(message truncated)`;
}

export function createTelegramAdapter(config: TelegramConfigValue): TelegramProviderAdapter {
  return {
    async send(input: TelegramSendInput) {
      if (!config.botToken?.trim()) {
        throw badRequestError("Telegram Bot Token 不能为空", "TELEGRAM_BOT_TOKEN_REQUIRED");
      }

      const chatId = input.chatId?.trim() || config.chatId?.trim();
      if (!chatId) {
        throw badRequestError("Telegram Chat ID 不能为空", "TELEGRAM_CHAT_ID_REQUIRED");
      }

      const body: Record<string, unknown> = {
        chat_id: chatId,
        text: trimMessage(input.text),
        disable_web_page_preview: true,
      };

      const response = await fetch(`${normalizeBaseUrl(config.apiBaseUrl)}/bot${config.botToken}/sendMessage`, {
        method: "POST",
        headers: {
          accept: "application/json",
          "content-type": "application/json",
        },
        body: JSON.stringify(body),
      });

      const json = await parseJsonSafely(response);
      if (!response.ok || json?.ok === false) {
        const description = typeof json?.description === "string" ? json.description : "Telegram 通知发送失败";
        throw externalServiceError(description, "TELEGRAM_SEND_FAILED");
      }

      const result = json?.result as { message_id?: number } | undefined;
      return {
        messageId: typeof result?.message_id === "number" ? String(result.message_id) : undefined,
        raw: json,
      };
    },
  };
}
