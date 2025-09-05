<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- hpost.css 링크 -->
<link rel="stylesheet" href="<c:url value='/css/hpost.css'/>">

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
    
    <!-- 정렬 드롭다운과 글쓰기 버튼 -->
    <div class="hpost-controls">
        <div class="hpost-sort-dropdown">
            <button class="btn btn-link dropdown-toggle ${sort == 'popular' ? 'popular-active' : ''}" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="bi bi-arrow-down-up"></i> ${sort == 'latest' || empty sort ? '최신순' : '인기순'}
            </button>
            <ul class="dropdown-menu">
                <li><a class="dropdown-item" href="<c:url value='/hpost?sort=latest'/>">최신순</a></li>
                <li><a class="dropdown-item" href="<c:url value='/hpost?sort=popular'/>">인기순</a></li>
            </ul>
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
                        <label for="passwd" class="form-label">글 비밀번호</label>
                        <input type="password" class="form-control" id="passwd" name="passwd" required maxlength="4" pattern="[0-9]{4}">
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
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" onclick="submitPost()">글쓰기</button>
            </div>
        </div>
    </div>
</div>

<script>
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
</script>
