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
var noticeId = <%=noticeId != null ? noticeId : "null"%>;

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
            html += '  ' + isPinned;
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
        } else {
            detailContent.innerHTML = '<div class="text-center" style="color: #666666; padding: 40px;"><i class="bi bi-exclamation-triangle" style="font-size: 3rem; margin-bottom: 20px; color: #dee2e6;"></i><p>공지사항을 찾을 수 없습니다.</p></div>';
        }
    })
    .catch(error => {
        console.error('공지사항 상세 로드 실패:', error);
        document.getElementById('notice-detail-content').innerHTML = '<div class="text-center" style="color: #666666; padding: 40px;"><i class="bi bi-exclamation-triangle" style="font-size: 3rem; margin-bottom: 20px; color: #dee2e6;"></i><p>공지사항을 불러오는 중 오류가 발생했습니다.</p></div>';
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