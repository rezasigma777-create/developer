#!/bin/bash
set -e

apt-get update -qq && apt-get install -y -qq curl git unzip

curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Hapus dulu kalau sudah ada
rm -rf /app/qwen-gate

# Clone repo
git clone https://github.com/youssefvdel/qwen-gate.git /app/qwen-gate
cd /app/qwen-gate

# Install dependency
bun install

echo "===== SEBELUM PATCH ====="
grep -n "QWEN_FETCH_TIMEOUT_MS" src/services/configService.ts || true
grep -n "QWEN_FETCH_TIMEOUT_MS" config.json || true

# Patch timeout
sed -i "s/30000/600000/g" src/services/configService.ts
sed -i "s/30000/600000/g" config.json

echo "===== SESUDAH PATCH ====="
grep -n "QWEN_FETCH_TIMEOUT_MS" src/services/configService.ts || true
grep -n "QWEN_FETCH_TIMEOUT_MS" config.json || true

RAILWAY_PORT="${PORT:-8080}"

bun -e "
const fs = require('fs');
let raw = fs.readFileSync('config.json', 'utf8');
raw = raw.replace(/\/\/[^\n]*/g, '').replace(/\/\*[\s\S]*?\*\//g, '');
const cfg = JSON.parse(raw);

cfg.HOST = '0.0.0.0';
cfg.PORT = '$RAILWAY_PORT';

fs.writeFileSync('config.json', JSON.stringify(cfg, null, 2));

console.log('Patched HOST:', cfg.HOST, 'PORT:', cfg.PORT);
"

echo "===== CONFIG AKHIR ====="
grep -n "QWEN_FETCH_TIMEOUT_MS" config.json || true

bun start
