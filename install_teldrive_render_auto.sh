#!/bin/bash

echo "🚀 Iniciando configuración automática de Teldrive en Render..."

# Generar valores automáticamente
POSTGRES_USER="teldrive"
POSTGRES_PASSWORD="secret"
POSTGRES_DB="teldrive"
TELDRIVE_SECRET=$(openssl rand -hex 32)
ENCRYPTION_KEY=$(openssl rand -hex 32)

# Pedir datos al usuario
echo "📌 Creando un bot en Telegram..."
echo "⚠️ ATENCIÓN: Ve a Telegram y abre @BotFather"
echo "Escribe: /newbot y sigue las instrucciones."
echo "Cuando termine, BotFather te dará un TOKEN. Pégalo aquí: "
read TELEGRAM_BOT_TOKEN

echo "📌 Ahora, crea un canal privado en Telegram."
echo "Agrega el bot como ADMINISTRADOR del canal."
echo "Escribe @userinfobot en Telegram y reenvía un mensaje desde tu canal."
echo "Te dará un ID en este formato: -1001234567890"
echo "Pega aquí el ID del canal: "
read TELEGRAM_CHANNEL_ID

# Configurar PostgreSQL en Render
echo "📌 Configurando PostgreSQL en Render..."
DATABASE_URL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@db.render.com:5432/$POSTGRES_DB"

# Descargar e instalar Teldrive
echo "📌 Descargando Teldrive..."
mkdir -p ~/teldrive
cd ~/teldrive
curl -sSL instl.vercel.app/tgdrive/teldrive | bash

# Crear archivo de configuración con los valores generados
echo "📌 Creando archivo de configuración..."
cat <<EOT > config.toml
[db]
data-source = "$DATABASE_URL"
prepare-stmt = false

[jwt]
allowed-users = ["$TELEGRAM_BOT_TOKEN"]
secret = "$TELDRIVE_SECRET"

[tg.uploads]
encryption-key = "$ENCRYPTION_KEY"
EOT

# Crear y configurar Docker Compose
echo "📌 Configurando Docker..."
cat <<EOT > docker-compose.yml
version: '3'
services:
  teldrive:
    image: ghcr.io/tgdrive/teldrive
    container_name: teldrive
    restart: always
    volumes:
      - ./config.toml:/config.toml
    ports:
      - "8080:8080"
EOT

# Ejecutar Teldrive
echo "📌 Iniciando Teldrive con Docker..."
sudo docker compose up -d

echo "✅ Instalación completa. Accede a Teldrive en: https://tu-app.onrender.com"
echo "⚠️ Guarda estos valores en un lugar seguro:"
echo "🔹 TELEGRAM_BOT_TOKEN: $TELEGRAM_BOT_TOKEN"
echo "🔹 TELEGRAM_CHANNEL_ID: $TELEGRAM_CHANNEL_ID"
echo "🔹 TELDRIVE_SECRET: $TELDRIVE_SECRET"
echo "🔹 ENCRYPTION_KEY: $ENCRYPTION_KEY"
