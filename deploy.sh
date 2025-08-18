#!/bin/bash

# ===== 운영 배포 스크립트 (하루 1만명+ 처리) =====

set -e

echo "🚀 어디핫 프로덕션 배포 시작..."

# 환경 변수 설정
export SPRING_PROFILES_ACTIVE=prod
export JAVA_OPTS="-Xms2g -Xmx8g -XX:+UseG1GC -XX:G1HeapRegionSize=16m -XX:+UseStringDeduplication"

# 1. 기존 컨테이너 정리
echo "📦 기존 컨테이너 정리 중..."
docker-compose down --remove-orphans

# 2. 이미지 빌드
echo "🔨 Docker 이미지 빌드 중..."
docker-compose build --no-cache

# 3. 데이터베이스 백업 (기존 DB가 있는 경우)
if docker volume ls | grep -q mysql_data; then
    echo "💾 데이터베이스 백업 중..."
    docker run --rm -v mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /data .
fi

# 4. 서비스 시작
echo "🎯 서비스 시작 중..."
docker-compose up -d

# 5. 헬스 체크
echo "🔍 헬스 체크 중..."
sleep 30

for i in {1..12}; do
    if curl -f http://localhost:8083/hotplace/actuator/health > /dev/null 2>&1; then
        echo "✅ 애플리케이션이 정상적으로 시작되었습니다!"
        break
    else
        echo "⏳ 애플리케이션 시작 대기 중... ($i/12)"
        sleep 10
    fi
    
    if [ $i -eq 12 ]; then
        echo "❌ 애플리케이션 시작 실패!"
        docker-compose logs app
        exit 1
    fi
done

# 6. 로그 확인
echo "📋 최신 로그 확인:"
docker-compose logs --tail=20 app

# 7. 서비스 상태 확인
echo "📊 서비스 상태:"
docker-compose ps

echo ""
echo "🎉 배포 완료!"
echo "🌐 서비스 URL: http://localhost:8083/hotplace"
echo "📊 모니터링: http://localhost:8083/hotplace/actuator"
echo ""
echo "📝 유용한 명령어:"
echo "  로그 실시간 확인: docker-compose logs -f app"
echo "  서비스 재시작: docker-compose restart app"
echo "  DB 접속: docker-compose exec mysql mysql -u root -p wherehot"
echo "  Redis 접속: docker-compose exec redis redis-cli"
echo ""

# 8. 성능 모니터링 스크립트 실행
if [ -f "monitor.sh" ]; then
    echo "📈 성능 모니터링 시작..."
    nohup ./monitor.sh > monitor.log 2>&1 &
fi

echo "✨ 하루 1만명+ 처리 준비 완료!"
