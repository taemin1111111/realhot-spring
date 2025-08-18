<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
%>

<!-- JWT 기반 마이페이지 - 세션 의존성 완전 제거 -->
<div class="mypage-container">
    <!-- 로딩 스피너 -->
    <div id="loading-spinner" class="text-center p-5">
        <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">로딩 중...</span>
        </div>
        <p class="mt-3">사용자 정보를 불러오는 중입니다...</p>
    </div>

    <!-- 마이페이지 메인 콘텐츠 (로딩 완료 후 표시) -->
    <div id="mypage-content" style="display: none;">
        
        <!-- 🙋 사용자 프로필 영역 -->
        <div class="profile-section mb-5">
            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <div class="row align-items-center">
                        <div class="col-md-2 text-center">
                            <div class="profile-avatar">
                                <i class="bi bi-person-circle display-3 text-secondary"></i>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <h4 class="mb-1" id="user-nickname">닉네임</h4>
                            <p class="text-muted mb-1" id="user-id">@userid</p>
                            <p class="text-muted mb-0">
                                <i class="bi bi-calendar-plus"></i> 
                                가입일: <span id="user-joindate">-</span>
                            </p>
                            <p class="text-muted mb-0">
                                <i class="bi bi-envelope"></i> 
                                <span id="user-email">이메일</span>
                            </p>
                        </div>
                        <div class="col-md-4 text-end">
                            <button class="btn btn-outline-primary me-2" onclick="showEditProfileModal()">
                                <i class="bi bi-pencil"></i> 프로필 수정
                            </button>
                            <button class="btn btn-outline-secondary" onclick="showChangePasswordModal()">
                                <i class="bi bi-key"></i> 비밀번호 변경
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 📊 통계 요약 영역 -->
        <div class="stats-section mb-5">
            <div class="row g-3">
                <div class="col-md-3">
                    <div class="card text-center h-100">
                        <div class="card-body">
                            <i class="bi bi-heart-fill text-danger display-6"></i>
                            <h5 class="card-title mt-2">위시리스트</h5>
                            <h3 class="text-danger" id="wish-count">0</h3>
                            <small class="text-muted">개의 핫플레이스</small>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center h-100">
                        <div class="card-body">
                            <i class="bi bi-file-post text-primary display-6"></i>
                            <h5 class="card-title mt-2">내 게시글</h5>
                            <h3 class="text-primary" id="post-count">0</h3>
                            <small class="text-muted">개의 게시글</small>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center h-100">
                        <div class="card-body">
                            <i class="bi bi-chat-dots text-success display-6"></i>
                            <h5 class="card-title mt-2">내 댓글</h5>
                            <h3 class="text-success" id="comment-count">0</h3>
                            <small class="text-muted">개의 댓글</small>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center h-100">
                        <div class="card-body">
                            <i class="bi bi-person-hearts text-warning display-6"></i>
                            <h5 class="card-title mt-2">찜한 MD</h5>
                            <h3 class="text-warning" id="md-wish-count">0</h3>
                            <small class="text-muted">명의 MD</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 📋 탭 메뉴 -->
        <ul class="nav nav-tabs mb-4" id="mypageTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="wishlist-tab" data-bs-toggle="tab" data-bs-target="#wishlist" type="button" role="tab">
                    <i class="bi bi-heart"></i> 위시리스트
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="posts-tab" data-bs-toggle="tab" data-bs-target="#posts" type="button" role="tab">
                    <i class="bi bi-file-post"></i> 내 게시글
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="comments-tab" data-bs-toggle="tab" data-bs-target="#comments" type="button" role="tab">
                    <i class="bi bi-chat-dots"></i> 내 댓글
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="md-wishes-tab" data-bs-toggle="tab" data-bs-target="#md-wishes" type="button" role="tab">
                    <i class="bi bi-person-hearts"></i> 찜한 MD
                </button>
            </li>
        </ul>

        <!-- 📋 탭 콘텐츠 -->
        <div class="tab-content" id="mypageTabContent">
            <!-- 위시리스트 탭 -->
            <div class="tab-pane fade show active" id="wishlist" role="tabpanel">
                <div id="wishlist-content">
                    <div class="text-center p-4">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">로딩 중...</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 내 게시글 탭 -->
            <div class="tab-pane fade" id="posts" role="tabpanel">
                <div id="posts-content">
                    <div class="text-center p-4">
                        <p class="text-muted">게시글 탭을 클릭하면 로드됩니다.</p>
                    </div>
                </div>
            </div>

            <!-- 내 댓글 탭 -->
            <div class="tab-pane fade" id="comments" role="tabpanel">
                <div id="comments-content">
                    <div class="text-center p-4">
                        <p class="text-muted">댓글 탭을 클릭하면 로드됩니다.</p>
                    </div>
                </div>
            </div>

            <!-- 찜한 MD 탭 -->
            <div class="tab-pane fade" id="md-wishes" role="tabpanel">
                <div id="md-wishes-content">
                    <div class="text-center p-4">
                        <p class="text-muted">찜한 MD 탭을 클릭하면 로드됩니다.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 🚨 계정 관리 영역 -->
        <div class="account-management-section mt-5">
            <div class="card border-danger">
                <div class="card-header bg-danger text-white">
                    <h5 class="mb-0"><i class="bi bi-exclamation-triangle"></i> 계정 관리</h5>
                </div>
                <div class="card-body">
                    <p class="text-muted">계정 삭제는 복구할 수 없습니다. 신중히 결정해 주세요.</p>
                    <button class="btn btn-danger" onclick="showWithdrawModal()">
                        <i class="bi bi-person-x"></i> 회원 탈퇴
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- 인증 실패 시 표시 -->
    <div id="auth-error" style="display: none;" class="text-center p-5">
        <i class="bi bi-shield-exclamation display-3 text-danger"></i>
        <h3 class="mt-3">인증이 필요합니다</h3>
        <p class="text-muted">로그인 후 이용해 주세요.</p>
        <button class="btn btn-primary" onclick="window.location.href='<%=root%>/'">
            메인으로 돌아가기
        </button>
    </div>
</div>

<!-- 프로필 수정 모달 -->
<div class="modal fade" id="editProfileModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">프로필 수정</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="editProfileForm">
                    <div class="mb-3">
                        <label for="edit-nickname" class="form-label">닉네임</label>
                        <input type="text" class="form-control" id="edit-nickname" required>
                    </div>
                    <div class="mb-3">
                        <label for="edit-email" class="form-label">이메일</label>
                        <input type="email" class="form-control" id="edit-email" required>
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
<div class="modal fade" id="changePasswordModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">비밀번호 변경</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="changePasswordForm">
                    <div class="mb-3">
                        <label for="current-password" class="form-label">현재 비밀번호</label>
                        <input type="password" class="form-control" id="current-password" required>
                    </div>
                    <div class="mb-3">
                        <label for="new-password" class="form-label">새 비밀번호</label>
                        <input type="password" class="form-control" id="new-password" required>
                    </div>
                    <div class="mb-3">
                        <label for="confirm-password" class="form-label">새 비밀번호 확인</label>
                        <input type="password" class="form-control" id="confirm-password" required>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" onclick="changePassword()">변경</button>
            </div>
        </div>
    </div>
</div>

<!-- 회원 탈퇴 모달 -->
<div class="modal fade" id="withdrawModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">회원 탈퇴</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="alert alert-danger">
                    <i class="bi bi-exclamation-triangle"></i>
                    <strong>주의!</strong> 회원 탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.
                </div>
                <form id="withdrawForm">
                    <div class="mb-3">
                        <label for="withdraw-password" class="form-label">비밀번호 확인</label>
                        <input type="password" class="form-control" id="withdraw-password" required>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="withdraw-confirm">
                        <label class="form-check-label" for="withdraw-confirm">
                            위 내용을 확인했으며, 회원 탈퇴에 동의합니다.
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
// JWT 토큰 기반 마이페이지 관리
let currentUser = null;

// 페이지 로드 시 인증 확인 및 데이터 로드
document.addEventListener('DOMContentLoaded', function() {
    loadUserData();
    setupTabEvents();
});

// 사용자 데이터 로드
async function loadUserData() {
    try {
        const token = localStorage.getItem('accessToken');
        if (!token) {
            showAuthError();
            return;
        }

        // 사용자 정보 조회
        const response = await fetch('<%=root%>/api/mypage/user-info', {
            headers: {
                'Authorization': 'Bearer ' + token
            }
        });

        if (!response.ok) {
            throw new Error('사용자 정보 조회 실패');
        }

        const userData = await response.json();
        currentUser = userData;

        // UI 업데이트
        updateUserProfile(userData);
        
        // 위시리스트 로드 (기본 탭)
        loadWishlist();
        
        // 로딩 완료
        document.getElementById('loading-spinner').style.display = 'none';
        document.getElementById('mypage-content').style.display = 'block';

    } catch (error) {
        console.error('사용자 데이터 로드 오류:', error);
        showAuthError();
    }
}

// 사용자 프로필 UI 업데이트
function updateUserProfile(userData) {
    document.getElementById('user-nickname').textContent = userData.nickname || userData.userid;
    document.getElementById('user-id').textContent = '@' + userData.userid;
    document.getElementById('user-email').textContent = userData.email || '이메일 없음';
    
    if (userData.joindate) {
        const joinDate = new Date(userData.joindate);
        document.getElementById('user-joindate').textContent = joinDate.toLocaleDateString('ko-KR');
    }
}

// 탭 이벤트 설정
function setupTabEvents() {
    document.getElementById('wishlist-tab').addEventListener('click', loadWishlist);
    document.getElementById('posts-tab').addEventListener('click', loadUserPosts);
    document.getElementById('comments-tab').addEventListener('click', loadUserComments);
    document.getElementById('md-wishes-tab').addEventListener('click', loadMdWishes);
}

// 위시리스트 로드
async function loadWishlist() {
    try {
        const token = localStorage.getItem('accessToken');
        const response = await fetch('<%=root%>/api/mypage/wishlist', {
            headers: {
                'Authorization': 'Bearer ' + token
            }
        });

        if (response.ok) {
            const data = await response.json();
            document.getElementById('wish-count').textContent = data.totalCount || 0;
            renderWishlist(data.wishlist || []);
        }
    } catch (error) {
        console.error('위시리스트 로드 오류:', error);
    }
}

// 사용자 게시글 로드
async function loadUserPosts() {
    try {
        const token = localStorage.getItem('accessToken');
        const response = await fetch('<%=root%>/api/mypage/posts', {
            headers: {
                'Authorization': 'Bearer ' + token
            }
        });

        if (response.ok) {
            const data = await response.json();
            document.getElementById('post-count').textContent = data.totalCount || 0;
            renderUserPosts(data.posts || []);
        }
    } catch (error) {
        console.error('게시글 로드 오류:', error);
    }
}

// 사용자 댓글 로드
async function loadUserComments() {
    try {
        const token = localStorage.getItem('accessToken');
        const response = await fetch('<%=root%>/api/mypage/comments', {
            headers: {
                'Authorization': 'Bearer ' + token
            }
        });

        if (response.ok) {
            const data = await response.json();
            document.getElementById('comment-count').textContent = data.totalCount || 0;
            renderUserComments(data.comments || []);
        }
    } catch (error) {
        console.error('댓글 로드 오류:', error);
    }
}

// 찜한 MD 로드
async function loadMdWishes() {
    // TODO: MD 위시리스트 API 구현 후 연동
    document.getElementById('md-wishes-content').innerHTML = '<div class="text-center p-4"><p class="text-muted">찜한 MD 기능은 준비 중입니다.</p></div>';
}

// 위시리스트 렌더링
function renderWishlist(wishlist) {
    const content = document.getElementById('wishlist-content');
    
    if (wishlist.length === 0) {
        content.innerHTML = '<div class="text-center p-4"><p class="text-muted">아직 위시리스트가 없습니다.</p></div>';
        return;
    }

    // TODO: 위시리스트 아이템 렌더링 구현
    content.innerHTML = '<div class="text-center p-4"><p class="text-muted">위시리스트 구현 예정</p></div>';
}

// 게시글 렌더링
function renderUserPosts(posts) {
    const content = document.getElementById('posts-content');
    
    if (posts.length === 0) {
        content.innerHTML = '<div class="text-center p-4"><p class="text-muted">작성한 게시글이 없습니다.</p></div>';
        return;
    }

    // TODO: 게시글 아이템 렌더링 구현
    content.innerHTML = '<div class="text-center p-4"><p class="text-muted">게시글 목록 구현 예정</p></div>';
}

// 댓글 렌더링
function renderUserComments(comments) {
    const content = document.getElementById('comments-content');
    
    if (comments.length === 0) {
        content.innerHTML = '<div class="text-center p-4"><p class="text-muted">작성한 댓글이 없습니다.</p></div>';
        return;
    }

    // TODO: 댓글 아이템 렌더링 구현
    content.innerHTML = '<div class="text-center p-4"><p class="text-muted">댓글 목록 구현 예정</p></div>';
}

// 모달 함수들
function showEditProfileModal() {
    if (currentUser) {
        document.getElementById('edit-nickname').value = currentUser.nickname || '';
        document.getElementById('edit-email').value = currentUser.email || '';
    }
    new bootstrap.Modal(document.getElementById('editProfileModal')).show();
}

function showChangePasswordModal() {
    document.getElementById('changePasswordForm').reset();
    new bootstrap.Modal(document.getElementById('changePasswordModal')).show();
}

function showWithdrawModal() {
    document.getElementById('withdrawForm').reset();
    new bootstrap.Modal(document.getElementById('withdrawModal')).show();
}

// 프로필 업데이트
async function updateProfile() {
    try {
        const token = localStorage.getItem('accessToken');
        const nickname = document.getElementById('edit-nickname').value;
        const email = document.getElementById('edit-email').value;

        const response = await fetch('<%=root%>/api/mypage/update-profile', {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + token,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ nickname, email })
        });

        if (response.ok) {
            alert('프로필이 성공적으로 업데이트되었습니다.');
            bootstrap.Modal.getInstance(document.getElementById('editProfileModal')).hide();
            loadUserData(); // 데이터 새로고침
        } else {
            const error = await response.json();
            alert(error.error || '프로필 업데이트에 실패했습니다.');
        }
    } catch (error) {
        console.error('프로필 업데이트 오류:', error);
        alert('프로필 업데이트 중 오류가 발생했습니다.');
    }
}

// 비밀번호 변경
async function changePassword() {
    try {
        const currentPassword = document.getElementById('current-password').value;
        const newPassword = document.getElementById('new-password').value;
        const confirmPassword = document.getElementById('confirm-password').value;

        if (newPassword !== confirmPassword) {
            alert('새 비밀번호가 일치하지 않습니다.');
            return;
        }

        const token = localStorage.getItem('accessToken');
        const response = await fetch('<%=root%>/api/mypage/change-password', {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + token,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ currentPassword, newPassword })
        });

        if (response.ok) {
            alert('비밀번호가 성공적으로 변경되었습니다.');
            bootstrap.Modal.getInstance(document.getElementById('changePasswordModal')).hide();
        } else {
            const error = await response.json();
            alert(error.error || '비밀번호 변경에 실패했습니다.');
        }
    } catch (error) {
        console.error('비밀번호 변경 오류:', error);
        alert('비밀번호 변경 중 오류가 발생했습니다.');
    }
}

// 회원 탈퇴
async function withdrawMember() {
    try {
        const password = document.getElementById('withdraw-password').value;
        const confirmed = document.getElementById('withdraw-confirm').checked;

        if (!confirmed) {
            alert('회원 탈퇴에 동의해 주세요.');
            return;
        }

        if (!confirm('정말로 회원 탈퇴하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) {
            return;
        }

        const token = localStorage.getItem('accessToken');
        const response = await fetch('<%=root%>/api/mypage/withdraw', {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + token,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ password })
        });

        if (response.ok) {
            alert('회원 탈퇴가 완료되었습니다.');
            localStorage.removeItem('accessToken');
            window.location.href = '<%=root%>/';
        } else {
            const error = await response.json();
            alert(error.error || '회원 탈퇴에 실패했습니다.');
        }
    } catch (error) {
        console.error('회원 탈퇴 오류:', error);
        alert('회원 탈퇴 중 오류가 발생했습니다.');
    }
}

// 인증 오류 표시
function showAuthError() {
    document.getElementById('loading-spinner').style.display = 'none';
    document.getElementById('mypage-content').style.display = 'none';
    document.getElementById('auth-error').style.display = 'block';
}
</script>

<style>
.mypage-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

.profile-avatar {
    width: 80px;
    height: 80px;
    margin: 0 auto;
    display: flex;
    align-items: center;
    justify-content: center;
}

.stats-section .card {
    transition: transform 0.2s;
}

.stats-section .card:hover {
    transform: translateY(-5px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.account-management-section {
    border-top: 2px solid #dee2e6;
    padding-top: 2rem;
}

.tab-content {
    min-height: 400px;
}

.modal-content {
    border-radius: 15px;
}

.card {
    border: none;
    border-radius: 15px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.btn {
    border-radius: 10px;
}

.nav-tabs .nav-link {
    border-radius: 10px 10px 0 0;
    border: none;
    margin-right: 5px;
}

.nav-tabs .nav-link.active {
    background-color: #007bff;
    color: white;
}
</style>
