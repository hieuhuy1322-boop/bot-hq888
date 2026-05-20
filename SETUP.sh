#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  HQ88.FUN — Setup script cho Replit mới
#  Chạy: bash SETUP.sh
# ─────────────────────────────────────────────
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo ""
echo "╔══════════════════════════════════════╗"
echo "║     HQ88.FUN Admin Panel Setup       ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── 1. Kiểm tra Node.js ────────────────────
NODE_VER=$(node -v 2>/dev/null | cut -d'v' -f2 | cut -d'.' -f1)
if [ -z "$NODE_VER" ] || [ "$NODE_VER" -lt 18 ]; then
  error "Cần Node.js >= 18. Tạo Replit với template 'Node.js'"
fi
info "Node.js $(node -v)"

# ── 2. Kiểm tra pnpm ───────────────────────
if ! command -v pnpm &> /dev/null; then
  warn "Đang cài pnpm..."
  npm install -g pnpm
fi
info "pnpm $(pnpm -v)"

# ── 3. Kiểm tra biến môi trường ────────────
echo ""
echo "── Kiểm tra biến môi trường ───────────"
MISSING=0

if [ -z "$DATABASE_URL" ]; then
  warn "DATABASE_URL chưa được set"
  warn "  → Vào tab 'Secrets' của Replit, thêm:"
  warn "     Key: DATABASE_URL"
  warn "     Value: (lấy từ tab PostgreSQL trong Replit)"
  MISSING=1
else
  info "DATABASE_URL ✓"
fi

if [ -z "$SESSION_SECRET" ]; then
  warn "SESSION_SECRET chưa được set"
  warn "  → Thêm secret: SESSION_SECRET = (chuỗi bất kỳ dài 32+ ký tự)"
  MISSING=1
else
  info "SESSION_SECRET ✓"
fi

if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
  warn "TELEGRAM_BOT_TOKEN chưa được set"
  warn "  → Thêm secret: TELEGRAM_BOT_TOKEN = (token từ @BotFather)"
  MISSING=1
else
  info "TELEGRAM_BOT_TOKEN ✓"
fi

if [ "$MISSING" -eq 1 ]; then
  echo ""
  echo "⚠️  Hãy set đủ 3 secrets ở trên rồi chạy lại script này."
  echo ""
  exit 1
fi

# ── 4. Cài dependencies ────────────────────
echo ""
echo "── Cài đặt dependencies ───────────────"
pnpm install --frozen-lockfile 2>&1 | tail -5
info "Dependencies đã cài xong"

# ── 5. Push DB schema (admin_users) ────────
echo ""
echo "── Khởi tạo database admin ────────────"
pnpm --filter @workspace/db run push 2>&1 | tail -5
info "Database schema đã push xong"

# ── 6. Tạo thư mục data cho SQLite bot ─────
echo ""
echo "── Tạo thư mục cho bot database ───────"
mkdir -p artifacts/api-server/data
info "Thư mục artifacts/api-server/data đã tạo"

# ── 7. Build API server ─────────────────────
echo ""
echo "── Build API server ───────────────────"
pnpm --filter @workspace/api-server run build 2>&1 | tail -5
info "Build xong"

# ── 8. Hoàn tất ─────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║                 SETUP HOÀN TẤT ✅                    ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Các bước tiếp theo trong Replit:                    ║"
echo "║                                                      ║"
echo "║  1. Vào tab Workflows, tạo 2 workflow:               ║"
echo "║                                                      ║"
echo "║  Workflow 1 — API Server:                            ║"
echo "║    pnpm --filter @workspace/api-server run dev       ║"
echo "║                                                      ║"
echo "║  Workflow 2 — Admin Web:                             ║"
echo "║    pnpm --filter @workspace/admin run dev            ║"
echo "║                                                      ║"
echo "║  2. Mở preview → đăng nhập:                         ║"
echo "║     Username: admin                                  ║"
echo "║     Password: admin123                               ║"
echo "║                                                      ║"
echo "║  3. Đổi mật khẩu ngay sau khi đăng nhập!            ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
