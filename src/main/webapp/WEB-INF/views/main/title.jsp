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
                <!-- 📌 핫플 평점보기 -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                         핫플 평점보기
                    </a>
                    <ul class="dropdown-menu text-start">
                       <li><a class="dropdown-item" href="<%=root%>/?main=review/gpaform.jsp">지역별 평점 보기</a></li>
                    </ul>
                </li>

                <!-- 썰 게시판 -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                        썰 게시판
                    </a>
                    <ul class="dropdown-menu text-start">
                        <li><a class="dropdown-item" href="<%=root%>/?main=community/cumain.jsp">커뮤니티 메인</a></li>
                        <li><a class="dropdown-item" href="<%=root%>/?main=community/cumain.jsp">카테고리별 썰</a></li>
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
                        <span id="user-nickname">사용자</span>님
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

function removeToken() {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('userInfo'); // 사용자 정보도 함께 제거
    location.reload();
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
        const payload = JSON.parse(atob(token.split('.')[1]));
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

// 페이지 로드 시 인증 상태 확인
document.addEventListener('DOMContentLoaded', function() {
    // 저장된 사용자 정보가 있으면 즉시 UI 업데이트
    const savedUserInfo = localStorage.getItem('userInfo');
    if (savedUserInfo) {
        try {
            const userInfo = JSON.parse(savedUserInfo);
            console.log('저장된 사용자 정보로 즉시 UI 업데이트:', userInfo);
            updateTitleUIFromSavedInfo(userInfo);
        } catch (error) {
            console.error('저장된 사용자 정보 파싱 오류:', error);
        }
    }
    
    // 토큰 검증도 실행 (백그라운드)
    updateAuthUI();
});

// 저장된 사용자 정보로 즉시 UI 업데이트
function updateTitleUIFromSavedInfo(userInfo) {
    const loginSection = document.getElementById('login-section');
    const userSection = document.getElementById('user-section');
    const userNickname = document.getElementById('user-nickname');
    const adminMenu = document.getElementById('admin-menu');
    
    if (loginSection && userSection && userNickname) {
        loginSection.style.display = 'none';
        userSection.style.display = 'block';
        userNickname.textContent = userInfo.nickname || userInfo.userid;
        
        if (adminMenu) {
            adminMenu.style.display = (userInfo.provider === 'admin') ? 'block' : 'none';
        }
        
        console.log('즉시 UI 업데이트 완료:', userInfo.nickname);
    }
}

// 인증 UI 업데이트 (서버 검증 포함)
async function updateAuthUI() {
    console.log('updateAuthUI 시작');
    const token = getToken();
    const loginSection = document.getElementById('login-section');
    const userSection = document.getElementById('user-section');
    const userNickname = document.getElementById('user-nickname');
    const adminMenu = document.getElementById('admin-menu');
    
    console.log('토큰 확인:', token ? '토큰 있음' : '토큰 없음');
    console.log('UI 요소들:', { loginSection, userSection, userNickname, adminMenu });
    
    if (token) {
        try {
            console.log('서버 권한 검증 시작...');
            // 🛡️ 서버에서 권한 검증 (보안)
            const response = await fetch('<%=root%>/api/auth/check-admin', {
                headers: {
                    'Authorization': 'Bearer ' + token
                }
            });
            
            if (response.ok) {
                const data = await response.json();
                console.log('서버 응답 데이터:', data);
                
                // 로그인 상태 UI
                if (loginSection) loginSection.style.display = 'none';
                if (userSection) userSection.style.display = 'block';
                if (userNickname) userNickname.textContent = data.nickname || data.userid;
                
                console.log('로그인 UI 업데이트 완료:', data.nickname || data.userid);
                
                // 🔐 서버에서 검증된 관리자 권한만 표시
                if (data.isAdmin === true) {
                    if (adminMenu) adminMenu.style.display = 'block';
                    console.log('관리자 메뉴 활성화');
                } else {
                    if (adminMenu) adminMenu.style.display = 'none';
                    console.log('일반 사용자 - 관리자 메뉴 숨김');
                }
            } else {
                console.error('서버 응답 오류:', response.status);
                // 토큰이 유효하지 않음
                throw new Error('Invalid token');
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
            await fetch('<%=root%>/api/auth/logout', {
                method: 'POST',
                headers: {
                    'Authorization': 'Bearer ' + token
                }
            });
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
</script>
