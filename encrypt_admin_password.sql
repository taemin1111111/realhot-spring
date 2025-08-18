-- 관리자 계정의 비밀번호를 암호화된 형태로 업데이트
-- Spring Boot BCrypt로 "admin" 암호화한 값

-- BCrypt로 암호화된 "admin" 비밀번호
-- $2a$12$로 시작하는 것이 BCrypt 암호화된 값입니다.
UPDATE member 
SET passwd = '$2a$12$K8ZFQGWmXa2QQ9mF8J7FBOqKt8J3O.9eSyp6DZhHyM5TGV4WgNB.K' 
WHERE userid = 'admin';

-- 또는 테스트 계정도 업데이트
UPDATE member 
SET passwd = '$2a$12$LQv3c1yqBwcXj7DJ1VBbn.1z9X8Dg7r8k1F5Q6z3QyF8g9h2J4k5m' 
WHERE userid = 'test';

-- 확인 쿼리
SELECT userid, passwd, provider, status FROM member WHERE userid IN ('admin', 'test');
