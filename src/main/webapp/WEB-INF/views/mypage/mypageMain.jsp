<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    
    // 로그인하지 않은 경우 처리
    if(loginId == null) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>마이페이지 - WhereHot</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- 마이페이지 전용 CSS -->
    <link rel="stylesheet" href="<%=root%>/css/mypage.css">
    <style>
        .mypage-container { margin-top: 30px; }
        .profile-card { border: none; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .stats-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
        .menu-card:hover { transform: translateY(-5px); transition: all 0.3s; }
    </style>
</head>
<body>
    <div class="container mypage-container">
        <div class="row">
            <!-- 사이드바 -->
            <div class="col-md-3">
                <div class="card profile-card">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0"><i class="bi bi-person-circle"></i> 내 정보</h5>
                    </div>
                    <div class="card-body" id="profileInfo">
                        <div class="text-center">
                            <div class="spinner-border" role="status">
                                <span class="visually-hidden">로딩중...</span>
                            </div>
                            <p class="mt-2">프로필 로딩중...</p>
                        </div>
                    </div>
                </div>

                <!-- 통계 -->
                <div class="card stats-card mt-3">
                    <div class="card-body">
                        <h6>내 활동</h6>
                        <div class="row text-center">
                            <div class="col-6">
                                <h4 id="myPostCount">-</h4>
                                <small>내 게시글</small>
                            </div>
                            <div class="col-6">
                                <h4 id="myWishCount">-</h4>
                                <small>찜 목록</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 메인 컨텐츠 -->
            <div class="col-md-9">
                <h2 class="mb-4">마이페이지</h2>
                
                <!-- 메뉴 -->
                <div class="row g-3">
                    <div class="col-md-6">
                        <div class="card menu-card h-100">
                            <div class="card-body text-center">
                                <i class="bi bi-person-gear fs-1 text-primary"></i>
                                <h5 class="mt-3">프로필 수정</h5>
                                <p class="text-muted">개인정보 및 프로필 관리</p>
                                <button class="btn btn-primary" onclick="showProfileEdit()">수정하기</button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="card menu-card h-100">
                            <div class="card-body text-center">
                                <i class="bi bi-key fs-1 text-warning"></i>
                                <h5 class="mt-3">비밀번호 변경</h5>
                                <p class="text-muted">계정 보안 관리</p>
                                <button class="btn btn-warning" onclick="showPasswordChange()">변경하기</button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="card menu-card h-100">
                            <div class="card-body text-center">
                                <i class="bi bi-heart fs-1 text-danger"></i>
                                <h5 class="mt-3">찜 목록</h5>
                                <p class="text-muted">관심 장소 및 미팅 관리</p>
                                <button class="btn btn-danger" onclick="showWishList()">보기</button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="card menu-card h-100">
                            <div class="card-body text-center">
                                <i class="bi bi-chat-dots fs-1 text-success"></i>
                                <h5 class="mt-3">내 게시글</h5>
                                <p class="text-muted">작성한 게시글 관리</p>
                                <button class="btn btn-success" onclick="showMyPosts()">보기</button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-12">
                        <div class="card menu-card">
                            <div class="card-body text-center">
                                <i class="bi bi-box-arrow-right fs-1 text-secondary"></i>
                                <h5 class="mt-3 text-danger">회원 탈퇴</h5>
                                <p class="text-muted">계정을 완전히 삭제합니다</p>
                                <button class="btn btn-outline-danger" onclick="showWithdraw()">탈퇴하기</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 프로필 수정 모달 -->
    <div class="modal fade" id="profileEditModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">프로필 수정</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="profileForm">
                        <div class="mb-3">
                            <label class="form-label">이름</label>
                            <input type="text" class="form-control" id="editName" name="name">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">닉네임</label>
                            <input type="text" class="form-control" id="editNickname" name="nickname">
                            <button type="button" class="btn btn-sm btn-outline-primary mt-1" onclick="checkNickname()">중복확인</button>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">이메일</label>
                            <input type="email" class="form-control" id="editEmail" name="email">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">전화번호</label>
                            <input type="tel" class="form-control" id="editPhone" name="phone">
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                    <button type="button" class="btn btn-primary" onclick="updateProfile()">저장</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 비밀번호 변경 모달 -->
    <div class="modal fade" id="passwordChangeModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">비밀번호 변경</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="passwordForm">
                        <div class="mb-3">
                            <label class="form-label">현재 비밀번호</label>
                            <input type="password" class="form-control" id="currentPassword" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">새 비밀번호</label>
                            <input type="password" class="form-control" id="newPassword" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">새 비밀번호 확인</label>
                            <input type="password" class="form-control" id="confirmPassword" required>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                    <button type="button" class="btn btn-warning" onclick="changePassword()">변경</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 회원 탈퇴 모달 -->
    <div class="modal fade" id="withdrawModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title text-danger">회원 탈퇴</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="alert alert-danger">
                        <strong>주의!</strong> 회원 탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.
                    </div>
                    <form id="withdrawForm">
                        <div class="mb-3">
                            <label class="form-label">비밀번호 확인</label>
                            <input type="password" class="form-control" id="withdrawPassword" required>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="withdrawConfirm" required>
                            <label class="form-check-label" for="withdrawConfirm">
                                위 내용을 확인했으며 회원 탈퇴에 동의합니다.
                            </label>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                    <button type="button" class="btn btn-danger" onclick="withdrawMember()">탈퇴하기</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // 페이지 로드시 초기화
        $(document).ready(function() {
            loadProfile();
        });

        // 프로필 정보 로드
        function loadProfile() {
            // 현재는 세션 정보만 표시
            $('#profileInfo').html(`
                <div class="text-center">
                    <i class="bi bi-person-circle fs-1 text-primary"></i>
                    <h6 class="mt-2"><%=loginId%></h6>
                    <small class="text-muted">로그인 중</small>
                </div>
                <hr>
                <div class="alert alert-info">
                    <small>
                        <strong>API 구현 필요:</strong><br>
                        GET /api/member/profile<br>
                        회원 상세 정보 조회
                    </small>
                </div>
            `);

            // 통계 정보 임시 설정
            $('#myPostCount').text('N/A');
            $('#myWishCount').text('N/A');
        }

        // 프로필 수정 모달 표시
        function showProfileEdit() {
            $('#profileEditModal').modal('show');
        }

        // 프로필 업데이트
        function updateProfile() {
            alert('프로필 업데이트 API 구현 필요:\nPUT /api/member/profile');
        }

        // 닉네임 중복 확인
        function checkNickname() {
            const nickname = $('#editNickname').val();
            if (!nickname) {
                alert('닉네임을 입력하세요.');
                return;
            }
            alert('닉네임 중복 확인 API 구현 필요:\nGET /api/member/check-nickname?nickname=' + nickname);
        }

        // 비밀번호 변경 모달 표시
        function showPasswordChange() {
            $('#passwordChangeModal').modal('show');
        }

        // 비밀번호 변경
        function changePassword() {
            const current = $('#currentPassword').val();
            const newPwd = $('#newPassword').val();
            const confirm = $('#confirmPassword').val();

            if (!current || !newPwd || !confirm) {
                alert('모든 필드를 입력하세요.');
                return;
            }

            if (newPwd !== confirm) {
                alert('새 비밀번호가 일치하지 않습니다.');
                return;
            }

            alert('비밀번호 변경 API 구현 필요:\nPUT /api/member/password');
        }

        // 찜 목록 보기
        function showWishList() {
            alert('찜 목록 API 구현 필요:\nGET /api/member/wishes');
        }

        // 내 게시글 보기
        function showMyPosts() {
            alert('내 게시글 API 구현 필요:\nGET /api/member/posts');
        }

        // 회원 탈퇴 모달 표시
        function showWithdraw() {
            $('#withdrawModal').modal('show');
        }

        // 회원 탈퇴
        function withdrawMember() {
            const password = $('#withdrawPassword').val();
            const confirmed = $('#withdrawConfirm').is(':checked');

            if (!password) {
                alert('비밀번호를 입력하세요.');
                return;
            }

            if (!confirmed) {
                alert('탈퇴 동의에 체크해주세요.');
                return;
            }

            if (!confirm('정말로 탈퇴하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) {
                return;
            }

            // 실제 API 호출
            $.ajax({
                url: '<%=root%>/api/member/withdraw',
                method: 'DELETE',
                data: { password: password },
                dataType: 'json',
                success: function(response) {
                    if (response.result) {
                        alert(response.message);
                        window.location.href = '<%=root%>/index.jsp';
                    } else {
                        alert('오류: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    console.error('탈퇴 오류:', error);
                    alert('서버 오류가 발생했습니다.');
                }
            });
        }
    </script>
</body>
</html>