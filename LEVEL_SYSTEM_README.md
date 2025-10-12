# 어디핫 레벨 시스템

## 개요
어디핫 플랫폼에 사용자 레벨 시스템을 추가했습니다. 사용자들이 다양한 활동을 통해 경험치를 획득하고 레벨을 올릴 수 있습니다.

## 주요 기능

### 1. 레벨 시스템
- **6단계 레벨**: 손님(1) → 단골(2) → 핫플러(3) → 핫플 마스터(4) → VIP(5) → 핫플스타(6)
- **경험치 기반 레벨업**: 누적 경험치에 따라 자동 레벨업
- **레벨 배지**: 사용자 닉네임 앞에 레벨 표시

### 2. 경험치 획득 방법
| 활동 | 경험치 | 하루 한도 | 비고 |
|------|--------|-----------|------|
| 🗳️ 투표 | 1 EXP | 4 EXP | 투표 1회당 1 EXP |
| 📍 코스 작성 | 25 EXP | 25 EXP | 하루 1개까지만 |
| 🔥 핫플썰 | 5 EXP | 20 EXP | 하루 4개까지 |
| 💬 댓글 | 3 EXP | 9 EXP | 하루 3개까지 |
| 👍 추천받음 | - | 10 EXP | 하루 최대 10 EXP |
| ❤️ 찜하기 | 1 EXP | 3 EXP | 하루 3개까지 |

**총 하루 한도: 50 EXP**

### 3. 레벨별 요구 경험치
- **손님 (Lv.1)**: 0 EXP
- **단골 (Lv.2)**: 200 EXP
- **핫플러 (Lv.3)**: 800 EXP
- **핫플 마스터 (Lv.4)**: 2,000 EXP
- **VIP (Lv.5)**: 5,000 EXP
- **핫플스타 (Lv.6)**: 12,000 EXP

## 설치 및 설정

### 1. 데이터베이스 초기화
```sql
-- level_system_init.sql 파일을 실행하여 데이터베이스 초기화
source src/main/resources/level_system_init.sql;
```

### 2. 파일 구조
```
src/main/java/com/wherehot/spring/
├── entity/
│   ├── Level.java              # 레벨 엔티티
│   ├── DailyExpLog.java        # 일일 경험치 로그 엔티티
│   ├── LevelLog.java           # 레벨 변경 로그 엔티티
│   └── Member.java             # 회원 엔티티 (level_id, exp 필드 추가)
├── mapper/
│   ├── LevelMapper.java        # 레벨 매퍼 인터페이스
│   ├── DailyExpLogMapper.java  # 일일 경험치 로그 매퍼
│   ├── LevelLogMapper.java     # 레벨 로그 매퍼
│   └── MemberMapper.java       # 회원 매퍼 (경험치 관련 메서드 추가)
├── service/
│   ├── LevelService.java       # 레벨 서비스 인터페이스
│   ├── ExpService.java         # 경험치 서비스 인터페이스
│   └── impl/
│       ├── LevelServiceImpl.java
│       └── ExpServiceImpl.java
└── controller/
    └── LevelController.java    # 레벨 관련 API 컨트롤러

src/main/resources/mapper/
├── LevelMapper.xml
├── DailyExpLogMapper.xml
├── LevelLogMapper.xml
└── MemberMapper.xml (업데이트)

src/main/webapp/WEB-INF/views/
└── main/
    ├── title.jsp (레벨 배지 및 메뉴 추가)
    └── main.jsp (레벨 확인 모달 추가)
```

## API 엔드포인트

### 1. 사용자 레벨 정보 조회
```
GET /api/level/info
Authorization: Bearer {token}
```

### 2. 모든 레벨 목록 조회
```
GET /api/level/list
```

### 3. 경험치 로그 조회
```
GET /api/level/exp-logs?limit=7
Authorization: Bearer {token}
```

### 4. 레벨 변경 로그 조회
```
GET /api/level/level-logs?limit=10
Authorization: Bearer {token}
```

### 5. 경험치 추가 가능 여부 확인
```
GET /api/level/can-add-exp?expType=vote&amount=1
Authorization: Bearer {token}
```

### 6. 경험치 추가 (테스트용)
```
POST /api/level/add-exp
Authorization: Bearer {token}
Content-Type: application/x-www-form-urlencoded

expType=vote&amount=1
```

## 사용법

### 1. 레벨 확인
- 사용자 드롭다운 메뉴에서 "레벨 확인" 클릭
- 모바일에서는 햄버거 메뉴에서 "레벨 확인" 클릭
- 현재 레벨, 경험치, 오늘 획득한 경험치 현황 확인 가능

### 2. 경험치 획득
경험치는 다음 활동 시 자동으로 추가됩니다:
- 투표 참여
- 코스 작성
- 핫플썰 작성
- 댓글 작성
- 추천받음
- 찜하기

### 3. 레벨업
- 경험치가 다음 레벨 요구치에 도달하면 자동으로 레벨업
- 레벨 변경 로그가 자동으로 기록됨

## 데이터베이스 테이블

### 1. level 테이블
```sql
CREATE TABLE level (
    level_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    exp_required INT NOT NULL,
    badge_icon VARCHAR(255),
    benefits TEXT
);
```

### 2. daily_exp_log 테이블
```sql
CREATE TABLE daily_exp_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    log_date DATE NOT NULL,
    vote_exp INT DEFAULT 0,
    course_exp INT DEFAULT 0,
    hpost_exp INT DEFAULT 0,
    comment_exp INT DEFAULT 0,
    like_exp INT DEFAULT 0,
    wish_exp INT DEFAULT 0,
    total_exp INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(userid),
    UNIQUE KEY unique_user_date (user_id, log_date)
);
```

### 3. level_log 테이블
```sql
CREATE TABLE level_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    old_level INT NOT NULL,
    new_level INT NOT NULL,
    gained_exp INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(userid)
);
```

## 주의사항

1. **하루 경험치 한도**: 사용자는 하루에 최대 50 EXP까지만 획득 가능
2. **타입별 한도**: 각 활동별로도 하루 한도가 설정되어 있음
3. **자동 레벨업**: 경험치가 충분하면 자동으로 레벨업됨
4. **로그 기록**: 모든 경험치 획득과 레벨 변경이 로그로 기록됨

## 확장 가능성

1. **레벨별 혜택**: 각 레벨에 따른 특별 혜택 추가
2. **배지 시스템**: 특정 조건 달성 시 배지 획득
3. **랭킹 시스템**: 레벨별 또는 경험치별 랭킹
4. **이벤트**: 특정 기간 동안 경험치 2배 이벤트 등

## 문제 해결

### 1. 레벨 배지가 표시되지 않는 경우
- 브라우저 캐시 삭제 후 새로고침
- 로그인 상태 확인

### 2. 경험치가 추가되지 않는 경우
- 하루 한도 확인
- 로그인 상태 확인
- 서버 로그 확인

### 3. 레벨업이 되지 않는 경우
- 현재 경험치와 다음 레벨 요구치 확인
- 데이터베이스 직접 확인

## 개발자 정보

이 레벨 시스템은 Spring Boot, MyBatis, JSP를 기반으로 구현되었습니다.
추가 기능이나 수정이 필요한 경우 관련 파일들을 참고하여 개발하시기 바랍니다.
