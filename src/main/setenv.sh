#!/bin/bash
# Kakao API Keys
export KAKAO_JAVASCRIPT_KEY='9c8d14f1fa7135d1f7778321b1e25fa'

# Database Configuration
export DB_URL='jdbc:mysql://localhost:3306/wherehot_db?useSSL=false&serverTimezone=Asia/Seoul&allowPublicKeyRetrieval=true'
export DB_USERNAME='wherehot_user'
export DB_PASSWORD='S7r!k#9vQp2&bL4xZt^6mNw'

# JWT Configuration
export JWT_SECRET='taeminSecureJwtSecretKey2024SuperLongSecureKeyForProductionEnvironment12345'
export JWT_EXPIRATION='86400000'

# Upload Directory
export UPLOAD_DIR='/opt/tomcat/webapps/taeminspring/uploads'

# CORS Configuration
export CORS_ALLOWED_ORIGINS='https://wherehotnow.com,https://www.wherehotnow.com,http://localhost:8083'

# OAuth2 Configuration (Naver)
export OAUTH2_NAVER_CLIENT_ID='Uhipu8CFRcKrmTNw5xie'
export OAUTH2_NAVER_CLIENT_SECRET='32CliACoQi'

