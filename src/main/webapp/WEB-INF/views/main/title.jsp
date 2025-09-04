<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String root = request.getContextPath();
    // JWT 기반 인증으로 변경 - 클라이언트 JavaScript에서 처리
%>

<style>
/* 알림 관련 스타일 */
.notification-container {
    position: relative;
    display: inline-block;
}

.notification-bell {
    position: relative;
    font-size: 18px;
    cursor: pointer;
    padding: 6px;
    border-radius: 50%;
    transition: background-color 0.2s ease;
}

.notification-bell:hover {
    background-color: rgba(255, 255, 255, 0.1);
}

.notification-badge {
    position: absolute;
    top: 0;
    right: 0;
    background-color: #dc3545;
    color: white;
    border-radius: 50%;
    width: 16px;
    height: 16px;
    font-size: 10px;
    font-weight: bold;
    display: flex;
    align-items: center;
    justify-content: center;
    transform: translate(25%, -25%);
}

.notification-dropdown {
    position: absolute;
    top: 100%;
    right: 0;
    background: white;
    border: 1px solid #ddd;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    width: 350px;
    max-height: 400px;
    z-index: 1000;
    margin-top: 8px;
}

.notification-header {
    padding: 12px 16px;
    border-bottom: 1px solid #eee;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background-color: #f8f9fa;
    border-radius: 8px 8px 0 0;
}

.notification-header span {
    font-weight: 600;
    color: #333;
}

.notification-list {
    max-height: 300px;
    overflow-y: auto;
}

.notification-item {
    padding: 12px 16px;
    border-bottom: 1px solid #f0f0f0;
    cursor: pointer;
    transition: background-color 0.2s ease;
}

.notification-item:hover {
    background-color: #f8f9fa;
}

.notification-item.unread {
    background-color: #e3f2fd;
    border-left: 3px solid #2196f3;
}

.notification-item:last-child {
    border-bottom: none;
}

.notification-message {
    font-size: 14px;
    color: #333;
    margin-bottom: 4px;
}

.notification-time {
    font-size: 12px;
    color: #666;
}

.notification-empty {
    padding: 24px 16px;
    text-align: center;
    color: #666;
    font-size: 14px;
}

/* 반응형 디자인 */
@media (max-width: 768px) {
    .notification-dropdown {
        width: 300px;
        right: -50px;
    }
}
</style>


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
                        <li><a class="dropdown-item" href="<%=root%>/hpost">핫플썰</a></li>
                    </ul>
                </li>

                <!-- 클럽 MD에게 문의하기 -->
                <li class="nav-item">
                    <a class="nav-link" href="<%=root%>/md">클럽 MD에게 문의하기</a>
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
                <div class="d-flex align-items-center">
                    <!-- 알림 벨 (일반 사용자만 표시) -->
                    <div id="notification-container" class="notification-container me-3" style="display: none;">
                        <div class="notification-bell" onclick="toggleNotifications()">
                            🔔
                            <span id="notification-badge" class="notification-badge">0</span>
                        </div>
                        <div id="notification-dropdown" class="notification-dropdown" style="display: none;">
                            <div class="notification-header">
                                <span>알림</span>
                                <button class="btn btn-sm btn-outline-secondary" onclick="markAllAsRead()">모두 읽음</button>
                            </div>
                            <div id="notification-list" class="notification-list">
                                <!-- 알림 목록이 여기에 동적으로 로드됩니다 -->
                            </div>
                        </div>
                    </div>
                    
                    <!-- 사용자 정보 -->
                    <div class="dropdown">
                        <a href="#" class="text-white text-decoration-none dropdown-toggle" data-bs-toggle="dropdown">
                            <span id="user-icon">👤</span> <span id="user-nickname">사용자</span>님
                        </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li id="mypage-menu"><a class="dropdown-item" href="<%=root%>/mypage">마이페이지</a></li>
                                        <li id="admin-menu1" style="display: none;"><a class="dropdown-item" href="#" onclick="goToAdminPage('/admin/hpost'); return false;">핫플썰 관리</a></li>
                <li id="admin-menu2" style="display: none;"><a class="dropdown-item" href="#" onclick="goToAdminPage('/admin/course'); return false;">코스 관리</a></li>
                <li id="admin-menu3" style="display: none;"><a class="dropdown-item" href="#" onclick="goToAdminPage('/admin/md'); return false;">MD 관리</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="#" onclick="logout()">로그아웃</a></li>
                    </ul>
                    </div>
                </div>
            </div>
        </div>


    </div>
</header>

<!-- ✅ 로그인 모달 JSP include -->
<jsp:include page="../login/loginModal.jsp" />

<script>
// 이 파일의 스크립트는 title.jsp에 특화된 UI 로직만 남깁니다.
// 모든 인증 관련 공통 함수(saveToken, getToken, removeToken, goToAdminPage)는
// index.jsp를 통해 로드되는 auth-utils.js에 의해 제공됩니다.

/**
 * 로그인 상태에 따라 UI를 업데이트하는 메인 함수
 */
function updateTitleUI(userInfo) {
    try {
        // DOM이 준비되지 않았으면 실행하지 않음
        if (document.readyState === 'loading') {
            console.log('DOM이 아직 로딩 중입니다. updateTitleUI 실행을 건너뜁니다.');
            return;
        }
        
        if (!userInfo) {
            showLoggedOutUI();
            return;
        }
        
        const loginSection = document.getElementById('login-section');
        const userSection = document.getElementById('user-section');
        const userNickname = document.getElementById('user-nickname');
        const userIcon = document.getElementById('user-icon');
        
        console.log('updateTitleUI 실행 - DOM 요소들:', {
            loginSection: !!loginSection,
            userSection: !!userSection,
            userNickname: !!userNickname,
            userIcon: !!userIcon
        });
        
        // 각 요소가 존재하는지 확인하고 안전하게 처리
        if (loginSection && loginSection.style) {
            try {
                loginSection.style.display = 'none';
            } catch (e) {
                console.warn('loginSection 스타일 변경 실패:', e);
            }
        }
        if (userSection && userSection.style) {
            try {
                userSection.style.display = 'block';
            } catch (e) {
                console.warn('userSection 스타일 변경 실패:', e);
            }
        }
        if (userNickname) {
            try {
                userNickname.textContent = userInfo.nickname || userInfo.userid;
            } catch (e) {
                console.warn('userNickname 텍스트 변경 실패:', e);
            }
        }
        
        // 이모티콘 설정
        if (userIcon) {
            try {
                if (userInfo.provider === 'admin' || userInfo.userid === 'admin') {
                    userIcon.textContent = '👑'; // 관리자는 왕관
                } else {
                    userIcon.textContent = '👤'; // 일반 사용자는 사람
                }
            } catch (e) {
                console.warn('userIcon 이모티콘 변경 실패:', e);
            }
        }
        
        // 알림 벨 표시/숨김 설정
        const notificationContainer = document.getElementById('notification-container');
        if (notificationContainer) {
            try {
                if (userInfo.provider === 'admin' || userInfo.userid === 'admin') {
                    notificationContainer.style.display = 'none'; // 관리자는 알림 벨 숨김
                } else {
                    notificationContainer.style.display = 'inline-block'; // 일반 사용자는 알림 벨 표시
                }
            } catch (e) {
                console.warn('알림 벨 표시 설정 실패:', e);
            }
        }
        
        // 관리자 메뉴들 표시
        const adminMenu1 = document.getElementById('admin-menu1');
        const adminMenu2 = document.getElementById('admin-menu2');
        const adminMenu3 = document.getElementById('admin-menu3');
        
        if (adminMenu1 && adminMenu1.style) {
            try {
                adminMenu1.style.display = (userInfo.provider === 'admin' || userInfo.userid === 'admin') ? 'block' : 'none';
            } catch (e) {
                console.warn('adminMenu1 스타일 변경 실패:', e);
            }
        }
        if (adminMenu2 && adminMenu2.style) {
            try {
                adminMenu2.style.display = (userInfo.provider === 'admin' || userInfo.userid === 'admin') ? 'block' : 'none';
            } catch (e) {
                console.warn('adminMenu2 스타일 변경 실패:', e);
            }
        }
        if (adminMenu3 && adminMenu3.style) {
            try {
                adminMenu3.style.display = (userInfo.provider === 'admin' || userInfo.userid === 'admin') ? 'block' : 'none';
            } catch (e) {
                console.warn('adminMenu3 스타일 변경 실패:', e);
            }
        }
        
        // 관리자일 때는 마이페이지 메뉴 숨기기
        const mypageMenu = document.getElementById('mypage-menu');
        if (mypageMenu && mypageMenu.style) {
            try {
                mypageMenu.style.display = (userInfo.provider === 'admin' || userInfo.userid === 'admin') ? 'none' : 'block';
            } catch (e) {
                console.warn('mypageMenu 스타일 변경 실패:', e);
            }
        }
        
        console.log('로그인 UI 업데이트 완료:', userInfo.nickname || userInfo.userid);
        
        // 알림 기능 초기화 및 즉시 개수 확인
        initializeNotifications();
        updateNotificationBadge();
    } catch (error) {
        console.warn('updateTitleUI 실행 중 오류:', error);
    }
}

function showLoggedOutUI() {
    try {
        // DOM이 준비되지 않았으면 실행하지 않음
        if (document.readyState === 'loading') {
            console.log('DOM이 아직 로딩 중입니다. showLoggedOutUI 실행을 건너뜁니다.');
            return;
        }
        
        const loginSection = document.getElementById('login-section');
        const userSection = document.getElementById('user-section');
        const adminMenu1 = document.getElementById('admin-menu1');
        const adminMenu2 = document.getElementById('admin-menu2');
        const adminMenu3 = document.getElementById('admin-menu3');
        const mypageMenu = document.getElementById('mypage-menu');
        
        console.log('showLoggedOutUI 실행 - DOM 요소들:', {
            loginSection: !!loginSection,
            userSection: !!userSection,
            adminMenu1: !!adminMenu1,
            adminMenu2: !!adminMenu2,
            adminMenu3: !!adminMenu3,
            mypageMenu: !!mypageMenu
        });
        
        // 각 요소가 존재하는지 확인하고 안전하게 처리
        if (loginSection && loginSection.style) {
            try {
                loginSection.style.display = 'block';
            } catch (e) {
                console.warn('loginSection 스타일 변경 실패:', e);
            }
        }
        if (userSection && userSection.style) {
            try {
                userSection.style.display = 'none';
            } catch (e) {
                console.warn('userSection 스타일 변경 실패:', e);
            }
        }
        if (adminMenu1 && adminMenu1.style) {
            try {
                adminMenu1.style.display = 'none';
            } catch (e) {
                console.warn('adminMenu1 스타일 변경 실패:', e);
            }
        }
        if (adminMenu2 && adminMenu2.style) {
            try {
                adminMenu2.style.display = 'none';
            } catch (e) {
                console.warn('adminMenu2 스타일 변경 실패:', e);
            }
        }
        if (adminMenu3 && adminMenu3.style) {
            try {
                adminMenu3.style.display = 'none';
            } catch (e) {
                console.warn('adminMenu3 스타일 변경 실패:', e);
            }
        }
        if (mypageMenu && mypageMenu.style) {
            try {
                mypageMenu.style.display = 'none';
            } catch (e) {
                console.warn('mypageMenu 스타일 변경 실패:', e);
            }
        }
        
        console.log('showLoggedOutUI 실행 완료');
    } catch (error) {
        console.warn('showLoggedOutUI 실행 중 오류:', error);
    }
}

// DOM 로드 시 초기 상태 확인 (coursedetail 방식)
document.addEventListener('DOMContentLoaded', function() {
    // 저장된 토큰으로 초기 상태 확인
    const userInfo = getUserInfoFromToken();
    if (userInfo) {
        updateTitleUI(userInfo);
    } else {
        showLoggedOutUI();
    }
});

// 토큰 관련 유틸리티 함수들
function getToken() {
    return localStorage.getItem('accessToken');
}

function removeToken() {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('userInfo');
}

// 관리자 페이지 이동 함수 (토큰 포함)
function goToAdminPage(path) {
    const token = getToken();
    if (!token) {
        alert('로그인이 필요합니다.');
        return;
    }
    
    // 토큰을 localStorage에 저장 (관리자 페이지에서 사용할 수 있도록)
    localStorage.setItem('adminAccessToken', token);
    
    // 쿠키 상태 확인 및 디버깅
    console.log('=== 관리자 페이지 이동 전 상태 ===');
    console.log('localStorage accessToken:', localStorage.getItem('accessToken') ? '있음' : '없음');
    console.log('현재 쿠키:', document.cookie);
    
    // 쿠키에서 토큰 확인
    const existingAccessToken = document.cookie.split(';').find(row => row.trim().startsWith('accessToken='));
    
    if (existingAccessToken) {
        console.log('기존 accessToken 쿠키 발견:', existingAccessToken.trim());
    } else {
        console.log('기존 accessToken 쿠키 없음 - 로그인 시 쿠키 설정 필요');
    }
    
    // 즉시 페이지 이동 (쿠키 설정은 로그인 시에만 처리)
    console.log('관리자 페이지 이동:', path);
    window.location.href = root + path;
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

// 토큰 갱신 함수
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
                localStorage.setItem('accessToken', data.token);
                console.log('토큰 갱신 성공');
                return true;
            }
        }
        console.log('토큰 갱신 실패');
        return false;
    } catch (error) {
        console.error('토큰 갱신 오류:', error);
        return false;
    }
}

// 토큰에서 사용자 정보 가져오기 (coursedetail 방식)
function getUserInfoFromToken() {
    const token = localStorage.getItem('accessToken');
    if (!token) return null;
    
    try {
        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        
        const payload = JSON.parse(jsonPayload);
        return {
            userid: payload.sub,
            nickname: payload.nickname,
            provider: payload.provider || 'site'
        };
    } catch (error) {
        console.error('토큰 파싱 오류:', error);
        return null;
    }
}



// 저장된 사용자 정보로 즉시 UI 업데이트
function updateTitleUIFromSavedInfo(userInfo) {
    try {
        // DOM이 준비되지 않았으면 실행하지 않음
        if (document.readyState === 'loading') {
            console.log('DOM이 아직 로딩 중입니다. updateTitleUIFromSavedInfo 실행을 건너뜁니다.');
            return;
        }
        
        if (!userInfo) {
            console.log('사용자 정보가 없습니다.');
            return;
        }
        
        const loginSection = document.getElementById('login-section');
        const userSection = document.getElementById('user-section');
        const userNickname = document.getElementById('user-nickname');
        const userIcon = document.getElementById('user-icon');
        
        console.log('updateTitleUIFromSavedInfo 실행 - DOM 요소들:', {
            loginSection: !!loginSection,
            userSection: !!userSection,
            userNickname: !!userNickname,
            userIcon: !!userIcon
        });
        
        // 각 요소가 존재하는지 확인하고 안전하게 처리
        if (loginSection && loginSection.style) {
            try {
                loginSection.style.display = 'none';
            } catch (e) {
                console.warn('loginSection 스타일 변경 실패:', e);
            }
        }
        if (userSection && userSection.style) {
            try {
                userSection.style.display = 'block';
            } catch (e) {
                console.warn('userSection 스타일 변경 실패:', e);
            }
        }
        if (userNickname) {
            try {
                userNickname.textContent = userInfo.nickname || userInfo.userid;
            } catch (e) {
                console.warn('userNickname 텍스트 변경 실패:', e);
            }
        }
        
        // 이모티콘 설정
        if (userIcon) {
            try {
                if (userInfo.provider === 'admin' || userInfo.userid === 'admin') {
                    userIcon.textContent = '👑'; // 관리자는 왕관
                } else {
                    userIcon.textContent = '👤'; // 일반 사용자는 사람
                }
            } catch (e) {
                console.warn('userIcon 이모티콘 변경 실패:', e);
            }
        }
        
        // 알림 벨 표시/숨김 설정
        const notificationContainer = document.getElementById('notification-container');
        if (notificationContainer) {
            try {
                if (userInfo.provider === 'admin' || userInfo.userid === 'admin') {
                    notificationContainer.style.display = 'none'; // 관리자는 알림 벨 숨김
                } else {
                    notificationContainer.style.display = 'inline-block'; // 일반 사용자는 알림 벨 표시
                }
            } catch (e) {
                console.warn('알림 벨 표시 설정 실패:', e);
            }
        }
        
        // 🔐 관리자 메뉴 처리 (즉시)
        if (userInfo.provider === 'admin' || userInfo.userid === 'admin') {
            const adminMenu1 = document.getElementById('admin-menu1');
            const adminMenu2 = document.getElementById('admin-menu2');
            const adminMenu3 = document.getElementById('admin-menu3');
            if (adminMenu1) adminMenu1.style.display = 'block';
            if (adminMenu2) adminMenu2.style.display = 'block';
            if (adminMenu3) adminMenu3.style.display = 'block';
            console.log('updateTitleUIFromSavedInfo: 관리자 메뉴 활성화');
        } else {
            const adminMenu1 = document.getElementById('admin-menu1');
            const adminMenu2 = document.getElementById('admin-menu2');
            const adminMenu3 = document.getElementById('admin-menu3');
            if (adminMenu1) adminMenu1.style.display = 'none';
            if (adminMenu2) adminMenu2.style.display = 'none';
            if (adminMenu3) adminMenu3.style.display = 'none';
            console.log('updateTitleUIFromSavedInfo: 일반 사용자 메뉴 설정');
        }
        
        // 🔐 마이페이지 메뉴 처리 (즉시)
        const mypageMenu = document.getElementById('mypage-menu');
        if (mypageMenu) {
            if (userInfo.provider === 'admin' || userInfo.userid === 'admin') {
                // 관리자는 마이페이지 메뉴 숨기기
                mypageMenu.style.display = 'none';
                console.log('updateTitleUIFromSavedInfo: 관리자 - 마이페이지 메뉴 숨김');
            } else {
                // 일반 사용자는 마이페이지 메뉴 표시
                mypageMenu.style.display = 'block';
                console.log('updateTitleUIFromSavedInfo: 일반 사용자 - 마이페이지 메뉴 표시');
            }
        }
        
        console.log('즉시 UI 업데이트 완료:', userInfo.nickname || userInfo.userid);
    } catch (error) {
        console.warn('updateTitleUIFromSavedInfo 실행 중 오류:', error);
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
    
    console.log('토큰 확인:', token ? '토큰 있음' : '토큰 없음');
    console.log('UI 요소들:', { loginSection, userSection, userNickname, userIcon });
    
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
                
                // 알림 벨 표시/숨김 설정
                const notificationContainer = document.getElementById('notification-container');
                if (notificationContainer) {
                    try {
                        if (payload.provider === 'admin' || payload.sub === 'admin') {
                            notificationContainer.style.display = 'none'; // 관리자는 알림 벨 숨김
                        } else {
                            notificationContainer.style.display = 'inline-block'; // 일반 사용자는 알림 벨 표시
                        }
                    } catch (e) {
                        console.warn('알림 벨 표시 설정 실패:', e);
                    }
                }
                
                console.log('즉시 로그인 UI 업데이트 완료:', payload.nickname || payload.sub);
                
                // 알림 개수 즉시 확인
                updateNotificationBadge();
                
                // 🔐 클라이언트 토큰 정보로 관리자 메뉴 표시 (즉시)
                if (payload.provider === 'admin' || payload.sub === 'admin') {
                    const adminMenu1 = document.getElementById('admin-menu1');
                    const adminMenu2 = document.getElementById('admin-menu2');
                    const adminMenu3 = document.getElementById('admin-menu3');
                    if (adminMenu1) adminMenu1.style.display = 'block';
                    if (adminMenu2) adminMenu2.style.display = 'block';
                    if (adminMenu3) adminMenu3.style.display = 'block';
                    console.log('클라이언트 토큰으로 관리자 메뉴 활성화');
                } else {
                    const adminMenu1 = document.getElementById('admin-menu1');
                    const adminMenu2 = document.getElementById('admin-menu2');
                    const adminMenu3 = document.getElementById('admin-menu3');
                    if (adminMenu1) adminMenu1.style.display = 'none';
                    if (adminMenu2) adminMenu2.style.display = 'none';
                    if (adminMenu3) adminMenu3.style.display = 'none';
                    console.log('클라이언트 토큰으로 일반 사용자 메뉴 설정');
                }
                
                // 백그라운드에서 서버 검증 (권한 확인) - 선택적
                // try {
                //     console.log('백그라운드 서버 권한 검증 시작...');
                //     const response = await fetchWithAuth('/hotplace/api/auth/check-admin');
                //     
                //     if (response.ok) {
                //         const data = await response.json();
                //         console.log('서버 응답 데이터:', data);
                //         
                //         // 서버 검증 결과로 추가 권한 확인
                //         if (data.isAdmin === true) {
                //             console.log('서버에서 관리자 권한 확인됨');
                //         } else {
                //             console.log('서버에서 일반 사용자로 확인됨');
                //         }
                //     }
                // } catch (serverError) {
                //     console.warn('서버 검증 중 오류, 클라이언트 토큰 정보 사용:', serverError);
                // }
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
    
    if (loginSection) loginSection.style.display = 'block';
    if (userSection) userSection.style.display = 'none';
    
    // 개별 관리자 메뉴들 숨기기
    const adminMenu1 = document.getElementById('admin-menu1');
    const adminMenu2 = document.getElementById('admin-menu2');
    const adminMenu3 = document.getElementById('admin-menu3');
    if (adminMenu1) adminMenu1.style.display = 'none';
    if (adminMenu2) adminMenu2.style.display = 'none';
    if (adminMenu3) adminMenu3.style.display = 'none';
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
        // 기존 방식으로 토큰 제거
        removeToken();
        
        // ✅ 즉시 로그아웃 UI 표시 (새로고침 없이)
        // DOM이 준비되었는지 확인 후 실행
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => {
                showLoggedOutUI();
            });
        } else {
            showLoggedOutUI();
        }
        console.log('로그아웃 후 즉시 UI 업데이트 완료');
        
        // hpostdetail.jsp의 댓글 폼도 업데이트
        if (window.updateCommentFormOnLoginChange) {
            window.updateCommentFormOnLoginChange();
            console.log('로그아웃 후 댓글 폼 업데이트 완료');
        }
        
        // 알림 드롭다운 닫기
        const notificationDropdown = document.getElementById('notification-dropdown');
        if (notificationDropdown) {
            notificationDropdown.style.display = 'none';
            notificationDropdownOpen = false;
        }
    }
}

// 전역에서 사용할 수 있도록 함수 노출
window.updateAuthUI = updateAuthUI;
window.getUserInfoFromToken = getUserInfoFromToken;
window.logout = logout;
window.fetchWithAuth = fetchWithAuth;
window.refreshAccessToken = refreshAccessToken;
window.showLoggedOutUI = showLoggedOutUI;  // ✅ 로그아웃 UI 함수 노출



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
                saveToken(data.token, data.refreshToken);
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

// JWT 토큰 관리 함수들
function saveToken(token, refreshToken) {
    // localStorage에 저장
    localStorage.setItem('accessToken', token);
    if (refreshToken) {
        localStorage.setItem('refreshToken', refreshToken);
    }
    
    // 쿠키에도 저장 (브라우저 직접 접근 시 인증을 위해)
    const expires = new Date();
    expires.setTime(expires.getTime() + (24 * 60 * 60 * 1000)); // 24시간
    
    // accessToken 쿠키 설정
    document.cookie = `accessToken=${token}; expires=${expires.toUTCString()}; path=/; SameSite=Strict`;
    
    if (refreshToken) {
        // refreshToken 쿠키 설정 (7일)
        const refreshExpires = new Date();
        refreshExpires.setTime(refreshExpires.getTime() + (7 * 24 * 60 * 60 * 1000)); // 7일
        document.cookie = `refreshToken=${refreshToken}; expires=${refreshExpires.toUTCString()}; path=/; SameSite=Strict`;
    }
    
    console.log('JWT 토큰을 localStorage와 쿠키에 저장 완료');
}

function removeToken() {
    // localStorage에서 삭제
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('userInfo');
    
    // 쿠키에서도 삭제
    document.cookie = 'accessToken=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    document.cookie = 'refreshToken=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    
    console.log('JWT 토큰을 localStorage와 쿠키에서 삭제 완료');
}

// 알림 관련 함수들
let notificationDropdownOpen = false;

// 알림 토글
function toggleNotifications() {
    const dropdown = document.getElementById('notification-dropdown');
    if (!dropdown) return;
    
    if (notificationDropdownOpen) {
        dropdown.style.display = 'none';
        notificationDropdownOpen = false;
    } else {
        dropdown.style.display = 'block';
        notificationDropdownOpen = true;
        loadNotifications();
    }
}

// 알림 목록 로드
async function loadNotifications() {
    const notificationList = document.getElementById('notification-list');
    if (!notificationList) return;
    
    try {
        const response = await fetchWithAuth('/api/notifications');
        if (response.ok) {
            const notifications = await response.json();
            displayNotifications(notifications);
        } else {
            console.error('알림 로드 실패:', response.status);
            notificationList.innerHTML = '<div class="notification-empty">알림을 불러올 수 없습니다.</div>';
        }
    } catch (error) {
        console.error('알림 로드 오류:', error);
        notificationList.innerHTML = '<div class="notification-empty">알림을 불러올 수 없습니다.</div>';
    }
}

// 알림 표시
function displayNotifications(notifications) {
    const notificationList = document.getElementById('notification-list');
    if (!notificationList) return;
    
    if (notifications.length === 0) {
        notificationList.innerHTML = '<div class="notification-empty">새로운 알림이 없습니다.</div>';
        return;
    }
    
    let html = '';
    notifications.forEach(notification => {
        const timeAgo = getTimeAgo(notification.createdAt);
        const unreadClass = notification.isRead ? '' : 'unread';
        
        html += `
            <div class="notification-item ${unreadClass}" onclick="markNotificationAsRead(${notification.notificationId})">
                <div class="notification-message">${notification.message}</div>
                <div class="notification-time">${timeAgo}</div>
            </div>
        `;
    });
    
    notificationList.innerHTML = html;
}

// 알림을 읽음으로 표시
async function markNotificationAsRead(notificationId) {
    try {
        const response = await fetchWithAuth(`/api/notifications/${notificationId}/read`, {
            method: 'PUT'
        });
        
        if (response.ok) {
            // UI에서 읽음 표시 제거
            const notificationItem = document.querySelector(`[onclick="markNotificationAsRead(${notificationId})"]`);
            if (notificationItem) {
                notificationItem.classList.remove('unread');
            }
            
            // 알림 개수 업데이트
            updateNotificationBadge();
        }
    } catch (error) {
        console.error('알림 읽음 처리 오류:', error);
    }
}

// 모든 알림을 읽음으로 표시
async function markAllAsRead() {
    try {
        const response = await fetchWithAuth('/api/notifications/mark-all-read', {
            method: 'PUT'
        });
        
        if (response.ok) {
            // 모든 알림 아이템에서 읽음 표시 제거
            const unreadItems = document.querySelectorAll('.notification-item.unread');
            unreadItems.forEach(item => {
                item.classList.remove('unread');
            });
            
            // 알림 개수 업데이트
            updateNotificationBadge();
        }
    } catch (error) {
        console.error('모든 알림 읽음 처리 오류:', error);
    }
}

// 알림 개수 업데이트
async function updateNotificationBadge() {
    const badge = document.getElementById('notification-badge');
    if (!badge) return;
    
    try {
        const response = await fetchWithAuth('/api/notifications/unread-count');
        if (response.ok) {
            const data = await response.json();
            const count = data.count || 0;
            
            // 항상 배지 표시 (0개여도 +0으로 표시)
            badge.textContent = '+' + count;
            badge.style.display = 'flex';
        }
    } catch (error) {
        console.error('알림 개수 업데이트 오류:', error);
        // 오류 시에도 +0 표시
        badge.textContent = '+0';
        badge.style.display = 'flex';
    }
}

// 시간 표시 함수
function getTimeAgo(dateString) {
    const now = new Date();
    const date = new Date(dateString);
    const diffInSeconds = Math.floor((now - date) / 1000);
    
    if (diffInSeconds < 60) {
        return '방금 전';
    } else if (diffInSeconds < 3600) {
        const minutes = Math.floor(diffInSeconds / 60);
        return `${minutes}분 전`;
    } else if (diffInSeconds < 86400) {
        const hours = Math.floor(diffInSeconds / 3600);
        return `${hours}시간 전`;
    } else {
        const days = Math.floor(diffInSeconds / 86400);
        return `${days}일 전`;
    }
}

// 외부 클릭 시 알림 드롭다운 닫기
document.addEventListener('click', function(event) {
    const notificationContainer = document.querySelector('.notification-container');
    if (notificationContainer && !notificationContainer.contains(event.target)) {
        const dropdown = document.getElementById('notification-dropdown');
        if (dropdown && notificationDropdownOpen) {
            dropdown.style.display = 'none';
            notificationDropdownOpen = false;
        }
    }
});

// 로그인 상태 변경 시 알림 기능 초기화
function initializeNotifications() {
    const userSection = document.getElementById('user-section');
    if (userSection && userSection.style.display !== 'none') {
        // 로그인된 상태이면 알림 개수 업데이트
        updateNotificationBadge();
        
        // 주기적으로 알림 개수 업데이트 (5분마다)
        setInterval(updateNotificationBadge, 5 * 60 * 1000);
    }
}

// 전역 함수로 노출
window.toggleNotifications = toggleNotifications;
window.markNotificationAsRead = markNotificationAsRead;
window.markAllAsRead = markAllAsRead;
window.updateNotificationBadge = updateNotificationBadge;
window.initializeNotifications = initializeNotifications;

</script>