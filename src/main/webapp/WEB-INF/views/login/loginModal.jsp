<%@ page contentType="text/html; charset=UTF-8"%>
<%
    String root = request.getContextPath();
%>

<div class="modal fade" id="loginModal" tabindex="-1" aria-labelledby="loginModalLabel">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content p-4">

            <!-- 닫기 버튼 -->
            <button type="button" class="btn-close position-absolute top-0 end-0 m-3" data-bs-dismiss="modal" aria-label="Close"></button>

            <div class="row">

                <!-- 왼쪽 폼 영역 -->
                <div class="col-md-7">

                    <!-- ✅ 로그인 폼 -->
                    <div id="loginForm">
                        <h4 class="mb-3 fw-bold">로그인</h4>

                        <form id="loginFormElement" onsubmit="handleLogin(event)">
                            <div class="mb-3">
                                <input type="text" id="userid" name="userid" class="form-control" placeholder="아이디" required>
                            </div>
                            <div class="mb-3">
                                <input type="password" id="passwd" name="passwd" class="form-control" placeholder="비밀번호" required>
                            </div>

                            <div class="mb-3 form-check">
                                <input type="checkbox" class="form-check-input" id="rememberId">
                                <label class="form-check-label" for="rememberId">아이디 저장</label>
                                <span class="ms-3 small"> 
                                    <a href="#">아이디 찾기</a> | 
                                    <a href="#">비밀번호 재설정</a> | 
                                    <a href="#" onclick="showJoin()">회원가입</a>
                                </span>
                            </div>

                            <button type="submit" class="btn btn-danger w-100" id="loginButton">로그인</button>
                        </form>

                        <hr>

                        <div class="d-flex justify-content-center my-3">
                            <a href="https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=Uhipu8CFRcKrmTNw5xie&redirect_uri=http%3A%2F%2Flocalhost%3A8083%2Fhotplace%2Flogin%2FnaverCallback.jsp&state=random_state">
                                <img src="https://static.nid.naver.com/oauth/small_g_in.PNG" alt="네이버 로그인" style="width: 300px; height: 50px;">
                            </a>
                        </div>
                    </div>

                    <!-- ✅ 회원가입 선택 화면 -->
                    <div id="joinSelectForm" style="display: none;">
                        <h4 class="mb-4 text-center fw-bold">회원가입 방법 선택</h4>

                        <!-- 일반 회원가입 -->
                        <button class="btn btn-primary w-100 mb-3" onclick="showNormalJoin()">
                            일반 회원가입
                        </button>

                        <!-- 네이버 간편회원가입 -->
                        <a href="https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=Uhipu8CFRcKrmTNw5xie&redirect_uri=http%3A%2F%2Flocalhost%3A8083%2Fhotplace%2Flogin%2FnaverCallback.jsp&state=random_state"
                           style="display: block; width: 300px; height: 50px; background: #03C75A; border: none; border-radius: 4px; color: white; text-decoration: none; font-size: 16px; font-weight: 500; margin: 0 auto 10px auto;">
                           <img src="https://static.nid.naver.com/oauth/small_g_in.PNG" alt="네이버" style="width: 300px; height: 50px;">
                        </a>
                    </div>

                    <!-- ✅ 일반 회원가입 폼 -->
                    <div id="joinForm" style="display: none;">
                        <jsp:include page="join.jsp" />
                    </div>

                </div>

                <!-- 오른쪽 이미지 영역 -->
                <div class="col-md-5 d-flex align-items-center justify-content-center">
                    <img src="#" alt="안내 이미지" style="max-width: 100%; height: auto;">
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// JWT 토큰 관리 함수들
function saveToken(token) {
    localStorage.setItem('accessToken', token);
}

function getToken() {
    return localStorage.getItem('accessToken');
}

function removeToken() {
    localStorage.removeItem('accessToken');
}

// API 요청 시 JWT 토큰을 헤더에 포함하는 함수
function fetchWithAuth(url, options = {}) {
    const token = getToken();
    const defaultOptions = {
        headers: {
            'Content-Type': 'application/json',
            ...(token && { 'Authorization': `Bearer ${token}` }),
            ...options.headers
        }
    };
    
    return fetch(url, { ...defaultOptions, ...options });
}

// 로그인 처리 함수
async function handleLogin(event) {
    event.preventDefault();
    
    const userid = document.getElementById('userid').value;
    const passwd = document.getElementById('passwd').value;
    const loginButton = document.getElementById('loginButton');
    
    if (!userid.trim() || !passwd.trim()) {
        alert('아이디와 비밀번호를 모두 입력해주세요.');
        return;
    }
    
    // 로딩 상태로 변경
    loginButton.disabled = true;
    loginButton.textContent = '로그인 중...';
    
    try {
        const response = await fetch('/hotplace/api/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                userid: userid,
                password: passwd
            })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            // 로그인 성공 - JwtResponse 구조에 맞춰 수정
            console.log('로그인 응답 데이터:', data);
            
            // 토큰 유효성 검사 (JwtResponse.token 필드 사용)
            if (data.token && data.token.includes('.')) {
                console.log('JWT 토큰 저장:', data.token.substring(0, 50) + '...');
                saveToken(data.token);
                
                // 사용자 정보도 함께 저장 (즉시 UI 업데이트용)
                const userInfo = {
                    userid: data.userid,
                    nickname: data.nickname,
                    provider: data.provider,
                    email: data.email
                };
                localStorage.setItem('userInfo', JSON.stringify(userInfo));
                console.log('사용자 정보 저장:', userInfo);
            } else {
                console.error('유효하지 않은 토큰 형식:', data.token);
                alert('로그인 처리 중 오류가 발생했습니다.');
                return;
            }
            
            // 아이디 저장 기능
            const rememberId = document.getElementById('rememberId').checked;
            if (rememberId) {
                localStorage.setItem('savedUserid', userid);
            } else {
                localStorage.removeItem('savedUserid');
            }
            
            alert('로그인이 완료되었습니다!');
            
            // 모달 닫기
            const loginModal = bootstrap.Modal.getInstance(document.getElementById('loginModal'));
            loginModal.hide();
            
            // 즉시 title UI 업데이트 (서버 정보로)
            updateTitleUI(data.nickname, data.provider);
            
            // main.jsp의 인증 상태도 업데이트
            if (typeof window.initAuthStatus === 'function') {
                window.initAuthStatus();
            }
            
        } else {
            // 로그인 실패
            alert(data.error || '로그인에 실패했습니다.');
        }
        
    } catch (error) {
        console.error('Login error:', error);
        alert('로그인 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
        // 로딩 상태 해제
        loginButton.disabled = false;
        loginButton.textContent = '로그인';
    }
}

// 로그아웃 함수
async function logout() {
    try {
        const token = getToken();
        if (token) {
            await fetchWithAuth('/hotplace/api/auth/logout', { method: 'POST' });
        }
    } catch (error) {
        console.error('Logout error:', error);
    } finally {
        removeToken();
        location.reload();
    }
}

// 페이지 로드 시 저장된 아이디 복원
document.addEventListener('DOMContentLoaded', function() {
    const savedUserid = localStorage.getItem('savedUserid');
    if (savedUserid) {
        const useridInput = document.getElementById('userid');
        const rememberIdCheckbox = document.getElementById('rememberId');
        if (useridInput && rememberIdCheckbox) {
            useridInput.value = savedUserid;
            rememberIdCheckbox.checked = true;
        }
    }
});

// 로그인 → 회원가입 선택 화면으로 전환
function showJoin() {
    document.getElementById("loginForm").style.display = "none";
    document.getElementById("joinForm").style.display = "none";
    document.getElementById("joinSelectForm").style.display = "block";
}

// 회원가입 선택 화면 → 일반 회원가입 폼으로 전환
function showNormalJoin() {
    document.getElementById("joinSelectForm").style.display = "none";
    document.getElementById("joinForm").style.display = "block";
}

// 일반 회원가입 → 다시 로그인으로 돌아가기 (옵션)
function showLogin() {
    document.getElementById("joinForm").style.display = "none";
    document.getElementById("joinSelectForm").style.display = "none";
    document.getElementById("loginForm").style.display = "block";
}

// title UI 즉시 업데이트 함수
function updateTitleUI(nickname, provider) {
    console.log('title UI 즉시 업데이트:', nickname, provider);
    
    const loginSection = document.getElementById('login-section');
    const userSection = document.getElementById('user-section');
    const userNickname = document.getElementById('user-nickname');
    const adminMenu = document.getElementById('admin-menu');
    
    if (loginSection && userSection && userNickname) {
        // 로그인 상태로 변경
        loginSection.style.display = 'none';
        userSection.style.display = 'block';
        userNickname.textContent = nickname || '사용자';
        
        // 관리자 메뉴 표시/숨김
        if (adminMenu) {
            adminMenu.style.display = (provider === 'admin') ? 'block' : 'none';
        }
        
        console.log('Title UI 업데이트 완료:', nickname);
    } else {
        console.error('Title UI 요소를 찾을 수 없음');
    }
}

// 모달이 닫힐 때 항상 로그인 폼으로 초기화
const loginModalEl = document.getElementById('loginModal');
if (loginModalEl) {
  loginModalEl.addEventListener('hidden.bs.modal', function () {
    showLogin();
  });
}
</script>
