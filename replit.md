# HQ88.FUN Admin Panel

Web admin panel để quản lý bot Telegram HQ88.FUN — bật/tắt bot, quản lý người chơi, phiên chơi, tài chính, và điều chỉnh kết quả game.

## Run & Operate

- `pnpm --filter @workspace/api-server run dev` — run the API server
- `pnpm --filter @workspace/db run push` — push DB schema changes (dev only)
- Required env: `DATABASE_URL`, `SESSION_SECRET`

## Stack

- pnpm workspaces, Node.js 24, TypeScript 5.9
- Frontend: Vite (pure HTML/JS, no React framework)
- API: Express 5 + `/api/admin/*` routes
- DB: PostgreSQL + Drizzle ORM
- Auth: HMAC-signed token (no JWT library needed)
- Build: esbuild (CJS bundle)

## Where things live

- `artifacts/admin/index.html` — toàn bộ admin frontend (standalone HTML/JS/CSS)
- `artifacts/api-server/src/routes/admin.ts` — tất cả admin API endpoints
- `lib/db/src/schema/admin.ts` — DB schema (tg_users, bets, sessions, deposits, withdrawals, giftcodes, fake_bots, game_settings)

## Architecture decisions

- Admin frontend là pure HTML/JS SPA, không cần React build step — nhanh và đơn giản hơn
- Auth dùng HMAC-signed base64 token tự triển khai, không cần jwt library
- Mật khẩu hash bằng SHA-256 + salt
- Bot on/off state lưu trong `game_settings` table với key `bot_enabled`
- Public endpoint `/api/admin/bot-status/public` không cần auth để bot Telegram có thể kiểm tra

## Product

- **Login** với username/password, lưu token 1 giờ
- **Dashboard** — thống kê tổng quan, rút tiền chờ duyệt
- **LIVE** — xem phiên đang diễn ra realtime (refresh 3s)
- **Người chơi** — tìm kiếm, xem chi tiết, khóa/mở, điều chỉnh số dư
- **Phiên chơi & cược** — lịch sử đầy đủ
- **Nạp/Rút tiền** — duyệt hoặc từ chối
- **Giftcode** — tạo và quản lý
- **Broadcast** — gửi thông báo tới tất cả user
- **Bot ảo** — tạo và bật/tắt bot ảo
- **Điều chỉnh kết quả** — can thiệp kết quả game
- **Quản lý Bot** — bật/tắt toàn bộ bot Telegram
- **Thông tin admin** — đổi username/password

## User preferences

- Giao diện tiếng Việt, dark theme (GitHub dark style)
- Mobile-first với drawer navigation

## Gotchas

- Tài khoản admin mặc định: `admin` / `admin123` — **đổi ngay sau khi đăng nhập lần đầu**
- Bot toggle ở topbar (nút "🤖 Bot: BẬT/TẮT") hoặc trang "Quản lý Bot"
- Để bot Telegram check trạng thái: `GET /api/admin/bot-status/public` (không cần auth)
- Sau khi sửa schema DB: `pnpm --filter @workspace/db run push`

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
