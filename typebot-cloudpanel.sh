#!/bin/bash

# Coleta informações do usuário
read -p "Digite o domínio para o Typebot (ex: typebot.exemplo.com): " TYPEBOT_DOMAIN
read -p "Digite a porta para o Typebot (ex: 3001): " TYPEBOT_PORT
read -p "Digite o domínio para o Chat (ex: chat.exemplo.com): " CHAT_DOMAIN
read -p "Digite a porta para o Chat (ex: 3002): " CHAT_PORT
read -p "Digite o domínio para o S3 (ex: s3.exemplo.com): " S3_DOMAIN
read -p "Digite a porta para o s3 (ex: 9000): " S3_PORT
read -p "Digite o domínio para o Minio (ex: storage.exemplo.com): " STORAGE_DOMAIN
read -p "Digite a porta para o Minio (ex: 9001): " MINIO_PORT
read -p "Digite o email do administrador: " ADMIN_EMAIL
read -p "Digite a senha do banco de dados PostgreSQL para o Typebot: " POSTGRES_PASSWORD
read -p "Digite o host do servidor SMTP (ex: smtp.zoho.com): " SMTP_HOST
read -p "Digite a porta do servidor SMTP (ex: 465 ou 587): " SMTP_PORT
read -p "Digite o nome de usuário do SMTP: " SMTP_USERNAME
read -p "Digite a senha do SMTP: " SMTP_PASSWORD

# Define SMTP_SECURE baseado na porta
if [[ "$SMTP_PORT" == "465" ]]; then
  SMTP_SECURE="true"
  SMTP_AUTH_DISABLED="false"
elif [[ "$SMTP_PORT" == "587" ]]; then
  SMTP_SECURE="false"
  SMTP_AUTH_DISABLED="false"
else
  echo "Porta SMTP inválida. Use 465 ou 587."
  exit 1
fi

# Gera a chave secreta de criptografia
ENCRYPTION_SECRET=$(openssl rand -base64 24)

# Salva a chave em um arquivo
echo "$ENCRYPTION_SECRET" > encryption_secret.txt

# Exibe a mensagem para o usuário
echo "A chave secreta de criptografia foi salva no arquivo encryption_secret.txt"

# Atualiza o docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3.3'
services:
  typebot-db:
    image: postgres:14
    restart: always
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=typebot
      - POSTGRES_PASSWORD=$POSTGRES_PASSWORD
  typebot-builder:
    ports:
      - $TYPEBOT_PORT:3000
    image: baptistearno/typebot-builder:latest
    restart: always
    depends_on:
      - typebot-db
    environment:
      - DATABASE_URL=postgresql://postgres:$POSTGRES_PASSWORD@typebot-db:5432/typebot
      - NEXTAUTH_URL=https://$TYPEBOT_DOMAIN
      - NEXT_PUBLIC_VIEWER_URL=https://$CHAT_DOMAIN
      - NEXTAUTH_URL_INTERNAL=http://localhost:$TYPEBOT_PORT
      - ENCRYPTION_SECRET=$ENCRYPTION_SECRET
      - ADMIN_EMAIL=$ADMIN_EMAIL
      - DISABLE_SIGNUP=false
      - SMTP_HOST=$SMTP_HOST
      - SMTP_PORT=$SMTP_PORT
      - SMTP_SECURE=$SMTP_SECURE
      - SMTP_USERNAME=$SMTP_USERNAME
      - SMTP_PASSWORD=$SMTP_PASSWORD
      - SMTP_AUTH_DISABLED=$SMTP_AUTH_DISABLED
      - NEXT_PUBLIC_SMTP_FROM='Suporte Typebot' <$ADMIN_EMAIL>
      - S3_ACCESS_KEY=minio
      - S3_SECRET_KEY=minio123
      - S3_BUCKET=typebot
      - S3_ENDPOINT=$STORAGE_DOMAIN
  typebot-viewer:
    ports:
      - $CHAT_PORT:3000
    image: baptistearno/typebot-viewer:latest
    restart: always
    environment:
      - DATABASE_URL=postgresql://postgres:$POSTGRES_PASSWORD@typebot-db:5432/typebot
      - NEXTAUTH_URL=https://$TYPEBOT_DOMAIN
      - NEXT_PUBLIC_VIEWER_URL=https://$CHAT_DOMAIN
      - NEXTAUTH_URL_INTERNAL=http://localhost:$TYPEBOT_PORT
      - ENCRYPTION_SECRET=$ENCRYPTION_SECRET
      - S3_ACCESS_KEY=minio
      - S3_SECRET_KEY=minio123
      - S3_BUCKET=typebot
      - S3_ENDPOINT=$S3_DOMAIN
  mail:
    image: bytemark/smtp
    restart: always
  minio:
    container_name: minio
    image: minio/minio
    restart: always
    ports:
      - '$S3_PORT:9000'
      - '$MINIO_PORT:9001'
    
    environment:
      MINIO_ROOT_USER: minio
      MINIO_ROOT_PASSWORD: minio123
      MINIO_BROWSER_REDIRECT_URL: https://$STORAGE_DOMAIN
      MINIO_SERVER_URL: https://$S3_DOMAIN
    volumes:
      - ./minio/data:/data
    command: server /data --console-address ":$MINIO_PORT"

  createbuckets:
    container_name: createbuckets
    image: minio/mc
    depends_on:
      - minio
    entrypoint: >
      /bin/sh -c "
      sleep 15;
      /usr/bin/mc config host add minio http://minio:$MINIO_PORT minio minio123;
      /usr/bin/mc mb minio/typebot;
      /usr/bin/mc anonymous set public minio/typebot/public;
      exit 0;
      "
volumes:
  db_data:
  s3_data:
EOF

# Instala as dependências e inicia os containers
apt-get install docker-compose -y
docker-compose up -d

# Configuração Nginx para Typebot

echo "Instalação concluída!"
