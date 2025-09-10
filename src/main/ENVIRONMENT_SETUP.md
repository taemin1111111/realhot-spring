# 🔒 환경변수 설정 가이드

## 📋 개요
이 문서는 운영환경에서 보안 정보를 환경변수로 관리하는 방법을 설명합니다.

## 🚀 개발환경 설정

### 1. 개발환경 실행
```bash
# 개발환경에서는 기본값 사용 (application-dev.properties)
java -jar -Dspring.profiles.active=dev your-app.jar
```

## 🏭 운영환경 설정

### 1. 환경변수 설정
운영환경에서는 다음 환경변수들을 반드시 설정해야 합니다:

```bash
# JWT 설정
export JWT_SECRET="새로운_강력한_JWT_시크릿_키_최소_64바이트"
export JWT_EXPIRATION="86400"
export JWT_REFRESH_EXPIRATION="2592000"

# 데이터베이스 설정
export DB_URL="jdbc:mysql://your-db-host:3306/your-db-name?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Seoul&useSSL=true"
export DB_USERNAME="your-db-username"
export DB_PASSWORD="your-secure-db-password"

# 이메일 설정
export EMAIL_HOST="smtp-relay.brevo.com"
export EMAIL_PORT="587"
export EMAIL_USERNAME="your-email-username"
export EMAIL_PASSWORD="your-email-password"

# OAuth2 설정
export OAUTH2_NAVER_CLIENT_ID="your-naver-client-id"
export OAUTH2_NAVER_CLIENT_SECRET="your-naver-client-secret"

# CORS 설정
export CORS_ALLOWED_ORIGINS="https://yourdomain.com,https://www.yourdomain.com"
```

### 2. 운영환경 실행
```bash
# 운영환경 실행
java -jar -Dspring.profiles.active=prod your-app.jar
```

## 🔐 보안 강화 설정

### 1. JWT 시크릿 키 생성
```bash
# 강력한 JWT 시크릿 키 생성 (64바이트 이상)
openssl rand -base64 64
```

### 2. 데이터베이스 비밀번호 생성
```bash
# 강력한 데이터베이스 비밀번호 생성
openssl rand -base64 32
```

### 3. HTTPS 설정
운영환경에서는 반드시 HTTPS를 사용해야 합니다:
- SSL 인증서 설정
- 리버스 프록시 (Nginx, Apache) 설정
- HTTP to HTTPS 리다이렉션

## 📁 파일 구조
```
src/main/resources/
├── application.properties          # 기본 설정 (환경변수 사용)
├── application-dev.properties      # 개발환경 설정
├── application-prod.properties     # 운영환경 설정
└── application-secure.properties   # 보안 설정 템플릿
```

## ⚠️ 주의사항

1. **절대 소스코드에 실제 비밀번호를 하드코딩하지 마세요**
2. **운영환경에서는 반드시 환경변수를 설정하세요**
3. **JWT 시크릿 키는 최소 64바이트 이상이어야 합니다**
4. **데이터베이스 연결은 SSL을 사용하세요**
5. **HTTPS를 사용하여 데이터 전송을 암호화하세요**

## 🚨 보안 체크리스트

- [ ] JWT 시크릿 키가 환경변수로 설정됨
- [ ] 데이터베이스 비밀번호가 환경변수로 설정됨
- [ ] 이메일 서비스 인증정보가 환경변수로 설정됨
- [ ] OAuth2 클라이언트 시크릿이 환경변수로 설정됨
- [ ] HTTPS가 활성화됨
- [ ] CORS가 적절히 제한됨
- [ ] 운영환경에서 디버그 로그가 비활성화됨
