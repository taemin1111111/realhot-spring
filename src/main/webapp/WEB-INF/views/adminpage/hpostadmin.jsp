<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = "";
%>
<!-- 관리자 페이지 전용 CSS -->
<link rel="stylesheet" href="<%=root%>/css/admin.css">

<div class="admin-report-container">
    <div class="admin-header">
        <h2>핫플썰 신고 관리</h2>
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
    
    <!-- 신고된 게시물 목록 -->
    <div id="reportedPostsList">
        <!-- 여기에 동적으로 로드됨 -->
    </div>
</div>

<script>
// hpostadmin 페이지가 로드되면 바로 신고 목록을 불러옵니다.
// 이제 서버의 JwtAuthenticationFilter가 모든 요청에 대한 인증/권한을 검사하므로,
// 클라이언트에서 별도의 관리자 권한 확인(checkAdminPermission)은 필요하지 않습니다.
document.addEventListener('DOMContentLoaded', function() {
    console.log('[Admin] hpostadmin.jsp 초기화 시작');
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
    console.log('Loading reports by count...');
    
    // 버튼 상태 업데이트
    document.getElementById('countBtn').classList.add('active');
    document.getElementById('latestBtn').classList.remove('active');
    
    // 로딩 상태 표시
    document.getElementById('reportedPostsList').innerHTML = 
        '<div class="loading-state"><div class="loading-spinner"></div>신고된 게시물을 불러오는 중...</div>';
    
    fetchWithAuth('<%=root%>/admin/reports/count')
        .then(response => {
            console.log('Count response status:', response.status);
            if (!response.ok) {
                // 403 Forbidden 에러는 권한 없음을 의미합니다.
                if (response.status === 403) {
                    alert('데이터를 조회할 관리자 권한이 없습니다.');
                    window.location.href = '/hotplace/';
                }
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('Reports by count data:', data);
            displayReportedPosts(data);
        })
        .catch(error => {
            console.error('Error loading reports by count:', error);
            document.getElementById('reportedPostsList').innerHTML = 
                '<div class="error-state">신고된 게시물을 불러오는 중 오류가 발생했습니다: ' + error.message + '</div>';
        });
}

// 최신 신고순으로 로드
function loadReportsByLatest() {
    console.log('Loading reports by latest...');
    
    // 버튼 상태 업데이트
    document.getElementById('latestBtn').classList.add('active');
    document.getElementById('countBtn').classList.remove('active');
    
    // 로딩 상태 표시
    document.getElementById('reportedPostsList').innerHTML = 
        '<div class="loading-state"><div class="loading-spinner"></div>신고된 게시물을 불러오는 중...</div>';
    
    fetchWithAuth('<%=root%>/admin/reports/latest')
        .then(response => {
            console.log('Latest response status:', response.status);
            if (!response.ok) {
                if (response.status === 403) {
                    alert('데이터를 조회할 관리자 권한이 없습니다.');
                    window.location.href = '/hotplace/';
                }
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('Reports by latest data:', data);
            displayReportedPosts(data);
        })
        .catch(error => {
            console.error('Error loading reports by latest:', error);
            document.getElementById('reportedPostsList').innerHTML = 
                '<div class="error-state">신고된 게시물을 불러오는 중 오류가 발생했습니다: ' + error.message + '</div>';
        });
}

// 신고된 게시물 목록 표시
function displayReportedPosts(posts) {
    const container = document.getElementById('reportedPostsList');
    
    if (!posts || posts.length === 0) {
        container.innerHTML = 
            '<div class="empty-state">' +
                '<i class="bi bi-shield-check"></i>' +
                '<h3>신고된 게시물이 없습니다</h3>' +
                '<p>현재 신고된 게시물이 없습니다.</p>' +
            '</div>';
        return;
    }
    
    let html = '';
    posts.forEach(post => {
        // postId 값 확인
        const postId = post.id || post.post_id;
        
        if (!postId) {
            return; // 이 게시물은 건너뛰기
        }
        
        // 안전한 문자열 처리
        const title = post.title || '제목 없음';
        const nickname = post.nickname || '익명';
        const content = post.content || '';
        const contentPreview = content.length > 150 ? content.substring(0, 150) + '...' : content;
        const views = post.views || 0;
        const likes = post.likes || 0;
        const dislikes = post.dislikes || 0;
        const reportCount = post.report_count || 0;
        const createdAt = post.created_at || '날짜 없음';

        html += 
            '<div class="report-card">' +
                '<div class="report-card-header">' +
                    '<h3 class="report-card-title">' +
                        '<a href="<%=root%>/hpost/' + postId + '" class="report-title-link" target="_blank">' + title + '</a>' +
                    '</h3>' +
                    '<div class="report-card-meta">' +
                        '<span><i class="bi bi-person"></i> ' + nickname + '</span>' +
                        '<span><i class="bi bi-calendar"></i> ' + createdAt + '</span>' +
                    '</div>' +
                    '<div class="report-card-content">' + contentPreview + '</div>' +
                    '<div class="report-card-stats">' +
                        '<div class="report-stat">' +
                            '<div class="report-stat-value">' + views + '</div>' +
                            '<div class="report-stat-label">조회수</div>' +
                        '</div>' +
                        '<div class="report-stat">' +
                            '<div class="report-stat-value">' + likes + '</div>' +
                            '<div class="report-stat-label">좋아요</div>' +
                        '</div>' +
                        '<div class="report-stat">' +
                            '<div class="report-stat-value">' + dislikes + '</div>' +
                            '<div class="report-stat-label">싫어요</div>' +
                        '</div>' +
                        '<div class="report-stat report-count">' +
                            '<div class="report-stat-value">' + reportCount + '</div>' +
                            '<div class="report-stat-label">신고수</div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="report-card-actions">' +
                        '<button class="report-detail-btn toggle-report-details-btn" data-post-id="' + postId + '">' +
                            '<i class="bi bi-chevron-down"></i>' +
                            '신고 상세보기' +
                        '</button>' +
                        '<button class="report-status-btn" onclick="showMemberStatusModal(\'' + (post.userid || '') + '\', \'' + (post.nickname || '') + '\', \'' + (post.status || 'A') + '\')" title="회원 상태 변경">' +
                            '<i class="bi bi-person-gear"></i>' +
                            '정지' +
                        '</button>' +
                        '<button class="report-delete-btn" onclick="deleteHpost(' + postId + ')" title="게시물 삭제">' +
                            '<i class="bi bi-trash"></i>' +
                            '삭제' +
                        '</button>' +
                    '</div>' +
                '</div>' +
                
                '<!-- 신고 상세 정보 (접힘) -->' +
                '<div id="reportDetails_' + postId + '" class="report-details" style="display: none;">' +
                    '<h6>신고 상세 정보</h6>' +
                    '<div id="reportDetailsContent_' + postId + '">' +
                        '<!-- 여기에 동적으로 로드됨 -->' +
                    '</div>' +
                '</div>' +
            '</div>';
    });
    
    container.innerHTML = html;
}

// 이벤트 위임을 사용하여 신고 상세 정보 토글
document.getElementById('reportedPostsList').addEventListener('click', function(event) {
    const button = event.target.closest('.toggle-report-details-btn');
    if (button) {
        // 디버깅을 위해 클릭된 버튼의 HTML을 로그로 남깁니다.
        console.log('Clicked button outerHTML:', button.outerHTML);
        const postId = button.dataset.postId;
        // 버튼 요소와 postId를 함께 전달합니다.
        toggleReportDetails(button, postId);
    }
});

// 신고 상세 정보 토글
function toggleReportDetails(button, postId) {
    console.log('toggleReportDetails called with postId:', postId, 'type:', typeof postId);
    
    if (!postId || postId === 'undefined' || postId === 'null') {
        console.error('postId is missing or invalid:', postId);
        alert('게시물 ID가 올바르지 않습니다.');
        return;
    }
    
    const detailsDiv = document.getElementById('reportDetails_' + postId);
    
    // 디버깅 로그
    console.log('detailsDiv:', detailsDiv);
    console.log('button element:', button);
    
    if (!detailsDiv || !button) {
        console.error('Element not found for postId:', postId);
        return;
    }
    
    const icon = button.querySelector('i');
    
    if (detailsDiv.style.display === 'none' || detailsDiv.style.display === '') {
        // 상세 정보 로드
        loadReportDetails(parseInt(postId));
        detailsDiv.style.display = 'block';
        button.classList.add('expanded');
        if(icon) icon.className = 'bi bi-chevron-up';
        button.innerHTML = '<i class="bi bi-chevron-up"></i> 신고 내용 닫기';
    } else {
        // 상세 정보 숨기기
        detailsDiv.style.display = 'none';
        button.classList.remove('expanded');
        if(icon) icon.className = 'bi bi-chevron-down';
        button.innerHTML = '<i class="bi bi-chevron-down"></i> 신고 상세보기';
    }
}

// 신고 상세 정보 로드
function loadReportDetails(postId) {
    console.log('Loading report details for postId:', postId);
    
    if (!postId || postId === 'undefined') {
        console.error('postId is undefined or invalid:', postId);
        return;
    }
    
    const contentDiv = document.getElementById('reportDetailsContent_' + postId);
    
    if (!contentDiv) {
        console.error('Content div not found for postId:', postId);
        return;
    }
    
    // 로딩 상태 표시
    contentDiv.innerHTML = '<div class="loading-state"><div class="loading-spinner"></div>신고 상세 정보를 불러오는 중...</div>';
    
    fetchWithAuth('<%=root%>/admin/reports/details?postId=' + postId)
        .then(response => {
            console.log('Response status:', response.status);
            if (!response.ok) {
                if (response.status === 403) {
                    alert('데이터를 조회할 관리자 권한이 없습니다.');
                } else if (response.status === 400) {
                    alert('잘못된 요청입니다. 게시물 ID를 확인해주세요.');
                }
                throw new Error('HTTP error! status: ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            console.log('Report details data:', data);
            let html = '';
            if (!data || data.length === 0) {
                html = 
                    '<div class="empty-state">' +
                        '<i class="bi bi-info-circle"></i>' +
                        '<h3>신고 상세 정보가 없습니다</h3>' +
                        '<p>이 게시물에 대한 신고 상세 정보가 없습니다.</p>' +
                    '</div>';
            } else {
                data.forEach(report => {
                    html += 
                        '<div class="report-detail-item">' +
                            '<div class="report-detail-grid">' +
                                '<div class="report-detail-field">' +
                                    '<div class="report-detail-label">신고자</div>' +
                                    '<div class="report-detail-value">' + (report.reporter || '익명') + '</div>' +
                                '</div>' +
                                '<div class="report-detail-field">' +
                                    '<div class="report-detail-label">신고 사유</div>' +
                                    '<div class="report-detail-value">' + (report.reason || '-') + '</div>' +
                                '</div>' +
                                '<div class="report-detail-field">' +
                                    '<div class="report-detail-label">신고 시간</div>' +
                                    '<div class="report-detail-value">' + (report.report_time || '-') + '</div>' +
                                '</div>' +
                            '</div>';
                    
                    if (report.report_content) {
                        html += 
                            '<div class="report-detail-field" style="margin-top: 12px;">' +
                                '<div class="report-detail-label">신고 내용</div>' +
                                '<div class="report-detail-value">' + report.report_content + '</div>' +
                            '</div>';
                    }
                    
                    html += '</div>';
                });
            }
            contentDiv.innerHTML = html;
        })
        .catch(error => {
            console.error('Error loading report details:', error);
            contentDiv.innerHTML = '<div class="error-state">신고 상세 정보를 불러오는 중 오류가 발생했습니다: ' + error.message + '</div>';
        });
}

// 관리자용 게시물 삭제 함수
async function deleteHpost(postId) {
    if (!postId || postId === 'undefined' || postId === 'null') {
        console.error('postId is missing or invalid:', postId);
        alert('게시물 ID가 올바르지 않습니다.');
        return;
    }
    
    // 확인 대화상자
    if (!confirm('정말로 이 게시물을 삭제하시겠습니까?\n\n삭제 시 다음 데이터가 함께 삭제됩니다:\n- 게시물 내용\n- 댓글\n- 좋아요/싫어요\n- 업로드된 사진 파일\n- 신고 내역\n\n이 작업은 되돌릴 수 없습니다.')) {
        return;
    }
    
    try {
        const baseUrl = '<%=root%>';
        const url = baseUrl + '/admin/hpost/' + postId + '/delete';
        
        console.log('관리자 삭제 요청 URL:', url);
        console.log('postId:', postId);
        
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
            alert('게시물이 성공적으로 삭제되었습니다.');
            // 목록 새로고침
            loadReportsByCount();
        } else {
            alert(data.message || '게시물 삭제에 실패했습니다.');
        }
    } catch (error) {
        console.error('게시물 삭제 오류:', error);
        alert('게시물 삭제 중 오류가 발생했습니다: ' + error.message);
    }
}

// 회원 상태 변경 모달 표시
function showMemberStatusModal(userid, nickname, currentStatus) {
    // 안전한 값 처리
    const safeUserid = userid || '알 수 없음';
    const safeNickname = nickname || '알 수 없음';
    const safeStatus = currentStatus || 'A';
    
    document.getElementById('statusModalUserid').textContent = safeUserid;
    document.getElementById('statusModalNickname').textContent = safeNickname;
    document.getElementById('statusModalCurrentStatus').textContent = getStatusText(safeStatus);
    
    // 현재 상태에 따라 라디오 버튼 선택
    const statusRadios = document.querySelectorAll('input[name="newStatus"]');
    statusRadios.forEach(radio => {
        radio.checked = radio.value === safeStatus;
    });
    
    $('#memberStatusModal').modal('show');
}

// 상태 텍스트 변환
function getStatusText(status) {
    switch(status) {
        case 'A': return '정상';
        case 'B': return '경고';
        case 'C': return '정지';
        case 'W': return '삭제';
        default: return status;
    }
}

// 회원 상태 변경 실행
async function changeMemberStatus() {
    const userid = document.getElementById('statusModalUserid').textContent;
    const nickname = document.getElementById('statusModalNickname').textContent;
    const newStatus = document.querySelector('input[name="newStatus"]:checked').value;
    
    // 유효성 검사
    if (!userid || userid === '알 수 없음') {
        alert('회원 정보를 찾을 수 없습니다.');
        return;
    }
    
    const statusText = getStatusText(newStatus);
    if (!confirm('정말로 ' + userid + '(' + nickname + ')의 상태를 ' + statusText + '로 변경하시겠습니까?')) {
        return;
    }
    
    try {
        const baseUrl = '<%=root%>';
        const url = baseUrl + '/admin/member/status';
        
        const response = await fetchWithAuth(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                userid: userid,
                status: newStatus
            })
        });
        
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`HTTP error! status: ${response.status}, response: ${errorText}`);
        }
        
        const data = await response.json();
        
        if (data.success) {
            alert('회원 상태가 성공적으로 변경되었습니다.');
            $('#memberStatusModal').modal('hide');
            // 목록 새로고침
            loadReportsByCount();
        } else {
            alert(data.message || '회원 상태 변경에 실패했습니다.');
        }
    } catch (error) {
        console.error('회원 상태 변경 오류:', error);
        alert('회원 상태 변경 중 오류가 발생했습니다: ' + error.message);
    }
}
</script>

<!-- 회원 상태 변경 모달 -->
<div class="modal fade" id="memberStatusModal" tabindex="-1" aria-labelledby="memberStatusModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="memberStatusModalLabel">회원 상태 변경</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label">회원 정보</label>
                    <div class="card">
                        <div class="card-body">
                            <p class="mb-1"><strong>아이디:</strong> <span id="statusModalUserid"></span></p>
                            <p class="mb-1"><strong>닉네임:</strong> <span id="statusModalNickname"></span></p>
                            <p class="mb-0"><strong>현재 상태:</strong> <span id="statusModalCurrentStatus"></span></p>
                        </div>
                    </div>
                </div>
                
                <div class="mb-3">
                    <label class="form-label">새로운 상태 선택</label>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="newStatus" id="statusA" value="A">
                        <label class="form-check-label" for="statusA">
                            <span class="badge bg-success">A - 정상</span>
                            <small class="text-muted d-block">모든 기능 사용 가능</small>
                        </label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="newStatus" id="statusB" value="B">
                        <label class="form-check-label" for="statusB">
                            <span class="badge bg-warning">B - 경고</span>
                            <small class="text-muted d-block">로그인 가능, 일부 기능 제한</small>
                        </label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="newStatus" id="statusC" value="C">
                        <label class="form-check-label" for="statusC">
                            <span class="badge bg-danger">C - 정지</span>
                            <small class="text-muted d-block">로그인 불가, 계정 정지</small>
                        </label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="newStatus" id="statusW" value="W">
                        <label class="form-check-label" for="statusW">
                            <span class="badge bg-secondary">W - 삭제</span>
                            <small class="text-muted d-block">계정 삭제, 로그인 불가</small>
                        </label>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" onclick="changeMemberStatus()">상태 변경</button>
            </div>
        </div>
    </div>
</div>
