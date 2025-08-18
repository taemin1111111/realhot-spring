-- Member 테이블에 누락된 컬럼 추가
-- 기존 Model1 스키마에 Spring Boot용 컬럼들 추가

-- 먼저 테이블 구조 확인
-- DESCRIBE member;

-- 누락된 컬럼들은 추가하지 않음 (사용자 요청에 따라)
-- ALTER TABLE member 
-- ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP NULL COMMENT '마지막 로그인 시간';

-- ALTER TABLE member 
-- ADD COLUMN IF NOT EXISTS login_count INT DEFAULT 0 COMMENT '로그인 횟수';

-- ALTER TABLE member 
-- ADD COLUMN IF NOT EXISTS profile_image VARCHAR(500) NULL COMMENT '프로필 이미지 경로';

-- 기존 Model1 구조 확인
-- 컬럼명 매핑:
-- Model1: passwd -> Spring Boot: password (AS 구문으로 처리)
-- Model1: regdate -> Spring Boot: created_at (AS 구문으로 처리)  
-- Model1: update_date -> Spring Boot: updated_at (AS 구문으로 처리)
-- Model1: status ('A', 'C') -> Spring Boot: status ('정상', 'C')

-- 상태 값 정규화 (필요시)
-- UPDATE member SET status = '정상' WHERE status = 'A';

-- 테스트용 관리자 계정 추가 (평문 비밀번호 - 기존 호환성)
INSERT IGNORE INTO member (userid, passwd, name, nickname, email, provider, status, regdate, update_date) 
VALUES ('admin', 'admin', '관리자', '관리자', 'admin@test.com', 'admin', 'A', NOW(), NOW());

-- 테스트용 일반 계정 추가 (평문 비밀번호)
INSERT IGNORE INTO member (userid, passwd, name, nickname, email, provider, status, regdate, update_date)
VALUES ('test', 'test', '테스트', '테스트유저', 'test@test.com', 'site', 'A', NOW(), NOW());

-- 암호화된 비밀번호 버전도 추가 (선택사항)
INSERT IGNORE INTO member (userid, passwd, name, nickname, email, provider, status, regdate, update_date) 
VALUES ('admin2', '$2a$12$K8ZFQGWmXa2QQ9mF8J7FBOqKt8J3O.9eSyp6DZhHyM5TGV4WgNB.K', '관리자2', '관리자2', 'admin2@test.com', 'admin', 'A', NOW(), NOW());
