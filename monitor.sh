#!/bin/bash

# ===== 실시간 성능 모니터링 스크립트 =====

echo "📊 어디핫 성능 모니터링 시작..."
echo "종료하려면 Ctrl+C를 누르세요."
echo ""

# 모니터링 간격 (초)
INTERVAL=10

# 로그 파일
LOG_FILE="performance.log"

# 헤더 출력
printf "%-20s %-10s %-10s %-10s %-15s %-15s %-10s\n" "TIME" "CPU%" "MEM%" "DISK%" "ACTIVE_CONN" "RESPONSE_TIME" "STATUS"
printf "%-20s %-10s %-10s %-10s %-15s %-15s %-10s\n" "----" "----" "----" "----" "-----------" "-------------" "------"

while true; do
    # 현재 시간
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # CPU 사용률
    CPU_USAGE=$(docker stats hotplace-app --no-stream --format "{{.CPUPerc}}" | sed 's/%//')
    
    # 메모리 사용률  
    MEM_USAGE=$(docker stats hotplace-app --no-stream --format "{{.MemPerc}}" | sed 's/%//')
    
    # 디스크 사용률
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    # 활성 연결 수 (netstat 사용)
    ACTIVE_CONN=$(docker exec hotplace-app sh -c "netstat -an | grep :8083 | grep ESTABLISHED | wc -l" 2>/dev/null || echo "N/A")
    
    # 응답 시간 측정
    RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}" http://localhost:8083/hotplace/actuator/health 2>/dev/null || echo "N/A")
    
    # 서비스 상태
    if curl -f http://localhost:8083/hotplace/actuator/health > /dev/null 2>&1; then
        STATUS="UP"
    else
        STATUS="DOWN"
    fi
    
    # 출력
    printf "%-20s %-10s %-10s %-10s %-15s %-15s %-10s\n" \
        "$TIMESTAMP" "${CPU_USAGE}%" "${MEM_USAGE}%" "${DISK_USAGE}%" \
        "$ACTIVE_CONN" "${RESPONSE_TIME}s" "$STATUS"
    
    # 로그 파일에 기록
    echo "$TIMESTAMP,${CPU_USAGE}%,${MEM_USAGE}%,${DISK_USAGE}%,$ACTIVE_CONN,${RESPONSE_TIME}s,$STATUS" >> $LOG_FILE
    
    # 경고 조건 체크
    if [ "${CPU_USAGE%.*}" -gt 80 ] 2>/dev/null; then
        echo "⚠️  WARNING: High CPU usage detected!"
    fi
    
    if [ "${MEM_USAGE%.*}" -gt 85 ] 2>/dev/null; then
        echo "⚠️  WARNING: High memory usage detected!"
    fi
    
    if [ "$STATUS" = "DOWN" ]; then
        echo "🚨 ALERT: Service is DOWN!"
    fi
    
    sleep $INTERVAL
done
