#!/bin/bash

###############################################################################
# 서버 초기 설정 스크립트 (서버에서 실행)
# 사용법: chmod +x server-setup.sh && ./server-setup.sh
###############################################################################

set -e

# 색상 설정
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  서버 초기 설정 스크립트${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 1. MySQL 설정
echo -e "${YELLOW}[1/4] MySQL 데이터베이스 설정${NC}"
echo -e "${RED}MySQL root 비밀번호를 입력하세요:${NC}"
read -s MYSQL_ROOT_PASSWORD

mysql -u root -p"$MYSQL_ROOT_PASSWORD" << 'EOF'
-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS hothot CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 사용자 생성 및 권한 부여
CREATE USER IF NOT EXISTS 'wherehot_user'@'localhost' IDENTIFIED BY 'S7r!k#9vQp2&bL4xZt^6mNw';
GRANT ALL PRIVILEGES ON hothot.* TO 'wherehot_user'@'localhost';
FLUSH PRIVILEGES;

-- 확인
SELECT User, Host FROM mysql.user WHERE User = 'wherehot_user';
SHOW DATABASES LIKE 'hothot';
EOF

echo -e "${GREEN}✅ MySQL 설정 완료${NC}"
echo ""

# 2. Tomcat 환경변수 설정
echo -e "${YELLOW}[2/4] Tomcat 환경변수 설정${NC}"

sudo mkdir -p /etc/systemd/system/tomcat9.service.d

sudo tee /etc/systemd/system/tomcat9.service.d/override.conf > /dev/null << 'EOF'
[Service]
# 데이터베이스 설정
Environment="DB_URL=jdbc:mysql://localhost:3306/hothot?serverTimezone=Asia/Seoul&characterEncoding=utf8&useSSL=false&allowPublicKeyRetrieval=true&rewriteBatchedStatements=true"
Environment="DB_USERNAME=wherehot_user"
Environment="DB_PASSWORD=S7r!k#9vQp2&bL4xZt^6mNw"

# JWT 설정
Environment="JWT_SECRET=dGFlbWluc3ByaW5nSndUU2VjcmV0S2V5Rm9yV2hlcmVIb3RBcHBsaWNhdGlvbjIwMjRTdXBlclNlY3VyZUxvbmdLZXlGb3JIUzUxMkFsZ29yaXRobVdpdGhNaW5pbXVtNjRCeXRlc0ZvclNlY3VyaXR5"

# 이메일 설정
Environment="EMAIL_HOST=smtp-relay.brevo.com"
Environment="EMAIL_PORT=587"
Environment="EMAIL_USERNAME=93959a002@smtp-brevo.com"
Environment="EMAIL_PASSWORD=gyEmT1QbCR5XjwaN"

# OAuth2 설정
Environment="OAUTH2_NAVER_CLIENT_ID=Uhipu8CFRcKrmTNw5xie"
Environment="OAUTH2_NAVER_CLIENT_SECRET=32CliACoQi"

# Spring 프로파일
Environment="SPRING_PROFILES_ACTIVE=prod"

# Java 옵션
Environment="CATALINA_OPTS=-Xms512m -Xmx2048m -XX:+UseG1GC"
EOF

sudo systemctl daemon-reload

echo -e "${GREEN}✅ Tomcat 환경변수 설정 완료${NC}"
echo ""

# 3. 업로드 디렉토리 생성
echo -e "${YELLOW}[3/4] 업로드 디렉토리 생성${NC}"

sudo mkdir -p /var/lib/tomcat9/webapps/taeminspring/uploads/{hpostsave,notices,places,mdphotos,community,course}
sudo chown -R tomcat9:tomcat9 /var/lib/tomcat9/webapps/taeminspring/uploads/
sudo chmod -R 755 /var/lib/tomcat9/webapps/taeminspring/uploads/

echo -e "${GREEN}✅ 업로드 디렉토리 생성 완료${NC}"
echo ""

# 4. 방화벽 설정
echo -e "${YELLOW}[4/4] 방화벽 설정${NC}"

if command -v ufw &> /dev/null; then
    sudo ufw allow 8080/tcp
    echo -e "${GREEN}✅ 방화벽 8080 포트 오픈 완료${NC}"
else
    echo -e "${YELLOW}⚠️  UFW가 설치되지 않았습니다. 수동으로 방화벽 설정이 필요합니다.${NC}"
fi

echo ""

# 5. Tomcat 재시작
echo -e "${YELLOW}Tomcat 재시작 중...${NC}"
sudo systemctl restart tomcat9

echo -e "${GREEN}✅ Tomcat 재시작 완료${NC}"
echo ""

# 완료
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  서버 초기 설정 완료! 🎉${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}다음 단계:${NC}"
echo -e "1. 로컬에서 WAR 파일 빌드: ${YELLOW}mvn clean package${NC}"
echo -e "2. WAR 파일 전송: ${YELLOW}scp target/taeminspring.war ubuntu@SERVER_IP:/tmp/${NC}"
echo -e "3. 배포 스크립트 실행: ${YELLOW}./deploy.sh${NC}"
echo ""
echo -e "${YELLOW}또는 자동 배포 스크립트 사용:${NC}"
echo -e "${YELLOW}./deploy.sh 59.18.34.179 ubuntu${NC}"
echo ""

exit 0
