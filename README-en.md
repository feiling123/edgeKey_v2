[![English](https://img.shields.io/badge/English-Click-yellow)](README-en.md)
[![中文文档](https://img.shields.io/badge/中文文档-点击查看-orange)](README.md)

# EdgeKey

EdgeKey is a full-stack card key shop system built with the Vike framework, deployable directly to Cloudflare. The same codebase includes frontend pages, SSR rendering, and backend API endpoints, all running on Cloudflare Workers.

## Features

- 🚀 **Truly Zero Cost** — No server or domain purchase needed. Runs on Cloudflare's global edge network. One-click deploy, instantly live.
- 🌍 **Zero Ops** — Built on Workers + D1. The free tier is sufficient for daily operations with no surprise bills.
- 🛍️ **Product Management** — Supports categories, product listing/unlisting, inventory modes (limited/unlimited), and min/max purchase quantities.
- 🔑 **Card Key Management** — Bulk import card keys, automatic delivery after payment, real-time inventory alerts.
- 📦 **Order Management** — Order list, manual redelivery, auto-close expired orders, and detailed payment logs.
- 💳 **Multiple Payment Gateways** — Built-in BEpusdt (USDT) and Epay (aggregated payments), with plugin-style extensibility for more.
- 🔔 **Telegram Notifications** — Supports Telegram Bot API, with payment success, delivery success, delivery failure alerts, and send logs.
- ⚙️ **Site Settings** — Flexible configuration for site name, logo, announcements, and support contact.
- 🔐 **Admin Panel** — Secure administrator account system.

> [!TIP]
> **About zero-cost operation:** When combined with a payment channel (USDT, self-hosted, etc.), Telegram Bot notifications, and a free image hosting service, this project can achieve **100% zero-cost** operation.

## Screenshots

![1](https://img.91starry.com/uploads/20260427/6286ff36cc987c47a1a27516db0d94c8.jpg)

![2](https://img.91starry.com/uploads/20260427/6072aac36a1d1db8b79cdb535d45138f.jpg)

![3](https://img.91starry.com/uploads/20260427/95dedb45c5d16d8cf69ffa058539b19d.jpg)

## Quick Start

Three deployment methods are supported, ordered by recommendation:

| Method | Best For | Ease |
|---|---|---|
| **One-Click Deploy** (recommended) | First-time deploy, no local environment needed | ⭐⭐⭐ Simplest, fully automatic |
| **Git Auto Deploy** | Continuous iteration, auto-update on push | ⭐⭐ Fully automatic after one-time setup |
| **Manual Deploy** | Custom development, full control | ⭐ Requires local environment and CLI |

### One-Click Deploy to Cloudflare Workers

[![Deploy to Cloudflare](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/34892002/edgeKey)

> **After clicking the button, the Cloudflare Workers deployment wizard will open:**
> 1. Log in and authorize your Git account (GitHub/GitLab). It will automatically create a new repository under your account.
> 2. For security, change the default secret (`AUTH_SECRET`) in the wizard.
> 3. If you don't bind an existing D1 database, it will automatically create and initialize one (including admin account), no manual steps needed.
> 4. After deployment, find a log entry like `Deployed edgekey triggers (0.38 sec) https://edgekey.youraccount.workers.dev` — that URL is your site.
> 5. The admin route is controlled by the `ADMIN_PATH` variable. The default is `admin`, so the initial login URL is `https://edgekey.youraccount.workers.dev/admin`. For production, change it to a random path in Cloudflare Variables. Default credentials: `admin` / `admin123456`. **Change your password immediately after first login!**

### Git-Connected Cloudflare Auto Deploy

If you use Cloudflare Workers' Git integration (auto-deploy on GitHub/GitLab push), keep the deploy command as:

```bash
npm run deploy
```

`npm run deploy` only runs `wrangler deploy`. It does not run D1 migrations during the build stage, so GitHub-triggered auto deploys do not fail when `wrangler.jsonc` has no `database_id`. The Worker initializes the D1 schema and seed data automatically on the first request or first Cron run.

If you manually created a D1 database and added its `database_id` to `wrangler.jsonc`, you can still use `npm run deploy:full` locally for the classic migration + seed + deploy flow.

**2. Configure AUTH_SECRET Environment Variable**

In the Cloudflare Workers Git integration "Advanced Settings":
1. Add variable name `AUTH_SECRET`
2. Enter your secret string as the value
3. Check the "Encrypt" option

### Manual Build & Deploy

Before deploying to Cloudflare for the first time, create and initialize the D1 database:

**1. Login and create the database**

```bash
npx wrangler login
npx wrangler d1 create edgekey-db
```

**2. Bind the Database ID**

Copy the `database_id` from the terminal output into `wrangler.jsonc`:

```jsonc
"d1_databases": [
  {
    "binding": "DB",
    "database_name": "edgekey-db",
    "database_id": "YOUR_UUID_HERE", // <-- add this line
    "migrations_dir": "prisma/migrations"
  }
]
```

**3. Initialize remote table schema**

```bash
npm run db:migrations:remote
```

**4. Seed admin account and initial data**

```bash
npm run db:seed:remote
```

**5. Configure AUTH_SECRET**

```bash
npx wrangler secret put AUTH_SECRET
```

**6. Generate Prisma Client and deploy**

```bash
npm run db:generate
npm run up
```

`npm run up` is equivalent to build + publish:
- `vike build`
- `wrangler deploy`

## Security Notes (Important)

The project uses admin username/password login. Before using in production:
- The system uses `AUTH_SECRET` or `NEXTAUTH_SECRET` from Cloudflare variables/secrets when configured.
- If no auth secret is configured, the app generates a per-install login secret in the D1 `RuntimeSecret` table. It does not use a fixed public default secret.
- For production, configuring `AUTH_SECRET` manually is still recommended. Command: `wrangler secret put AUTH_SECRET`
- Default admin credentials: `admin / admin123456` — **change your password immediately after first login.**

### Forgot Your Password?

Reset your password to `admin123456` via the D1 Console in Cloudflare Dashboard:

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com) → **Storage & Databases** → **D1** → click `edgekey-db`
2. Open the **Console** tab
3. Run the following SQL:

```sql
UPDATE Admin SET passwordHash = '$2b$10$viMe8RgcpM30gmmF9OpOcuA/QgleSIUk5VRtqjOulfSIbgK5jQCI6' WHERE username = 'admin';
```

4. Log in and change your password immediately.

## Local Development

npm is recommended. pnpm/yarn can also be used.

```bash
npm install
```

Since this project uses Cloudflare D1, you must initialize the local D1 simulator schema before starting the dev server for the first time:

```bash
# 1. Generate Prisma Client (required after first install)
npm run db:generate

# 2. Apply all migrations to the local Wrangler simulator
npm run db:migrations:local

# 3. Seed admin account and initial data
npm run db:seed

# 4. Prepare .env file
# Fill in required env vars (e.g. AUTH_SECRET) in env.example, then copy to env.

# 5. Start dev server
npm run dev
```

### Cloudflare D1 + Prisma Local Dev Workflow

This project follows the official [Prisma + Cloudflare D1 guide](https://www.prisma.io/docs/guides/deployment/cloudflare-d1) best practices.

- `npm run dev` runs in a Cloudflare-style local environment; Prisma connects to the **local D1 simulator** via `env.DB`.
- After `npm run up`, Prisma connects to **remote D1** via the same `env.DB` binding.
- `DATABASE_URL` in `.env` is only used by the Prisma CLI, not at runtime.
- The current `prisma/schema.prisma` only retains the Cloudflare client generator; runtime uses `generated/prisma/client`.

### Database Development Workflow

When modifying the database schema, follow this process strictly:

**Step 1: Modify schema and generate SQL migration**

```bash
npx prisma migrate diff \
  --from-migrations prisma/migrations \
  --to-schema prisma/schema.prisma \
  --script > prisma/migrations/0002_xxx.sql
```

- `0001_init.sql` is for initial setup only — do not overwrite it.
- Add incremental files in order: `0002_add_foo.sql`, `0003_add_bar.sql`, etc.

**Step 2: Sync to local D1 simulator**

```bash
npm run db:migrations:local
```

**Step 3: Sync to Cloudflare remote (before publishing)**

```bash
npm run db:migrations:remote
```

### Daily Dev Command

```bash
npm run dev
```

### Telefunc Notes

- Telefunc functions are placed in the corresponding page directory, ending with `.telefunc.ts`.
- On Windows + `npm run dev` + `workerd`, Telefunc's dev-mode naming/co-location check triggers a path compatibility issue, so it is disabled in `server/telefunc-handler.ts`. This does not affect actual Telefunc loading or invocation.

**⚠️ Never do the following:**
1. Do **not** assume `npm run dev` uses `prisma/db.sqlite` — it uses the local D1 simulator.
2. Do **not** use `prisma migrate dev` — it deviates from the D1 migration workflow.
3. Do **not** overwrite `prisma/migrations/0001_init.sql` — keep init and incremental migrations separate.

## Tech Stack

- **Framework & Rendering:** Vike (file routing + SSR), Vue 3
- **Server / Runtime:** Hono, Photon, Wrangler
- **Data & Mutations:** Telefunc, Prisma, D1 (Cloudflare native SQLite)
- **UI:** Tailwind CSS, daisyUI
- **Auth:** Auth.js (admin username/password login)

## Project Structure

```text
.
├─ assets/                 # Static assets
├─ components/             # Reusable components (non-route pages)
├─ pages/                  # Vike file routing (pages co-located with components/styles/types)
│  ├─ +config.ts           # Global config (title, SSR, etc.)
│  ├─ +Layout.vue          # Global layout
│  ├─ +Head.vue            # Global head tags
│  ├─ tailwind.css         # Tailwind + daisyUI entry
│  ├─ index/+Page.vue      # Storefront home (/)
│  ├─ product/+Page.vue    # Product detail (/product/:slug)
│  ├─ query/+Page.vue      # Order query (/query)
│  ├─ order/+Page.vue      # Order detail (/order/:orderNo)
│  ├─ admin/               # Admin panel (/admin)
│  └─ _error/+Page.vue     # Error page
├─ server/                 # Server entry (Hono) and middleware
│  ├─ entry.ts
│  ├─ authjs-handler.ts
│  ├─ prisma-middleware.ts
│  └─ telefunc-handler.ts
├─ lib/                    # Business logic (payment adapters, delivery, etc.)
├─ modules/                # Feature modules (payment notifications, orders, etc.)
├─ scripts/                # Helper scripts (seed data, validation)
├─ prisma/                 # Prisma schema and migration SQL
│  ├─ schema.prisma
│  └─ migrations/
│     ├─ 0001_init.sql
│     └─ 0002_xxx.sql
├─ vite.config.ts          # Vite plugin config
├─ wrangler.jsonc          # Cloudflare Workers config
└─ package.json            # Scripts and dependencies
```

### About `+` Files (Vike Convention)

Files prefixed with `+` in `pages/` are Vike "convention interface files" for declaring pages, config, and data loading. Files without `+` are treated as regular modules (components, styles, types).

Common `+` files:
- `+Page.vue` — page component
- `+data.ts` — page data fetching (SSR/CSR shared)
- `+Layout.vue` — layout wrapper
- `+Head.vue` — head tags
- `+config.ts` — page/global config

## Log Troubleshooting

When Telegram notification or payment callback issues occur, check Workers logs in Cloudflare Dashboard:

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com)
2. Left menu → **Workers & Pages** → click **edgekey**
3. Top tab → **Observability**
4. Filter logs by keyword, e.g.:
   - `telegram.notify_order_paid.config_failed` — Telegram config fetch failed after payment
   - `telegram.send.failed` — Telegram send failed
   - `telegram.order_paid.failed` — Telegram notification failed after successful payment
   - `payment.notify.route_exception` — payment callback routing exception
   - `payment.notify.context_missing` — payment callback missing DB context
   - `payment.notify.diagnostic` — payment callback validation exception (signature error, amount mismatch, etc.)
   - `bepusdt.verify_notify` — BEpusdt callback raw payload (info level)

## Acknowledgements

Thanks to the [Linux.do](https://linux.do/) and [NodeSeek](https://www.nodeseek.com/) communities for their support.

Thanks to the following open source projects:
- [BEpusdt](https://github.com/v03413/BEpusdt) — Cryptocurrency transaction support


## 🏝️ Get Involved
- Join our Group: https://t.me/edgeKeyChannel
- Subscribe to Channel: https://t.me/edgeKeyGroup
