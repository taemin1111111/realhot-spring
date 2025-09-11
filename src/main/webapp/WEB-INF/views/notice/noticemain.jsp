<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
%>

<link rel="stylesheet" href="<%=root%>/css/notice.css">

<div class="notice-page">
    <!-- 메인 콘텐츠 래퍼 -->
    <div class="notice-content-wrapper">
        <div class="main-container">
            <div class="container">
                <div class="notice-title">
                    <h2>
                        <i class="bi bi-megaphone"></i>
                        공지사항
                    </h2>
                </div>
                
                <!-- 관리자만 보이는 공지사항 작성 버튼 -->
                <div id="admin-notice-write" style="display: none; text-align: right; margin-bottom: 20px;">
                    <button class="btn btn-primary" onclick="openNoticeWriteModal()">
                        <i class="bi bi-plus-circle"></i> 공지사항 작성
                    </button>
                </div>
                
                <!-- 공지사항 목록 -->
                <div id="notice-list">
                    <div class="text-center" style="color: #666666; padding: 40px;">
                        <i class="bi bi-hourglass-split" style="font-size: 3rem; margin-bottom: 20px; color: #dee2e6;"></i>
                        <p>공지사항을 불러오는 중...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- 공지사항 작성 모달 -->
    <div id="notice-write-modal" class="modal-overlay" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="bi bi-pencil-square"></i> 공지사항 작성</h3>
                <button class="modal-close" onclick="closeNoticeWriteModal()">&times;</button>
            </div>
            <div class="modal-body">
                <form id="notice-write-form" enctype="multipart/form-data">
                    <div class="form-group">
                        <label for="notice-title">제목</label>
                        <input type="text" id="notice-title" name="title" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label for="notice-content">내용</label>
                        <textarea id="notice-content" name="content" class="form-control" rows="5" required></textarea>
                    </div>
                    <div class="form-group">
                        <label for="notice-photo">사진 (선택사항)</label>
                        <input type="file" id="notice-photo" name="photo" class="form-control" accept="image/*">
                    </div>
                    <div class="form-group">
                        <div class="form-check">
                            <input type="checkbox" id="notice-pinned" name="isPinned" class="form-check-input">
                            <label for="notice-pinned" class="form-check-label">상단 고정</label>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeNoticeWriteModal()">취소</button>
                <button type="button" class="btn btn-primary" onclick="submitNotice()">작성하기</button>
            </div>
        </div>
    </div>
</div>

<script>
// 전역 변수
var isAdmin = false;
var rootPath = '<%=root%>';

// 관리자 권한 확인
function checkAdminPermission() {
    const token = localStorage.getItem('accessToken');
    if (!token) {
        document.getElementById('admin-notice-write').style.display = 'none';
        return;
    }
    
    // JWT 토큰에서 직접 관리자 권한 확인
    try {
        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        
        const payload = JSON.parse(jsonPayload);
        
        // provider가 'admin'인 경우만 관리자로 판단
        if (payload.provider === 'admin') {
            isAdmin = true;
            document.getElementById('admin-notice-write').style.display = 'block';
        } else {
            document.getElementById('admin-notice-write').style.display = 'none';
            // 일반 사용자로 확인됨
        }
    } catch (error) {
        // JWT 토큰 파싱 오류
        document.getElementById('admin-notice-write').style.display = 'none';
    }
}

// 공지사항 목록 로드
function loadNoticeList() {
    fetch(rootPath + '/notice/api/list')
    .then(response => response.json())
    .then(data => {
        const noticeList = document.getElementById('notice-list');
        
        if (data.success && data.notices && data.notices.length > 0) {
            let html = '<div class="notice-count" style="color: #000000; margin-bottom: 20px; font-size: 1.1rem; font-weight: bold;">';
            html += '<i class="bi bi-list-ul"></i> 총 ' + data.notices.length + '개의 공지사항';
            html += '</div>';
            
            // 테이블 헤더
            html += '<div class="notice-header">';
            html += '  <div class="row">';
            html += '    <div class="col-1">번호</div>';
            html += '    <div class="col-6">제목</div>';
            html += '    <div class="col-2">작성자</div>';
            html += '    <div class="col-2">작성일</div>';
            html += '    <div class="col-1">조회</div>';
            html += '  </div>';
            html += '</div>';
            html += '<hr class="notice-divider">';
            
            // 공지사항 목록
            html += '<div class="notice-content">';
            data.notices.forEach((notice, index) => {
                const isPinned = notice.isPinned ? '<span class="pinned-badge"><i class="bi bi-pin-angle-fill"></i> 고정</span>' : '';
                const titleWithPin = notice.title + (isPinned ? ' ' + isPinned : '');
                const pinnedClass = notice.isPinned ? ' pinned' : '';
                
                html += '<div class="notice-item' + pinnedClass + '" onclick="window.location.href=\'' + rootPath + '/notice/detail/' + notice.noticeId + '\'" style="cursor: pointer;">';
                html += '  <div class="row">';
                html += '    <div class="col-1">' + (index + 1) + '</div>';
                html += '    <div class="col-6">' + titleWithPin + '</div>';
                html += '    <div class="col-2">' + notice.writerUserid + '</div>';
                html += '    <div class="col-2 notice-date">' + formatDate(notice.createdAt) + '</div>';
                html += '    <div class="col-1">' + notice.viewCount + '</div>';
                html += '  </div>';
                html += '</div>';
            });
            html += '</div>';
            
            noticeList.innerHTML = html;
        } else {
            noticeList.innerHTML = '<div class="text-center" style="color: #666666; padding: 40px;"><i class="bi bi-inbox" style="font-size: 3rem; margin-bottom: 20px; color: #dee2e6;"></i><p>아직 공지사항이 없습니다!</p></div>';
        }
    })
    .catch(error => {
        console.error('공지사항 로드 실패:', error);
        document.getElementById('notice-list').innerHTML = '<div class="text-center" style="color: #666666; padding: 40px;"><i class="bi bi-exclamation-triangle" style="font-size: 3rem; margin-bottom: 20px; color: #dee2e6;"></i><p>공지사항을 불러오는데 실패했습니다.</p></div>';
    });
}

// 날짜 포맷팅
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

// 모달 열기
function openNoticeWriteModal() {
    const modal = document.getElementById('notice-write-modal');
    modal.style.display = 'block';
    document.body.style.overflow = 'hidden';
    
    // 폼 초기화
    document.getElementById('notice-write-form').reset();
    document.getElementById('notice-pinned').checked = false;
}

// 모달 닫기
function closeNoticeWriteModal() {
    const modal = document.getElementById('notice-write-modal');
    modal.style.display = 'none';
    document.body.style.overflow = 'auto';
}

// 공지사항 작성
function submitNotice() {
    const form = document.getElementById('notice-write-form');
    const formData = new FormData(form);
    
    // isPinned 값을 명시적으로 설정
    const isPinned = document.getElementById('notice-pinned').checked;
    formData.set('isPinned', isPinned ? 'true' : 'false');
    
    // FormData 내용 확인
    console.log('FormData entries:');
    for (let [key, value] of formData.entries()) {
        console.log(key + ':', value);
    }
    
    const submitBtn = document.querySelector('#notice-write-modal .btn-primary');
    submitBtn.disabled = true;
    submitBtn.textContent = '작성 중...';
    
    // fetchWithAuth 대신 직접 fetch 사용 (multipart/form-data용)
    const token = localStorage.getItem('accessToken');
    fetch(rootPath + '/notice/api/create', {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + token
        },
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('공지사항이 성공적으로 작성되었습니다.');
            closeNoticeWriteModal();
            loadNoticeList(); // 목록 새로고침
        } else {
            alert('공지사항 작성에 실패했습니다: ' + (data.message || '알 수 없는 오류'));
        }
    })
    .catch(error => {
        console.error('공지사항 작성 실패:', error);
        alert('공지사항 작성 중 오류가 발생했습니다.');
    })
    .finally(() => {
        submitBtn.disabled = false;
        submitBtn.textContent = '작성하기';
    });
}

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    // body에 클래스 추가
    document.body.classList.add('notice-page');
    
    // 관리자 권한 확인
    checkAdminPermission();
    
    // 공지사항 목록 로드
    loadNoticeList();
});
</script>