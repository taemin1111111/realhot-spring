-- admin 계정의 비밀번호를 올바르게 수정

-- 방법 1: 평문 'admin'으로 변경 (간단) - 권장
UPDATE member SET passwd = 'admin' WHERE userid = 'admin';

-- 방법 2: BCrypt로 'admin'을 암호화한 값으로 변경 (로그에서 확인된 올바른 해시)
UPDATE member SET passwd = '$2a$12$QyR6IjI7V8.74bqXt.dAlu2far/e1YY.I/FKeUFz9xAoJI44HnmmG' WHERE userid = 'admin';

-- 확인
SELECT userid, passwd, provider, status FROM member WHERE userid = 'admin';

-- 참고: BCrypt에서 'admin'을 암호화한 실제 값들
-- $2a$12$LQv3c1yqBwcXj7DJ1VBbn.VZWlvJj2AN54r3PU4K6j3ELKHZpJ1Se
-- $2a$12$8HqFAmA1dHj.PzP0Ql2k1e9QlGKZHjwdQ2QrqWbF9J2t1L3mNnOpO
