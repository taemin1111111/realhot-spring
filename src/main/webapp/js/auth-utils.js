/**
 * =================================================================================
 * 인증 관련 유틸리티 함수 (auth-utils.js)
 * =================================================================================
 * 이 파일은 JWT 토큰 관리 및 인증 관련 UI 업데이트를 위한 모든 JavaScript 함수를 포함합니다.
 * 모든 JSP 파일에서 이 파일을 공통으로 사용하여 코드 중복을 방지하고 유지보수성을 높입니다.
 * 
 * 주요 기능:
 * - JWT 토큰 (Access, Refresh) 저장 및 삭제 (localStorage, Cookie)
 * - 토큰 존재 여부에 따른 UI 동적 업데이트
 * - 관리자 페이지 접근 처리
 * - 토큰 자동 갱신
 * =================================================================================
 */

// 전역 변수로 root context path 설정 (모든 JSP에서 설정 필요)
// root 변수는 각 JSP에서 선언된 것을 사용

/**
 * JWT 토큰을 localStorage에만 저장 (쿠키는 서버에서 설정)
 * @param {string} token - Access Token
 * @param {string} refreshToken - Refresh Token
 */
function saveToken(token, refreshToken) {
    console.log('[Auth] saveToken 실행: localStorage에 토큰 저장');
    localStorage.setItem('accessToken', token);
    if (refreshToken) {
        localStorage.setItem('refreshToken', refreshToken);
    }
    console.log('[Auth] localStorage 저장 완료.');
}

/**
 * 저장된 모든 토큰 및 사용자 정보 삭제 (쿠키는 서버에서 삭제)
 */
function removeToken() {
    console.log('[Auth] removeToken 실행: localStorage 정보 삭제');
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('userInfo');
    
    // 쿠키는 HttpOnly이므로 클라이언트에서 직접 삭제 불가.
    // 서버에 로그아웃 요청을 보내서 서버가 쿠키를 삭제하도록 해야 함.
    console.log('[Auth] localStorage 정보 삭제 완료.');
}

/**
 * localStorage에서 Access Token 가져오기
 * @returns {string|null} Access Token
 */
function getToken() {
    return localStorage.getItem('accessToken');
}

/**
 * 관리자 페이지로 이동
 * @param {string} path - 이동할 관리자 페이지 경로 (e.g., '/admin/hpost')
 */
function goToAdminPage(path) {
    console.log('[Auth] 관리자 페이지로 이동:', path);
    // 쿠키는 브라우저가 자동으로 요청에 포함하므로, 바로 페이지 이동
    window.location.href = root + path;
}
