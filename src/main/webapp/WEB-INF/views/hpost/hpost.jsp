<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- hpost.css 링크 -->
<link rel="stylesheet" href="<c:url value='/css/hpost.css'/>">

<!-- 관리자 삭제 버튼 스타일 -->
<style>
.hpost-admin-delete-btn {
    position: absolute;
    top: 5px;
    right: 5px;
    width: 25px;
    height: 25px;
    background-color: #dc3545;
    color: white !important;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    z-index: 10;
    font-size: 14px;
    font-weight: bold;
    line-height: 1;
    transition: all 0.3s ease;
    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    user-select: none;
    text-align: center;
    margin: 0;
    padding: 0;
}

.hpost-admin-delete-btn:hover {
    background-color: #c82333;
    transform: scale(1.1);
    box-shadow: 0 4px 8px rgba(0,0,0,0.3);
}

.hpost-item {
    position: relative;
}
</style>

<!-- 메인 컨텐츠 -->
<div class="container mt-5 hpost-container">
    <!-- 핫플썰 제목 -->
    <div class="hpost-title">
        <h2><img src="<c:url value='/logo/fire.png'/>" alt="Fire" class="title-icon"> 핫플썰</h2>
    </div>
    
    <!-- 검색 기능 -->
    <div class="hpost-search-container">
        <form action="<c:url value='/hpost'/>" method="GET" class="hpost-search-form">
            <div class="hpost-search-row">
                <div class="hpost-search-type">
                    <select name="searchType" class="form-select">
                        <option value="all" ${param.searchType == 'all' || empty param.searchType ? 'selected' : ''}>전체</option>
                        <option value="title" ${param.searchType == 'title' ? 'selected' : ''}>제목</option>
                        <option value="content" ${param.searchType == 'content' ? 'selected' : ''}>내용</option>
                    </select>
                </div>
                <div class="hpost-search-input">
                    <input type="text" name="searchKeyword" value="${param.searchKeyword}" 
                           class="form-control" placeholder="검색어를 입력하세요" maxlength="100">
                </div>
                <div class="hpost-search-button">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-search"></i> 검색
                    </button>
                </div>
            </div>
            <!-- 정렬 옵션 유지 -->
            <input type="hidden" name="sort" value="${param.sort}">
        </form>
    </div>
    
    <!-- 정렬 버튼과 글쓰기 버튼 -->
    <div class="hpost-controls">
        <div class="hpost-sort-buttons">
            <button class="hpost-sort-btn ${sort == 'latest' || empty sort ? 'active' : ''}" onclick="changeSort('latest')">
                최신순
            </button>
            <button class="hpost-sort-btn ${sort == 'popular' ? 'active' : ''}" onclick="changeSort('popular')">
                인기순
            </button>
        </div>
        <div class="hpost-write-btn">
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#writePostModal">
                <i class="bi bi-pencil"></i> 글쓰기
            </button>
        </div>
    </div>
    
    <!-- 게시글 목록 헤더 -->
    <div class="hpost-header">
        <div class="row">
            <c:choose>
                <c:when test="${param.sort == 'popular' && currentPage == 1}">
                    <div class="col-1">순위</div>
                    <div class="col-2">닉네임</div>
                    <div class="col-4">제목</div>
                </c:when>
                <c:otherwise>
                    <div class="col-3">닉네임</div>
                    <div class="col-4">제목</div>
                </c:otherwise>
            </c:choose>
            <div class="col-1"><i class="bi bi-eye text-muted"></i></div>
            <div class="col-1"><i class="bi bi-hand-thumbs-up text-primary"></i></div>
            <div class="col-1"><i class="bi bi-hand-thumbs-down text-danger"></i></div>
            <div class="col-1"><i class="bi bi-chat-dots text-info"></i></div>
            <div class="col-1">작성일</div>
        </div>
    </div>
    
    <!-- 구분선 -->
    <hr class="hpost-divider">
    
    <!-- 게시글 목록 영역 -->
    <div class="hpost-content">
        <c:choose>
            <c:when test="${not empty hpostList}">
                <c:forEach var="hpost" items="${hpostList}" varStatus="status">
                    <div class="row hpost-item">
                        <!-- 관리자 삭제 버튼 (오른쪽 상단) -->
                        <div class="hpost-admin-delete-btn" onclick="event.stopPropagation(); deleteHpost(${hpost.id}, '${fn:escapeXml(hpost.title)}')" style="display: none;">
                            ×
                        </div>
                        <c:choose>
                            <c:when test="${param.sort == 'popular' && currentPage == 1}">
                                <div class="col-1">
                                    <c:set var="rank" value="${status.index + 1}" />
                                    <span class="rank-number ${rank <= 3 ? 'top-rank' : ''}" style="font-weight: bold; color: #ff6b6b; font-size: 16px;">${rank}위</span>
                                </div>
                                <div class="col-2">
                                    <c:if test="${not empty hpost.userid and hpost.userid ne 'null'}">
                                        <span style="display: inline-block; width: 24px; text-align: center;">
                                            <i class="bi bi-person-fill" style="color: #ff69b4; font-size: 18px;"></i>
                                        </span>
                                    </c:if>
                                    <span style="display: inline-block; vertical-align: middle;">${hpost.nickname}</span>
                                </div>
                                <div class="col-4">
                                    <a href="<c:url value='/hpost/${hpost.id}'/>" class="hpost-title-link" title="${hpost.title}">${hpost.title}</a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="col-3">
                                    <c:if test="${not empty hpost.userid and hpost.userid ne 'null'}">
                                        <span style="display: inline-block; width: 24px; text-align: center;">
                                            <i class="bi bi-person-fill" style="color: #ff69b4; font-size: 18px;"></i>
                                        </span>
                                    </c:if>
                                    <span style="display: inline-block; vertical-align: middle;">${hpost.nickname}</span>
                                </div>
                                <div class="col-4">
                                    <a href="<c:url value='/hpost/${hpost.id}'/>" class="hpost-title-link" title="${hpost.title}">${hpost.title}</a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                        <div class="col-1">${hpost.views}</div>
                        <div class="col-1">${hpost.likes}</div>
                        <div class="col-1">${hpost.dislikes}</div>
                        <div class="col-1">${hpost.commentCount}</div>
                        <div class="col-1 hpost-date">${hpost.formattedTime}</div>
                    </div>
                    <hr class="hpost-item-divider">
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="text-center py-5">
                    <p>글 출력 예정중...</p>
                    <p>이곳에 핫플썰 게시글 목록이 표시될 예정입니다.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    
    <!-- 페이징 -->
    <c:if test="${not empty hpostList and totalPages > 1}">
        <div class="hpost-pagination">
            <nav aria-label="게시글 페이지 네비게이션">
                <ul class="pagination justify-content-center">
                                         <!-- 이전 페이지 -->
                     <c:if test="${currentPage > 1}">
                         <li class="page-item">
                             <a class="page-link" href="<c:url value='/hpost?sort=${param.sort}&searchType=${param.searchType}&searchKeyword=${param.searchKeyword}&page=${currentPage - 1}'/>" aria-label="이전">
                                 <i class="bi bi-chevron-left"></i>
                             </a>
                         </li>
                     </c:if>
                     
                     <!-- 페이지 번호들 -->
                     <c:forEach var="pageNum" begin="${startPage}" end="${endPage}">
                         <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                             <a class="page-link" href="<c:url value='/hpost?sort=${param.sort}&searchType=${param.searchType}&searchKeyword=${param.searchKeyword}&page=${pageNum}'/>">${pageNum}</a>
                         </li>
                     </c:forEach>
                     
                     <!-- 다음 페이지 -->
                     <c:if test="${currentPage < totalPages}">
                         <li class="page-item">
                             <a class="page-link" href="<c:url value='/hpost?sort=${param.sort}&searchType=${param.searchType}&searchKeyword=${param.searchKeyword}&page=${currentPage + 1}'/>" aria-label="다음">
                                 <i class="bi bi-chevron-right"></i>
                             </a>
                         </li>
                     </c:if>
                </ul>
            </nav>
        </div>
    </c:if>
    
    
</div>

<!-- 글쓰기 모달 -->
<div class="modal fade" id="writePostModal" tabindex="-1" aria-labelledby="writePostModalLabel" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="writePostModalLabel">핫플썰 글쓰기</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="writePostForm" enctype="multipart/form-data">
                    <div class="mb-3">
                        <label for="title" class="form-label">제목</label>
                        <input type="text" class="form-control" id="title" name="title" required maxlength="100">
                    </div>
                    
                    <div class="mb-3">
                        <label for="nickname" class="form-label">닉네임</label>
                        <input type="text" class="form-control" id="nickname" name="nickname" required maxlength="5">
                        <div class="form-text">5글자 이하로 입력해주세요.</div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="hpost-passwd" class="form-label">글 비밀번호</label>
                        <input type="password" class="form-control" id="hpost-passwd" name="passwd" required maxlength="4" pattern="[0-9]{4}">
                        <div class="form-text">숫자 4자리로 입력해주세요.</div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="content" class="form-label">내용</label>
                        <textarea class="form-control" id="content" name="content" rows="5" required></textarea>
                    </div>
                    
                    <div class="mb-3">
                        <label for="photo1" class="form-label">사진 1</label>
                        <input type="file" class="form-control" id="photo1" name="photo1" accept="image/*">
                    </div>
                    
                    <div class="mb-3">
                        <label for="photo2" class="form-label">사진 2</label>
                        <input type="file" class="form-control" id="photo2" name="photo2" accept="image/*">
                    </div>
                    
                    <div class="mb-3">
                        <label for="photo3" class="form-label">사진 3</label>
                        <input type="file" class="form-control" id="photo3" name="photo3" accept="image/*">
                    </div>
                    
                    <!-- 핫플썰 글 작성 체크리스트 -->
                    <div class="hpost-checklist-container">
                        <h6>핫플썰 글 작성 체크리스트 (배포용)</h6>
                        <div class="hpost-checklist">
                            <div class="checklist-item">
                                <label class="checklist-label">
                                    <input type="checkbox" class="checklist-checkbox" required>
                                    <span class="checkmark"></span>
                                    <span class="checklist-text">불법·음란 업소 언급 금지<br><small class="text-muted">(성매매, 불법 영업, 음란 서비스 관련 내용은 절대 허용되지 않습니다.)</small></span>
                                </label>
                            </div>
                            <div class="checklist-item">
                                <label class="checklist-label">
                                    <input type="checkbox" class="checklist-checkbox" required>
                                    <span class="checkmark"></span>
                                    <span class="checklist-text">허위 사실 유포 금지<br><small class="text-muted">(사실과 다른 과장된 내용, 없는 일 꾸미기, 평판 조작은 제재됩니다.)</small></span>
                                </label>
                            </div>
                            <div class="checklist-item">
                                <label class="checklist-label">
                                    <input type="checkbox" class="checklist-checkbox" required>
                                    <span class="checkmark"></span>
                                    <span class="checklist-text">개인 정보 언급 금지<br><small class="text-muted">(실명, 연락처, SNS 아이디 등 타인의 개인정보를 노출할 수 없습니다.)</small></span>
                                </label>
                            </div>
                            <div class="checklist-item">
                                <label class="checklist-label">
                                    <input type="checkbox" class="checklist-checkbox" required>
                                    <span class="checkmark"></span>
                                    <span class="checklist-text">비방·모욕 금지<br><small class="text-muted">(특정인, 특정 업소를 욕하거나 조롱하는 내용은 삭제됩니다.)</small></span>
                                </label>
                            </div>
                            <div class="checklist-item">
                                <label class="checklist-label">
                                    <input type="checkbox" class="checklist-checkbox" required>
                                    <span class="checkmark"></span>
                                    <span class="checklist-text">선정적 사진/영상 업로드 금지<br><small class="text-muted">(나체, 성적 행위 묘사, 과도한 노출이 담긴 이미지는 등록 불가합니다.)</small></span>
                                </label>
                            </div>
                            <div class="checklist-item">
                                <label class="checklist-label">
                                    <input type="checkbox" class="checklist-checkbox" required>
                                    <span class="checkmark"></span>
                                    <span class="checklist-text">광고성·영업성 게시물 금지<br><small class="text-muted">(사전 협의 없는 홍보/광고 게시물은 차단됩니다.)</small></span>
                                </label>
                            </div>
                            <div class="checklist-item">
                                <label class="checklist-label">
                                    <input type="checkbox" class="checklist-checkbox" required>
                                    <span class="checkmark"></span>
                                    <span class="checklist-text">책임 있는 작성<br><small class="text-muted">(모든 글은 작성자의 경험을 바탕으로 해야 하며, 문제가 될 경우 책임은 작성자에게 있습니다.)</small></span>
                                </label>
                            </div>
                        </div>
                        <div class="checklist-agreement">
                            <label class="agreement-label">
                                <input type="checkbox" id="hpostChecklistAgreement" class="agreement-checkbox" required>
                                <span class="agreement-checkmark"></span>
                                <span class="agreement-text">위 모든 항목을 확인했으며, 이를 준수할 것을 동의합니다.</span>
                            </label>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" id="hpostSubmitBtn" onclick="submitPost()" disabled>글쓰기</button>
            </div>
        </div>
    </div>
</div>

<!-- 게시글 삭제 확인 모달 -->
<div class="modal fade" id="hpostDeleteModal" tabindex="-1" aria-labelledby="hpostDeleteModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="hpostDeleteModalLabel">
                    <i class="bi bi-exclamation-triangle text-warning"></i> 게시글 삭제 확인
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="bi bi-exclamation-triangle text-warning" style="font-size: 48px;"></i>
                    <h4 class="mt-3">정말로 이 게시글을 삭제하시겠습니까?</h4>
                    <p class="text-muted mt-3">
                        <strong id="deleteHpostTitle"></strong> 게시글을 삭제하면<br>
                        관련된 댓글, 좋아요, 사진 파일도 함께 삭제됩니다.
                    </p>
                    <div class="alert alert-warning">
                        <i class="bi bi-info-circle me-2"></i>
                        <strong>주의:</strong> 이 작업은 되돌릴 수 없습니다.
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="bi bi-x-circle me-1"></i> 취소
                </button>
                <button type="button" class="btn btn-danger" onclick="confirmDeleteHpost()">
                    <i class="bi bi-trash me-1"></i> 삭제
                </button>
            </div>
        </div>
    </div>
</div>

<script>
// 정렬 변경 함수
function changeSort(sortType) {
    const currentUrl = new URL(window.location);
    currentUrl.searchParams.set('sort', sortType);
    window.location.href = currentUrl.toString();
}

// 아이폰 Chrome 감지 및 스타일 강제 적용
function detectAndApplyIPhoneStyles() {
    const isIPhone = /iPhone|iPad|iPod/.test(navigator.userAgent) || 
                     (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1) ||
                     (window.innerWidth <= 991 && navigator.maxTouchPoints > 0);
    
    if (isIPhone) {
        // 아이폰 감지됨 - 스타일 강제 적용
        
        // 동적 스타일 태그 생성
        const style = document.createElement('style');
        style.textContent = `
            .hpost-sort-btn {
                padding: 14px 22px !important;
                font-size: 18px !important;
                min-height: 52px !important;
                min-width: 90px !important;
                border-width: 2px !important;
                cursor: pointer !important;
                -webkit-tap-highlight-color: rgba(0, 123, 255, 0.3) !important;
            }
            .hpost-sort-btn:hover {
                background: #f8f9fa !important;
                border-color: #adb5bd !important;
            }
            .hpost-sort-btn.active {
                background: #007bff !important;
                color: white !important;
                border-color: #007bff !important;
            }
        `;
        document.head.appendChild(style);
        
        // 직접 DOM 요소에 스타일 적용
        setTimeout(() => {
            const sortButtons = document.querySelectorAll('.hpost-sort-btn');
            sortButtons.forEach(btn => {
                btn.style.setProperty('padding', '14px 22px', 'important');
                btn.style.setProperty('font-size', '18px', 'important');
                btn.style.setProperty('min-height', '52px', 'important');
                btn.style.setProperty('min-width', '90px', 'important');
                btn.style.setProperty('border-width', '2px', 'important');
                btn.style.setProperty('cursor', 'pointer', 'important');
                btn.style.setProperty('-webkit-tap-highlight-color', 'rgba(0, 123, 255, 0.3)', 'important');
            });
        }, 100);
    }
}

// 페이지 로드 시 아이폰 스타일 적용
document.addEventListener('DOMContentLoaded', function() {
    detectAndApplyIPhoneStyles();
    checkAdminPermission();
});

// 추가로 window load 이벤트에서도 실행 (이미지 등 모든 리소스 로드 후)
window.addEventListener('load', function() {
    detectAndApplyIPhoneStyles();
});

// 모달이 열릴 때 로그인 상태 확인 및 필드 설정
document.getElementById('writePostModal').addEventListener('show.bs.modal', function () {
    const userInfo = getUserInfoFromToken();
    const nicknameField = document.getElementById('nickname');
    
    if (userInfo) {
        // 로그인된 사용자
        nicknameField.value = userInfo.nickname;
        nicknameField.readOnly = true;
    } else {
        // 비로그인 사용자
        nicknameField.value = '';
        nicknameField.readOnly = false;
    }
});

// 글쓰기 제출
async function submitPost() {
    const form = document.getElementById('writePostForm');
    const formData = new FormData(form);
    
    // ✅ 로그인 상태 확인 및 토큰 설정
    const userInfo = getUserInfoFromToken();
    let headers = {};
    
    if (userInfo) {
        // 로그인된 사용자: JWT 토큰을 헤더에 포함
        const token = localStorage.getItem('accessToken');
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
            console.log('로그인된 사용자 - JWT 토큰 포함:', token.substring(0, 30) + '...');
        }
        
        // 로그인된 사용자는 userid 필드 추가
        formData.append('userid', userInfo.userid);
        console.log('로그인된 사용자 ID 추가:', userInfo.userid);
    } else {
        // 비로그인 사용자: IP 주소 사용
        console.log('비로그인 사용자 - IP 주소 사용');
    }
    
    try {
        const response = await fetch('<c:url value="/hpost/write"/>', {
            method: 'POST',
            headers: headers,
            body: formData
        });
        
        const result = await response.json();
        
        if (result.success) {
            alert('글이 성공적으로 작성되었습니다.');
            location.reload();
        } else {
            alert('글 작성에 실패했습니다: ' + result.message);
        }
    } catch (error) {
        console.error('Error:', error);
        alert('글 작성 중 오류가 발생했습니다.');
    }
}

// 관리자 권한 확인 함수
function checkAdminPermission() {
    const token = localStorage.getItem('accessToken');
    if (!token) {
        document.querySelectorAll('.hpost-admin-delete-btn').forEach(btn => btn.style.display = 'none');
        return;
    }
    
    try {
        // JWT 토큰 파싱
        const payload = JSON.parse(atob(token.split('.')[1]));
        
        // 관리자 권한 확인 (provider가 'admin'인 경우만)
        const isAdmin = payload.provider === 'admin';
        
        if (isAdmin) {
            document.querySelectorAll('.hpost-admin-delete-btn').forEach(btn => btn.style.display = 'block');
        } else {
            // 일반 사용자 - 관리자 버튼 숨김
            document.querySelectorAll('.hpost-admin-delete-btn').forEach(btn => btn.style.display = 'none');
        }
    } catch (error) {
        // JWT 토큰 파싱 실패
        document.querySelectorAll('.hpost-admin-delete-btn').forEach(btn => btn.style.display = 'none');
    }
}

// 게시글 삭제 함수
function deleteHpost(hpostId, hpostTitle) {
    // 관리자 권한 재확인
    const token = localStorage.getItem('accessToken');
    if (!token) {
        alert('로그인이 필요합니다.');
        return;
    }
    
    try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        const isAdmin = payload.provider === 'admin';
        
        if (!isAdmin) {
            alert('관리자 권한이 필요합니다.');
            return;
        }
    } catch (error) {
        alert('권한 확인에 실패했습니다.');
        return;
    }
    
    // 삭제할 게시글 정보 저장
    
    // ID가 유효한지 확인
    if (!hpostId || hpostId === null || hpostId === undefined) {
        alert('유효하지 않은 게시글 ID입니다.');
        return;
    }
    
    // 숫자로 변환
    const numericId = parseInt(hpostId);
    if (isNaN(numericId) || numericId <= 0) {
        alert('유효하지 않은 게시글 ID입니다.');
        return;
    }
    
    window.currentDeleteHpostId = numericId;
    document.getElementById('deleteHpostTitle').textContent = hpostTitle;
    
    // 모달 표시
    const modal = new bootstrap.Modal(document.getElementById('hpostDeleteModal'));
    modal.show();
}

// 게시글 삭제 확인
function confirmDeleteHpost() {
    
    if (!window.currentDeleteHpostId || window.currentDeleteHpostId <= 0) {
        alert('삭제할 게시글 정보가 없습니다.');
        return;
    }
    
    const token = localStorage.getItem('accessToken');
    if (!token) {
        alert('로그인이 필요합니다.');
        return;
    }
    
    // 삭제 버튼 비활성화
    const deleteBtn = document.querySelector('#hpostDeleteModal .btn-danger');
    deleteBtn.disabled = true;
    deleteBtn.innerHTML = '<i class="bi bi-hourglass-split me-1"></i> 삭제 중...';
    
    // AJAX로 삭제 요청 (기존 API 사용, 관리자는 비밀번호 없이 삭제 가능)
    const deleteUrl = `<c:url value='/hpost/delete'/>`;
    
    fetch(deleteUrl, {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + token,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            hpostId: window.currentDeleteHpostId.toString(),
            password: '', // 관리자는 비밀번호 없이 삭제
            authorUserid: 'admin',
            userId: 'admin'
        })
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        if (data.success) {
            alert('게시글이 성공적으로 삭제되었습니다!');
            // 모달 닫기
            const modal = bootstrap.Modal.getInstance(document.getElementById('hpostDeleteModal'));
            modal.hide();
            // 페이지 새로고침
            location.reload();
        } else {
            alert(data.message || '게시글 삭제에 실패했습니다.');
        }
    })
    .catch(error => {
        alert('서버 오류가 발생했습니다.');
    })
    .finally(() => {
        // 버튼 상태 복원
        deleteBtn.disabled = false;
        deleteBtn.innerHTML = '<i class="bi bi-trash me-1"></i> 삭제';
    });
}

// 핫플썰 체크리스트 관련 함수들
function initializeHpostChecklist() {
    const checklistCheckboxes = document.querySelectorAll('.hpost-checklist .checklist-checkbox');
    const agreementCheckbox = document.getElementById('hpostChecklistAgreement');
    const submitBtn = document.getElementById('hpostSubmitBtn');
    
    // 개별 체크박스 이벤트 리스너
    checklistCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', updateHpostSubmitButton);
    });
    
    // 전체 동의 체크박스 이벤트 리스너
    if (agreementCheckbox) {
        agreementCheckbox.addEventListener('change', function() {
            if (this.checked) {
                // 전체 동의 시 모든 개별 체크박스도 체크
                checklistCheckboxes.forEach(checkbox => {
                    checkbox.checked = true;
                });
            } else {
                // 전체 동의 해제 시 모든 개별 체크박스도 해제
                checklistCheckboxes.forEach(checkbox => {
                    checkbox.checked = false;
                });
            }
            updateHpostSubmitButton();
        });
    }
    
    // 개별 체크박스가 변경될 때 전체 동의 체크박스 상태 업데이트
    checklistCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            updateHpostAgreementCheckbox();
        });
    });
}

function updateHpostSubmitButton() {
    const checklistCheckboxes = document.querySelectorAll('.hpost-checklist .checklist-checkbox');
    const agreementCheckbox = document.getElementById('hpostChecklistAgreement');
    const submitBtn = document.getElementById('hpostSubmitBtn');
    
    // 모든 개별 체크박스가 체크되었고 전체 동의도 체크되었을 때만 제출 버튼 활성화
    const allChecked = Array.from(checklistCheckboxes).every(checkbox => checkbox.checked);
    const agreementChecked = agreementCheckbox ? agreementCheckbox.checked : false;
    
    if (submitBtn) {
        if (allChecked && agreementChecked) {
            submitBtn.disabled = false;
            submitBtn.style.opacity = '1';
            submitBtn.style.cursor = 'pointer';
        } else {
            submitBtn.disabled = true;
            submitBtn.style.opacity = '0.6';
            submitBtn.style.cursor = 'not-allowed';
        }
    }
}

function updateHpostAgreementCheckbox() {
    const checklistCheckboxes = document.querySelectorAll('.hpost-checklist .checklist-checkbox');
    const agreementCheckbox = document.getElementById('hpostChecklistAgreement');
    
    if (agreementCheckbox) {
        // 모든 개별 체크박스가 체크되었을 때만 전체 동의 체크박스도 체크
        const allChecked = Array.from(checklistCheckboxes).every(checkbox => checkbox.checked);
        agreementCheckbox.checked = allChecked;
    }
}

// 모달이 열릴 때 체크리스트 초기화
function initializeHpostChecklistOnModalOpen() {
    setTimeout(() => {
        initializeHpostChecklist();
        // 초기 상태에서는 제출 버튼 비활성화
        updateHpostSubmitButton();
    }, 100);
}

// 페이지 로드 시 체크리스트 초기화
document.addEventListener('DOMContentLoaded', function() {
    // 체크리스트 초기화
    initializeHpostChecklist();
    
    // 초기 상태에서는 제출 버튼 비활성화
    updateHpostSubmitButton();
});

// 모달이 열릴 때 체크리스트 초기화 (Bootstrap 모달 이벤트)
document.addEventListener('DOMContentLoaded', function() {
    const writeModal = document.getElementById('writePostModal');
    if (writeModal) {
        writeModal.addEventListener('shown.bs.modal', function() {
            initializeHpostChecklistOnModalOpen();
        });
        
        writeModal.addEventListener('hidden.bs.modal', function() {
            // 모달이 닫힐 때 체크리스트 초기화
            setTimeout(() => {
                initializeHpostChecklist();
                updateHpostSubmitButton();
            }, 100);
        });
    }
});
</script>
