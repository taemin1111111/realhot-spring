<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = "";
%>
<!-- 관리자 페이지 전용 CSS -->
<link rel="stylesheet" href="<%=root%>/css/admin.css">

<div class="admin-report-container">
    <div class="admin-header">
        <h2>회원 관리</h2>
    </div>
    
    <!-- 회원 통계 -->
    <div class="member-stats-container">
        <div class="member-stat-card" onclick="filterMembersByStatus('all')" style="cursor: pointer;">
            <div class="member-stat-value" id="totalMembers">-</div>
            <div class="member-stat-label">전체 회원</div>
        </div>
        <div class="member-stat-card" onclick="filterMembersByStatus('A')" style="cursor: pointer;">
            <div class="member-stat-value" id="normalMembers">-</div>
            <div class="member-stat-label">정상 회원</div>
        </div>
        <div class="member-stat-card" onclick="filterMembersByStatus('B')" style="cursor: pointer;">
            <div class="member-stat-value" id="warningMembers">-</div>
            <div class="member-stat-label">경고 회원</div>
        </div>
        <div class="member-stat-card" onclick="filterMembersByStatus('C')" style="cursor: pointer;">
            <div class="member-stat-value" id="suspendedMembers">-</div>
            <div class="member-stat-label">정지 회원</div>
        </div>
        <div class="member-stat-card" onclick="filterMembersByStatus('W')" style="cursor: pointer;">
            <div class="member-stat-value" id="withdrawnMembers">-</div>
            <div class="member-stat-label">탈퇴 회원</div>
        </div>
    </div>
    
    <!-- 회원 목록 -->
    <div class="member-list-container">
        <div class="member-list-header">
            <h3>회원 목록</h3>
            <div class="member-search-box">
                <input type="text" id="memberSearchInput" placeholder="닉네임 또는 아이디 검색..." class="form-control">
                <button class="btn btn-outline-primary" onclick="searchMembers()">
                    <i class="bi bi-search"></i>
                </button>
            </div>
        </div>
        
        <div id="memberList">
            <!-- 여기에 동적으로 로드됨 -->
        </div>
    </div>
</div>

<script>
// memberadmin 페이지가 로드되면 바로 회원 목록을 불러옵니다.
document.addEventListener('DOMContentLoaded', function() {
    console.log('[Admin] memberadmin.jsp 초기화 시작');
    loadMemberStats();
    loadMemberList();
});

// API 요청 시 JWT 토큰을 헤더에 포함하는 공통 함수
async function fetchWithAuth(url, options = {}) {
    return fetch(url, options);
}

// 회원 통계 로드
async function loadMemberStats() {
    try {
        const baseUrl = '<%=root%>';
        const url = baseUrl + '/admin/member/stats';
        
        const response = await fetchWithAuth(url);
        
        if (!response.ok) {
            throw new Error('HTTP error! status: ' + response.status);
        }
        
        const data = await response.json();
        
        if (data.success) {
            document.getElementById('totalMembers').textContent = data.stats.totalMembers || 0;
            document.getElementById('normalMembers').textContent = data.stats.normal || 0;
            document.getElementById('warningMembers').textContent = data.stats.warning || 0;
            document.getElementById('suspendedMembers').textContent = data.stats.suspended || 0;
            document.getElementById('withdrawnMembers').textContent = data.stats.withdrawn || 0;
        } else {
            console.error('회원 통계 로드 실패:', data.message);
        }
    } catch (error) {
        console.error('회원 통계 로드 오류:', error);
    }
}

// 회원 목록 로드
async function loadMemberList() {
    try {
        const baseUrl = '<%=root%>';
        const url = baseUrl + '/admin/member/list';
        
        const response = await fetchWithAuth(url);
        
        if (!response.ok) {
            throw new Error('HTTP error! status: ' + response.status);
        }
        
        const data = await response.json();
        
        if (data.success) {
            displayMemberList(data.members);
        } else {
            console.error('회원 목록 로드 실패:', data.message);
            document.getElementById('memberList').innerHTML = '<div class="empty-state"><p>회원 목록을 불러올 수 없습니다.</p></div>';
        }
    } catch (error) {
        console.error('회원 목록 로드 오류:', error);
        document.getElementById('memberList').innerHTML = '<div class="empty-state"><p>회원 목록을 불러올 수 없습니다.</p></div>';
    }
}

// 회원 목록 표시
function displayMemberList(members) {
    const container = document.getElementById('memberList');
    
    if (!members || members.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>등록된 회원이 없습니다.</p></div>';
        return;
    }
    
    const html = members.map(member => {
        const statusBadge = getStatusBadge(member.status);
        const statusText = getStatusText(member.status);
        
        return '<div class="member-card">' +
            '<div class="member-info">' +
                '<div class="member-nickname">' + (member.nickname || '-') + '</div>' +
                '<div class="member-userid">' + member.userid + '</div>' +
                '<div class="member-provider">' + (member.provider || '일반') + '</div>' +
            '</div>' +
            '<div class="member-status">' +
                statusBadge +
            '</div>' +
            '<div class="member-actions">' +
                '<button class="member-status-btn" onclick="showMemberStatusModal(\'' + member.userid + '\', \'' + (member.nickname || '') + '\', \'' + member.status + '\')" title="상태 변경">' +
                    '<i class="bi bi-person-gear"></i>' +
                    '상태 변경' +
                '</button>' +
            '</div>' +
        '</div>';
    }).join('');
    
    container.innerHTML = html;
}

// 상태 배지 생성
function getStatusBadge(status) {
    switch(status) {
        case 'A':
            return '<span class="badge bg-success">정상</span>';
        case 'B':
            return '<span class="badge bg-warning">경고</span>';
        case 'C':
            return '<span class="badge bg-danger">정지</span>';
        case 'W':
            return '<span class="badge bg-secondary">탈퇴</span>';
        default:
            return '<span class="badge bg-light text-dark">알 수 없음</span>';
    }
}

// 상태 텍스트 변환
function getStatusText(status) {
    switch(status) {
        case 'A': return '정상';
        case 'B': return '경고';
        case 'C': return '정지';
        case 'W': return '탈퇴';
        default: return status;
    }
}

// 회원 검색
function searchMembers() {
    const searchTerm = document.getElementById('memberSearchInput').value.trim();
    if (searchTerm) {
        loadMemberListWithSearch(searchTerm);
    } else {
        loadMemberList();
    }
}

// 검색어로 회원 목록 로드
async function loadMemberListWithSearch(searchTerm) {
    try {
        const baseUrl = '<%=root%>';
        const url = baseUrl + '/admin/member/search?keyword=' + encodeURIComponent(searchTerm);
        
        const response = await fetchWithAuth(url);
        
        if (!response.ok) {
            throw new Error('HTTP error! status: ' + response.status);
        }
        
        const data = await response.json();
        
        if (data.success) {
            displayMemberList(data.members);
        } else {
            console.error('회원 검색 실패:', data.message);
            document.getElementById('memberList').innerHTML = '<div class="empty-state"><p>검색 결과를 찾을 수 없습니다.</p></div>';
        }
    } catch (error) {
        console.error('회원 검색 오류:', error);
        document.getElementById('memberList').innerHTML = '<div class="empty-state"><p>검색 중 오류가 발생했습니다.</p></div>';
    }
}

// 회원 상태 변경 모달 표시
function showMemberStatusModal(userid, nickname, currentStatus) {
    document.getElementById('statusModalUserid').textContent = userid;
    document.getElementById('statusModalNickname').textContent = nickname || '-';
    document.getElementById('statusModalCurrentStatus').textContent = getStatusText(currentStatus);
    
    // 현재 상태에 따라 라디오 버튼 선택
    const statusRadios = document.querySelectorAll('input[name="newStatus"]');
    statusRadios.forEach(radio => {
        radio.checked = radio.value === currentStatus;
    });
    
    $('#memberStatusModal').modal('show');
}

// 회원 상태 변경 실행
async function changeMemberStatus() {
    const userid = document.getElementById('statusModalUserid').textContent;
    const newStatus = document.querySelector('input[name="newStatus"]:checked').value;
    
    const statusText = getStatusText(newStatus);
        if (!confirm('정말로 ' + userid + '(' + document.getElementById('statusModalNickname').textContent + ')의 상태를 ' + statusText + '로 변경하시겠습니까?')) {
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
            throw new Error('HTTP error! status: ' + response.status + ', response: ' + errorText);
        }
        
        const data = await response.json();
        
        if (data.success) {
            alert('회원 상태가 성공적으로 변경되었습니다.');
            $('#memberStatusModal').modal('hide');
            // 통계와 목록 새로고침
            loadMemberStats();
            loadMemberList();
        } else {
            alert(data.message || '회원 상태 변경에 실패했습니다.');
        }
    } catch (error) {
        console.error('회원 상태 변경 오류:', error);
        alert('회원 상태 변경 중 오류가 발생했습니다: ' + error.message);
    }
}

// 엔터키로 검색
document.getElementById('memberSearchInput').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        searchMembers();
    }
});

// 상태별 회원 필터링
async function filterMembersByStatus(status) {
    try {
        // 검색어 초기화
        document.getElementById('memberSearchInput').value = '';
        
        if (status === 'all') {
            // 전체 회원 로드
            loadMemberList();
        } else {
            // 특정 상태의 회원만 로드
            const baseUrl = '<%=root%>';
            const url = baseUrl + '/admin/member/list/status?status=' + encodeURIComponent(status);
            
            const response = await fetchWithAuth(url);
            
            if (!response.ok) {
                throw new Error('HTTP error! status: ' + response.status);
            }
            
            const data = await response.json();
            
            if (data.success) {
                displayMemberList(data.members);
            } else {
                console.error('상태별 회원 조회 실패:', data.message);
                document.getElementById('memberList').innerHTML = '<div class="empty-state"><p>해당 상태의 회원을 찾을 수 없습니다.</p></div>';
            }
        }
    } catch (error) {
        console.error('상태별 회원 필터링 오류:', error);
        document.getElementById('memberList').innerHTML = '<div class="empty-state"><p>필터링 중 오류가 발생했습니다.</p></div>';
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
