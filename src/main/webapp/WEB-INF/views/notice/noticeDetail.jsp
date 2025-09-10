<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
    Long noticeId = (Long) request.getAttribute("noticeId");
    if (noticeId == null) {
        // URL에서 noticeId 추출
        String requestURI = request.getRequestURI();
        String[] pathParts = requestURI.split("/");
        if (pathParts.length > 0) {
            try {
                noticeId = Long.parseLong(pathParts[pathParts.length - 1]);
            } catch (NumberFormatException e) {
                noticeId = null;
            }
        }
    }
%>

<link rel="stylesheet" href="<%=root%>/css/notice.css">

<div class="notice-detail-page">

    <!-- 메인 콘텐츠 래퍼 -->
    <div class="notice-detail-content-wrapper">
        <div class="main-container">
            <div class="container">
                <!-- 뒤로가기 버튼 -->
                <div class="back-button" style="margin-bottom: 20px;">
                    <a href="<%=root%>/notice" style="color: #666; text-decoration: none; display: inline-flex; align-items: center; gap: 8px;">
                        <i class="bi bi-arrow-left"></i> 목록으로 돌아가기
                    </a>
                </div>
                
                <!-- 공지사항 상세 정보 -->
                <div id="notice-detail-content">
                    <div class="text-center" style="color: #666666; padding: 40px;">
                        <i class="bi bi-hourglass-split" style="font-size: 3rem; margin-bottom: 20px; color: #dee2e6;"></i>
                        <p>공지사항을 불러오는 중...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// 전역 변수
var rootPath = '<%=root%>';
var noticeId = '<%=noticeId != null ? noticeId : ""%>';
if (noticeId === '') noticeId = null;
else noticeId = parseInt(noticeId);

// 별 생성 함수 제거 (흰색 배경 사용)

// 날짜 포맷팅 함수
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('ko-KR', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
    });
}

// 공지사항 상세 정보 로드
function loadNoticeDetail() {
    if (!noticeId) {
        document.getElementById('notice-detail-content').innerHTML = '<div class="text-center" style="color: #fff; padding: 40px;"><i class="bi bi-exclamation-triangle" style="font-size: 3rem; margin-bottom: 20px;"></i><p>잘못된 공지사항 ID입니다.</p></div>';
        return;
    }
    
    const apiUrl = rootPath + '/notice/api/detail/' + noticeId;
    console.log('API 호출:', apiUrl);
    
    fetch(apiUrl)
    .then(response => {
        console.log('API 응답 상태:', response.status);
        return response.json();
    })
    .then(data => {
        console.log('API 응답 데이터:', data);
        const detailContent = document.getElementById('notice-detail-content');
        
        if (data.success && data.notice) {
            const notice = data.notice;
            const isPinned = notice.isPinned ? '<span class="pinned-badge"><i class="bi bi-pin-angle-fill"></i> 고정</span>' : '';
            // 이미지 경로 수정 (기존 경로와 새 경로 모두 처리)
            let imageUrl = notice.photoUrl;
            if (imageUrl && imageUrl.startsWith('/uploads/')) {
                imageUrl = rootPath + imageUrl;
            } else if (imageUrl && !imageUrl.startsWith('http') && !imageUrl.startsWith('/hotplace/')) {
                imageUrl = rootPath + '/uploads/noticesave/' + imageUrl.split('/').pop();
            }
            
            const photoHtml = notice.photoUrl ? 
                '<div class="notice-detail-photo"><img src="' + imageUrl + '" alt="공지사항 이미지"></div>' : '';
            
            let html = '<div class="notice-detail-item">';
            
            // 제목과 고정 배지
            html += '<div class="notice-detail-header">';
            html += '  <h1 class="notice-detail-title">' + notice.title + '</h1>';
            html += '  <div class="notice-detail-header-right">';
            html += '    ' + isPinned;
            html += '    <div id="admin-buttons" class="admin-buttons" style="display: none;">';
            html += '      <button type="button" class="btn btn-warning btn-sm" onclick="togglePinned(' + notice.noticeId + ', ' + !notice.isPinned + ')">';
            html += '        <i class="bi ' + (notice.isPinned ? 'bi-pin-angle' : 'bi-pin-angle-fill') + '"></i> ' + (notice.isPinned ? '고정 취소' : '고정');
            html += '      </button>';
            html += '      <button type="button" class="btn btn-danger btn-sm" onclick="deleteNotice(' + notice.noticeId + ')">';
            html += '        <i class="bi bi-trash"></i> 삭제';
            html += '      </button>';
            html += '    </div>';
            html += '  </div>';
            html += '</div>';
            
            // 작성자, 날짜, 조회수
            html += '<div class="notice-detail-meta">';
            html += '  <span class="notice-detail-writer"><i class="bi bi-person"></i> ' + notice.writerUserid + '</span>';
            html += '  <span class="notice-detail-date"><i class="bi bi-calendar"></i> ' + formatDate(notice.createdAt) + '</span>';
            html += '  <span class="notice-detail-views"><i class="bi bi-eye"></i> ' + notice.viewCount + '</span>';
            html += '</div>';
            
            // 사진
            html += photoHtml;
            
            // 내용
            html += '<div class="notice-detail-content">' + notice.content + '</div>';
            
            html += '</div>';
            
            detailContent.innerHTML = html;
            
            // 관리자 권한 확인 후 버튼 표시
            checkAdminPermission();
        } else {
            detailContent.innerHTML = '<div class="text-center" style="color: #666666; padding: 40px;"><i class="bi bi-exclamation-triangle" style="font-size: 3rem; margin-bottom: 20px; color: #dee2e6;"></i><p>공지사항을 찾을 수 없습니다.</p></div>';
        }
    })
    .catch(error => {
        console.error('공지사항 상세 로드 실패:', error);
        document.getElementById('notice-detail-content').innerHTML = '<div class="text-center" style="color: #666666; padding: 40px;"><i class="bi bi-exclamation-triangle" style="font-size: 3rem; margin-bottom: 20px; color: #dee2e6;"></i><p>공지사항을 불러오는 중 오류가 발생했습니다.</p></div>';
    });
}

// 관리자 권한 확인
function checkAdminPermission() {
    const token = localStorage.getItem('accessToken');
    if (!token) {
        console.log('토큰이 없음 - 관리자 버튼 숨김');
        return;
    }
    
    try {
        // JWT 토큰 파싱
        const payload = JSON.parse(atob(token.split('.')[1]));
        console.log('JWT 토큰 payload:', payload);
        
        // 관리자 권한 확인 (provider가 'admin'인 경우만)
        const isAdmin = payload.provider === 'admin';
        
        if (isAdmin) {
            console.log('관리자 권한 확인됨');
            const adminButtons = document.getElementById('admin-buttons');
            if (adminButtons) {
                adminButtons.style.display = 'block';
            }
        } else {
            console.log('일반 사용자 - 관리자 버튼 숨김');
        }
    } catch (error) {
        console.error('JWT 토큰 파싱 실패:', error);
    }
}

// 공지사항 고정/고정취소
function togglePinned(noticeId, isPinned) {
    const token = localStorage.getItem('accessToken');
    if (!token) {
        alert('로그인이 필요합니다.');
        return;
    }
    
    const confirmMessage = isPinned ? '이 공지사항을 고정하시겠습니까?' : '이 공지사항의 고정을 취소하시겠습니까?';
    if (!confirm(confirmMessage)) {
        return;
    }
    
    const apiUrl = rootPath + '/notice/api/toggle-pinned/' + noticeId;
    
    fetch(apiUrl, {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + token,
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: 'isPinned=' + isPinned
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert(data.message);
            // 페이지 새로고침
            loadNoticeDetail();
        } else {
            alert(data.message || '처리에 실패했습니다.');
        }
    })
    .catch(error => {
        console.error('고정/고정취소 실패:', error);
        alert('처리 중 오류가 발생했습니다.');
    });
}

// 공지사항 삭제
function deleteNotice(noticeId) {
    const token = localStorage.getItem('accessToken');
    if (!token) {
        alert('로그인이 필요합니다.');
        return;
    }
    
    if (!confirm('정말로 이 공지사항을 삭제하시겠습니까?\n삭제된 공지사항은 복구할 수 없습니다.')) {
        return;
    }
    
    const apiUrl = rootPath + '/notice/api/delete/' + noticeId;
    
    fetch(apiUrl, {
        method: 'DELETE',
        headers: {
            'Authorization': 'Bearer ' + token
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert(data.message);
            // 공지사항 목록으로 이동
            window.location.href = rootPath + '/notice';
        } else {
            alert(data.message || '삭제에 실패했습니다.');
        }
    })
    .catch(error => {
        console.error('삭제 실패:', error);
        alert('삭제 중 오류가 발생했습니다.');
    });
}

// 페이지 로드 시 실행
document.addEventListener('DOMContentLoaded', function() {
    console.log('noticedetail.jsp 로드됨, noticeId:', noticeId);
    document.body.classList.add('notice-detail-page');
    loadNoticeDetail();
});
</script>

<style>
/* 공지사항 상세 페이지 전용 스타일 */

/* 뒤로가기 버튼 */
.back-button {
    margin: 20px auto 30px auto;
    max-width: 800px;
    padding: 0 50px;
    text-align: left;
    width: 100%;
    box-sizing: border-box;
    position: relative;
}

.back-button a {
    color: #666666;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    transition: all 0.3s ease;
}

.back-button a:hover {
    color: #007bff;
    transform: translateX(-5px);
}

/* 공지사항 상세 아이템 */
.notice-detail-item {
    background: transparent;
    padding: 40px 50px 0 50px;
    margin: 0;
    max-width: 800px;
    margin: 0 auto;
    border: 1px solid #000000;
    border-radius: 8px;
}

/* 공지사항 상세 헤더 */
.notice-detail-header {
    margin-bottom: 30px;
    padding-bottom: 20px;
    border-bottom: 1px solid #e9ecef;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 20px;
}

/* 공지사항 헤더 오른쪽 영역 */
.notice-detail-header-right {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 10px;
}

/* 관리자 버튼들 */
.admin-buttons {
    display: flex;
    gap: 8px;
    margin-top: 10px;
}

.admin-buttons .btn {
    font-size: 0.875rem;
    padding: 0.375rem 0.75rem;
    border-radius: 6px;
    font-weight: 500;
    transition: all 0.3s ease;
}

.admin-buttons .btn-warning {
    background-color: #ffc107;
    border-color: #ffc107;
    color: #000;
}

.admin-buttons .btn-warning:hover {
    background-color: #e0a800;
    border-color: #d39e00;
    color: #000;
    transform: translateY(-1px);
}

.admin-buttons .btn-danger {
    background-color: #dc3545;
    border-color: #dc3545;
    color: #fff;
}

.admin-buttons .btn-danger:hover {
    background-color: #c82333;
    border-color: #bd2130;
    color: #fff;
    transform: translateY(-1px);
}

/* 공지사항 상세 제목 */
.notice-detail-title {
    color: #000000;
    font-size: 2.5rem;
    margin: 0;
    font-weight: bold;
    flex: 1;
    line-height: 1.3;
}

/* 공지사항 상세 메타 정보 */
.notice-detail-meta {
    margin-bottom: 30px;
    padding: 0;
    background: transparent;
    display: flex;
    gap: 30px;
    font-size: 14px;
    color: #666666;
}

.notice-detail-writer,
.notice-detail-date,
.notice-detail-views {
    display: flex;
    align-items: center;
    gap: 6px;
}

/* 공지사항 상세 사진 */
.notice-detail-photo {
    margin: 50px 0 50px 0;
    text-align: center;
}

.notice-detail-photo img {
    max-width: 100%;
    max-height: 500px;
}

/* 공지사항 상세 내용 */
.notice-detail-content {
    color: #000000;
    line-height: 1.8;
    font-size: 1.2rem;
    white-space: pre-wrap;
    margin-top: 30px;
    text-align: center;
    padding-bottom: 120px;
}

/* 고정 배지 (상세 페이지용) */
.notice-detail-header .pinned-badge {
    background: transparent;
    color: #007bff;
    padding: 0;
    font-size: 14px;
    font-weight: 500;
    margin: 0;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    flex-shrink: 0;
}

/* 반응형 디자인 */
@media (max-width: 768px) {
    .back-button {
        margin: 20px auto 30px auto;
        padding: 0 40px;
        max-width: 800px;
        width: 100%;
        box-sizing: border-box;
    }
    
    .notice-detail-item {
        padding: 40px 40px 0 40px;
        border: 1px solid #000000;
        border-radius: 8px;
    }
    
    .notice-detail-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 15px;
    }
    
    .notice-detail-header-right {
        align-items: flex-start;
        width: 100%;
    }
    
    .admin-buttons {
        flex-wrap: wrap;
        gap: 6px;
    }
    
    .admin-buttons .btn {
        font-size: 0.8rem;
        padding: 0.3rem 0.6rem;
    }
    
    .notice-detail-title {
        font-size: 2rem;
    }
    
    .notice-detail-meta {
        flex-direction: column;
        gap: 15px;
    }
    
    .notice-detail-photo {
        margin: 40px 0 40px 0;
    }
    
    .notice-detail-content {
        font-size: 1.1rem;
        text-align: center;
        padding-bottom: 100px;
    }
}

@media (max-width: 480px) {
    .back-button {
        margin: 20px auto 30px auto;
        padding: 0 20px;
        max-width: 800px;
        width: 100%;
        box-sizing: border-box;
    }
    
    .notice-detail-item {
        padding: 40px 20px 0 20px;
        border: 1px solid #000000;
        border-radius: 8px;
    }
    
    .notice-detail-title {
        font-size: 1.8rem;
    }
    
    .notice-detail-photo {
        margin: 30px 0 30px 0;
    }
    
    .notice-detail-content {
        text-align: center;
        padding-bottom: 80px;
    }
}
</style>