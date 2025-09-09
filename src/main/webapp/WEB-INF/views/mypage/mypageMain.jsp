<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
%>
<!-- 마이페이지 전용 CSS -->
<link rel="stylesheet" href="<%=root%>/css/mypage.css">

<div class="mypage-container">
    <div class="container mt-4">
        <div class="row">
            <!-- 사이드바 -->
            <div class="col-md-3">
                                 <!-- 내 정보 카드 -->
                 <div class="card border-0 shadow-sm mb-4">
                     <div class="card-header bg-white border-bottom border-2 border-primary">
                         <h5 class="mb-0 fw-semibold text-dark"><i class="bi bi-person-circle me-2 text-primary"></i>내 정보</h5>
                     </div>
                     <div class="card-body p-4" id="profileInfo">
                         <div class="text-center">
                             <div class="spinner-border text-primary" role="status">
                                 <span class="visually-hidden">로딩중...</span>
                             </div>
                             <p class="mt-2 text-muted">프로필 로딩중...</p>
                         </div>
                     </div>
                 </div>

                                 <!-- 통계 카드 -->
                 <div class="card border-0 shadow-sm">
                     <div class="card-body p-4">
                         <h6 class="text-dark fw-semibold mb-3">내 활동</h6>
                         <div class="row text-center">
                             <div class="col-6">
                                 <h3 class="fw-bold text-primary mb-1" id="myPostCount">-</h3>
                                 <small class="text-muted">내 게시글</small>
                             </div>
                             <div class="col-6">
                                 <h3 class="fw-bold text-success mb-1" id="myWishCount">-</h3>
                                 <small class="text-muted">나의 장소</small>
                             </div>
                         </div>
                     </div>
                 </div>
            </div>

            <!-- 메인 컨텐츠 -->
            <div class="col-md-9">
                                 <div class="d-flex align-items-center mb-4">
                     <h2 class="mb-0 fw-bold text-dark">마이페이지</h2>
                     <div class="ms-3 px-3 py-1 bg-primary bg-opacity-10 rounded-pill">
                         <small class="text-primary fw-semibold">개인정보 관리</small>
                     </div>
                 </div>
                
                                 <!-- 프로필 수정 -->
                 <div class="card border-0 shadow-sm mb-4">
                     <div class="card-header bg-transparent border-0 pb-0">
                         <h5 class="mb-0 text-dark fw-semibold"><i class="bi bi-person-gear text-primary me-2"></i>프로필 수정</h5>
                     </div>
                     <div class="card-body pt-3">
                         <p class="text-muted mb-3">닉네임을 수정할 수 있습니다.</p>
                         <button type="button" class="btn btn-primary px-4" onclick="showProfileEditModal()">프로필 수정</button>
                     </div>
                 </div>

                 <!-- 비밀번호 변경 (OAuth2 사용자 제외) -->
                 <div class="card border-0 shadow-sm mb-4" id="passwordChangeSection">
                     <div class="card-header bg-transparent border-0 pb-0">
                         <h5 class="mb-0 text-dark fw-semibold"><i class="bi bi-key text-primary me-2"></i>비밀번호 변경</h5>
                     </div>
                     <div class="card-body pt-3">
                         <p class="text-muted mb-3">현재 비밀번호를 확인한 후 새 비밀번호로 변경할 수 있습니다.</p>
                         <button type="button" class="btn btn-outline-primary px-4" onclick="showPasswordChangeModal()">비밀번호 변경</button>
                     </div>
                 </div>

                                 <!-- 메뉴 -->
                 <div class="row g-3 mb-4">
                     <div class="col-md-6">
                         <div class="card border-0 shadow-sm h-100">
                             <div class="card-body text-center p-4">
                                 <i class="bi bi-geo-alt fs-1 text-primary mb-3"></i>
                                 <h5 class="fw-semibold text-dark mb-2">나의 장소</h5>
                                 <p class="text-muted mb-3">지도에서 찜한 장소 관리</p>
                                 <button class="btn btn-outline-primary px-4" onclick="showWishList()">보기</button>
                             </div>
                         </div>
                     </div>
                     
                     <div class="col-md-6">
                         <div class="card border-0 shadow-sm h-100">
                             <div class="card-body text-center p-4">
                                 <i class="bi bi-chat-dots fs-1 text-primary mb-3"></i>
                                 <h5 class="fw-semibold text-dark mb-2">내 게시글</h5>
                                 <p class="text-muted mb-3">작성한 게시글 관리</p>
                                 <button class="btn btn-outline-primary px-4" onclick="showMyPosts()">보기</button>
                             </div>
                         </div>
                     </div>
                 </div>
                 
                 <!-- 나의 MD 찜 -->
                 <div class="row mt-4">
                     <div class="col-12">
                         <div class="card border-0 shadow-sm">
                             <div class="card-body text-center p-4">
                                 <i class="bi bi-heart fs-1 text-danger mb-3"></i>
                                 <h5 class="fw-semibold text-dark mb-2">나의 MD 찜</h5>
                                 <p class="text-muted mb-3">찜한 MD 목록 관리</p>
                                 <button class="btn btn-outline-danger px-4" onclick="showMdWish()">보기</button>
                             </div>
                         </div>
                     </div>
                 </div>

                                 <!-- 회원 탈퇴 -->
                 <div class="card border-0 shadow-sm">
                     <div class="card-header bg-transparent border-0 pb-0">
                         <h5 class="mb-0 text-dark fw-semibold"><i class="bi bi-box-arrow-right text-danger me-2"></i>회원 탈퇴</h5>
                     </div>
                     <div class="card-body pt-3">
                         <div class="withdraw-warning">
                             <span class="text-danger fw-bold">주의!</span>
                             <span class="text-dark ms-2">회원 탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.</span>
                         </div>
                         <button class="btn btn-outline-danger px-4" onclick="showWithdraw()">회원 탈퇴</button>
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
                         <div class="mb-4">
                             <label class="form-label fw-semibold text-dark mb-2">닉네임</label>
                             <div class="d-flex gap-2">
                                 <input type="text" class="form-control form-control-lg" id="editNickname" name="nickname" 
                                        maxlength="7" placeholder="닉네임 입력" required>
                                 <button type="button" class="btn btn-primary px-4" onclick="checkNickname()">중복확인</button>
                             </div>
                             <div class="form-text text-muted mt-2">닉네임은 2~7자 사이로 입력해주세요.</div>
                             <div id="nicknameCheckResult" class="mt-2 small"></div>
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

    <!-- 비밀번호 확인 모달 -->
    <div class="modal fade" id="passwordVerifyModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">현재 비밀번호 확인</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="passwordVerifyForm">
                        <div class="mb-3">
                            <label class="form-label">현재 비밀번호</label>
                            <input type="password" class="form-control" id="currentPassword" placeholder="현재 비밀번호를 입력하세요" required>
                            <div id="currentPasswordResult" class="mt-1 small"></div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                    <button type="button" class="btn btn-primary" onclick="verifyCurrentPassword()">확인</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 비밀번호 변경 모달 -->
    <div class="modal fade" id="passwordChangeModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">새 비밀번호 설정</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="passwordChangeForm">
                        <div class="mb-3">
                            <label class="form-label">새 비밀번호</label>
                            <input type="password" class="form-control" id="newPassword" placeholder="새 비밀번호 (10자 이상, 영문+숫자+특수문자)" required>
                            <div id="newPasswordResult" class="mt-1 small"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">새 비밀번호 확인</label>
                            <input type="password" class="form-control" id="confirmPassword" placeholder="새 비밀번호를 다시 입력하세요" required>
                            <div id="confirmPasswordResult" class="mt-1 small"></div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                    <button type="button" class="btn btn-warning" onclick="changePassword()">비밀번호 변경</button>
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
                    <form id="withdrawForm">
                        <!-- 네이버 로그인 사용자용 메시지 -->
                        <div id="naverWithdrawMessage" class="alert alert-warning" style="display: none;">
                            <i class="bi bi-exclamation-triangle"></i>
                            <strong>네이버 로그인 사용자</strong><br>
                            탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.
                        </div>
                        
                        <!-- 일반 로그인 사용자용 비밀번호 입력 -->
                        <div id="passwordInputSection" class="mb-3" style="display: none;">
                            <label class="form-label">비밀번호 확인</label>
                            <input type="password" class="form-control" id="withdrawPassword">
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
            console.log('페이지 로드 완료');
            
            // JWT 토큰 확인
            const token = getJwtToken();
            console.log('JWT 토큰:', token ? '존재함' : '없음');
            
            if (!token) {
                alert('로그인이 필요합니다.');
                window.location.href = '<%=root%>/';
                return;
            }
            
            console.log('loadProfile 함수 호출 시작');
            loadProfile();
        });

        // JWT 토큰 가져오기
        function getJwtToken() {
            return localStorage.getItem('accessToken');
        }

        // API 요청 헤더 설정
        function getRequestHeaders() {
            const token = getJwtToken();
            return {
                'Authorization': 'Bearer ' + token,
                'Content-Type': 'application/json'
            };
        }

        // 프로필 정보 로드
        function loadProfile() {
            console.log('loadProfile 함수 호출됨');
            console.log('API URL:', '<%=root%>/mypage/api/user-info');
            console.log('Request Headers:', getRequestHeaders());
            
            $.ajax({
                url: '<%=root%>/mypage/api/user-info',
                method: 'GET',
                headers: getRequestHeaders(),
                success: function(response) {
                    console.log('프로필 정보 로드 성공:', response);
                    console.log('response.nickname:', response.nickname);
                    console.log('response.joindate:', response.joindate);
                    
                    // 깔끔한 HTML 생성 (흰색 배경에 맞춰 검정색 글자)
                    const htmlContent = 
                        '<div class="text-center">' +
                            '<i class="bi bi-person-circle fs-1 text-primary mb-3"></i>' +
                            '<h5 class="fw-bold text-dark mb-2">' + response.nickname + '</h5>' +
                            '<p class="text-dark mb-1">' + response.email + '</p>' +
                            '<small class="text-dark">가입일: ' + response.joindate + '</small>' +
                        '</div>';
                    
                                         $('#profileInfo').html(htmlContent);
                     
                     // 폼에 현재 값 설정 (닉네임만)
                     $('#editNickname').val(response.nickname);
                     
                     // 페이지 제목 업데이트 (닉네임 포함)
                     if (document.title.includes('님')) {
                         document.title = document.title.replace(/^.*님/, response.nickname + '님');
                     }
                     
                                         // OAuth2 사용자일 때 비밀번호 변경 섹션 숨기기
                    if (response.provider && response.provider !== 'site') {
                        console.log('OAuth2 사용자 감지 - 비밀번호 변경 섹션 숨김:', response.provider);
                        $('#passwordChangeSection').hide();
                    } else {
                        console.log('일반 사용자 - 비밀번호 변경 섹션 표시');
                        $('#passwordChangeSection').show();
                    }
                    
                    // 통계 정보도 함께 로드
                    loadStats();
                },
                error: function(xhr, status, error) {
                    console.error('프로필 정보 로드 오류:', error);
                    console.error('Status:', status);
                    console.error('Response Text:', xhr.responseText);
                    console.error('Status Code:', xhr.status);
                    
                    if (xhr.status === 401) {
                        alert('인증이 만료되었습니다. 다시 로그인해주세요.');
                        localStorage.removeItem('accessToken');
                        window.location.href = '<%=root%>/';
                    } else {
                        $('#profileInfo').html(`
                            <div class="text-center text-dark">
                                <i class="bi bi-exclamation-triangle fs-1 text-danger"></i>
                                <p class="mt-2 text-dark">프로필 정보를 불러올 수 없습니다.</p>
                                <small class="text-muted">상태: ${status}, 오류: ${error}</small>
                            </div>
                        `);
                    }
                }
            });
        }

        // 통계 정보 로드
        function loadStats() {
            $.ajax({
                url: '<%=root%>/mypage/api/stats',
                method: 'GET',
                headers: getRequestHeaders(),
                success: function(response) {
                    // course와 hpost 게시물 개수를 합쳐서 표시
                    const totalPostCount = (response.courseCount || 0) + (response.hpostCount || 0);
                    $('#myPostCount').text(totalPostCount);
                    $('#myWishCount').text(response.wishCount || 0);
                },
                error: function(xhr, status, error) {
                    console.error('통계 정보 로드 오류:', error);
                    $('#myPostCount').text('0');
                    $('#myWishCount').text('0');
                }
            });
        }

        // 닉네임 중복 확인
        function checkNickname() {
            const nickname = $('#editNickname').val().trim();
            if (!nickname) {
                $('#nicknameCheckResult').text('닉네임을 입력하세요.').removeClass('text-success').addClass('text-danger');
                return;
            }

            $.ajax({
                url: '<%=root%>/api/member/check-nickname',
                method: 'GET',
                data: { nickname: nickname },
                success: function(response) {
                    if (response.available) {
                        $('#nicknameCheckResult').text('사용 가능한 닉네임입니다.').removeClass('text-danger').addClass('text-success');
                        window.nicknameAvailable = true;
                    } else {
                        $('#nicknameCheckResult').text('이미 사용 중인 닉네임입니다.').removeClass('text-success').addClass('text-danger');
                        window.nicknameAvailable = false;
                    }
                },
                error: function(xhr, status, error) {
                    console.error('닉네임 중복 확인 오류:', error);
                    $('#nicknameCheckResult').text('확인 중 오류가 발생했습니다.').removeClass('text-success').addClass('text-danger');
                }
            });
        }

                 // 프로필 수정 모달 표시
         function showProfileEditModal() {
             // 현재 프로필 정보로 폼 초기화 (닉네임만)
             const currentNickname = $('#profileInfo h5').text();
             
             $('#editNickname').val(currentNickname);
             $('#nicknameCheckResult').text('').removeClass('text-success text-danger');
             window.nicknameAvailable = false;
             
             $('#profileEditModal').modal('show');
         }

        // 프로필 업데이트
        function updateProfile() {
            const nickname = $('#editNickname').val().trim();
            
            if (!nickname) {
                alert('닉네임을 입력하세요.');
                return;
            }

            if (nickname.length < 2) {
                alert('닉네임은 최소 2자 이상 입력해주세요.');
                return;
            }
            
            if (nickname.length > 7) {
                alert('닉네임은 최대 7자까지 입력 가능합니다.');
                return;
            }

            if (!window.nicknameAvailable) {
                alert('닉네임 중복 확인을 먼저 해주세요.');
                return;
            }
            
            $.ajax({
                url: '<%=root%>/mypage/api/update-profile',
                method: 'POST',
                headers: getRequestHeaders(),
                data: JSON.stringify({
                    nickname: nickname
                }),
                success: function(response) {
                    alert(response.message);
                    $('#profileEditModal').modal('hide');
                    
                    // 새로운 JWT 토큰으로 localStorage 업데이트
                    if (response.newToken) {
                        localStorage.setItem('accessToken', response.newToken);
                        console.log('새로운 JWT 토큰으로 업데이트됨');
                    }
                    
                    // 프로필 정보 다시 로드
                    loadProfile();
                    
                    // 페이지 제목 업데이트 (닉네임 포함)
                    const newNickname = response.nickname || $('#editNickname').val().trim();
                    if (document.title.includes('님')) {
                        document.title = document.title.replace(/^.*님/, newNickname + '님');
                    }
                    
                    // 로컬 스토리지의 사용자 정보 업데이트
                    const userInfo = localStorage.getItem('userInfo');
                    if (userInfo) {
                        try {
                            const user = JSON.parse(userInfo);
                            user.nickname = newNickname;
                            localStorage.setItem('userInfo', JSON.stringify(user));
                        } catch (e) {
                            console.log('사용자 정보 업데이트 실패:', e);
                        }
                    }
                    
                    // 페이지 새로고침으로 모든 곳의 닉네임 동기화
                    setTimeout(function() {
                        location.reload();
                    }, 500);
                    
                    // 중복 확인 초기화
                    window.nicknameAvailable = false;
                    $('#nicknameCheckResult').text('').removeClass('text-success text-danger');
                },
                error: function(xhr, status, error) {
                    console.error('프로필 수정 오류:', error);
                    if (xhr.responseJSON && xhr.responseJSON.error) {
                        alert('오류: ' + xhr.responseJSON.error);
                    } else {
                        alert('프로필 수정 중 오류가 발생했습니다.');
                    }
                }
            });
        }

        // 비밀번호 변경 모달 표시
        function showPasswordChangeModal() {
            // 폼 초기화
            $('#currentPassword').val('');
            $('#currentPasswordResult').text('').removeClass('text-success text-danger');
            
            // 전역 변수는 초기화하지 않음 (이전 세션의 값이 남아있을 수 있음)
            console.log('비밀번호 변경 시작 - 첫 번째 모달 열림');
            
            $('#passwordVerifyModal').modal('show');
        }

        // 현재 비밀번호 확인
        function verifyCurrentPassword() {
            const currentPassword = $('#currentPassword').val();
            if (!currentPassword) {
                $('#currentPasswordResult').text('현재 비밀번호를 입력하세요.').removeClass('text-success').addClass('text-danger');
                return;
            }

            $.ajax({
                url: '<%=root%>/mypage/api/verify-password',
                method: 'POST',
                headers: getRequestHeaders(),
                data: JSON.stringify({
                    password: currentPassword
                }),
                success: function(response) {
                    if (response.verified) {
                        // 비밀번호 확인 성공 시 비밀번호 변경 모달 표시
                        $('#passwordVerifyModal').modal('hide');
                        
                        // 현재 비밀번호를 전역 변수에 저장 (두 번째 모달에서 사용)
                        window.verifiedCurrentPassword = currentPassword;
                        console.log('현재 비밀번호 저장됨:', window.verifiedCurrentPassword);
                        
                        // 새 비밀번호 입력 폼 초기화
                        $('#newPassword, #confirmPassword').val('');
                        $('#newPasswordResult, #confirmPasswordResult').text('').removeClass('text-success text-danger');
                        
                        $('#passwordChangeModal').modal('show');
                    } else {
                        $('#currentPasswordResult').text('비밀번호가 일치하지 않습니다.').removeClass('text-success').addClass('text-danger');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('비밀번호 확인 오류:', error);
                    $('#currentPasswordResult').text('확인 중 오류가 발생했습니다.').removeClass('text-success').addClass('text-danger');
                }
            });
        }

        // 비밀번호 변경
        function changePassword() {
            const newPassword = $('#newPassword').val();
            const confirmPassword = $('#confirmPassword').val();

            if (!newPassword || !confirmPassword) {
                alert('모든 필드를 입력하세요.');
                return;
            }

            if (newPassword !== confirmPassword) {
                alert('새 비밀번호가 일치하지 않습니다.');
                return;
            }

            // 비밀번호 규칙 검증 (회원가입과 동일)
            const regex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\[\]{};':"\\|,.<>\/?]).{10,}$/;
            if (!regex.test(newPassword)) {
                alert('비밀번호는 10자 이상, 영문+숫자+특수문자를 포함해야 합니다.');
                return;
            }

            // 전역 변수 확인
            console.log('저장된 현재 비밀번호:', window.verifiedCurrentPassword);
            console.log('새 비밀번호:', newPassword);

            if (!window.verifiedCurrentPassword) {
                alert('현재 비밀번호가 확인되지 않았습니다. 다시 시도해주세요.');
                return;
            }

            $.ajax({
                url: '<%=root%>/mypage/api/change-password',
                method: 'POST',
                headers: getRequestHeaders(),
                data: JSON.stringify({
                    currentPassword: window.verifiedCurrentPassword,
                    newPassword: newPassword
                }),
                success: function(response) {
                    alert(response.message + '\n보안을 위해 자동으로 로그아웃됩니다.');
                    $('#passwordChangeModal').modal('hide');
                    
                    // 모든 모달 폼 초기화
                    $('#currentPassword, #newPassword, #confirmPassword').val('');
                    $('#currentPasswordResult, #newPasswordResult, #confirmPasswordResult').text('').removeClass('text-success text-danger');
                    
                    // 전역 변수 초기화
                    window.verifiedCurrentPassword = null;
                    
                    // 비밀번호 변경 완료 후 자동 로그아웃
                    setTimeout(function() {
                        localStorage.removeItem('accessToken');
                        alert('로그아웃되었습니다. 새로운 비밀번호로 다시 로그인해주세요.');
                        window.location.href = '<%=root%>/';
                    }, 1000);
                },
                error: function(xhr, status, error) {
                    console.error('비밀번호 변경 오류:', error);
                    if (xhr.responseJSON && xhr.responseJSON.error) {
                        alert('오류: ' + xhr.responseJSON.error);
                    } else {
                        alert('비밀번호 변경 중 오류가 발생했습니다.');
                    }
                }
            });
        }

        // 찜 목록 보기 (나의 장소)
        function showWishList() {
            window.location.href = '<%=root%>/mypage/wishlist';
        }

        // 내 게시글 보기
        function showMyPosts() {
            window.location.href = '<%=root%>/mypage/posts';
        }

        // 전역 변수로 사용자 정보 저장
        let currentUserInfo = null;

        // 회원 탈퇴 모달 표시
        function showWithdraw() {
            // 사용자 정보가 없으면 먼저 로드
            if (!currentUserInfo) {
                loadUserInfo().then(() => {
                    setupWithdrawModal();
                    $('#withdrawModal').modal('show');
                });
            } else {
                setupWithdrawModal();
                $('#withdrawModal').modal('show');
            }
        }

        // 사용자 정보 로드
        function loadUserInfo() {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: '<%=root%>/mypage/api/user-info-for-withdraw',
                    method: 'GET',
                    headers: getRequestHeaders(),
                    success: function(response) {
                        currentUserInfo = response;
                        resolve(response);
                    },
                    error: function(xhr, status, error) {
                        console.error('사용자 정보 로드 오류:', error);
                        reject(error);
                    }
                });
            });
        }

        // 탈퇴 모달 설정
        function setupWithdrawModal() {
            if (!currentUserInfo) return;

            // 모달 초기화
            $('#withdrawPassword').val('');
            $('#withdrawConfirm').prop('checked', false);

            // 네이버 로그인 사용자인지 확인
            if (currentUserInfo.provider === 'naver') {
                $('#naverWithdrawMessage').show();
                $('#passwordInputSection').hide();
                $('#withdrawPassword').removeAttr('required');
            } else {
                $('#naverWithdrawMessage').hide();
                $('#passwordInputSection').show();
                $('#withdrawPassword').attr('required', 'required');
            }
        }

        // 회원 탈퇴
        function withdrawMember() {
            const password = $('#withdrawPassword').val();
            const confirmed = $('#withdrawConfirm').is(':checked');

            if (!confirmed) {
                alert('탈퇴 동의에 체크해주세요.');
                return;
            }

            // 일반 로그인 사용자는 비밀번호 확인
            if (currentUserInfo && currentUserInfo.provider !== 'naver') {
                if (!password || password.trim() === '') {
                    alert('비밀번호를 입력하세요.');
                    return;
                }
            }

            // 최종 확인
            const confirmMessage = currentUserInfo && currentUserInfo.provider === 'naver' 
                ? '정말로 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.'
                : '정말로 탈퇴하시겠습니까?\n이 작업은 되돌릴 수 없습니다.';

            if (!confirm(confirmMessage)) {
                return;
            }

            // 탈퇴 요청 데이터 준비
            const withdrawData = {};
            if (currentUserInfo && currentUserInfo.provider !== 'naver') {
                withdrawData.password = password;
            }

            $.ajax({
                url: '<%=root%>/mypage/api/withdraw',
                method: 'POST',
                headers: getRequestHeaders(),
                data: JSON.stringify(withdrawData),
                success: function(response) {
                    alert(response.message);
                    localStorage.removeItem('accessToken');
                    localStorage.removeItem('refreshToken');
                    localStorage.removeItem('userInfo');
                    window.location.href = '<%=root%>/';
                },
                error: function(xhr, status, error) {
                    console.error('탈퇴 오류:', error);
                    if (xhr.responseJSON && xhr.responseJSON.error) {
                        alert('오류: ' + xhr.responseJSON.error);
                    } else {
                        alert('탈퇴 처리 중 오류가 발생했습니다.');
                    }
                }
            });
        }

        // 비밀번호 입력 시 실시간 검증
        $('#newPassword').on('input', function() {
            const password = $(this).val();
            const regex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\[\]{};':"\\|,.<>\/?]).{10,}$/;
            
            if (password === '') {
                $('#newPasswordResult').text('').removeClass('text-success text-danger');
            } else if (regex.test(password)) {
                $('#newPasswordResult').text('사용가능한 비밀번호입니다.').removeClass('text-danger').addClass('text-success');
            } else {
                $('#newPasswordResult').text('10자 이상, 영문+숫자+특수문자 포함 필수').removeClass('text-success').addClass('text-danger');
            }
        });

        // 비밀번호 확인 입력 시 실시간 검증
        $('#confirmPassword').on('input', function() {
            const newPassword = $('#newPassword').val();
            const confirmPassword = $(this).val();
            
            if (newPassword === '' || confirmPassword === '') {
                $('#confirmPasswordResult').text('').removeClass('text-success text-danger');
                return;
            }
            
            if (newPassword === confirmPassword) {
                $('#confirmPasswordResult').text('비밀번호가 일치합니다.').removeClass('text-danger').addClass('text-success');
            } else {
                $('#confirmPasswordResult').text('비밀번호가 일치하지 않습니다.').removeClass('text-success').addClass('text-danger');
            }
        });

        // MD 찜 목록으로 이동
        function showMdWish() {
            window.location.href = '<%=root%>/mypage/mdwish';
        }
        
        // 모달이 닫힐 때 폼 초기화
        $('#profileEditModal').on('hidden.bs.modal', function() {
            $('#editNickname').val('');
            $('#nicknameCheckResult').text('').removeClass('text-success text-danger');
            window.nicknameAvailable = false;
        });

        $('#passwordVerifyModal').on('hidden.bs.modal', function() {
            $('#currentPassword').val('');
            $('#currentPasswordResult').text('').removeClass('text-success text-danger');
            // 첫 번째 모달이 닫힐 때는 전역 변수를 초기화하지 않음
            // 두 번째 모달에서 사용해야 하므로
        });

        $('#passwordChangeModal').on('hidden.bs.modal', function() {
            $('#newPassword, #confirmPassword').val('');
            $('#newPasswordResult, #confirmPasswordResult').text('').removeClass('text-success text-danger');
            // 두 번째 모달이 닫힐 때 전역 변수 초기화
            window.verifiedCurrentPassword = null;
            console.log('두 번째 모달 닫힘 - 전역 변수 초기화됨');
        });
    </script>
</div>
