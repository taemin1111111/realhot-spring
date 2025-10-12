#!/bin/bash

###############################################################################
# WAR 배포 자동화 스크립트
# 사용법: ./deploy.sh [SERVER_IP] [SERVER_USER]
# 예시: ./deploy.sh 59.18.34.179 ubuntu
###############################################################################

set -e  # 에러 발생시 중단

# 색상 설정
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 서버 정보
SERVER_IP=${1:-59.18.34.179}
SERVER_USER=${2:-ubuntu}
WAR_FILE="target/taeminspring.war"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  WAR 배포 자동화 스크립트${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "서버 IP: ${YELLOW}$SERVER_IP${NC}"
echo -e "사용자: ${YELLOW}$SERVER_USER${NC}"
echo ""

# 1. WAR 파일 빌드
echo -e "${YELLOW}[1/6] WAR 파일 빌드 중...${NC}"
mvn clean package -DskipTests

if [ ! -f "$WAR_FILE" ]; then
    echo -e "${RED}❌ WAR 파일 빌드 실패!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ WAR 파일 빌드 완료: $WAR_FILE${NC}"
echo ""

# 2. WAR 파일 크기 확인
WAR_SIZE=$(du -h "$WAR_FILE" | cut -f1)
echo -e "WAR 파일 크기: ${YELLOW}$WAR_SIZE${NC}"
echo ""

# 3. 서버로 WAR 파일 전송
echo -e "${YELLOW}[2/6] 서버로 WAR 파일 전송 중...${NC}"
scp "$WAR_FILE" "$SERVER_USER@$SERVER_IP:/tmp/"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ WAR 파일 전송 실패!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ WAR 파일 전송 완료${NC}"
echo ""

# 4. 서버에서 배포 스크립트 실행
echo -e "${YELLOW}[3/6] 서버에서 배포 시작...${NC}"

ssh "$SERVER_USER@$SERVER_IP" << 'ENDSSH'
    set -e
    
    echo "📦 WAR 파일 배포 중..."
    
    # 기존 WAR 파일 백업
    if [ -f /var/lib/tomcat9/webapps/taeminspring.war ]; then
        echo "이전 WAR 파일 백업 중..."
        sudo mv /var/lib/tomcat9/webapps/taeminspring.war \
             /var/lib/tomcat9/webapps/taeminspring.war.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    # 기존 압축 해제된 디렉토리 삭제
    if [ -d /var/lib/tomcat9/webapps/taeminspring ]; then
        echo "이전 배포 파일 삭제 중..."
        sudo rm -rf /var/lib/tomcat9/webapps/taeminspring
    fi
    
    # 새 WAR 파일 복사
    echo "새 WAR 파일 복사 중..."
    sudo cp /tmp/taeminspring.war /var/lib/tomcat9/webapps/
    sudo chown tomcat9:tomcat9 /var/lib/tomcat9/webapps/taeminspring.war
    
    # 업로드 디렉토리 생성 (없는 경우)
    echo "업로드 디렉토리 확인 중..."
    sudo mkdir -p /var/lib/tomcat9/webapps/taeminspring/uploads/{hpostsave,notices,places,mdphotos,community,course}
    sudo chown -R tomcat9:tomcat9 /var/lib/tomcat9/webapps/taeminspring/uploads/
    sudo chmod -R 755 /var/lib/tomcat9/webapps/taeminspring/uploads/
    
    echo "✅ WAR 파일 배포 완료"
ENDSSH

echo -e "${GREEN}✅ 서버 배포 완료${NC}"
echo ""

# 5. Tomcat 재시작
echo -e "${YELLOW}[4/6] Tomcat 재시작 중...${NC}"

ssh "$SERVER_USER@$SERVER_IP" << 'ENDSSH'
    echo "Tomcat 재시작 중..."
    sudo systemctl restart tomcat9
    
    # Tomcat이 완전히 시작될 때까지 대기
    echo "Tomcat 시작 대기 중..."
    sleep 10
    
    # Tomcat 상태 확인
    if sudo systemctl is-active --quiet tomcat9; then
        echo "✅ Tomcat 정상 실행 중"
    else
        echo "❌ Tomcat 시작 실패!"
        sudo systemctl status tomcat9
        exit 1
    fi
ENDSSH

echo -e "${GREEN}✅ Tomcat 재시작 완료${NC}"
echo ""

# 6. 배포 확인
echo -e "${YELLOW}[5/6] 배포 확인 중...${NC}"

ssh "$SERVER_USER@$SERVER_IP" << 'ENDSSH'
    # WAR 파일 압축 해제 확인 (최대 30초 대기)
    echo "WAR 압축 해제 확인 중..."
    for i in {1..30}; do
        if [ -d /var/lib/tomcat9/webapps/taeminspring/WEB-INF ]; then
            echo "✅ WAR 압축 해제 완료"
            break
        fi
        echo "대기 중... ($i/30)"
        sleep 1
    done
    
    if [ ! -d /var/lib/tomcat9/webapps/taeminspring/WEB-INF ]; then
        echo "❌ WAR 압축 해제 실패!"
        exit 1
    fi
    
    # Spring Boot 시작 확인
    echo "Spring Boot 시작 확인 중..."
    for i in {1..60}; do
        if sudo grep -q "Started TaeminspringApplication" /var/log/tomcat9/catalina.out; then
            echo "✅ Spring Boot 정상 시작"
            break
        fi
        echo "Spring Boot 시작 대기 중... ($i/60)"
        sleep 1
    done
    
    # 최근 로그 출력
    echo ""
    echo "========== 최근 Tomcat 로그 =========="
    sudo tail -n 30 /var/log/tomcat9/catalina.out
ENDSSH

echo -e "${GREEN}✅ 배포 확인 완료${NC}"
echo ""

# 7. 최종 결과
echo -e "${YELLOW}[6/6] 배포 완료!${NC}"
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  배포 성공! 🎉${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "접속 URL: ${YELLOW}http://$SERVER_IP:8080/taeminspring/${NC}"
echo ""
echo -e "${YELLOW}다음 명령으로 로그를 확인하세요:${NC}"
echo -e "ssh $SERVER_USER@$SERVER_IP 'sudo tail -f /var/log/tomcat9/catalina.out'"
echo ""

# 브라우저에서 열기 (Windows)
if command -v cmd.exe &> /dev/null; then
    echo -e "${YELLOW}브라우저에서 열기...${NC}"
    cmd.exe /c start "http://$SERVER_IP:8080/taeminspring/"
fi

exit 0