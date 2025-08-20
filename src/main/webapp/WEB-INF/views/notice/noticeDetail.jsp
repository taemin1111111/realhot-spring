<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Spring REST API 방식으로 변환: Model1 DAO/DTO 제거 --%>

<%
    String root = request.getContextPath();
    String noticeId = request.getParameter("id");
    
    if (noticeId == null || noticeId.trim().isEmpty()) {
        response.sendRedirect(root + "/index.jsp?main=notice/noticemain.jsp");
        return;
    }
%>

<div class="notice-detail-container" id="notice-detail-container">
    <!-- 공지사항 상세정보는 REST API를 통해 동적으로 로드됩니다 -->
    <div class="loading">공지사항을 불러오는 중...</div>
</div>

<script>
// URL에서 공지사항 ID 가져오기
const noticeId = '<%=noticeId%>';

// 페이지 로드 시 공지사항 상세정보 로드
document.addEventListener('DOMContentLoaded', function() {
    if (noticeId && noticeId !== 'null') {
        loadNoticeDetail(noticeId);
    } else {
        window.location.href = '<%=root%>/index.jsp?main=notice/noticemain.jsp';
    }
});

// REST API를 통한 공지사항 상세정보 로드
function loadNoticeDetail(id) {
    const url = '<%=root%>/api/notices/' + id;
    
    fetch(url, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('공지사항을 찾을 수 없습니다.');
        }
        return response.json();
    })
    .then(notice => {
        renderNoticeDetail(notice);
    })
    .catch(error => {
        console.error('공지사항 로드 오류:', error);
        document.getElementById('notice-detail-container').innerHTML = 
            '<div class="error">공지사항을 불러올 수 없습니다. <a href="<%=root%>/index.jsp?main=notice/noticemain.jsp">목록으로 돌아가기</a></div>';
    });
}

// 공지사항 상세정보 렌더링
function renderNoticeDetail(notice) {
    const formattedDate = formatDate(notice.createdAt);
    const isAdmin = checkAdminAuth(); // 관리자 권한 체크
    
    let html = `
        <div class="notice-detail-header">
            <div class="card-header">
                <div class="d-flex justify-content-between align-items-center">
                    <h5 class="notice-detail-title">
                        ${notice.isPinned ? '<span class="pinned-badge me-2">📌 고정</span>' : ''}
                        ${notice.title || '제목 없음'}
                    </h5>
                    <small>📅 ${formattedDate}</small>
                </div>
                <div class="notice-detail-meta">
                    <span>👤 작성자: ${notice.writer || notice.authorId || '관리자'}</span>
                    <span>👁️ 조회수: ${notice.viewCount || 0}</span>
                </div>
            </div>
            
            <div class="notice-detail-body">`;
    
    // 첨부 이미지가 있는 경우
    if (notice.photo && notice.photo.trim().length > 0) {
        html += `
                <div class="notice-detail-image">
                    <img src="<%=root%>/noticephoto/${notice.photo}" 
                         alt="첨부 이미지" class="img-fluid notice-image">
                </div>`;
    }
    
    // 공지사항 내용
    html += `
                <div class="notice-detail-content">
                    ${notice.content ? notice.content.replace(/\n/g, '<br>') : '내용이 없습니다.'}
                </div>
                
                <div class="notice-detail-actions">
                    <a href="<%=root%>/index.jsp?main=notice/noticemain.jsp" class="btn btn-outline-secondary">
                        📋 목록으로
                    </a>`;
    
    // 관리자인 경우 삭제 버튼 추가
    if (isAdmin) {
        html += `
                    <button onclick="deleteNotice(${notice.id || notice.noticeId})" class="btn btn-outline-danger">
                        🗑️ 삭제
                    </button>
                    <button onclick="togglePin(${notice.id || notice.noticeId}, ${!notice.isPinned})" class="btn btn-outline-warning">
                        ${notice.isPinned ? '📌 고정해제' : '📌 고정하기'}
                    </button>`;
    }
    
    html += `
                </div>
            </div>
        </div>`;
    
    document.getElementById('notice-detail-container').innerHTML = html;
}

// 공지사항 삭제
function deleteNotice(noticeId) {
    if (!confirm('정말로 이 공지사항을 삭제하시겠습니까?')) {
        return;
    }
    
    const url = '<%=root%>/api/notices/' + noticeId;
    
    fetch(url, {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => {
        if (response.ok) {
            alert('공지사항이 삭제되었습니다.');
            window.location.href = '<%=root%>/index.jsp?main=notice/noticemain.jsp';
        } else if (response.status === 403) {
            alert('삭제 권한이 없습니다.');
        } else if (response.status === 404) {
            alert('공지사항을 찾을 수 없습니다.');
        } else {
            throw new Error('삭제 실패');
        }
    })
    .catch(error => {
        console.error('삭제 오류:', error);
        alert('공지사항 삭제 중 오류가 발생했습니다.');
    });
}

// 고정 상태 토글
function togglePin(noticeId, isPinned) {
    const url = '<%=root%>/api/notices/' + noticeId + '/pin?isPinned=' + isPinned;
    
    fetch(url, {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => {
        if (response.ok) {
            alert(isPinned ? '공지사항이 고정되었습니다.' : '공지사항 고정이 해제되었습니다.');
            loadNoticeDetail(noticeId); // 새로고침
        } else if (response.status === 403) {
            alert('고정 설정 권한이 없습니다.');
        } else {
            throw new Error('고정 설정 실패');
        }
    })
    .catch(error => {
        console.error('고정 설정 오류:', error);
        alert('고정 설정 중 오류가 발생했습니다.');
    });
}

// 관리자 권한 체크 (세션 기반)
function checkAdminAuth() {
    // 서버 세션에서 관리자 권한 확인
    // 실제로는 JWT 토큰이나 세션을 통해 확인해야 함
    return <%= session.getAttribute("provider") != null && "admin".equals(session.getAttribute("provider")) %>;
}

// 날짜 포맷팅
function formatDate(dateString) {
    if (!dateString) return '';
    
    const date = new Date(dateString);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hour = String(date.getHours()).padStart(2, '0');
    const minute = String(date.getMinutes()).padStart(2, '0');
    
    return `${year}-${month}-${day} ${hour}:${minute}`;
}

// CSS 추가
const style = document.createElement('style');
style.textContent = `
    .notice-detail-container {
        max-width: 900px;
        margin: 0 auto;
        padding: 20px;
    }
    
    .notice-detail-header {
        background: white;
        border-radius: 15px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        overflow: hidden;
    }
    
    .card-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 25px;
    }
    
    .notice-detail-title {
        font-size: 1.5rem;
        font-weight: bold;
        margin: 0;
        line-height: 1.4;
    }
    
    .pinned-badge {
        background: rgba(255,255,255,0.2);
        color: white;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 0.9rem;
        font-weight: 500;
    }
    
    .notice-detail-meta {
        margin-top: 15px;
        display: flex;
        gap: 20px;
        font-size: 0.95rem;
        opacity: 0.9;
    }
    
    .notice-detail-body {
        padding: 30px;
    }
    
    .notice-detail-image {
        text-align: center;
        margin-bottom: 25px;
    }
    
    .notice-image {
        max-width: 100%;
        height: auto;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    
    .notice-detail-content {
        font-size: 1.1rem;
        line-height: 1.8;
        color: #2c3e50;
        margin-bottom: 30px;
        min-height: 200px;
        padding: 20px;
        background: #f8f9fa;
        border-radius: 10px;
        border-left: 4px solid #667eea;
    }
    
    .notice-detail-actions {
        display: flex;
        gap: 15px;
        flex-wrap: wrap;
        justify-content: center;
        padding-top: 20px;
        border-top: 1px solid #dee2e6;
    }
    
    .notice-detail-actions .btn {
        padding: 10px 20px;
        font-weight: 500;
        border-radius: 25px;
        transition: all 0.3s ease;
    }
    
    .notice-detail-actions .btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.15);
    }
    
    .loading, .error {
        text-align: center;
        padding: 60px 20px;
        color: #6c757d;
    }
    
    .error {
        color: #dc3545;
        background: #f8d7da;
        border: 1px solid #f5c6cb;
        border-radius: 10px;
    }
    
    .error a {
        color: #721c24;
        text-decoration: underline;
    }
    
    @media (max-width: 768px) {
        .notice-detail-container {
            padding: 10px;
        }
        
        .card-header {
            padding: 20px;
        }
        
        .notice-detail-title {
            font-size: 1.3rem;
        }
        
        .notice-detail-meta {
            flex-direction: column;
            gap: 10px;
        }
        
        .notice-detail-body {
            padding: 20px;
        }
        
        .notice-detail-content {
            font-size: 1rem;
            padding: 15px;
        }
        
        .notice-detail-actions {
            flex-direction: column;
            align-items: center;
        }
        
        .notice-detail-actions .btn {
            min-width: 200px;
        }
    }
`;
document.head.appendChild(style);
</script>