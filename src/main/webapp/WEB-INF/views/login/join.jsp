<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String root = request.getContextPath();
%>

<div class="container my-4" style="max-width: 600px;">
    <h3 class="mb-4 fw-bold text-center">회원가입</h3>

    <form id="joinForm" onsubmit="return handleSignup(event)">
        <input type="hidden" name="provider" value="site">

        <!-- 아이디 -->
        <div class="mb-3">
            <div class="input-group">
                <input type="text" name="userid" id="join-userid" class="form-control" placeholder="아이디" required>
                <button type="button" class="btn btn-outline-secondary" onclick="checkId()">중복확인</button>
            </div>
            <div id="join-idCheckResult" class="mt-1 small"></div>
        </div>

        <!-- 비밀번호 -->
        <div class="mb-3">
            <input type="password" name="passwd" id="join-passwd" class="form-control" placeholder="비밀번호" required>
            <div id="join-pwRuleResult" class="mt-1 small"></div>
        </div>

        <!-- 비밀번호 확인 -->
        <div class="mb-3">
            <input type="password" name="passwdConfirm" id="join-passwdConfirm" class="form-control" placeholder="비밀번호 확인" required>
            <div id="join-pwCheckResult" class="mt-1 small"></div>
        </div>

        <!-- 이름 -->
        <div class="mb-3">
            <input type="text" name="name" class="form-control" placeholder="이름" required>
        </div>

        <!-- 닉네임 -->
        <div class="mb-3">
            <div class="input-group">
                <input type="text" name="nickname" id="join-nickname" class="form-control" placeholder="닉네임" required>
                <button type="button" class="btn btn-outline-secondary" onclick="checkNickname()">중복확인</button>
            </div>
            <div id="join-nickCheckResult" class="mt-1 small"></div>
        </div>



        <!-- 이메일 (이메일 필수 + 인증코드 발송) -->
        <div class="mb-3">
            <div class="input-group">
                <input type="email" name="email" id="join-email" class="form-control" placeholder="이메일" required>
                <button type="button" class="btn btn-outline-primary" onclick="sendEmailCode()">인증요청</button>
            </div>
            <div id="join-emailResult" class="mt-1 small"></div>
        </div>

        <!-- 이메일 인증코드 입력 -->
        <div class="mb-3">
            <div class="input-group">
                <input type="text" name="emailVerificationCode" id="join-emailCodeInput" class="form-control" placeholder="이메일 인증코드 입력" disabled required>
                <button type="button" class="btn btn-outline-success" onclick="verifyEmailCode()" disabled>확인</button>
            </div>
            <div id="join-emailCodeResult" class="mt-1 small"></div>
        </div>

        <!-- 생년월일 -->
        <div class="mb-3">
            <input type="date" name="birth" class="form-control">
        </div>

        <!-- 성별 -->
        <div class="mb-3">
            <select name="gender" class="form-select">
                <option value="">성별 선택</option>
                <option value="M">남자</option>
                <option value="F">여자</option>
            </select>
        </div>

        <!-- 약관동의 -->
        <div class="form-check mb-3">
            <input class="form-check-input" type="checkbox" required>
            <label class="form-check-label">이용약관 및 개인정보 수집 동의 (필수)</label>
        </div>

        <div class="d-flex gap-2">
            <button type="button" class="btn btn-secondary" onclick="showLogin()">뒤로가기</button>
            <button type="submit" class="btn btn-primary flex-fill">회원가입 완료</button>
        </div>
    </form>
</div>

<script>
// ✅ 아이디 중복확인 (AJAX 연결)
function checkId() {
    const userid = document.getElementById("join-userid").value.trim();
    if(userid.length < 4) {
        document.getElementById("join-idCheckResult").textContent = "아이디는 최소 4자 이상 입력해주세요.";
        document.getElementById("join-idCheckResult").style.color = "red";
        return;
    }
    fetch("<%=root%>/api/auth/check/userid?userid=" + encodeURIComponent(userid))
        .then(res => res.json())
        .then(data => {
            if (!data.exists) {
                document.getElementById("join-idCheckResult").textContent = "사용가능한 아이디입니다.";
                document.getElementById("join-idCheckResult").style.color = "green";
            } else {
                document.getElementById("join-idCheckResult").textContent = "이미 사용중인 아이디입니다.";
                document.getElementById("join-idCheckResult").style.color = "red";
            }
        });
}

// ✅ 닉네임 중복확인 (AJAX 연결)
function checkNickname() {
    const nickname = document.getElementById("join-nickname").value.trim();
    if(nickname === "") {
        document.getElementById("join-nickCheckResult").textContent = "닉네임을 입력하세요.";
        document.getElementById("join-nickCheckResult").style.color = "red";
        return;
    }
    fetch("<%=root%>/api/auth/check/nickname?nickname=" + encodeURIComponent(nickname))
        .then(res => res.json())
        .then(data => {
            if (!data.exists) {
                document.getElementById("join-nickCheckResult").textContent = "사용가능한 닉네임입니다.";
                document.getElementById("join-nickCheckResult").style.color = "green";
            } else {
                document.getElementById("join-nickCheckResult").textContent = "이미 사용중인 닉네임입니다.";
                document.getElementById("join-nickCheckResult").style.color = "red";
                document.getElementById("join-nickname").value = "";
                document.getElementById("join-nickname").focus();
            }
        });
}



// ✅ 이메일 인증코드 발송 (이메일 중복 체크 포함)
function sendEmailCode() {
    const email = document.getElementById("join-email").value.trim();
    if(email === "") {
        document.getElementById("join-emailResult").innerText = "이메일을 입력하세요.";
        document.getElementById("join-emailResult").style.color = "red";
        return;
    }
    
    // 이메일 형식 검증
    const emailRegex = /^[A-Za-z0-9+_.-]+@(.+)$/;
    if (!emailRegex.test(email)) {
        document.getElementById("join-emailResult").innerText = "올바른 이메일 형식이 아닙니다.";
        document.getElementById("join-emailResult").style.color = "red";
        return;
    }
    
    // 버튼 비활성화
    const button = event.target;
    const originalText = button.textContent;
    button.disabled = true;
    button.textContent = "확인중...";
    
    // 먼저 이메일 중복 체크
    fetch("<%=root%>/api/auth/check/email?email=" + encodeURIComponent(email))
        .then(res => res.json())
        .then(data => {
            if (data.exists) {
                // 이메일 중복인 경우
                document.getElementById("join-emailResult").innerText = "해당 이메일로 가입된 계정이 있습니다.";
                document.getElementById("join-emailResult").style.color = "red";
                // 이메일 입력 필드 초기화
                document.getElementById("join-email").value = "";
                document.getElementById("join-email").focus();
                return;
            } else {
                // 이메일 중복이 아닌 경우, 기존 이메일 인증 프로세스 진행
                button.textContent = "발송중...";
                
                return fetch("<%=root%>/api/auth/email/send-verification", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: "email=" + encodeURIComponent(email)
                });
            }
        })
        .catch(error => {
            throw new Error("이메일 중복 체크 중 오류가 발생했습니다.");
        })
        .then(res => {
            console.log("Email send response status:", res.status);
            if (!res.ok) {
                // 오류 응답인 경우
                return res.json().then(errorData => {
                    console.error("Email send error response:", errorData);
                    throw new Error(errorData.error || "이메일 발송에 실패했습니다.");
                });
            }
            return res.json();
        })
        .then(data => {
            console.log("Email send response data:", data);
            if (data.success) {
                document.getElementById("join-emailResult").innerText = data.message;
                document.getElementById("join-emailResult").style.color = "green";
                // 인증코드 입력 필드와 확인 버튼 활성화
                document.getElementById("join-emailCodeInput").disabled = false;
                document.getElementById("join-emailCodeInput").focus();
                document.querySelector('button[onclick="verifyEmailCode()"]').disabled = false;
            } else {
                document.getElementById("join-emailResult").innerText = data.message;
                document.getElementById("join-emailResult").style.color = "red";
            }
        })
        .catch(error => {
            console.error("Email send error:", error);
            document.getElementById("join-emailResult").innerText = error.message || "오류가 발생했습니다.";
            document.getElementById("join-emailResult").style.color = "red";
        })
        .finally(() => {
            // 버튼 다시 활성화
            button.disabled = false;
            button.textContent = originalText;
        });
}



// ✅ 이메일 인증코드 확인
function verifyEmailCode() {
    const email = document.getElementById("join-email").value.trim();
    const code = document.getElementById("join-emailCodeInput").value.trim();
    
    if(email === "") {
        document.getElementById("join-emailCodeResult").innerText = "이메일을 먼저 입력하세요.";
        document.getElementById("join-emailCodeResult").style.color = "red";
        return;
    }
    
    if(code === "") {
        document.getElementById("join-emailCodeResult").innerText = "인증코드를 입력하세요.";
        document.getElementById("join-emailCodeResult").style.color = "red";
        return;
    }
    
    // 버튼 비활성화
    const button = event.target;
    const originalText = button.textContent;
    button.disabled = true;
    button.textContent = "확인중...";
    
    fetch("<%=root%>/api/auth/email/verify", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
        },
        body: "email=" + encodeURIComponent(email) + "&code=" + encodeURIComponent(code)
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            document.getElementById("join-emailCodeResult").innerText = data.message;
            document.getElementById("join-emailCodeResult").style.color = "green";
            // 인증 완료 표시
            document.getElementById("join-email").readOnly = true;
            document.getElementById("join-emailCodeInput").readOnly = true;
            // 이메일 인증 완료 플래그 설정
            window.emailVerified = true;
        } else {
            document.getElementById("join-emailCodeResult").innerText = data.message;
            document.getElementById("join-emailCodeResult").style.color = "red";
        }
    })
    .catch(error => {
        document.getElementById("join-emailCodeResult").innerText = "오류가 발생했습니다.";
        document.getElementById("join-emailCodeResult").style.color = "red";
    })
    .finally(() => {
        // 버튼 다시 활성화
        button.disabled = false;
        button.textContent = originalText;
    });
}

// ✅ 비밀번호 검증
const pwInput = document.getElementById('join-passwd');
const pwRuleResult = document.getElementById('join-pwRuleResult');
pwInput.addEventListener("input", function() {
    const regex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\[\]{};':"\\|,.<>\/?]).{10,}$/;
    if (pwInput.value === "") {
        pwRuleResult.textContent = "";
    } else if (regex.test(pwInput.value)) {
        pwRuleResult.textContent = "사용가능한 비밀번호입니다.";
        pwRuleResult.style.color = "green";
    } else {
        pwRuleResult.textContent = "10자 이상, 영문+숫자+특수문자 포함 필수";
        pwRuleResult.style.color = "red";
    }
});

// ✅ 비밀번호 일치검사
const pwConfirmInput = document.getElementById('join-passwdConfirm');
const pwCheckResult = document.getElementById('join-pwCheckResult');
pwConfirmInput.addEventListener("input", function() {
    if (pwInput.value === "" || pwConfirmInput.value === "") {
        pwCheckResult.textContent = "";
        return;
    }
    if (pwInput.value === pwConfirmInput.value) {
        pwCheckResult.textContent = "비밀번호가 일치합니다.";
        pwCheckResult.style.color = "green";
    } else {
        pwCheckResult.textContent = "비밀번호가 일치하지 않습니다.";
        pwCheckResult.style.color = "red";
    }
});

// ✅ Spring Boot REST API 방식 회원가입 처리
async function handleSignup(event) {
    event.preventDefault();
    
    const pwRuleResult = document.getElementById('join-pwRuleResult');
    const pwCheckResult = document.getElementById('join-pwCheckResult');
    
    // 비밀번호 검증
    if (pwRuleResult.style.color !== "green" || pwCheckResult.style.color !== "green") {
        alert("비밀번호 조건 또는 비밀번호 확인을 다시 확인하세요.");
        return false;
    }
    
    // 이메일 인증 확인
    if (!window.emailVerified) {
        alert("이메일 인증을 완료해주세요.");
        return false;
    }
    
    // 폼 데이터 수집
    const formData = new FormData(event.target);
    const signupData = {
        userid: formData.get('userid'),
        password: formData.get('passwd'),
        passwordConfirm: formData.get('passwdConfirm'),
        name: formData.get('name'),
        nickname: formData.get('nickname'),
        email: formData.get('email'),
        emailVerificationCode: formData.get('emailVerificationCode'),
        birth: formData.get('birth') || null,
        gender: formData.get('gender') || null,
        provider: 'site'
    };
    
    console.log('Signup data:', signupData);
    
    // 제출 버튼 비활성화
    const submitButton = event.target.querySelector('button[type="submit"]');
    const originalText = submitButton.textContent;
    submitButton.disabled = true;
    submitButton.textContent = '처리중...';
    
    try {
        const response = await fetch('<%=root%>/api/auth/signup', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(signupData)
        });
        
        const result = await response.json();
        console.log('Signup response:', result);
        
        if (response.ok) {
            alert('회원가입이 완료되었습니다! 로그인해주세요.');
            // 로그인 폼으로 이동
            showLogin();
        } else {
            alert(result.error || '회원가입에 실패했습니다.');
        }
        
    } catch (error) {
        console.error('Signup error:', error);
        alert('회원가입 중 오류가 발생했습니다.');
    } finally {
        // 버튼 복구
        submitButton.disabled = false;
        submitButton.textContent = originalText;
    }
    
    return false;
}
</script>

