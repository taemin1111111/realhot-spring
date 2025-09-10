<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
%>
<!-- 관리자 페이지 전용 CSS -->
<link rel="stylesheet" href="<%=root%>/css/admin.css">

<!-- 관리자 권한 확인 및 JWT 토큰 관리 -->
<script>
// JWT 토큰 관리 함수들
function getToken() {
    return localStorage.getItem('accessToken');
}

function removeToken() {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('userInfo');
    
    // 쿠키에서도 삭제
    document.cookie = 'accessToken=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    document.cookie = 'refreshToken=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    
    console.log('JWT 토큰을 localStorage와 쿠키에서 삭제 완료');
}

// 토큰 자동 갱신 함수
async function refreshAccessToken() {
    const refreshToken = localStorage.getItem('refreshToken');
    if (!refreshToken) {
        console.log('리프레시 토큰이 없습니다.');
        return false;
    }
    
    try {
        const response = await fetch('/hotplace/api/auth/refresh', {
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

// API 요청 시 JWT 토큰을 헤더에 포함하는 함수
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
            removeToken();
            return response;
        }
    }
    
    return response;
}

// 관리자 권한 확인
async function checkAdminPermission() {
    const token = getToken();
    if (!token) {
        console.log('JWT 토큰이 없습니다.');
        return false;
    }
    
    try {
        const response = await fetchWithAuth('/hotplace/api/auth/check-admin');
        if (response.ok) {
            const data = await response.json();
            return data.isAdmin === true;
        }
        return false;
    } catch (error) {
        console.error('관리자 권한 확인 오류:', error);
        return false;
    }
}

// 페이지 로드 시 권한 확인 및 초기화
async function initializeAdminPage() {
    console.log('관리자 페이지 초기화 시작...');
    
    const isAdmin = await checkAdminPermission();
    if (!isAdmin) {
        // 권한이 없으면 메인 페이지로 리다이렉트
        alert('관리자 권한이 필요합니다.');
        window.location.href = '/hotplace/';
        return;
    }
    
    // 권한이 있으면 페이지 초기화
    console.log('관리자 권한 확인됨');
    
    // 페이지별 초기화 함수 호출
    if (typeof initMdAdmin === 'function') {
        initMdAdmin();
    }
}

// 토큰 상태 확인 (운영 환경에서는 제거됨)

// 페이지 로드 시 자동 실행
document.addEventListener('DOMContentLoaded', initializeAdminPage);
</script>

<div class="container mt-4">
    <h2>MD 어드민 입니다</h2>
    <p>MD 관리 페이지입니다.</p>
</div>

<script>
// mdadmin 페이지 초기화 함수
function initMdAdmin() {
    console.log('mdadmin 페이지 초기화 시작');
    // MD 관리 페이지 초기화 로직
}
</script>
