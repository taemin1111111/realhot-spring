/**
 * 관리자 페이지 JavaScript 함수들
 */

// 회원 상태 변경
function changeMemberStatus(userid, status) {
    if (!userid || !status) {
        alert('필수 파라미터가 누락되었습니다.');
        return;
    }
    
    if (!confirm('회원 상태를 변경하시겠습니까?')) {
        return;
    }
    
    const statusText = {
        'A': '활성',
        'B': '경고', 
        'C': '정지'
    };
    
    $.ajax({
        url: '/api/admin/members/' + userid + '/status',
        method: 'PUT',
        data: {
            status: status
        },
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                alert(response.message);
                // 페이지 새로고침 또는 상태 업데이트
                location.reload();
            } else {
                alert('오류: ' + response.message);
            }
        },
        error: function(xhr, status, error) {
            console.error('AJAX Error:', error);
            alert('서버 오류가 발생했습니다: ' + error);
        }
    });
}

// 회원 삭제
function deleteMember(userid) {
    if (!userid) {
        alert('회원 ID가 필요합니다.');
        return;
    }
    
    if (userid === 'admin') {
        alert('관리자 계정은 삭제할 수 없습니다.');
        return;
    }
    
    if (!confirm('정말로 이 회원을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) {
        return;
    }
    
    $.ajax({
        url: '/api/admin/members/' + userid,
        method: 'DELETE',
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                alert(response.message);
                // 페이지 새로고침 또는 해당 행 제거
                location.reload();
            } else {
                alert('오류: ' + response.message);
            }
        },
        error: function(xhr, status, error) {
            console.error('AJAX Error:', error);
            alert('서버 오류가 발생했습니다: ' + error);
        }
    });
}

// 게시글 삭제
function deletePost(postId) {
    if (!postId) {
        alert('게시글 ID가 필요합니다.');
        return;
    }
    
    if (!confirm('정말로 이 게시글을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) {
        return;
    }
    
    $.ajax({
        url: '/api/admin/posts/' + postId,
        method: 'DELETE',
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                alert(response.message);
                // 페이지 새로고침 또는 해당 행 제거
                location.reload();
            } else {
                alert('오류: ' + response.message);
            }
        },
        error: function(xhr, status, error) {
            console.error('AJAX Error:', error);
            alert('서버 오류가 발생했습니다: ' + error);
        }
    });
}

// 회원 목록 조회
function loadMembers(page = 0, size = 20, keyword = '', provider = '', status = '') {
    const params = new URLSearchParams({
        page: page,
        size: size
    });
    
    if (keyword) params.append('keyword', keyword);
    if (provider) params.append('provider', provider);
    if (status) params.append('status', status);
    
    $.ajax({
        url: '/api/admin/members?' + params.toString(),
        method: 'GET',
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                displayMembers(response.members, response.totalCount, response.currentPage, response.totalPages);
            } else {
                alert('오류: ' + response.message);
            }
        },
        error: function(xhr, status, error) {
            console.error('AJAX Error:', error);
            alert('서버 오류가 발생했습니다: ' + error);
        }
    });
}

// 회원 목록 표시
function displayMembers(members, totalCount, currentPage, totalPages) {
    let html = '<div class="member-list-container">';
    html += '<h3>회원 목록 (총 ' + totalCount + '명)</h3>';
    html += '<table class="table table-striped">';
    html += '<thead><tr><th>ID</th><th>이름</th><th>닉네임</th><th>이메일</th><th>제공자</th><th>상태</th><th>가입일</th><th>관리</th></tr></thead>';
    html += '<tbody>';
    
    members.forEach(function(member) {
        html += '<tr>';
        html += '<td>' + member.userid + '</td>';
        html += '<td>' + member.name + '</td>';
        html += '<td>' + member.nickname + '</td>';
        html += '<td>' + member.email + '</td>';
        html += '<td>' + member.provider + '</td>';
        html += '<td>' + member.status + '</td>';
        html += '<td>' + new Date(member.regdate).toLocaleDateString() + '</td>';
        html += '<td>';
        html += '<select onchange="changeMemberStatus(\'' + member.userid + '\', this.value)">';
        html += '<option value="">상태변경</option>';
        html += '<option value="A"' + (member.status === 'A' ? ' selected' : '') + '>활성</option>';
        html += '<option value="B"' + (member.status === 'B' ? ' selected' : '') + '>경고</option>';
        html += '<option value="C"' + (member.status === 'C' ? ' selected' : '') + '>정지</option>';
        html += '</select>';
        if (member.userid !== 'admin') {
            html += ' <button class="btn btn-danger btn-sm" onclick="deleteMember(\'' + member.userid + '\')">삭제</button>';
        }
        html += '</td>';
        html += '</tr>';
    });
    
    html += '</tbody></table>';
    
    // 페이지네이션
    html += '<nav><ul class="pagination">';
    for (let i = 0; i < totalPages; i++) {
        html += '<li class="page-item' + (i === currentPage ? ' active' : '') + '">';
        html += '<a class="page-link" href="#" onclick="loadMembers(' + i + ')">' + (i + 1) + '</a>';
        html += '</li>';
    }
    html += '</ul></nav>';
    
    html += '</div>';
    
    $('#member-list-container').html(html);
}

// 회원 통계 로드
function loadMemberStats() {
    $.ajax({
        url: '/api/admin/members/stats',
        method: 'GET',
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                displayMemberStats(response);
            } else {
                alert('오류: ' + response.message);
            }
        },
        error: function(xhr, status, error) {
            console.error('AJAX Error:', error);
            alert('서버 오류가 발생했습니다: ' + error);
        }
    });
}

// 회원 통계 표시
function displayMemberStats(stats) {
    let html = '<div class="stats-container">';
    html += '<h3>회원 통계</h3>';
    html += '<div class="row">';
    html += '<div class="col-md-3"><div class="card"><div class="card-body"><h5>전체 회원</h5><h2>' + stats.totalMembers + '</h2></div></div></div>';
    html += '<div class="col-md-3"><div class="card"><div class="card-body"><h5>활성 회원</h5><h2>' + stats.activeMembers + '</h2></div></div></div>';
    html += '</div>';
    html += '</div>';
    
    $('#stats-container').html(html);
}

// 페이지 로드시 초기화
$(document).ready(function() {
    // 관리자 페이지에서만 실행
    if (window.location.pathname.includes('/admin')) {
        loadMembers();
        loadMemberStats();
    }
});
