<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
%>
<!-- 관리자 페이지 전용 CSS -->
<link rel="stylesheet" href="<%=root%>/css/admin.css">

<div class="admin-report-container">
    <div class="admin-header">
        <h2>코스 신고 관리</h2>
    </div>
    
    <!-- 정렬 버튼 -->
    <div class="admin-filter-group">
        <button class="admin-filter-btn active" onclick="loadReportsByCount()" id="countBtn">
            <i class="bi bi-graph-up"></i>
            신고 많은순
        </button>
        <button class="admin-filter-btn" onclick="loadReportsByLatest()" id="latestBtn">
            <i class="bi bi-clock"></i>
            최신 신고순
        </button>
    </div>
    
    <!-- 신고된 코스 목록 -->
    <div id="reportedCoursesList">
        <!-- 여기에 동적으로 로드됨 -->
    </div>
</div>

<script>
// courseadmin 페이지가 로드되면 바로 신고 목록을 불러옵니다.
// 이제 서버의 JwtAuthenticationFilter가 모든 요청에 대한 인증/권한을 검사하므로,
// 클라이언트에서 별도의 관리자 권한 확인(checkAdminPermission)은 필요하지 않습니다.
document.addEventListener('DOMContentLoaded', function() {
    console.log('[Admin] courseadmin.jsp 초기화 시작');
    loadReportsByCount();
});

// API 요청 시 JWT 토큰을 헤더에 포함하는 공통 함수
// 참고: 이 함수는 이제 title.jsp의 로직과 중복됩니다.
// 추후 하나의 공통 JS 파일로 통합하는 것을 권장합니다.
async function fetchWithAuth(url, options = {}) {
    // 서버에서 HttpOnly 쿠키를 사용하므로, 클라이언트는 요청만 보내면 됩니다.
    // 브라우저가 자동으로 인증 쿠키를 포함하여 전송합니다.
    return fetch(url, options);
}

// 신고 많은순으로 로드
function loadReportsByCount() {
    console.log('Loading course reports by count...');
    
    // 버튼 활성화 상태 변경
    document.getElementById('countBtn').classList.add('active');
    document.getElementById('latestBtn').classList.remove('active');
    
    fetchWithAuth('<%=root%>/admin/course/reports/count')
        .then(response => {
            console.log('Course reports API response status:', response.status);
            if (!response.ok) {
                throw new Error('HTTP error! status: ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            console.log('Received course reports data:', data);
            displayReportedCourses(data);
        })
        .catch(error => {
            console.error('Course reports load failed:', error);
            document.getElementById('reportedCoursesList').innerHTML = 
                '<div class="admin-error">코스 신고 목록을 불러오는데 실패했습니다.</div>';
        });
}

// 최신 신고순으로 로드
function loadReportsByLatest() {
    console.log('Loading course reports by latest...');
    
    // 버튼 활성화 상태 변경
    document.getElementById('latestBtn').classList.add('active');
    document.getElementById('countBtn').classList.remove('active');
    
    fetchWithAuth('<%=root%>/admin/course/reports/latest')
        .then(response => {
            console.log('Course reports API response status:', response.status);
            if (!response.ok) {
                throw new Error('HTTP error! status: ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            console.log('Received course reports data:', data);
            displayReportedCourses(data);
        })
        .catch(error => {
            console.error('Course reports load failed:', error);
            document.getElementById('reportedCoursesList').innerHTML = 
                '<div class="admin-error">코스 신고 목록을 불러오는데 실패했습니다.</div>';
        });
}

// 신고된 코스 목록 표시
function displayReportedCourses(courses) {
    console.log('Display course reports function called, course count:', courses.length);
    
    const container = document.getElementById('reportedCoursesList');
    
    if (!courses || courses.length === 0) {
        container.innerHTML = '<div class="admin-empty">신고된 코스가 없습니다.</div>';
        return;
    }
    
    let html = '';
    courses.forEach((course, index) => {
        console.log('Course ' + (index + 1) + ':', course);
        
        // 시간 포맷팅
        const createdAt = new Date(course.created_at);
        const formattedTime = formatTimeAgo(createdAt);
        
        // 신고 시간 포맷팅
        const reportTime = new Date(course.latest_report_time);
        const formattedReportTime = formatTimeAgo(reportTime);
        
        html += '<div class="admin-report-item">' +
            '<div class="admin-report-header">' +
                '<div class="admin-report-title">' +
                    '<h4>' + (course.title ? course.title : '제목 없음') + '</h4>' +
                    '<span class="admin-report-count">신고 ' + course.report_count + '건</span>' +
                '</div>' +
                '<div class="admin-report-actions">' +
                    '<button class="admin-btn admin-btn-info" onclick="viewCourseDetails(' + course.course_id + ')">' +
                        '<i class="bi bi-eye"></i> 상세보기' +
                    '</button>' +
                    '<button class="admin-btn admin-btn-danger" onclick="deleteCourse(' + course.course_id + ')">' +
                        '<i class="bi bi-trash"></i> 삭제' +
                    '</button>' +
                '</div>' +
            '</div>' +
            
            '<div class="admin-report-content">' +
                '<div class="admin-report-info">' +
                    '<div class="admin-report-meta">' +
                        '<span><i class="bi bi-person"></i> ' + (course.nickname ? course.nickname : '작성자 없음') + '</span>' +
                        '<span><i class="bi bi-eye"></i> ' + (course.view_count ? course.view_count : 0) + '</span>' +
                        '<span><i class="bi bi-hand-thumbs-up"></i> ' + (course.like_count ? course.like_count : 0) + '</span>' +
                        '<span><i class="bi bi-hand-thumbs-down"></i> ' + (course.dislike_count ? course.dislike_count : 0) + '</span>' +
                        '<span><i class="bi bi-clock"></i> ' + formattedTime + '</span>' +
                    '</div>' +
                    '<div class="admin-report-summary">' +
                        (course.summary ? course.summary : '요약 정보가 없습니다.') +
                    '</div>' +
                '</div>' +
                
                '<div class="admin-report-details">' +
                    '<div class="admin-report-latest">' +
                        '<strong>최근 신고:</strong> ' + formattedReportTime +
                    '</div>' +
                '</div>' +
            '</div>' +
        '</div>';
    });
    
    console.log('Generated HTML:', html);
    container.innerHTML = html;
}

// 시간 포맷팅 함수
function formatTimeAgo(date) {
    const now = new Date();
    const diffInSeconds = Math.floor((now - date) / 1000);
    
    if (diffInSeconds < 60) {
        return '방금전';
    } else if (diffInSeconds < 3600) {
        const minutes = Math.floor(diffInSeconds / 60);
        return minutes + '분전';
    } else if (diffInSeconds < 86400) {
        const hours = Math.floor(diffInSeconds / 3600);
        return hours + '시간전';
    } else {
        const days = Math.floor(diffInSeconds / 86400);
        return days + '일전';
    }
}

// HTML 이스케이프 함수 (사용하지 않음 - JSP에서 직접 처리)
// function escapeHtml(text) {
//     if (!text) return '';
//     const div = document.createElement('div');
//     div.textContent = text;
//     return div.innerHTML;
// }

// 코스 상세보기 (새 탭에서 열기)
function viewCourseDetails(courseId) {
    window.open('<%=root%>/course/' + courseId, '_blank');
}

// 코스 신고 상세 모달 표시
function showCourseReportModal(courseId, reportDetails) {
    // 모달 HTML 생성
    let modalHtml = `
        <div class="admin-modal-overlay" onclick="closeCourseReportModal()">
            <div class="admin-modal-content" onclick="event.stopPropagation()">
                <div class="admin-modal-header">
                    <h3>코스 신고 상세 정보</h3>
                    <button class="admin-modal-close" onclick="closeCourseReportModal()">&times;</button>
                </div>
                <div class="admin-modal-body">
                    <div class="admin-report-detail-info">
                        <h4>코스 ID: ${courseId}</h4>
                        <p>총 신고 건수: ${reportDetails.length}건</p>
                    </div>
                    <div class="admin-report-list">
    `;
    
    reportDetails.forEach((report, index) => {
        const reportTime = new Date(report.report_time);
        const formattedTime = formatTimeAgo(reportTime);
        
        modalHtml += '<div class="admin-report-detail-item">' +
            '<div class="admin-report-detail-header">' +
                '<span class="admin-report-detail-reporter">신고자: ' + (report.reporter ? report.reporter : '신고자 없음') + '</span>' +
                '<span class="admin-report-detail-time">' + formattedTime + '</span>' +
            '</div>' +
            '<div class="admin-report-detail-reason">' +
                '<strong>신고 사유:</strong> ' + (report.reason ? report.reason : '사유 없음') +
            '</div>' +
            '<div class="admin-report-detail-content">' +
                '<strong>신고 내용:</strong> ' + (report.report_content ? report.report_content : '내용 없음') +
            '</div>' +
        '</div>';
    });
    
    modalHtml += '</div>' +
            '</div>' +
            '<div class="admin-modal-footer">' +
                '<button class="admin-btn admin-btn-danger" onclick="deleteCourse(' + courseId + '); closeCourseReportModal();">' +
                    '<i class="bi bi-trash"></i> 코스 삭제' +
                '</button>' +
                '<button class="admin-btn admin-btn-secondary" onclick="closeCourseReportModal()">' +
                    '닫기' +
                '</button>' +
            '</div>' +
        '</div>' +
    '</div>';
    
    // 모달을 body에 추가
    document.body.insertAdjacentHTML('beforeend', modalHtml);
}

// 코스 신고 모달 닫기
function closeCourseReportModal() {
    const modal = document.querySelector('.admin-modal-overlay');
    if (modal) {
        modal.remove();
    }
}

// 관리자용 코스 삭제 함수
async function deleteCourse(courseId) {
    if (!courseId || courseId === 'undefined' || courseId === 'null') {
        console.error('courseId is missing or invalid:', courseId);
        alert('코스 ID가 올바르지 않습니다.');
        return;
    }
    
    // 확인 대화상자
    if (!confirm('정말로 이 코스를 삭제하시겠습니까?\n\n삭제 시 다음 데이터가 함께 삭제됩니다:\n- 코스 내용\n- 코스 스텝\n- 댓글\n- 좋아요/싫어요\n- 업로드된 이미지 파일\n- 신고 내역\n\n이 작업은 되돌릴 수 없습니다.')) {
        return;
    }
    
    try {
        const baseUrl = '<%=root%>';
        const url = baseUrl + '/admin/course/' + courseId + '/delete';
        
        console.log('관리자 코스 삭제 요청 URL:', url);
        console.log('courseId:', courseId);
        
        const response = await fetchWithAuth(url, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        console.log('서버 응답 상태:', response.status, response.statusText);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('서버 응답 오류:', errorText);
            throw new Error(`HTTP error! status: ${response.status}, response: ${errorText}`);
        }
        
        const data = await response.json();
        console.log('서버 응답 데이터:', data);
        
        if (data.success) {
            alert('코스가 성공적으로 삭제되었습니다.');
            // 목록 새로고침
            loadReportsByCount();
        } else {
            alert(data.message || '코스 삭제에 실패했습니다.');
        }
    } catch (error) {
        console.error('코스 삭제 오류:', error);
        alert('코스 삭제 중 오류가 발생했습니다: ' + error.message);
    }
}

// ESC 키로 모달 닫기
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeCourseReportModal();
    }
});
</script>
