#!/bin/bash
set -e

apt-get update -qq && apt-get install -y -qq curl git unzip

curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Hapus dulu kalau sudah ada
rm -rf /app/qwen-gate

# Clone Qwen Gate
git clone https://github.com/youssefvdel/qwen-gate.git /app/qwen-gate
cd /app/qwen-gate

# Install dependencies
bun install

# Patch timeout menjadi 10 menit
sed -i "s/QWEN_FETCH_TIMEOUT_MS: '30000'/QWEN_FETCH_TIMEOUT_MS: '600000'/" src/services/configService.ts
sed -i 's/"QWEN_FETCH_TIMEOUT_MS": "30000"/"QWEN_FETCH_TIMEOUT_MS": "600000"/' config.json

echo "===== CHECK PATCH ====="
grep -n "QWEN_FETCH_TIMEOUT_MS" src/services/configService.ts || true
grep -n "QWEN_FETCH_TIMEOUT_MS" config.json || true
echo "======================="

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

bun start
