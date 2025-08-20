<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
    
    // 관리자 권한 확인
    String provider = (String)session.getAttribute("provider");
    if(provider == null || !"admin".equals(provider)) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 페이지 - WhereHot</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        .admin-container {
            margin-top: 50px;
        }
        .stats-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            padding: 20px;
            margin: 10px 0;
        }
        .member-table {
            margin-top: 30px;
        }
        .btn-action {
            margin: 0 2px;
        }
    </style>
</head>
<body>
    <div class="container admin-container">
        <div class="row">
            <div class="col-12">
                <h1 class="text-center mb-4">🛠️ 관리자 페이지</h1>
                
                <!-- 네비게이션 탭 -->
                <ul class="nav nav-tabs" id="adminTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="dashboard-tab" data-bs-toggle="tab" data-bs-target="#dashboard" type="button" role="tab">대시보드</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="members-tab" data-bs-toggle="tab" data-bs-target="#members" type="button" role="tab">회원 관리</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="posts-tab" data-bs-toggle="tab" data-bs-target="#posts" type="button" role="tab">게시글 관리</button>
                    </li>
                </ul>
                
                <!-- 탭 컨텐츠 -->
                <div class="tab-content" id="adminTabContent">
                    
                    <!-- 대시보드 -->
                    <div class="tab-pane fade show active" id="dashboard" role="tabpanel">
                        <div class="row mt-4">
                            <div class="col-12">
                                <h3>📊 시스템 통계</h3>
                                <div id="stats-container">
                                    <div class="text-center">
                                        <div class="spinner-border" role="status">
                                            <span class="visually-hidden">로딩중...</span>
                                        </div>
                                        <p>통계를 불러오는 중...</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 회원 관리 -->
                    <div class="tab-pane fade" id="members" role="tabpanel">
                        <div class="row mt-4">
                            <div class="col-12">
                                <h3>👥 회원 관리</h3>
                                
                                <!-- 검색 필터 -->
                                <div class="card mb-3">
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-3">
                                                <input type="text" id="searchKeyword" class="form-control" placeholder="검색어 (이름, 닉네임, 이메일)">
                                            </div>
                                            <div class="col-md-2">
                                                <select id="searchProvider" class="form-select">
                                                    <option value="">전체 제공자</option>
                                                    <option value="site">사이트</option>
                                                    <option value="naver">네이버</option>
                                                    <option value="admin">관리자</option>
                                                </select>
                                            </div>
                                            <div class="col-md-2">
                                                <select id="searchStatus" class="form-select">
                                                    <option value="">전체 상태</option>
                                                    <option value="A">활성</option>
                                                    <option value="B">경고</option>
                                                    <option value="C">정지</option>
                                                </select>
                                            </div>
                                            <div class="col-md-2">
                                                <button class="btn btn-primary" onclick="searchMembers()">검색</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- 회원 목록 -->
                                <div id="member-list-container">
                                    <div class="text-center">
                                        <div class="spinner-border" role="status">
                                            <span class="visually-hidden">로딩중...</span>
                                        </div>
                                        <p>회원 목록을 불러오는 중...</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 게시글 관리 -->
                    <div class="tab-pane fade" id="posts" role="tabpanel">
                        <div class="row mt-4">
                            <div class="col-12">
                                <h3>📝 게시글 관리</h3>
                                <div class="alert alert-info">
                                    <strong>개발 예정:</strong> 게시글 관리 기능은 추후 구현 예정입니다.
                                    <br>현재는 개별 게시글 삭제 API(/api/admin/posts/{postId})만 구현되어 있습니다.
                                </div>
                                
                                <!-- 테스트용 게시글 삭제 -->
                                <div class="card">
                                    <div class="card-header">
                                        <h5>게시글 삭제 테스트</h5>
                                    </div>
                                    <div class="card-body">
                                        <div class="input-group">
                                            <input type="number" id="deletePostId" class="form-control" placeholder="삭제할 게시글 ID 입력">
                                            <button class="btn btn-danger" onclick="deletePostById()">게시글 삭제</button>
                                        </div>
                                        <small class="text-muted">주의: 이 작업은 되돌릴 수 없습니다.</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                </div>
            </div>
        </div>
    </div>

    <!-- 관리자 JavaScript 로드 -->
    <script src="<%=root%>/js/admin.js"></script>
    
    <script>
        // 검색 함수
        function searchMembers() {
            const keyword = document.getElementById('searchKeyword').value;
            const provider = document.getElementById('searchProvider').value;
            const status = document.getElementById('searchStatus').value;
            loadMembers(0, 20, keyword, provider, status);
        }
        
        // 게시글 삭제 테스트
        function deletePostById() {
            const postId = document.getElementById('deletePostId').value;
            if (!postId) {
                alert('게시글 ID를 입력하세요.');
                return;
            }
            deletePost(parseInt(postId));
        }
        
        // Enter 키로 검색
        document.getElementById('searchKeyword').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                searchMembers();
            }
        });
        
        // 탭 변경시 데이터 로드
        document.getElementById('members-tab').addEventListener('shown.bs.tab', function() {
            loadMembers();
        });
        
        document.getElementById('dashboard-tab').addEventListener('shown.bs.tab', function() {
            loadMemberStats();
        });
    </script>
</body>
</html>
