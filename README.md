 어디핫? (WhereHot) - Spring Boot 프로젝트

> 핫플레이스 정보 공유 플랫폼

 프로젝트 정보

- **프레임워크**: Spring Boot 3.5.4
- **자바 버전**: Java 17
- **빌드 도구**: Maven
- **패키징**: WAR
- **뷰 템플릿**: JSP + JSTL
- **데이터베이스**: MySQL 8.0+
- **ORM**: MyBatis
- **인증**: JWT + OAuth2 (네이버)
- **보안**: Spring Security

---

 빠른 시작

### 1. 자동 배포 (추천)

```bash
# 1. 서버 초기 설정 
ssh ubuntu@59.18.34.179
chmod +x server-setup.sh
./server-setup.sh

# 2. 로컬에서 자동 배포
./deploy.sh 59.18.34.179 ubuntu
```

### 2. 수동 배포

```bash
# 1. WAR 빌드
mvn clean package -DskipTests

# 2. 서버로 전송
scp target/taeminspring.war ubuntu@59.18.34.179:/tmp/

# 3. 서버에서 배포
ssh ubuntu@59.18.34.179
sudo cp /tmp/taeminspring.war /var/lib/tomcat9/webapps/
sudo systemctl restart tomcat9
```

### 3. 접속 확인

```
http://59.18.34.179:8080/taeminspring/
```

---

주요 문서

- **[배포방법_최종정리.md](배포방법_최종정리.md)** - 한글 배포 가이드 
- **[FINAL_DEPLOYMENT_GUIDE.md](FINAL_DEPLOYMENT_GUIDE.md)** - 상세 배포 가이드
- **[COMPLETE_WAR_DEPLOYMENT_FIX.md](COMPLETE_WAR_DEPLOYMENT_FIX.md)** - 문제 원인 및 해결 방안
- **[WAR_DEPLOYMENT_GUIDE.md](WAR_DEPLOYMENT_GUIDE.md)** - WAR 배포 가이드
- **[LEVEL_SYSTEM_README.md](LEVEL_SYSTEM_README.md)** - 레벨 시스템 설명

---

## 개발 환경 설정

### 필수 요구사항

- **Java 17+**
- **Maven 3.6+**
- **MySQL 8.0+**
- **Tomcat 9.0+** (WAR 배포시)

### 로컬 개발 환경

```bash
# 1. MySQL 데이터베이스 생성
mysql -u root -p
CREATE DATABASE hothot CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 2. application-dev.properties 설정 확인
# src/main/resources/application-dev.properties

# 3. 스프링 부트 실행
mvn spring-boot:run
```

**로컬 접속:** `http://localhost:8083/`

---

## 프로젝트 구조

```
realhot-spring/
├── src/
│   ├── main/
│   │   ├── java/com/wherehot/spring/
│   │   │   ├── config/          # 설정 클래스
│   │   │   ├── controller/      # 컨트롤러
│   │   │   ├── entity/          # 엔티티
│   │   │   ├── mapper/          # MyBatis 매퍼
│   │   │   ├── security/        # 보안 설정
│   │   │   └── service/         # 서비스
│   │   ├── resources/
│   │   │   ├── mapper/          # MyBatis XML
│   │   │   ├── application.properties
│   │   │   ├── application-dev.properties
│   │   │   └── application-prod.properties
│   │   └── webapp/
│   │       ├── WEB-INF/views/   # JSP 파일
│   │       ├── css/             # CSS 파일
│   │       ├── js/              # JavaScript
│   │       └── logo/            # 이미지
│   └── test/                    # 테스트
├── pom.xml
├── deploy.sh                    # 자동 배포 스크립트
├── server-setup.sh              # 서버 초기 설정
└── README.md
```

---

## 주요 설정

### 데이터베이스 설정

```properties
# application-prod.properties
spring.datasource.url=jdbc:mysql://localhost:3306/hothot?serverTimezone=Asia/Seoul
spring.datasource.username=wherehot_user
spring.datasource.password=S7r!k#9vQp2&bL4xZt^6mNw
```

### JWT 설정

```properties
app.jwt.secret=${JWT_SECRET:...}
app.jwt.expiration=86400
app.jwt.refresh-expiration=2592000
```

### Redis 설정 (현재 비활성화)

```properties
# Redis 사용 안함
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration
```

---

주요 기능 설명입니다

### 1. 사용자 관리
- 회원가입 / 로그인
- 네이버 OAuth2 로그인
- JWT 기반 인증
- 레벨 시스템

### 2. 핫플레이스
- 핫플레이스 정보 조회
- 지역별 / 카테고리별 검색
- 실시간 투표
- 찜하기 기능

### 3. 커뮤니티
- 핫플썰 게시판
- 댓글 및 대댓글
- 좋아요 / 싫어요
- 신고 기능

### 4. 코스 추천
- 데이트 코스 추천
- 코스별 상세 정보
- 코스 평가 및 댓글

### 5. 관리자
- 회원 관리
- 게시글 관리
- 신고 처리
- 광고 배너 관리

---

 문제 해결 방법입니다.

배포 실패시

1. Tomcat 로그 확인
   ```bash
   sudo tail -f /var/log/tomcat9/catalina.out
   ```

2. 데이터베이스 연결 확인
   ```bash
   mysql -u wherehot_user -p'S7r!k#9vQp2&bL4xZt^6mNw' hothot
   ```

3. **환경변수 확인**
   ```bash
   sudo systemctl show tomcat9 | grep Environment
   ```

4. **포트 확인**
   ```bash
   sudo netstat -tlnp | grep :8080
   ```

### 자주 발생하는 오류

- **JSP 404 에러**: WebConfig 리소스 경로 확인
- **Redis 연결 실패**: `spring.autoconfigure.exclude` 설정 확인
- **DB 연결 실패**: MySQL 사용자 권한 확인
- **CSS 404 에러**: webapp/css/ 디렉토리 확인

자세한 내용은 **[배포방법_최종정리.md](배포방법_최종정리.md)** 참고

---

## 성능 최적화

### HikariCP 설정
- Maximum Pool Size: 200
- Minimum Idle: 50
- Connection Timeout: 30초

### Tomcat 설정
- Max Threads: 2000
- Max Connections: 50000
- Accept Count: 5000

### 캐시 설정
- 메모리 기반 캐시 (ConcurrentHashMap)
- Redis 캐시 (선택사항)

---

## 보안 설정

### Spring Security
- JWT 기반 무상태 인증
- OAuth2 (네이버 로그인)
- BCrypt 비밀번호 암호화
- CSRF 비활성화 (JWT 사용)

### 보안 헤더
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- X-XSS-Protection: 1; mode=block
- Content-Security-Policy

---

## 개발자 가이드

### 새 기능 추가

1. **Entity 생성**: `entity/` 패키지
2. **Mapper 작성**: `mapper/` 인터페이스 + XML
3. **Service 작성**: `service/` 인터페이스 + Impl
4. **Controller 작성**: `controller/` 패키지
5. **JSP 작성**: `webapp/WEB-INF/views/`

### 빌드 및 테스트

```bash
# 빌드
mvn clean package

# 테스트
mvn test

# 스프링 부트 실행
mvn spring-boot:run
```

---

## 라이선스

이 프로젝트는 개인 프로젝트이며, 상업적 사용 금지입니다.

---

## 개발팀

- **개발자**: WhereHot Team
- **배포일**: 2025

---

## 배포 체크리스트

### 서버 준비
- [ ] MySQL 설치 및 데이터베이스 생성
- [ ] Tomcat 설치 및 환경변수 설정
- [ ] 업로드 디렉토리 생성
- [ ] 방화벽 8080 포트 오픈

### WAR 배포
- [ ] WAR 파일 빌드 (`mvn clean package`)
- [ ] WAR 파일 서버로 전송
- [ ] Tomcat webapps에 배포
- [ ] Tomcat 재시작

### 배포 확인
- [ ] 메인 페이지 접속
- [ ] 정적 리소스 로딩 확인
- [ ] 데이터베이스 연결 확인
- [ ] 로그인 기능 테스트
- [ ] 게시글 작성 테스트

---

**배포 성공을 기원합니다!** 🎉

문제가 발생하면 [배포방법_최종정리.md](배포방법_최종정리.md)를 참고하세요.
