<%@ page contentType="text/html; charset=UTF-8"%>
<%
    String root = request.getContextPath();
%>

<div class="modal fade" id="loginModal" tabindex="-1" aria-labelledby="loginModalLabel">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content p-4">

            <!-- 닫기 버튼 -->
            <button type="button" class="btn-close position-absolute top-0 end-0 m-3" data-bs-dismiss="modal" aria-label="Close"></button>

            <div class="row" id="modalRow">

                <!-- 왼쪽 폼 영역 -->
                <div class="col-md-7" id="formArea">

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
                                    <a href="<%=root%>/idsearch">아이디 찾기</a> | 
                                    <a href="<%=root%>/passsearch">비밀번호 재설정</a> | 
                                    <a href="#" onclick="showJoin()">회원가입</a>
                                </span>
                            </div>

                            <button type="submit" class="btn btn-danger w-100" id="loginButton">로그인</button>
                        </form>

                        <hr>

                        <div class="d-flex justify-content-center my-3">
                            <a href="<%=root%>/oauth2/authorization/naver" class="naver-login-btn">
                                <div class="naver-logo">N</div>
                                <span class="naver-text">네이버 로그인</span>
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
                        <a href="<%=root%>/oauth2/authorization/naver" class="naver-login-btn mb-3">
                            <div class="naver-logo">N</div>
                            <span class="naver-text">네이버 간편가입</span>
                        </a>
                    </div>

                    <!-- ✅ 일반 회원가입 폼 -->
                    <div id="joinForm" style="display: none;">
                        <jsp:include page="join.jsp" />
                    </div>

                </div>

                <!-- 오른쪽 이미지 영역 -->
                <div id="imageArea" class="col-md-5 d-flex align-items-center justify-content-center">
                    <div class="login-image-container" style="position: relative; width: 100%; height: 400px; overflow: hidden; border-radius: 10px;">
                        <img id="loginImage" src="<%=root%>/logo/loginman.png?v=<%=System.currentTimeMillis()%>" alt="로그인 이미지" 
                             style="width: 100%; height: 100%; object-fit: cover; transition: opacity 1s ease-in-out;">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
/* 회원가입 관련 화면에서 이미지 영역 강제 숨김 */
#modalRow.hide-image #imageArea {
    display: none !important;
}

/* 회원가입 관련 화면에서 폼 영역 전체 너비 */
#modalRow.hide-image #formArea {
    width: 100% !important;
    flex: 0 0 100% !important;
    max-width: 100% !important;
}

/* 네이버 로그인 버튼 스타일 - 공식 가이드 적용 */
.naver-login-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    width: 100%;
    max-width: 300px;
    height: 50px;
    background: #03C75A;
    border: none;
    border-radius: 6px;
    color: white;
    text-decoration: none;
    font-size: 16px;
    font-weight: 500;
    transition: all 0.2s ease;
    box-shadow: 0 2px 4px rgba(3, 199, 90, 0.2);
}

.naver-login-btn:hover {
    background: #02B351;
    color: white;
    text-decoration: none;
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(3, 199, 90, 0.3);
}

.naver-login-btn:active {
    transform: translateY(0);
    box-shadow: 0 2px 4px rgba(3, 199, 90, 0.2);
}

.naver-logo {
    flex-shrink: 0;
    width: 20px;
    height: 20px;
    background: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 14px;
    color: #03C75A;
    font-family: Arial, sans-serif;
}

.naver-text {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    letter-spacing: -0.01em;
}

/* 모바일에서 네이버 로그인 버튼 크기 조정 */
@media (max-width: 768px) {
    .naver-login-btn {
        height: 55px;
        font-size: 17px;
    }
    
    .naver-logo {
        width: 22px;
        height: 22px;
        font-size: 15px;
    }
}

/* 아이폰에서 네이버 로그인 버튼 크기 더 증가 */
@media (max-width: 480px) {
    .naver-login-btn {
        height: 60px;
        font-size: 18px;
        gap: 10px;
    }
    
    .naver-logo {
        width: 24px;
        height: 24px;
        font-size: 16px;
    }
}

/* 아이폰 Safari 전용 - 네이버 로그인 버튼 최대 크기 */
@supports (-webkit-touch-callout: none) and (max-width: 991px) {
    .naver-login-btn {
        height: 65px;
        font-size: 19px;
        gap: 12px;
    }
    
    .naver-logo {
        width: 26px;
        height: 26px;
        font-size: 17px;
    }
}
</style>

<script>
// 로그인 이미지 슬라이드 기능
let currentImageIndex = 0;
const loginImages = [
    '<%=root%>/logo/loginman.png',
    '<%=root%>/logo/logingirl.png'
];

function startImageSlide() {
    const imageElement = document.getElementById('loginImage');
    if (!imageElement) return;
    
    // 초기 이미지를 loginman.png로 설정하고 캐시 우회
    imageElement.src = loginImages[0] + '?v=' + Date.now();
    
    setInterval(() => {
        // 페이드 아웃
        imageElement.style.opacity = '0';
        
        setTimeout(() => {
            // 다음 이미지로 변경 (캐시 우회를 위해 타임스탬프 추가)
            currentImageIndex = (currentImageIndex + 1) % loginImages.length;
            imageElement.src = loginImages[currentImageIndex] + '?v=' + Date.now();
            
            // 페이드 인
            imageElement.style.opacity = '1';
        }, 1000); // 1초 후 이미지 변경
    }, 5000); // 5초마다 변경
}

// 페이지 로드 시 이미지 슬라이드 시작
document.addEventListener('DOMContentLoaded', function() {
    startImageSlide();
});

// 회원가입 폼 표시 시 이미지 영역 숨기기
function showNormalJoin() {
    document.getElementById('loginForm').style.display = 'none';
    document.getElementById('joinSelectForm').style.display = 'none';
    document.getElementById('joinForm').style.display = 'block';
    
    // 이미지 영역 완전히 숨기기 - 여러 방법으로 확실하게
    const imageArea = document.getElementById('imageArea');
    if (imageArea) {
        imageArea.style.display = 'none !important';
        imageArea.style.visibility = 'hidden';
        imageArea.style.opacity = '0';
        imageArea.style.width = '0';
        imageArea.style.height = '0';
        imageArea.style.padding = '0';
        imageArea.style.margin = '0';
        imageArea.className = 'd-none';
    }
    
    // 폼 영역을 전체 너비로 확장
    const formArea = document.getElementById('formArea');
    if (formArea) {
        formArea.style.width = '100% !important';
        formArea.style.flex = '0 0 100% !important';
        formArea.style.maxWidth = '100% !important';
        formArea.className = 'col-12';
    }
}

// 로그인 폼으로 돌아가기
function showLogin() {
    document.getElementById('loginForm').style.display = 'block';
    document.getElementById('joinSelectForm').style.display = 'none';
    document.getElementById('joinForm').style.display = 'none';
    
    // 이미지 영역 다시 표시 - 모든 스타일 초기화
    const imageArea = document.getElementById('imageArea');
    if (imageArea) {
        imageArea.style.display = '';
        imageArea.style.visibility = '';
        imageArea.style.opacity = '';
        imageArea.style.width = '';
        imageArea.style.height = '';
        imageArea.style.padding = '';
        imageArea.style.margin = '';
        imageArea.className = 'col-md-5 d-flex align-items-center justify-content-center';
    }
    
    // 폼 영역을 원래 크기로 복원
    const formArea = document.getElementById('formArea');
    if (formArea) {
        formArea.style.width = '';
        formArea.style.flex = '';
        formArea.style.maxWidth = '';
        formArea.className = 'col-md-7';
    }
}

// 회원가입 선택 화면 표시
function showJoin() {
    document.getElementById('loginForm').style.display = 'none';
    document.getElementById('joinSelectForm').style.display = 'block';
    document.getElementById('joinForm').style.display = 'none';
    
    // 이미지 영역 완전히 숨기기 - 여러 방법으로 확실하게
    const imageArea = document.getElementById('imageArea');
    if (imageArea) {
        imageArea.style.display = 'none !important';
        imageArea.style.visibility = 'hidden';
        imageArea.style.opacity = '0';
        imageArea.style.width = '0';
        imageArea.style.height = '0';
        imageArea.style.padding = '0';
        imageArea.style.margin = '0';
        imageArea.className = 'd-none';
    }
    
    // 폼 영역을 전체 너비로 확장
    const formArea = document.getElementById('formArea');
    if (formArea) {
        formArea.style.width = '100% !important';
        formArea.style.flex = '0 0 100% !important';
        formArea.style.maxWidth = '100% !important';
        formArea.className = 'col-12';
    }
}

// API 요청 시 JWT 토큰을 헤더에 포함하는 함수 (자동 갱신 포함)
async function fetchWithAuth(url, options = {}) {
    const token = getToken();
    const defaultOptions = {
        headers: {
            'Content-Type': 'application/json',
            ...(token && { 'Authorization': `Bearer ${token}` }),
            ...options.headers
        }
    };
    
    let response = await fetch(url, { ...defaultOptions, ...options });
    
    // 401 에러 시 토큰 갱신 시도
    if (response.status === 401) {
        console.log('토큰 만료, 갱신 시도...');
        const refreshSuccess = await refreshAccessToken();
        
        if (refreshSuccess) {
            // 갱신된 토큰으로 재요청
            const newToken = getToken();
            const retryOptions = {
                ...defaultOptions,
                headers: {
                    ...defaultOptions.headers,
                    'Authorization': `Bearer ${newToken}`
                }
            };
            response = await fetch(url, { ...retryOptions, ...options });
        } else {
            // 갱신 실패 시 로그아웃
            removeToken();
            location.reload();
        }
    }
    
    return response;
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
                console.log('refreshToken 존재:', !!data.refreshToken);
                
                // 토큰 저장 전 상태 확인
                console.log('저장 전 localStorage accessToken:', localStorage.getItem('accessToken') ? '있음' : '없음');
                console.log('저장 전 쿠키:', document.cookie);
                
                // ✅ 분리된 auth-utils.js의 함수 호출 (이제 localStorage에만 저장)
                saveToken(data.token, data.refreshToken);
                
                // 저장 후 상태 확인
                console.log('저장 후 localStorage accessToken:', localStorage.getItem('accessToken') ? '있음' : '없음');
                
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
            
            // 즉시 title UI 업데이트
            if (window.updateTitleUI) {
                const userInfo = JSON.parse(localStorage.getItem('userInfo'));
                if (userInfo) {
                    window.updateTitleUI(userInfo);
                    console.log('로그인 후 즉시 UI 업데이트 완료');
                }
            }
            
            // 모바일 메뉴도 별도로 업데이트
            if (window.updateTitleUIFromSavedInfo) {
                const userInfo = JSON.parse(localStorage.getItem('userInfo'));
                if (userInfo) {
                    window.updateTitleUIFromSavedInfo(userInfo);
                    console.log('로그인 후 모바일 메뉴 업데이트 완료');
                }
            }
            
            // hpostdetail.jsp의 댓글 폼도 업데이트
            if (window.updateCommentFormOnLoginChange) {
                window.updateCommentFormOnLoginChange();
                console.log('로그인 후 댓글 폼 업데이트 완료');
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
        const response = await fetch(root + '/api/auth/logout', {
            method: 'POST',
        });
        
        if (response.ok) {
            console.log('서버 로그아웃 성공');
        } else {
            console.error('서버 로그아웃 실패');
        }
    } catch (error) {
        console.error('로그아웃 요청 오류:', error);
    }
    
    // 서버 응답과 관계없이 클라이언트 데이터 정리
    removeToken(); // localStorage 정리
    
    // UI 업데이트
    if (window.showLoggedOutUI) {
        window.showLoggedOutUI();
        console.log('로그아웃 후 즉시 UI 업데이트 완료');
    } else {
        location.reload(); // fallback
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

// ✅ 더 이상 사용하지 않는 updateTitleUI 함수 제거
// 새로운 아키텍처에서는 title.jsp의 updateTitleUIFromSavedInfo 함수를 사용

// 모달이 닫힐 때 항상 로그인 폼으로 초기화
const loginModalEl = document.getElementById('loginModal');
if (loginModalEl) {
  loginModalEl.addEventListener('hidden.bs.modal', function () {
    showLogin();
  });
}
</script>
