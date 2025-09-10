<%@ page contentType="text/html; charset=UTF-8"%>
<%
    String root = request.getContextPath();
%>

<style>
    .passsearch-container {
        background: white;
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        padding: 40px;
        width: 100%;
        max-width: 500px;
        margin: 50px auto;
    }
    
    .passsearch-title {
        text-align: center;
        margin-bottom: 30px;
        color: #333;
        font-weight: bold;
    }
    
    .form-control {
        height: 50px;
        border-radius: 8px;
        border: 2px solid #e9ecef;
        font-size: 16px;
    }
    
    .form-control:focus {
        border-color: #ff69b4;
        box-shadow: 0 0 0 0.2rem rgba(255, 105, 180, 0.25);
    }
    
    .btn-primary {
        background-color: #ff69b4;
        border-color: #ff69b4;
        height: 50px;
        font-size: 18px;
        font-weight: bold;
        border-radius: 8px;
    }
    
    .btn-primary:hover {
        background-color: #ff1493;
        border-color: #ff1493;
    }
    
    .btn-secondary {
        background-color: #6c757d;
        border-color: #6c757d;
        height: 50px;
        font-size: 16px;
        border-radius: 8px;
    }
    
    .verification-section {
        display: none;
        margin-top: 20px;
        padding: 20px;
        background-color: #f8f9fa;
        border-radius: 8px;
        border: 1px solid #e9ecef;
    }
    
    .password-change-section {
        display: none;
        margin-top: 20px;
        padding: 20px;
        background-color: #e8f5e8;
        border-radius: 8px;
        border: 1px solid #c3e6cb;
    }
    
    .result-section {
        display: none;
        margin-top: 20px;
        padding: 20px;
        background-color: #d4edda;
        border-radius: 8px;
        border: 1px solid #c3e6cb;
    }
    
    .error-section {
        display: none;
        margin-top: 20px;
        padding: 20px;
        background-color: #f8d7da;
        border-radius: 8px;
        border: 1px solid #f5c6cb;
    }
    
    .countdown {
        color: #ff69b4;
        font-weight: bold;
    }
    
    .back-link {
        text-align: center;
        margin-top: 20px;
    }
    
    .back-link a {
        color: #ff69b4;
        text-decoration: none;
        font-weight: bold;
    }
    
    .back-link a:hover {
        text-decoration: underline;
    }
    
    .password-rule {
        font-size: 12px;
        margin-top: 5px;
    }
    
    .password-check {
        font-size: 12px;
        margin-top: 5px;
    }
    
    .valid {
        color: #28a745;
    }
    
    .invalid {
        color: #dc3545;
    }
</style>

<div class="passsearch-container">
    <h2 class="passsearch-title">
        <i class="bi bi-key me-2"></i>비밀번호 변경
    </h2>
    
    <div class="alert alert-danger text-center mb-4" style="font-size: 14px; padding: 10px;">
        <i class="bi bi-info-circle me-1"></i>비밀번호 재설정은 1일 1회 가능합니다
    </div>
    
    <!-- 이메일 입력 섹션 -->
    <div id="emailSection">
        <div class="mb-3">
            <label for="email" class="form-label">이메일 주소</label>
            <input type="email" id="email" class="form-control" placeholder="가입 시 사용한 이메일을 입력하세요" required>
            <div class="form-text">가입 시 사용한 이메일 주소를 입력해주세요.</div>
        </div>
        
        <button type="button" class="btn btn-primary w-100" onclick="sendVerificationCode()">
            <i class="bi bi-envelope me-2"></i>인증번호 발송
        </button>
    </div>
    
    <!-- 인증번호 입력 섹션 -->
    <div id="verificationSection" class="verification-section">
        <div class="mb-3">
            <label for="verificationCode" class="form-label">인증번호</label>
            <input type="text" id="verificationCode" class="form-control" placeholder="6자리 인증번호를 입력하세요" maxlength="6" required>
            <div class="form-text">
                인증번호가 발송되었습니다. 10분 후 만료됩니다.
            </div>
        </div>
        
        <button type="button" class="btn btn-primary w-100" onclick="verifyCode()">
            <i class="bi bi-check-circle me-2"></i>인증번호 확인
        </button>
        
        <button type="button" class="btn btn-secondary w-100 mt-2" onclick="resendCode()">
            <i class="bi bi-arrow-clockwise me-2"></i>인증번호 재발송
        </button>
    </div>
    
    <!-- 비밀번호 변경 섹션 -->
    <div id="passwordChangeSection" class="password-change-section">
        <h5><i class="bi bi-shield-lock text-success me-2"></i>새 비밀번호 설정</h5>
        
        <div class="mb-3">
            <label for="newPassword" class="form-label">새 비밀번호</label>
            <input type="password" id="newPassword" class="form-control" placeholder="새 비밀번호를 입력하세요" required>
            <div id="passwordRule" class="password-rule">
                • 8자 이상, 영문, 숫자, 특수문자 포함
            </div>
        </div>
        
        <div class="mb-3">
            <label for="confirmPassword" class="form-label">새 비밀번호 확인</label>
            <input type="password" id="confirmPassword" class="form-control" placeholder="새 비밀번호를 다시 입력하세요" required>
            <div id="passwordCheck" class="password-check">
                비밀번호를 다시 입력해주세요.
            </div>
        </div>
        
        <button type="button" class="btn btn-primary w-100" onclick="changePassword()" id="changePasswordBtn" disabled>
            <i class="bi bi-check-circle me-2"></i>비밀번호 변경
        </button>
    </div>
    
    <!-- 결과 섹션 -->
    <div id="resultSection" class="result-section">
        <h5><i class="bi bi-check-circle-fill text-success me-2"></i>비밀번호 변경 완료</h5>
        <p class="mb-2">비밀번호가 성공적으로 변경되었습니다.</p>
        <p class="small text-muted">새로운 비밀번호로 로그인해주세요.</p>
    </div>
    
    <!-- 에러 섹션 -->
    <div id="errorSection" class="error-section">
        <h5><i class="bi bi-exclamation-triangle-fill text-danger me-2"></i>오류</h5>
        <p id="errorMessage"></p>
    </div>
    
    <!-- 하루 1회 제한 안내 -->
    <div id="dailyLimitSection" class="error-section">
        <h5><i class="bi bi-clock-fill text-warning me-2"></i>이용 제한</h5>
        <p>비밀번호 변경은 하루에 1회만 이용할 수 있습니다.</p>
        <p class="small text-muted">내일 다시 시도해주세요.</p>
    </div>
    
    <!-- 네이버 계정 안내 -->
    <div id="naverAccountSection" class="error-section">
        <h5><i class="bi bi-info-circle-fill text-info me-2"></i>네이버 계정 안내</h5>
        <p>네이버로 가입한 계정은 비밀번호 변경을 이용할 수 없습니다.</p>
        <p class="small text-muted">네이버 로그인을 통해 접속해주세요.</p>
    </div>
    
    <div class="back-link">
        <a href="<%=root%>/" onclick="history.back(); return false;">
            <i class="bi bi-arrow-left me-1"></i>뒤로 가기
        </a>
    </div>
</div>

<script>
    let isPasswordValid = false;
    let isPasswordMatched = false;
    
    // 인증번호 발송
    async function sendVerificationCode() {
        const email = document.getElementById('email').value.trim();
        
        if (!email) {
            alert('이메일을 입력해주세요.');
            return;
        }
        
        if (!isValidEmail(email)) {
            alert('올바른 이메일 형식을 입력해주세요.');
            return;
        }
        
        try {
            const response = await fetch('/hotplace/api/auth/send-password-reset-code', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email: email })
            });
            
            const data = await response.json();
            
            if (response.ok) {
                // 인증번호 입력 섹션 표시
                document.getElementById('emailSection').style.display = 'none';
                document.getElementById('verificationSection').style.display = 'block';
                
            } else {
                if (data.error === 'DAILY_LIMIT_EXCEEDED') {
                    showSection('dailyLimitSection');
                } else if (data.error === 'NAVER_ACCOUNT') {
                    showSection('naverAccountSection');
                } else if (data.error === 'EMAIL_NOT_FOUND') {
                    showError('입력하신 이메일로 가입된 계정을 찾을 수 없습니다.');
                } else {
                    showError(data.error || '인증번호 발송에 실패했습니다.');
                }
            }
            
        } catch (error) {
            console.error('Error:', error);
            showError('서버 오류가 발생했습니다. 다시 시도해주세요.');
        }
    }
    
    // 인증번호 확인
    async function verifyCode() {
        const email = document.getElementById('email').value.trim();
        const code = document.getElementById('verificationCode').value.trim();
        
        if (!code) {
            alert('인증번호를 입력해주세요.');
            return;
        }
        
        if (code.length !== 6) {
            alert('6자리 인증번호를 입력해주세요.');
            return;
        }
        
        try {
            const response = await fetch('/hotplace/api/auth/verify-password-reset-code', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ 
                    email: email,
                    code: code
                })
            });
            
            const data = await response.json();
            
            if (response.ok) {
                // 비밀번호 변경 섹션 표시
                document.getElementById('verificationSection').style.display = 'none';
                document.getElementById('passwordChangeSection').style.display = 'block';
                
            } else {
                if (data.error === 'INVALID_CODE') {
                    showError('인증번호가 올바르지 않습니다.');
                } else if (data.error === 'CODE_EXPIRED') {
                    showError('인증번호가 만료되었습니다. 다시 발송해주세요.');
                } else {
                    showError(data.error || '인증에 실패했습니다.');
                }
            }
            
        } catch (error) {
            console.error('Error:', error);
            showError('서버 오류가 발생했습니다. 다시 시도해주세요.');
        }
    }
    
    // 인증번호 재발송
    async function resendCode() {
        const email = document.getElementById('email').value.trim();
        
        try {
            const response = await fetch('/hotplace/api/auth/resend-password-reset-code', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email: email })
            });
            
            const data = await response.json();
            
            if (response.ok) {
                alert('인증번호가 재발송되었습니다.');
            } else {
                showError(data.error || '인증번호 재발송에 실패했습니다.');
            }
            
        } catch (error) {
            console.error('Error:', error);
            showError('서버 오류가 발생했습니다. 다시 시도해주세요.');
        }
    }
    
    // 비밀번호 변경
    async function changePassword() {
        const email = document.getElementById('email').value.trim();
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        
        if (!newPassword || !confirmPassword) {
            alert('비밀번호를 모두 입력해주세요.');
            return;
        }
        
        if (!isPasswordValid) {
            alert('비밀번호 조건을 만족하지 않습니다.');
            return;
        }
        
        if (!isPasswordMatched) {
            alert('비밀번호가 일치하지 않습니다.');
            return;
        }
        
        try {
            const response = await fetch('/hotplace/api/auth/reset-password', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ 
                    email: email,
                    newPassword: newPassword
                })
            });
            
            const data = await response.json();
            
            if (response.ok) {
                // 결과 표시
                document.getElementById('passwordChangeSection').style.display = 'none';
                showSection('resultSection');
                
            } else {
                showError(data.error || '비밀번호 변경에 실패했습니다.');
            }
            
        } catch (error) {
            console.error('Error:', error);
            showError('서버 오류가 발생했습니다. 다시 시도해주세요.');
        }
    }
    
    
    // 섹션 표시
    function showSection(sectionId) {
        // 모든 섹션 숨기기
        const sections = ['emailSection', 'verificationSection', 'passwordChangeSection', 'resultSection', 'errorSection', 'dailyLimitSection', 'naverAccountSection'];
        sections.forEach(id => {
            document.getElementById(id).style.display = 'none';
        });
        
        // 해당 섹션 표시
        document.getElementById(sectionId).style.display = 'block';
    }
    
    // 에러 메시지 표시
    function showError(message) {
        document.getElementById('errorMessage').textContent = message;
        showSection('errorSection');
    }
    
    // 이메일 형식 검증
    function isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }
    
    // 비밀번호 규칙 검증
    function validatePassword(password) {
        const minLength = password.length >= 8;
        const hasLetter = /[a-zA-Z]/.test(password);
        const hasNumber = /\d/.test(password);
        const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password);
        
        const ruleElement = document.getElementById('passwordRule');
        const changeBtn = document.getElementById('changePasswordBtn');
        
        if (minLength && hasLetter && hasNumber && hasSpecial) {
            ruleElement.innerHTML = '✓ 비밀번호 조건을 만족합니다.';
            ruleElement.className = 'password-rule valid';
            isPasswordValid = true;
        } else {
            let message = '• ';
            if (!minLength) message += '8자 이상, ';
            if (!hasLetter) message += '영문, ';
            if (!hasNumber) message += '숫자, ';
            if (!hasSpecial) message += '특수문자 ';
            message += '포함';
            
            ruleElement.innerHTML = message;
            ruleElement.className = 'password-rule invalid';
            isPasswordValid = false;
        }
        
        updateChangeButton();
    }
    
    // 비밀번호 확인 검증
    function validatePasswordConfirm() {
        const password = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        const checkElement = document.getElementById('passwordCheck');
        const changeBtn = document.getElementById('changePasswordBtn');
        
        if (confirmPassword === '') {
            checkElement.innerHTML = '비밀번호를 다시 입력해주세요.';
            checkElement.className = 'password-check';
            isPasswordMatched = false;
        } else if (password === confirmPassword) {
            checkElement.innerHTML = '✓ 비밀번호가 일치합니다.';
            checkElement.className = 'password-check valid';
            isPasswordMatched = true;
        } else {
            checkElement.innerHTML = '✗ 비밀번호가 일치하지 않습니다.';
            checkElement.className = 'password-check invalid';
            isPasswordMatched = false;
        }
        
        updateChangeButton();
    }
    
    // 변경 버튼 활성화/비활성화
    function updateChangeButton() {
        const changeBtn = document.getElementById('changePasswordBtn');
        if (isPasswordValid && isPasswordMatched) {
            changeBtn.disabled = false;
        } else {
            changeBtn.disabled = true;
        }
    }
    
    // 페이지 로드 시 초기화
    document.addEventListener('DOMContentLoaded', function() {
        showSection('emailSection');
        
        // 비밀번호 입력 이벤트 리스너
        document.getElementById('newPassword').addEventListener('input', function() {
            validatePassword(this.value);
            validatePasswordConfirm(); // 비밀번호가 변경되면 확인도 다시 검증
        });
        
        document.getElementById('confirmPassword').addEventListener('input', function() {
            validatePasswordConfirm();
        });
    });
</script>
