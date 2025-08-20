<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    String provider = (String)session.getAttribute("provider");
    
    // 관리자 권한 확인
    if(loginId == null || !"admin".equals(provider)) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원 관리 - WhereHot Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        .admin-container { margin-top: 30px; }
        .member-table th { background-color: #f8f9fa; }
        .status-badge { font-size: 0.8em; }
        .provider-badge { font-size: 0.7em; }
        .loading { text-align: center; padding: 50px; }
    </style>
</head>
<body>
    <div class="container admin-container">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="page-title"><i class="bi bi-people-fill me-2"></i>회원 관리</h2>
            <a href="<%=root%>/WEB-INF/views/adminpage/admin.jsp" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> 관리자 메인
        </a>
    </div>

        <!-- 검색 및 필터 -->
        <div class="card mb-4">
                    <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">검색어</label>
                        <input type="text" id="searchKeyword" class="form-control" placeholder="이름, 닉네임, 이메일, ID">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">제공자</label>
                        <select id="searchProvider" class="form-select">
                            <option value="">전체</option>
                            <option value="site">사이트</option>
                            <option value="naver">네이버</option>
                            <option value="admin">관리자</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">상태</label>
                        <select id="searchStatus" class="form-select">
                            <option value="">전체</option>
                            <option value="A">활성</option>
                            <option value="B">경고</option>
                            <option value="C">정지</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">페이지 크기</label>
                        <select id="pageSize" class="form-select">
                            <option value="10">10개</option>
                            <option value="20" selected>20개</option>
                            <option value="50">50개</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">&nbsp;</label>
                        <button class="btn btn-primary d-block w-100" onclick="loadMembers()">
                            <i class="bi bi-search"></i> 검색
                        </button>
                    </div>
                    </div>
                </div>
            </div>

        <!-- 통계 정보 -->
        <div class="row mb-4" id="statsContainer">
            <div class="col-md-3">
                <div class="card bg-primary text-white">
                    <div class="card-body">
                        <h5>전체 회원</h5>
                        <h2 id="totalMembers">-</h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-success text-white">
                    <div class="card-body">
                        <h5>활성 회원</h5>
                        <h2 id="activeMembers">-</h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-warning text-white">
                    <div class="card-body">
                        <h5>경고 회원</h5>
                        <h2 id="warningMembers">-</h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-danger text-white">
                    <div class="card-body">
                        <h5>정지 회원</h5>
                        <h2 id="suspendedMembers">-</h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- 회원 목록 -->
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">회원 목록</h5>
                <span id="memberCount" class="badge bg-secondary">총 0명</span>
            </div>
            <div class="card-body">
                <div id="memberListContainer">
                    <div class="loading">
                        <div class="spinner-border" role="status">
                            <span class="visually-hidden">로딩중...</span>
                    </div>
                        <p class="mt-2">회원 목록을 불러오는 중...</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 페이지네이션 -->
        <nav id="paginationContainer" class="mt-4" style="display: none;">
            <ul class="pagination justify-content-center" id="pagination">
                             </ul>
                         </nav>
    </div>

    <script>
        let currentPage = 0;
        let currentSize = 20;
        let totalPages = 0;

        // 페이지 로드시 초기화
        $(document).ready(function() {
            loadMemberStats();
            loadMembers();
            
            // Enter 키 검색
            $('#searchKeyword').on('keypress', function(e) {
                if (e.which === 13) {
                    loadMembers();
                }
            });
        });
        
        // 회원 통계 로드
        function loadMemberStats() {
            $.ajax({
                url: '<%=root%>/api/admin/members/stats',
                method: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        $('#totalMembers').text(response.totalMembers || 0);
                        $('#activeMembers').text(response.activeMembers || 0);
                        // TODO: 경고/정지 회원 수 API 구현 필요
                        $('#warningMembers').text('N/A');
                        $('#suspendedMembers').text('N/A');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('통계 로드 오류:', error);
                }
            });
        }

        // 회원 목록 로드
        function loadMembers(page = 0) {
            const keyword = $('#searchKeyword').val();
            const provider = $('#searchProvider').val();
            const status = $('#searchStatus').val();
            const size = parseInt($('#pageSize').val());
            
            currentPage = page;
            currentSize = size;

            const params = new URLSearchParams({
                page: page,
                size: size
            });
            
            if (keyword) params.append('keyword', keyword);
            if (provider) params.append('provider', provider);
            if (status) params.append('status', status);

            $.ajax({
                url: '<%=root%>/api/admin/members?' + params.toString(),
                method: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        displayMembers(response.members, response.totalCount);
                        updatePagination(response.currentPage, response.totalPages, response.totalCount);
                    } else {
                        $('#memberListContainer').html('<div class="alert alert-warning">회원 목록을 불러올 수 없습니다: ' + response.message + '</div>');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('회원 목록 로드 오류:', error);
                    $('#memberListContainer').html('<div class="alert alert-danger">회원 목록 로드 중 오류가 발생했습니다.</div>');
                }
            });
        }

        // 회원 목록 표시
        function displayMembers(members, totalCount) {
            $('#memberCount').text('총 ' + totalCount + '명');
            
            if (!members || members.length === 0) {
                $('#memberListContainer').html('<div class="alert alert-info">조건에 맞는 회원이 없습니다.</div>');
                return;
            }

            let html = '<div class="table-responsive">';
            html += '<table class="table table-hover member-table">';
            html += '<thead>';
            html += '<tr>';
            html += '<th>ID</th>';
            html += '<th>이름</th>';
            html += '<th>닉네임</th>';
            html += '<th>이메일</th>';
            html += '<th>제공자</th>';
            html += '<th>상태</th>';
            html += '<th>가입일</th>';
            html += '<th>관리</th>';
            html += '</tr>';
            html += '</thead>';
            html += '<tbody>';

            members.forEach(function(member) {
                html += '<tr>';
                html += '<td><strong>' + member.userid + '</strong></td>';
                html += '<td>' + (member.name || '-') + '</td>';
                html += '<td>' + (member.nickname || '-') + '</td>';
                html += '<td>' + (member.email || '-') + '</td>';
                html += '<td><span class="badge provider-badge bg-' + getProviderColor(member.provider) + '">' + member.provider + '</span></td>';
                html += '<td><span class="badge status-badge bg-' + getStatusColor(member.status) + '">' + getStatusText(member.status) + '</span></td>';
                html += '<td>' + formatDate(member.regdate) + '</td>';
                html += '<td>';
                
                if (member.userid !== 'admin') {
                    html += '<div class="btn-group btn-group-sm" role="group">';
                    html += '<select class="form-select form-select-sm" onchange="changeMemberStatus(\'' + member.userid + '\', this.value)" style="width: auto;">';
                    html += '<option value="">상태변경</option>';
                    html += '<option value="A"' + (member.status === 'A' ? ' selected' : '') + '>활성</option>';
                    html += '<option value="B"' + (member.status === 'B' ? ' selected' : '') + '>경고</option>';
                    html += '<option value="C"' + (member.status === 'C' ? ' selected' : '') + '>정지</option>';
                    html += '</select>';
                    html += '<button class="btn btn-outline-danger btn-sm" onclick="deleteMember(\'' + member.userid + '\')" title="회원삭제">';
                    html += '<i class="bi bi-trash"></i>';
                    html += '</button>';
                    html += '</div>';
                } else {
                    html += '<span class="text-muted">관리자</span>';
                }
                
                html += '</td>';
                html += '</tr>';
            });

            html += '</tbody>';
            html += '</table>';
            html += '</div>';

            $('#memberListContainer').html(html);
        }

        // 페이지네이션 업데이트
        function updatePagination(currentPage, totalPages, totalCount) {
            if (totalPages <= 1) {
                $('#paginationContainer').hide();
                return;
            }

            let html = '';
            
            // 이전 페이지
            if (currentPage > 0) {
                html += '<li class="page-item"><a class="page-link" href="#" onclick="loadMembers(' + (currentPage - 1) + ')">이전</a></li>';
            }
            
            // 페이지 번호들
            const startPage = Math.max(0, currentPage - 2);
            const endPage = Math.min(totalPages - 1, currentPage + 2);
            
            for (let i = startPage; i <= endPage; i++) {
                const active = i === currentPage ? ' active' : '';
                html += '<li class="page-item' + active + '"><a class="page-link" href="#" onclick="loadMembers(' + i + ')">' + (i + 1) + '</a></li>';
            }
            
            // 다음 페이지
            if (currentPage < totalPages - 1) {
                html += '<li class="page-item"><a class="page-link" href="#" onclick="loadMembers(' + (currentPage + 1) + ')">다음</a></li>';
            }

            $('#pagination').html(html);
            $('#paginationContainer').show();
        }

        // 회원 상태 변경
        function changeMemberStatus(userid, status) {
            if (!status) return;
            
            if (!confirm('회원 상태를 변경하시겠습니까?')) {
                location.reload(); // 셀렉트 박스 초기화
                return;
            }

            $.ajax({
                url: '<%=root%>/api/admin/members/' + userid + '/status',
                method: 'PUT',
                data: { status: status },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        alert(response.message);
                        loadMembers(currentPage);
                        loadMemberStats();
                } else {
                        alert('오류: ' + response.message);
                        location.reload();
                    }
                },
                error: function(xhr, status, error) {
                    console.error('상태 변경 오류:', error);
                    alert('서버 오류가 발생했습니다.');
                    location.reload();
                }
            });
        }

        // 회원 삭제
        function deleteMember(userid) {
            if (!confirm('정말로 이 회원을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) {
                return;
            }

            $.ajax({
                url: '<%=root%>/api/admin/members/' + userid,
                method: 'DELETE',
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        alert(response.message);
                        loadMembers(currentPage);
                        loadMemberStats();
                        } else {
                        alert('오류: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    console.error('회원 삭제 오류:', error);
                    alert('서버 오류가 발생했습니다.');
                }
            });
        }

        // 유틸리티 함수들
        function getProviderColor(provider) {
            switch(provider) {
                case 'naver': return 'success';
                case 'admin': return 'dark';
                default: return 'primary';
            }
        }

        function getStatusColor(status) {
            switch(status) {
                case 'A': return 'success';
                case 'B': return 'warning';
                case 'C': return 'danger';
                default: return 'secondary';
            }
        }

        function getStatusText(status) {
            switch(status) {
                case 'A': return '활성';
                case 'B': return '경고';
                case 'C': return '정지';
                default: return '알수없음';
            }
        }

        function formatDate(dateString) {
            if (!dateString) return '-';
            const date = new Date(dateString);
            return date.toLocaleDateString('ko-KR');
        }
    </script>
</body>
</html>