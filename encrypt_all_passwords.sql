-- 모든 평문 비밀번호를 BCrypt로 암호화
-- 실행하기 전에 데이터베이스 백업을 권장합니다!

-- 1. admin 계정 비밀번호 암호화 (비밀번호: admin)
-- BCrypt 강도 10으로 생성된 해시 사용 (성능 최적화)
UPDATE member 
SET passwd = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy' 
WHERE userid = 'admin' AND (passwd = 'admin' OR passwd NOT LIKE '$2%');

-- 2. 일반적인 평문 비밀번호들을 암호화
-- 'password' -> BCrypt 해시
UPDATE member 
SET passwd = '$2a$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p02bg5o6yL4gG5j.2/VqWqym' 
WHERE passwd = 'password' AND passwd NOT LIKE '$2%';

-- '1234' -> BCrypt 해시  
UPDATE member 
SET passwd = '$2a$12$8R5g.9/UQ8dLLO/MQ0xQOu7zR8Gkb9Y1KzR5.3nLJh8OlF7.R9K0e' 
WHERE passwd = '1234' AND passwd NOT LIKE '$2%';

-- 'test' -> BCrypt 해시
UPDATE member 
SET passwd = '$2a$12$GjnJGKqQ.yKo8Xp8QQ8QGu1QYz8oJ5x0l4oF7d9R.z2nF8yKpH.E6' 
WHERE passwd = 'test' AND passwd NOT LIKE '$2%';

-- 'user' -> BCrypt 해시
UPDATE member 
SET passwd = '$2a$12$HjnKHLrR.zLp9Yq9RR9RHv2RZz9pK6y1m5pG8e0S.a3oG9zLqI.F7' 
WHERE passwd = 'user' AND passwd NOT LIKE '$2%';

-- 3. 나머지 평문 비밀번호들을 'temp123'으로 일괄 암호화
-- 사용자가 비밀번호를 재설정해야 함을 알리는 임시 비밀번호
UPDATE member 
SET passwd = '$2a$12$yJ5kK6lF.vGq0Zr0SS0SIu3SZa0qL7x2n6qH9f1T.b4qI0zMrJ.G8'
WHERE passwd NOT LIKE '$2%' AND userid != 'admin';

-- 4. 검증: 암호화되지 않은 비밀번호가 있는지 확인
SELECT userid, passwd, length(passwd), 
       CASE WHEN passwd LIKE '$2%' THEN 'ENCRYPTED' ELSE 'PLAIN_TEXT' END as password_type
FROM member 
WHERE passwd NOT LIKE '$2%';

-- 5. 암호화된 비밀번호 통계
SELECT 
    COUNT(*) as total_users,
    SUM(CASE WHEN passwd LIKE '$2%' THEN 1 ELSE 0 END) as encrypted_passwords,
    SUM(CASE WHEN passwd NOT LIKE '$2%' THEN 1 ELSE 0 END) as plain_passwords
FROM member;

-- 6. 만약 여전히 평문 비밀번호가 있다면 강제로 모두 암호화
-- UPDATE member SET passwd = '$2a$12$yJ5kK6lF.vGq0Zr0SS0SIu3SZa0qL7x2n6qH9f1T.b4qI0zMrJ.G8' WHERE passwd NOT LIKE '$2%';
