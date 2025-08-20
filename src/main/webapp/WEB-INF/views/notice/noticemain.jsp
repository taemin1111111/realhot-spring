<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Spring REST API 방식으로 변환: Model1 DAO/DTO 제거 --%>

<%
    String root = request.getContextPath();
    String loginProvider = (String)session.getAttribute("provider");
%>

<!-- Notice 전용 CSS 로드 -->
<link rel="stylesheet" href="<%=root%>/css/notice.css">

<div class="notice-container" id="notice-container">
    <!-- 공지사항 목록은 REST API를 통해 동적으로 로드됩니다 -->
    <div class="loading">공지사항을 불러오는 중...</div>
</div>

<script>
// URL에서 페이지 번호 가져오기
const urlParams = new URLSearchParams(window.location.search);
let currentPage = parseInt(urlParams.get('page')) || 1;
const pageSize = 10;

// 페이지 로드 시 공지사항 목록 로드
document.addEventListener('DOMContentLoaded', function() {
    loadNoticeList(currentPage);
});

// REST API를 통한 공지사항 목록 로드
function loadNoticeList(page = 1) {
    const url = '<%=root%>/api/notices?page=' + page + '&size=' + pageSize;
    
    fetch(url, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('공지사항을 불러올 수 없습니다.');
        }
        return response.json();
    })
    .then(data => {
        renderNoticeList(data.notices || [], data.totalCount || 0, data.currentPage || 1, data.totalPages || 1);
    })
    .catch(error => {
        console.error('공지사항 로드 오류:', error);
        document.getElementById('notice-container').innerHTML = 
            '<div class="error">공지사항을 불러올 수 없습니다.</div>';
    });
}

// 공지사항 목록 렌더링
function renderNoticeList(notices, totalCount, currentPage, totalPages) {
    const isAdmin = <%= "admin".equals(loginProvider) %>;
    
    let html = `
        <div class="notice-header">
            <div class="d-flex justify-content-between align-items-center">
                <h3>📢 공지사항</h3>
                ${isAdmin ? '<a class="btn btn-primary" href="<%=root%>/index.jsp?main=notice/noticeinset.jsp">✏️ 공지 등록</a>' : ''}
            </div>
        </div>`;
    
    if (!notices || notices.length === 0) {
        html += `
            <div class="notice-empty">
                <div class="empty-icon">📝</div>
                <h4>등록된 공지사항이 없습니다</h4>
                <p>새로운 공지사항을 등록해보세요.</p>
            </div>`;
    } else {
        html += '<div class="notice-list">';
        
        notices.forEach(notice => {
            const formattedDate = formatDate(notice.createdAt);
            const isPinned = notice.isPinned || notice.pinned;
            
            html += `
                <div class="notice-item ${isPinned ? 'pinned' : ''}">
                    <a href="<%=root%>/index.jsp?main=notice/noticeDetail.jsp&id=${notice.id || notice.noticeId}" class="notice-content">
                        <div class="notice-title">
                            ${isPinned ? '<span class="pinned-badge">📌 고정</span>' : ''}
                            ${notice.title || '제목 없음'}
                        </div>
                        <div class="notice-meta">
                            <span>👤 ${notice.writer || notice.authorId || '관리자'}</span>
                            <span>👁️ ${notice.viewCount || 0}</span>
                            <span>📅 ${formattedDate}</span>
                        </div>
                    </a>`;
            
            if (isAdmin) {
                html += `
                    <div class="notice-actions">
                        <button class="btn btn-outline-secondary" onclick="togglePin(${notice.id || notice.noticeId}, ${!isPinned})">
                            ${isPinned ? '📌 고정해제' : '📌 고정하기'}
                        </button>
                        <button class="btn btn-outline-danger" onclick="deleteNotice(${notice.id || notice.noticeId})">
                            🗑️ 삭제
                        </button>
                    </div>`;
            }
            
            html += '</div>';
        });
        
        html += '</div>';
        
        // 페이징 추가
        if (totalPages > 1) {
            html += renderPagination(currentPage, totalPages);
        }
    }
    
    document.getElementById('notice-container').innerHTML = html;
}

// 페이징 렌더링
function renderPagination(currentPage, totalPages) {
    let html = `
        <div class="notice-pagination">
            <nav>
                <ul class="pagination">
                    <li class="page-item ${currentPage === 1 ? 'disabled' : ''}">
                        <a class="page-link" href="#" onclick="changePage(${currentPage - 1}); return false;">◀ 이전</a>
                    </li>`;
    
    for (let p = 1; p <= totalPages; p++) {
        html += `
            <li class="page-item ${p === currentPage ? 'active' : ''}">
                <a class="page-link" href="#" onclick="changePage(${p}); return false;">${p}</a>
            </li>`;
    }
    
    html += `
                    <li class="page-item ${currentPage === totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="#" onclick="changePage(${currentPage + 1}); return false;">다음 ▶</a>
                    </li>
                </ul>
            </nav>
        </div>`;
    
    return html;
}

// 페이지 변경
function changePage(page) {
    if (page < 1 || page > totalPages) return;
    
    currentPage = page;
    
    // URL 업데이트
    const newUrl = new URL(window.location);
    newUrl.searchParams.set('page', page);
    window.history.pushState({}, '', newUrl);
    
    loadNoticeList(page);
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
            loadNoticeList(currentPage); // 목록 새로고침
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
            loadNoticeList(currentPage); // 목록 새로고침
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

// Bootstrap 스타일 클래스 추가
const style = document.createElement('style');
style.textContent = `
    .d-flex {
        display: flex;
    }
    
    .justify-content-between {
        justify-content: space-between;
    }
    
    .align-items-center {
        align-items: center;
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
`;
document.head.appendChild(style);
</script>