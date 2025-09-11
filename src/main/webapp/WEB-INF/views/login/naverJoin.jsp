<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
request.setCharacterEncoding("UTF-8");   
String root = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>네이버 추가 정보 입력</title>

    <!-- 부트스트랩 (CDN) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <link rel="stylesheet" href="<%=root%>/css/naverJoin.css">
</head>
<body class="bg-light">

    <div class="container my-5 form-container shadow p-4 bg-white rounded">
        <h3 class="form-title text-center mb-4">추가 정보 입력</h3>

        <div class="info-box mb-4">
            <div class="info-item mb-3">
                <label>이름</label>
                <div class="info-value">${name}</div>
            </div>

            <div class="info-item mb-3">
                <label>이메일</label>
                <div class="info-value">${email}</div>
            </div>

            <div class="info-item mb-3">
                <label>성별</label>
                <div class="info-value">
                    ${gender == 'M' ? '남자' : (gender == 'F' ? '여자' : '미지정')}
                </div>
            </div>
        </div>

        <form method="post" action="<%=root%>/oauth2/signup/naver">
            <input type="hidden" name="naverId" value="${naverId}">

            <!-- 닉네임 입력 + 중복확인 -->
            <div class="mb-4">
                <label for="nickname" class="form-label">닉네임</label>
                <div class="input-group">
                    <input type="text" name="nickname" id="nickname" class="form-control" 
                           maxlength="7" required placeholder="닉네임 (2~7자)">
                    <button type="button" class="btn btn-outline-secondary" onclick="checkNickname()">중복확인</button>
                </div>
                <div class="form-text text-muted">닉네임은 2~7자 사이로 입력해주세요.</div>
                <div id="nickResult" class="mt-2 small"></div>
            </div>

            <!-- 생년월일 입력 (선택사항) -->
            <div class="mb-4">
                <label for="birth" class="form-label">생년월일 (선택사항)</label>
                <input type="date" name="birth" id="birth" class="form-control">
                <div class="form-text text-muted">생년월일은 선택사항입니다.</div>
            </div>

            <button type="submit" class="submit-btn-custom w-100">회원가입 완료</button>
        </form>
    </div>

    <script>
        function checkNickname() {
            const nickname = document.getElementById("nickname").value.trim();
            if (nickname === "") {
                document.getElementById("nickResult").innerText = "닉네임을 입력하세요.";
                document.getElementById("nickResult").style.color = "red";
                return;
            }
            if (nickname.length < 2) {
                document.getElementById("nickResult").innerText = "닉네임은 최소 2자 이상 입력해주세요.";
                document.getElementById("nickResult").style.color = "red";
                return;
            }

            fetch("<%=root%>/api/auth/check/nickname?nickname=" + encodeURIComponent(nickname))
                .then(res => res.json())
                .then(data => {
                    if (data.success && !data.exists) {
                        document.getElementById("nickResult").innerText = "사용 가능한 닉네임입니다.";
                        document.getElementById("nickResult").style.color = "green";
                    } else {
                        document.getElementById("nickResult").innerText = "이미 사용 중인 닉네임입니다.";
                        document.getElementById("nickResult").style.color = "red";
                        document.getElementById("nickname").value = "";
                        document.getElementById("nickname").focus();
                    }
                })
                .catch(error => {
                    document.getElementById("nickResult").innerText = "닉네임 확인 중 오류가 발생했습니다.";
                    document.getElementById("nickResult").style.color = "red";
                });
        }
    </script>

</body>
</html>
