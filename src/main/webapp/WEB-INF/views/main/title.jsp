<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String root = request.getContextPath();
    // JWT 기반 인증으로 변경 - 클라이언트 JavaScript에서 처리
%>


<!-- ✅ title.jsp - 상단 헤더 영역 -->
<header style="background-color: #1a1a1a;" class="text-white py-3 px-4 shadow-sm">
    <div class="container d-flex justify-content-between align-items-center">
        
        <!--  로고 -->
        <div class="logo-box" style="cursor: pointer;">
            <a href="<%=root%>/">
                <img src="<%=root %>/logo/mainlogo2.png" alt="어디핫 로고" style="height: 60px;">
            </a>
        </div>

        <!--  중앙 메뉴 -->
        <nav class="flex-grow-1 text-center header-nav">
            <ul class="nav justify-content-center">
                <!-- 📌 코스 추천 -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                         코스 추천
                    </a>
                    <ul class="dropdown-menu text-start">
                                               <li><a class="dropdown-item" href="<%=root%>/course">지역별 코스 추천</a></li>
                    </ul>
                </li>

                <!-- 썰 게시판 -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                        썰 게시판
                    </a>
                    <ul class="dropdown-menu text-start">
                        <li><a class="dropdown-item" href="<%=root%>/hpost">썰게시판 메인</a></li>
                        <li><a class="dropdown-item" href="<%=root%>/hpost">카테고리별 썰</a></li>
                    </ul>
                </li>

                <!-- 클럽 MD에게 문의하기 -->
                <li class="nav-item">
                    <a class="nav-link" href="<%=root%>/?main=clubmd/clubmd.jsp">클럽 MD에게 문의하기</a>
                </li>

                <!-- 테이블 예약하기 -->
                <li class="nav-item">
                    <a class="nav-link" href="<%=root%>/?main=clubtable/clubtable.jsp">테이블 예약하기</a>
                </li>

                <!-- 📢 공지사항 -->
                <li class="nav-item">
                    <a class="nav-link" href="<%=root%>/?main=notice/noticemain.jsp">공지사항</a>
                </li>
            </ul>
        </nav>

        <!-- 🙋 로그인/회원가입 or 마이페이지 - JWT 기반 동적 처리 -->
        <div class="ms-3" id="auth-area">
            <!-- 로그인 전 -->
            <div id="login-section">
                <a href="#" class="text-white text-decoration-none" data-bs-toggle="modal" data-bs-target="#loginModal">
                    로그인 / 회원가입
                </a>
            </div>
            
            <!-- 로그인 후 -->
            <div id="user-section" style="display: none;">
                <div class="dropdown">
                    <a href="#" class="text-white text-decoration-none dropdown-toggle" data-bs-toggle="dropdown">
                        <span id="user-icon">👤</span> <span id="user-nickname">사용자</span>님
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="<%=root%>/?main=mypage/mypageMain.jsp">마이페이지</a></li>
                        <li id="admin-menu" style="display: none;"><a class="dropdown-item" href="<%=root%>/?main=adminpage/member.jsp">관리자 페이지</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="#" onclick="logout()">로그아웃</a></li>
                    </ul>
                </div>
            </div>
        </div>


    </div>
</header>

<!-- ✅ 로그인 모달 JSP include -->
<jsp:include page="../login/loginModal.jsp" />

<script>
// JWT 토큰 관리 함수들 (loginModal.jsp와 중복이지만 전역에서 사용)
function getToken() {
    return localStorage.getItem('accessToken');
}

function getRefreshToken() {
    return localStorage.getItem('refreshToken');
}

function removeToken() {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('userInfo'); // 사용자 정보도 함께 제거
    location.reload();
}

// API 요청 시 자동 토큰 갱신 포함
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
            return response;
        }
    }
    
    return response;
}

// JWT 토큰에서 사용자 정보 추출 (model1과 동일한 구조)
function getUserInfoFromToken() {
    const token = getToken();
    if (!token) {
        console.log('토큰 없음');
        return null;
    }
    
    // 토큰 형식 검증
    if (typeof token !== 'string' || token.split('.').length !== 3) {
        console.error('잘못된 JWT 토큰 형식:', token);
        removeToken();
        return null;
    }
    
    try {
        // Base64 디코딩 시 한글 인코딩 문제 해결
        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        
        const payload = JSON.parse(jsonPayload);
        console.log('토큰 파싱 성공:', payload);
        return {
            userid: payload.sub,
            nickname: payload.nickname,
            provider: payload.provider || 'site'  // model1과 동일: provider 필드 사용
        };
    } catch (error) {
        console.error('Token parsing error:', error);
        removeToken();
        return null;
    }
}



// 저장된 사용자 정보로 즉시 UI 업데이트
function updateTitleUIFromSavedInfo(userInfo) {
    if (!userInfo) {
        console.log('사용자 정보가 없습니다.');
        return;
    }
    
    const loginSection = document.getElementById('login-section');
    const userSection = document.getElementById('user-section');
    const userNickname = document.getElementById('user-nickname');
    const userIcon = document.getElementById('user-icon');
    const adminMenu = document.getElementById('admin-menu');
    
    if (loginSection && userSection && userNickname) {
        loginSection.style.display = 'none';
        userSection.style.display = 'block';
        userNickname.textContent = userInfo.nickname || userInfo.userid;
        
        // 이모티콘 설정
        if (userIcon) {
            if (userInfo.provider === 'admin' || userInfo.userid === 'admin') {
                userIcon.textContent = '👑'; // 관리자는 왕관
            } else {
                userIcon.textContent = '👤'; // 일반 사용자는 사람
            }
        }
        
        if (adminMenu) {
            adminMenu.style.display = (userInfo.provider === 'admin' || userInfo.userid === 'admin') ? 'block' : 'none';
        }
        
        console.log('즉시 UI 업데이트 완료:', userInfo.nickname || userInfo.userid);
    } else {
        console.warn('UI 요소를 찾을 수 없습니다:', { loginSection, userSection, userNickname });
    }
}

// 인증 UI 업데이트 (서버 검증 포함)
async function updateAuthUI() {
    console.log('updateAuthUI 시작');
    const token = getToken();
    const loginSection = document.getElementById('login-section');
    const userSection = document.getElementById('user-section');
    const userNickname = document.getElementById('user-nickname');
    const userIcon = document.getElementById('user-icon');
    const adminMenu = document.getElementById('admin-menu');
    
    console.log('토큰 확인:', token ? '토큰 있음' : '토큰 없음');
    console.log('UI 요소들:', { loginSection, userSection, userNickname, userIcon, adminMenu });
    
    if (token) {
        try {
            // 먼저 클라이언트에서 토큰 유효성 확인 (즉시 UI 업데이트)
            // Base64 디코딩 시 한글 인코딩 문제 해결
            const base64Url = token.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));
            
            const payload = JSON.parse(jsonPayload);
            const currentTime = Date.now() / 1000;
            
            if (payload.exp > currentTime) {
                // 토큰이 유효하면 즉시 UI 업데이트
                if (loginSection) loginSection.style.display = 'none';
                if (userSection) userSection.style.display = 'block';
                if (userNickname) userNickname.textContent = payload.nickname || payload.sub;
                
                // 이모티콘 설정
                if (userIcon) {
                    if (payload.provider === 'admin' || payload.sub === 'admin') {
                        userIcon.textContent = '👑'; // 관리자는 왕관
                    } else {
                        userIcon.textContent = '👤'; // 일반 사용자는 사람
                    }
                }
                
                console.log('즉시 로그인 UI 업데이트 완료:', payload.nickname || payload.sub);
                
                // 백그라운드에서 서버 검증 (권한 확인)
                try {
                    console.log('백그라운드 서버 권한 검증 시작...');
                    const response = await fetchWithAuth('<%=root%>/api/auth/check-admin');
                    
                    if (response.ok) {
                        const data = await response.json();
                        console.log('서버 응답 데이터:', data);
                        
                        // 🔐 서버에서 검증된 관리자 권한만 표시
                        if (data.isAdmin === true) {
                            if (adminMenu) adminMenu.style.display = 'block';
                            console.log('관리자 메뉴 활성화');
                        } else {
                            if (adminMenu) adminMenu.style.display = 'none';
                            console.log('일반 사용자 - 관리자 메뉴 숨김');
                        }
                    } else {
                        console.warn('서버 권한 검증 실패, 클라이언트 토큰 정보 사용');
                        // 서버 검증 실패해도 클라이언트 토큰으로 기본 UI는 유지
                        if (adminMenu) adminMenu.style.display = 'none';
                    }
                } catch (serverError) {
                    console.warn('서버 검증 중 오류, 클라이언트 토큰 정보 사용:', serverError);
                    // 서버 오류가 있어도 클라이언트 토큰으로 기본 UI는 유지
                    if (adminMenu) adminMenu.style.display = 'none';
                }
            } else {
                console.log('토큰이 만료되었습니다.');
                throw new Error('Token expired');
            }
        } catch (error) {
            console.error('Auth check failed:', error);
            removeToken(); // 유효하지 않은 토큰 제거
            showLoggedOutUI();
        }
    } else {
        console.log('토큰 없음 - 로그아웃 UI 표시');
        showLoggedOutUI();
    }
}

// 로그아웃 상태 UI 표시
function showLoggedOutUI() {
    const loginSection = document.getElementById('login-section');
    const userSection = document.getElementById('user-section');
    const adminMenu = document.getElementById('admin-menu');
    
    loginSection.style.display = 'block';
    userSection.style.display = 'none';
    adminMenu.style.display = 'none';
}

// 로그아웃 함수
async function logout() {
    try {
        const token = getToken();
        if (token) {
            await fetchWithAuth('<%=root%>/api/auth/logout', { method: 'POST' });
        }
    } catch (error) {
        console.error('Logout error:', error);
    } finally {
        removeToken();
    }
}

// 전역에서 사용할 수 있도록 함수 노출
window.updateAuthUI = updateAuthUI;
window.getUserInfoFromToken = getUserInfoFromToken;
window.logout = logout;
window.fetchWithAuth = fetchWithAuth;
window.refreshAccessToken = refreshAccessToken;

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    console.log('title.jsp 초기화 시작');
    
    // 즉시 클라이언트 토큰으로 UI 업데이트 (빠른 응답)
    const userInfo = getUserInfoFromToken();
    if (userInfo) {
        updateTitleUIFromSavedInfo(userInfo);
    }
    
    // 초기 인증 상태 설정 (서버 검증 포함)
    updateAuthUI();
    
    // 토큰 자동 갱신 타이머 설정
    setupTokenRefreshTimer();
    
    // 주기적으로 인증 상태 확인 (1분마다)
    setInterval(() => {
        const token = getToken();
        if (token) {
            try {
                // Base64 디코딩 시 한글 인코딩 문제 해결
                const base64Url = token.split('.')[1];
                const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
                const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
                    return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
                }).join(''));
                
                const payload = JSON.parse(jsonPayload);
                const currentTime = Date.now() / 1000;
                if (payload.exp <= currentTime) {
                    console.log('토큰이 만료되었습니다. 갱신 시도...');
                    refreshAccessToken().then(success => {
                        if (success) {
                            updateAuthUI();
                            setupTokenRefreshTimer();
                        } else {
                            console.log('토큰 갱신 실패. 로그아웃 처리...');
                            removeToken();
                            updateAuthUI();
                        }
                    });
                }
            } catch (error) {
                console.error('토큰 검증 오류:', error);
                removeToken();
                updateAuthUI();
            }
        }
    }, 60000); // 1분마다 체크
});

// 토큰 자동 갱신 타이머 설정
function setupTokenRefreshTimer() {
    const token = getToken();
    if (!token) return;
    
    try {
        // Base64 디코딩 시 한글 인코딩 문제 해결
        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        
        const payload = JSON.parse(jsonPayload);
        const currentTime = Date.now() / 1000;
        const tokenExpiry = payload.exp;
        const timeUntilExpiry = tokenExpiry - currentTime;
        
        // 토큰 만료 10분 전에 갱신
        const refreshTime = Math.max(timeUntilExpiry - 600, 0) * 1000; // 10분 = 600초
        
        if (refreshTime > 0) {
            console.log(`토큰 자동 갱신 타이머 설정: ${Math.round(refreshTime / 1000)}초 후`);
            setTimeout(async () => {
                console.log('토큰 자동 갱신 시작...');
                const success = await refreshAccessToken();
                if (success) {
                    console.log('토큰 자동 갱신 성공');
                    // 갱신 후 새로운 타이머 설정
                    setupTokenRefreshTimer();
                } else {
                    console.log('토큰 자동 갱신 실패');
                }
            }, refreshTime);
        } else {
            console.log('토큰이 곧 만료됩니다. 즉시 갱신 시도...');
            refreshAccessToken();
        }
    } catch (error) {
        console.error('토큰 타이머 설정 오류:', error);
    }
}

// 토큰 자동 갱신 함수
async function refreshAccessToken() {
    const refreshToken = localStorage.getItem('refreshToken');
    if (!refreshToken) {
        console.log('리프레시 토큰이 없습니다.');
        return false;
    }
    
    try {
        const response = await fetch('<%=root%>/api/auth/refresh', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ refreshToken: refreshToken })
        });
        
        if (response.ok) {
            const data = await response.json();
            if (data.result && data.token) {
                // 새 액세스 토큰 저장
                localStorage.setItem('accessToken', data.token);
                console.log('토큰 자동 갱신 성공');
                
                // UI 업데이트
                updateAuthUI();
                
                return true;
            }
        }
        
        console.log('토큰 자동 갱신 실패');
        return false;
    } catch (error) {
        console.error('토큰 자동 갱신 오류:', error);
        return false;
    }
}

</script>
