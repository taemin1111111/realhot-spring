# 🚀 배포 가이드 - 하루 1만명 처리 최적화

## 📋 배포 전 체크리스트

### 1. **보안 설정 (필수)**

#### 환경변수 설정
```bash
# JWT 보안 (256비트 이상의 랜덤 문자열)
export JWT_SECRET="your-super-secure-jwt-secret-key-256-bits-minimum"

# 데이터베이스
export DB_URL="jdbc:mysql://your-db-host:3306/wherehot?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Seoul&useSSL=true"
export DB_USERNAME="your-db-username"
export DB_PASSWORD="your-super-secure-db-password"

# Redis (세션 관리)
export REDIS_HOST="your-redis-host"
export REDIS_PORT="6379"
export REDIS_PASSWORD="your-redis-password"

# 이메일 서비스
export EMAIL_HOST="your-smtp-host"
export EMAIL_USERNAME="your-email-username"
export EMAIL_PASSWORD="your-email-password"

# OAuth2 (네이버)
export OAUTH2_NAVER_CLIENT_ID="your-naver-client-id"
export OAUTH2_NAVER_CLIENT_SECRET="your-naver-client-secret"

# CORS 설정
export CORS_ALLOWED_ORIGINS="https://yourdomain.com,https://www.yourdomain.com"
```

### 2. **서버 사양 권장사항**

#### 최소 사양 (1만명 동시 접속)
- **CPU**: 8코어 이상
- **RAM**: 16GB 이상
- **SSD**: 100GB 이상
- **네트워크**: 1Gbps 이상

#### 권장 사양
- **CPU**: 16코어 이상
- **RAM**: 32GB 이상
- **SSD**: 200GB 이상
- **네트워크**: 10Gbps

### 3. **데이터베이스 최적화**

#### MySQL 설정 (my.cnf)
```ini
[mysqld]
# 연결 최적화
max_connections = 1000
max_connect_errors = 10000
connect_timeout = 10
wait_timeout = 28800
interactive_timeout = 28800

# 버퍼 최적화
innodb_buffer_pool_size = 8G
innodb_log_file_size = 1G
innodb_log_buffer_size = 64M
innodb_flush_log_at_trx_commit = 2

# 쿼리 최적화
query_cache_size = 256M
query_cache_type = 1
tmp_table_size = 256M
max_heap_table_size = 256M

# 인덱스 최적화
key_buffer_size = 256M
sort_buffer_size = 2M
read_buffer_size = 2M
read_rnd_buffer_size = 8M
```

### 4. **Redis 설정**

#### Redis 설정 (redis.conf)
```conf
# 메모리 최적화
maxmemory 4gb
maxmemory-policy allkeys-lru

# 지속성 설정
save 900 1
save 300 10
save 60 10000

# 네트워크 최적화
tcp-keepalive 300
timeout 0
```

### 5. **로드 밸런서 설정**

#### Nginx 설정 예시
```nginx
upstream hotplace_backend {
    server 127.0.0.1:8083 weight=1 max_fails=3 fail_timeout=30s;
    # 추가 서버 인스턴스
    # server 127.0.0.1:8084 weight=1 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    
    # SSL 인증서
    ssl_certificate /path/to/your/certificate.crt;
    ssl_certificate_key /path/to/your/private.key;
    
    # SSL 보안 설정
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # 보안 헤더
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # 정적 파일 캐싱
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # API 요청
    location /hotplace/ {
        proxy_pass http://hotplace_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 타임아웃 설정
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # 버퍼 설정
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
    }
}
```

### 6. **모니터링 설정**

#### Prometheus + Grafana 설정
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'hotplace-app'
    static_configs:
      - targets: ['localhost:8083']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 5s
```

### 7. **백업 전략**

#### 데이터베이스 백업
```bash
#!/bin/bash
# daily_backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u root -p wherehot > /backup/wherehot_$DATE.sql
gzip /backup/wherehot_$DATE.sql

# 30일 이상 된 백업 삭제
find /backup -name "wherehot_*.sql.gz" -mtime +30 -delete
```

### 8. **배포 스크립트**

#### Docker 배포 예시
```dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app
COPY target/hotplace-*.jar app.jar

EXPOSE 8083

ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xms2g -Xmx4g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

### 9. **성능 테스트**

#### JMeter 테스트 시나리오
- **동시 사용자**: 1000명
- **테스트 시간**: 10분
- **시나리오**: 로그인, 게시글 조회, 투표, 댓글 작성

### 10. **장애 대응**

#### 알림 설정
- **CPU 사용률**: 80% 이상
- **메모리 사용률**: 85% 이상
- **디스크 사용률**: 90% 이상
- **응답 시간**: 5초 이상
- **에러율**: 5% 이상

## ⚠️ 주의사항

1. **절대 하지 말 것**:
   - 프로덕션 환경에 개발용 설정 사용
   - 하드코딩된 비밀번호 사용
   - SSL 없이 배포
   - 로그에 민감한 정보 출력

2. **반드시 해야 할 것**:
   - 환경변수로 모든 비밀 정보 관리
   - HTTPS 강제 사용
   - 정기적인 보안 업데이트
   - 모니터링 및 알림 설정
   - 백업 및 복구 계획 수립

## 📊 예상 비용 (월)

### AWS 기준
- **EC2 (t3.xlarge)**: $150
- **RDS (db.t3.large)**: $200
- **ElastiCache (cache.t3.medium)**: $50
- **Load Balancer**: $20
- **총 예상 비용**: $420/월

### 국내 클라우드 기준
- **네이버 클라우드**: $300-400/월
- **카카오 클라우드**: $350-450/월
