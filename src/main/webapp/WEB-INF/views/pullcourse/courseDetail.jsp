<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    String root = request.getContextPath();
%>

<!-- 코스 상세 페이지 CSS -->
<link rel="stylesheet" href="<%=root%>/css/coursedetail.css">

<script>
// body에 클래스 추가
document.body.classList.add('course-detail-page');

// Course ID 설정 - JSP에서 전달받은 실제 값 사용
let COURSE_ID = parseInt('${course.id}');
if (isNaN(COURSE_ID)) {
    COURSE_ID = 0;
}

// fetchWithAuth 함수가 없으면 정의
if (typeof window.fetchWithAuth === 'undefined') {
    window.fetchWithAuth = async function(url, options = {}) {
        const token = localStorage.getItem('accessToken');
        
        // 기본 헤더 설정
        if (!options.headers) {
            options.headers = {};
        }
        
        // Authorization 헤더 추가
        if (token) {
            options.headers['Authorization'] = 'Bearer ' + token;
        }
        
        try {
            let response = await fetch(url, options);
            
            // 401 에러 시 토큰 갱신 시도
            if (response.status === 401) {
                const refreshToken = localStorage.getItem('refreshToken');
                if (refreshToken) {
                    try {
                        const refreshResponse = await fetch('<%=root%>/api/auth/refresh', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify({ refreshToken: refreshToken })
                        });
                        
                        if (refreshResponse.ok) {
                            const refreshData = await refreshResponse.json();
                            if (refreshData.token) {
                                localStorage.setItem('accessToken', refreshData.token);
                                
                                // 새로운 토큰으로 원래 요청 재시도
                                options.headers['Authorization'] = 'Bearer ' + refreshData.token;
                                response = await fetch(url, options);
                            }
                        }
                    } catch (refreshError) {
                        console.error('토큰 갱신 실패:', refreshError);
                        // 토큰 갱신 실패 시 로그아웃 처리
                        localStorage.removeItem('accessToken');
                        localStorage.removeItem('refreshToken');
                        localStorage.removeItem('userInfo');
                        location.reload();
                        return;
                    }
                } else {
                    // 리프레시 토큰이 없으면 로그아웃 처리
                    localStorage.removeItem('accessToken');
                    localStorage.removeItem('refreshToken');
                    localStorage.removeItem('userInfo');
                    location.reload();
                    return;
                }
            }
            
            return response;
        } catch (error) {
            console.error('fetchWithAuth 오류:', error);
            throw error;
        }
    };
}
</script>

<div class="course-detail-container">
    <div class="course-detail-content">

        <!-- 제목과 삭제 버튼 -->
        <div class="course-detail-title-container">
            <h1 class="course-detail-title">${course.title}</h1>
            <div class="course-detail-menu" onclick="showDeleteMenu(${course.id}, '${course.authorUserid}', '${course.userId}')">
                <span class="course-detail-menu-dots">⋯</span>
                <div class="course-detail-menu-dropdown" id="deleteMenu_${course.id}" style="display: none;">
                    <div class="course-detail-menu-item" onclick="reportCourse(${course.id})">신고</div>
                    <div class="course-detail-menu-item" onclick="deleteCourse(${course.id}, '${course.authorUserid}', '${course.userId}')">삭제</div>
                </div>
            </div>
        </div>
        
        <!-- 작성자 정보 -->
        <div class="course-detail-author-info">
            <span class="course-detail-nickname">${course.nickname}</span>
            <div style="display: flex; align-items: center;">
                <span class="course-detail-time" id="courseCreatedTime" data-created-at="${course.createdAt}">
                    계산중...
                </span>
                <span class="course-detail-view-count" style="color: #6c757d; filter: grayscale(100%); font-size: 15px;">👁️ ${course.viewCount}</span>
            </div>
        </div>
        
        <!-- 구분선 -->
        <div class="course-detail-divider"></div>
        
        <!-- 코스 스텝들 -->
        <div class="course-detail-steps">
            <c:forEach var="step" items="${courseSteps}" varStatus="status">
                <div class="course-detail-step">
                    <!-- 스텝 번호와 장소명 -->
                    <div class="course-detail-step-header">
                        <span class="course-detail-step-number">${step.stepNo}</span>
                        <span class="course-detail-step-place">
                            ${step.placeName}
                            <c:if test="${not empty step.placeAddress}">
                                <span class="course-detail-step-address">(${step.placeAddress})</span>
                            </c:if>
                        </span>
                    </div>
                    
                    <!-- 사진과 내용을 하나의 테두리로 묶기 -->
                    <div class="course-detail-step-content-wrapper">
                        <!-- 스텝 사진 -->
                        <c:if test="${not empty step.photoUrl}">
                            <div class="course-detail-step-photo">
                                <img src="<%=root%>${step.photoUrl}" alt="스텝 ${step.stepNo} 사진" />
                            </div>
                        </c:if>
                        
                        <!-- 스텝 설명 -->
                        <c:if test="${not empty step.description}">
                            <div class="course-detail-step-description">
                                ${step.description}
                            </div>
                        </c:if>
                    </div>
                 </div>
                 
                 <!-- 화살표 (마지막 스텝이 아닌 경우) -->
                 <c:if test="${!status.last}">
                     <div class="course-detail-step-arrow">
                         ↓
                     </div>
                 </c:if>
            </c:forEach>
        </div>
        
        <!-- 코스 요약 -->
        <div class="course-detail-summary">
            <h3>코스 요약</h3>
            <p>${course.summary}</p>
        </div>
        
        <!-- 좋아요/싫어요 버튼 -->
        <div class="course-detail-reactions">
            <button class="course-detail-like-btn" id="likeBtn" onclick="toggleReaction(${course.id}, 'LIKE')">
                👍 <span class="like-count">${likeCount}</span>
            </button>
            <button class="course-detail-dislike-btn" id="dislikeBtn" onclick="toggleReaction(${course.id}, 'DISLIKE')">
                👎 <span class="dislike-count">${dislikeCount}</span>
            </button>
        </div>
        
        <!-- 구분선 -->
        <div class="course-detail-divider"></div>
        
        <!-- 댓글 갯수 -->
        <div class="comment-count-container">
            <div class="comment-count-box">
                <span class="comment-count-text">댓글 <span id="comment-count-display">0</span></span>
            </div>
        </div>
        
        <!-- 댓글 입력 -->
        <div class="course-detail-comment-form">
            <div class="comment-input-row">
                <div class="comment-left-column">
                    <input type="text" class="comment-nickname" id="commentNickname" placeholder="닉네임" maxlength="5" />
                    <input type="password" class="comment-password" id="commentPassword" placeholder="비밀번호 (숫자 4자리)" maxlength="4" pattern="[0-9]{4}" />
                </div>
                <div class="comment-right-section">
                    <textarea class="comment-content" id="commentContent" placeholder="댓글을 입력하세요..."></textarea>
                    <button class="comment-submit-btn" onclick="submitComment()">댓글 작성</button>
                </div>
            </div>
        </div>
        
        <!-- 구분선 -->
        <div class="course-detail-divider"></div>
        
        <!-- 정렬 버튼 -->
        <div class="comments-sort-container">
            <div class="comments-sort-buttons">
                <button class="sort-btn active" onclick="loadComments('latest')">최신순</button>
                <button class="sort-btn" onclick="loadComments('popular')">인기순</button>
            </div>
        </div>
        
                 <!-- 댓글 목록 -->
         <div class="course-detail-comments">
             <div id="commentsList" class="comments-list">
                 <!-- 댓글들이 여기에 동적으로 로드됩니다 -->
             </div>
         </div>
    </div>
</div>

<script>
// 사용자 정보 가져오기 함수
function getUserInfo() {
    const userInfoStr = localStorage.getItem('userInfo');
    if (userInfoStr) {
        try {
            return JSON.parse(userInfoStr);
        } catch (error) {
            console.error('사용자 정보 파싱 오류:', error);
            return null;
        }
    }
    return null;
}

// 로그인 상태 확인 함수
function isLoggedIn() {
    const token = localStorage.getItem('accessToken');
            if (!token) {
            return false;
        }
    
    try {
        // Base64 디코딩 시 한글 인코딩 문제 해결
        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        
        const payload = JSON.parse(jsonPayload);
        const currentTime = Date.now() / 1000;
        const isValid = payload.exp > currentTime;
        return isValid;
    } catch (error) {
        console.error('토큰 파싱 오류:', error);
        return false;
    }
}

// 댓글 목록 로드
async function loadComments(sort = 'latest') {
    try {
        console.log('Course ID from global variable:', COURSE_ID);
        console.log('Course ID type:', typeof COURSE_ID);
        
        if (!COURSE_ID || COURSE_ID === 0) {
            console.error('Course ID가 없습니다. COURSE_ID:', COURSE_ID);
            document.getElementById('commentsList').innerHTML = '<div class="no-comments">Course ID를 찾을 수 없습니다.</div>';
            return;
        }
        
        // JWT 토큰 가져오기
        const token = localStorage.getItem('accessToken');
        
        const url = '<%=root%>/course/' + COURSE_ID + '/comments?sort=' + sort;
        console.log('요청 URL:', url);
        
        const response = await fetch(url, {
            headers: {
                'Authorization': token ? 'Bearer ' + token : ''
            }
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        console.log('서버 응답 데이터:', data);
        
        if (data.success) {
            console.log('댓글 데이터:', data.comments);
            displayComments(data.comments, sort);
            updateSortButtons(sort);
        } else {
            console.error('댓글 로드 실패:', data.message);
            document.getElementById('commentsList').innerHTML = '<div class="no-comments">댓글을 불러오는데 실패했습니다.</div>';
        }
    } catch (error) {
        console.error('댓글 로드 오류:', error);
        document.getElementById('commentsList').innerHTML = '<div class="no-comments">댓글을 불러오는데 실패했습니다: ' + error.message + '</div>';
    }
}

// 댓글 표시
function displayComments(comments, sortType = 'latest') {
    console.log('displayComments 호출됨, comments:', comments, 'sortType:', sortType);
    const commentsList = document.getElementById('commentsList');
    
    if (!comments || comments.length === 0) {
        console.log('댓글이 없습니다');
        commentsList.innerHTML = '<div class="no-comments">아직 댓글이 없습니다.</div>';
        updateCommentCount(0);
        return;
    }
    
    // 정렬 처리
    let sortedComments = [...comments]; // 원본 배열 복사
    
    if (sortType === 'latest') {
        // 최신순: createdAt 기준으로 내림차순 정렬
        sortedComments.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
        console.log('최신순 정렬 완료');
    } else if (sortType === 'popular') {
        // 인기순: 좋아요 수 기준으로 내림차순 정렬
        sortedComments.sort((a, b) => {
            const aLikes = a.likeCount || 0;
            const bLikes = b.likeCount || 0;
            if (aLikes !== bLikes) {
                return bLikes - aLikes; // 좋아요 수가 다르면 좋아요 수로 정렬
            } else {
                // 좋아요 수가 같으면 최신순으로 정렬
                return new Date(b.createdAt) - new Date(a.createdAt);
            }
        });
        console.log('인기순 정렬 완료');
    }
    
    console.log('정렬된 댓글 개수:', sortedComments.length);
    let html = '';
    sortedComments.forEach((comment, index) => {
        console.log(`댓글 ${index + 1}:`, comment);
        html += createCommentHTML(comment);
    });
    
    console.log('생성된 HTML:', html);
    commentsList.innerHTML = html;
    updateCommentCount(sortedComments.length);
    
    // 답글 상태 복원
    restoreReplyStates();
}

// 답글 상태 복원 함수
async function restoreReplyStates() {
    for (let parentId of expandedReplies) {
        const repliesContainer = document.getElementById('replies-' + parentId);
        const replyBtn = document.querySelector(`[data-comment-id="${parentId}"] .reply-btn`);
        
        if (repliesContainer && replyBtn) {
            // 답글 로드 및 표시
            try {
                const token = localStorage.getItem('accessToken');
                
                const response = await fetch('<%=root%>/course/' + COURSE_ID + '/replies?parentId=' + parentId, {
                    headers: {
                        'Authorization': token ? 'Bearer ' + token : ''
                    }
                });
                const data = await response.json();
                
                let repliesHtml = '';
                if (data.success && data.comments) {
                    data.comments.forEach(reply => {
                        repliesHtml += createReplyHTML(reply);
                    });
                }
                
                // 답글 입력폼 추가
                const loggedIn = isLoggedIn();
                let formHtml = '<div class="reply-form-container">' +
                    '<div class="reply-form-row">';
                
                if (loggedIn) {
                    // 로그인한 사용자: 내용만 입력
                    formHtml += '<div class="reply-form-right-section">' +
                        '<textarea class="reply-form-content" id="replyContent-' + parentId + '" placeholder="답글을 입력하세요..."></textarea>' +
                        '<button class="reply-form-submit-btn" onclick="submitReply(' + parentId + ')">답글 작성</button>' +
                        '<button class="reply-form-cancel-btn" onclick="cancelReplyForm()">취소</button>' +
                        '</div>';
                } else {
                    // 비로그인 사용자: 닉네임, 비밀번호, 내용 입력
                    formHtml += '<div class="reply-form-left-column">' +
                        '<input type="text" class="reply-form-nickname" id="replyNickname-' + parentId + '" placeholder="닉네임 (5자 이하)" maxlength="5">' +
                        '<input type="password" class="reply-form-password" id="replyPassword-' + parentId + '" placeholder="비밀번호 (4자리)" maxlength="4">' +
                        '</div>' +
                        '<div class="reply-form-right-section">' +
                        '<textarea class="reply-form-content" id="replyContent-' + parentId + '" placeholder="답글을 입력하세요..."></textarea>' +
                        '<button class="reply-form-submit-btn" onclick="submitReply(' + parentId + ')">답글 작성</button>' +
                        '<button class="reply-form-cancel-btn" onclick="cancelReplyForm()">취소</button>' +
                        '</div>';
                }
                
                formHtml += '</div></div>';
                
                repliesContainer.innerHTML = repliesHtml + formHtml;
                repliesContainer.style.display = 'block';
                replyBtn.textContent = '답글 접기';
                replyBtn.setAttribute('data-expanded', 'true');
                
            } catch (error) {
                console.error('답글 상태 복원 오류:', error);
                // 오류 발생 시 해당 답글 상태 제거
                expandedReplies.delete(parentId);
            }
        }
    }
}

// 댓글 갯수 업데이트 (부모 댓글 개수만)
function updateCommentCount(count) {
    const countDisplay = document.getElementById('comment-count-display');
    if (countDisplay) {
        countDisplay.textContent = count;
    }
}

// 댓글 HTML 생성
function createCommentHTML(comment) {
    console.log('createCommentHTML 호출됨, comment:', comment);
    const timeAgo = getTimeAgo(comment.createdAt);
    const isReply = comment.parentId != null;
    const replyCount = comment.replyCount || 0;
    
    // 대댓글인 경우 답글 버튼을 표시하지 않음
    let replyButtonHtml = '';
    if (!isReply) {
        replyButtonHtml = '<button class="reply-btn" data-expanded="false" onclick="toggleRepliesAndShowForm(' + comment.id + ')">답글 ' + replyCount + '개</button>';
    }
    
    const html = '<div class="comment-item ' + (isReply ? 'comment-reply' : '') + '" data-comment-id="' + comment.id + '" data-author-userid="' + (comment.authorUserid || '') + '">' +
        '<div class="comment-header">' +
            '<span class="comment-display-nickname">' + (comment.nickname || '') + '</span>' +
            '<div class="comment-menu" onclick="showCommentDeleteMenu(' + comment.id + ', \'' + (comment.nickname || '') + '\')">' +
                '<span class="comment-menu-dots">⋯</span>' +
                '<div class="comment-menu-dropdown" id="commentDeleteMenu_' + comment.id + '" style="display: none;">' +
                    '<div class="comment-menu-item" onclick="deleteComment(' + comment.id + ', \'' + (comment.nickname || '') + '\')">삭제</div>' +
                '</div>' +
            '</div>' +
        '</div>' +
                    '<div class="comment-display-content">' +
            (comment.content || '') +
        '</div>' +
        '<div class="comment-footer">' +
            '<div class="comment-info">' +
                '<span class="comment-time">' + timeAgo + '</span>' +
                replyButtonHtml +
            '</div>' +
                         '<div class="comment-reactions">' +
                '<button class="comment-like-btn' + (comment.userReaction === 'LIKE' ? ' active' : '') + '" onclick="likeComment(' + comment.id + ')">' +
                    '👍 <span class="like-count">' + (comment.likeCount || 0) + '</span>' +
                '</button>' +
                '<button class="comment-dislike-btn' + (comment.userReaction === 'DISLIKE' ? ' active' : '') + '" onclick="dislikeComment(' + comment.id + ')">' +
                    '👎 <span class="dislike-count">' + (comment.dislikeCount || 0) + '</span>' +
                '</button>' +
            '</div>' +
        '</div>' +
        '<div id="replies-' + comment.id + '" class="replies-container" style="display: none;"></div>' +
    '</div>';
    
    console.log('생성된 HTML 조각:', html);
    return html;
}

// 대댓글 HTML 생성 (대댓글 버튼과 화살표 버튼 없음)
function createReplyHTML(reply) {
    console.log('createReplyHTML 호출됨, reply:', reply);
    const timeAgo = getTimeAgo(reply.createdAt);
    
    const html = '<div class="comment-item comment-reply" data-comment-id="' + reply.id + '" data-author-userid="' + (reply.authorUserid || '') + '">' +
        '<div class="comment-header">' +
            '<span class="comment-display-nickname">' + (reply.nickname || '') + '</span>' +
            '<div class="comment-menu" onclick="showCommentDeleteMenu(' + reply.id + ', \'' + (reply.nickname || '') + '\')">' +
                '<span class="comment-menu-dots">⋯</span>' +
                '<div class="comment-menu-dropdown" id="commentDeleteMenu_' + reply.id + '" style="display: none;">' +
                    '<div class="comment-menu-item" onclick="deleteComment(' + reply.id + ', \'' + (reply.nickname || '') + '\')">삭제</div>' +
                '</div>' +
            '</div>' +
        '</div>' +
                    '<div class="comment-display-content">' +
            (reply.content || '') +
        '</div>' +
        '<div class="comment-footer">' +
            '<div class="comment-info">' +
                '<span class="comment-time">' + timeAgo + '</span>' +
            '</div>' +
                         '<div class="comment-reactions">' +
                '<button class="comment-like-btn' + (reply.userReaction === 'LIKE' ? ' active' : '') + '" onclick="likeComment(' + reply.id + ')">' +
                    '👍 <span class="like-count">' + (reply.likeCount || 0) + '</span>' +
                '</button>' +
                '<button class="comment-dislike-btn' + (reply.userReaction === 'DISLIKE' ? ' active' : '') + '" onclick="dislikeComment(' + reply.id + ')">' +
                    '👎 <span class="dislike-count">' + (reply.dislikeCount || 0) + '</span>' +
                '</button>' +
            '</div>' +
        '</div>' +
    '</div>';
    
    console.log('생성된 대댓글 HTML 조각:', html);
    return html;
}

// 시간 계산 (몇분전, 몇시간전, 몇일전)
function getTimeAgo(createdAt) {
    console.log('getTimeAgo 호출됨, createdAt:', createdAt);
    
    const createdDate = new Date(createdAt);
    const now = new Date();
    const diffMs = now - createdDate;
    
    console.log('시간 차이 (밀리초):', diffMs);
    
    if (diffMs < 60000) { // 1분 미만
        return '방금전';
    } else if (diffMs < 3600000) { // 1시간 미만
        const minutes = Math.floor(diffMs / 60000);
        return minutes + '분전';
    } else if (diffMs < 86400000) { // 24시간 미만
        const hours = Math.floor(diffMs / 3600000);
        return hours + '시간전';
    } else {
        const days = Math.floor(diffMs / 86400000);
        return days + '일전';
    }
}

// 정렬 버튼 업데이트
function updateSortButtons(activeSort) {
    const sortButtons = document.querySelectorAll('.sort-btn');
    sortButtons.forEach(btn => {
        btn.classList.remove('active');
        if ((activeSort === 'latest' && btn.textContent.includes('최신순')) || 
            (activeSort === 'popular' && btn.textContent.includes('인기순'))) {
            btn.classList.add('active');
        }
    });
}



// 답글 상태 추적을 위한 전역 변수
let expandedReplies = new Set();

// 답글 토글 및 폼 표시 기능
async function toggleRepliesAndShowForm(parentId) {
    console.log('답글 토글 및 폼 표시:', parentId);
    const repliesContainer = document.getElementById('replies-' + parentId);
    const replyBtn = event.target;
    
    if (repliesContainer.style.display === 'none') {
        // 답글 로드 및 표시
        try {
            // JWT 토큰 가져오기
            const token = localStorage.getItem('accessToken');
            
            const response = await fetch('<%=root%>/course/' + COURSE_ID + '/replies?parentId=' + parentId, {
                headers: {
                    'Authorization': token ? 'Bearer ' + token : ''
                }
            });
            const data = await response.json();
            
            let repliesHtml = '';
            if (data.success && data.comments) {
                data.comments.forEach(reply => {
                    // 답글은 답글 버튼이 없도록 별도 HTML 생성
                    repliesHtml += createReplyHTML(reply);
                });
            }
            
            // 답글 입력폼 추가
            const loggedIn = isLoggedIn();
            let formHtml = '<div class="reply-form-container">' +
                '<div class="reply-form-row">';
            
            if (loggedIn) {
                // 로그인한 사용자: 내용만 입력
                formHtml += '<div class="reply-form-right-section">' +
                    '<textarea class="reply-form-content" id="replyContent-' + parentId + '" placeholder="답글을 입력하세요..."></textarea>' +
                    '<button class="reply-form-submit-btn" onclick="submitReply(' + parentId + ')">답글 작성</button>' +
                    '<button class="reply-form-cancel-btn" onclick="cancelReplyForm()">취소</button>' +
                    '</div>';
            } else {
                // 비로그인 사용자: 닉네임, 비밀번호, 내용 입력
                formHtml += '<div class="reply-form-left-column">' +
                    '<input type="text" class="reply-form-nickname" id="replyNickname-' + parentId + '" placeholder="닉네임 (5자 이하)" maxlength="5">' +
                    '<input type="password" class="reply-form-password" id="replyPassword-' + parentId + '" placeholder="비밀번호 (4자리)" maxlength="4">' +
                    '</div>' +
                    '<div class="reply-form-right-section">' +
                    '<textarea class="reply-form-content" id="replyContent-' + parentId + '" placeholder="답글을 입력하세요..."></textarea>' +
                    '<button class="reply-form-submit-btn" onclick="submitReply(' + parentId + ')">답글 작성</button>' +
                    '<button class="reply-form-cancel-btn" onclick="cancelReplyForm()">취소</button>' +
                    '</div>';
            }
            
            formHtml += '</div></div>';
            
            repliesContainer.innerHTML = repliesHtml + formHtml;
            repliesContainer.style.display = 'block';
            replyBtn.textContent = '답글 접기';
            replyBtn.setAttribute('data-expanded', 'true');
            
            // 답글 상태를 확장된 것으로 기록
            expandedReplies.add(parentId);
            
            // 포커스 설정
            const contentTextarea = document.getElementById('replyContent-' + parentId);
            if (contentTextarea) {
                contentTextarea.focus();
            }
        } catch (error) {
            console.error('답글 로드 오류:', error);
        }
    } else {
        // 답글 숨기기
        repliesContainer.style.display = 'none';
        replyBtn.textContent = '답글 ' + (repliesContainer.querySelectorAll('.comment-reply').length) + '개';
        replyBtn.setAttribute('data-expanded', 'false');
        
        // 답글 상태를 접힌 것으로 기록
        expandedReplies.delete(parentId);
    }
}

// 대댓글 작성
async function submitReply(parentId) {
    if (!COURSE_ID || COURSE_ID === 0) {
        showCourseMessage('Course ID가 없습니다.', 'error');
        return;
    }
    
    const loggedIn = isLoggedIn();
    let nickname = '';
    let password = '';
    const content = document.getElementById('replyContent-' + parentId).value.trim();
    
    if (loggedIn) {
        // 로그인한 사용자: 토큰에서 닉네임 추출
        try {
            const token = localStorage.getItem('accessToken');
            const base64Url = token.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));
            
            const payload = JSON.parse(jsonPayload);
            nickname = payload.nickname || '';
        } catch (error) {
            console.error('토큰에서 닉네임 추출 실패:', error);
            showCourseMessage('사용자 정보를 가져오는데 실패했습니다.', 'error');
            return;
        }
    } else {
        // 비로그인 사용자: 입력값 사용
        nickname = document.getElementById('replyNickname-' + parentId).value.trim();
        password = document.getElementById('replyPassword-' + parentId).value;
    }
    
    // 입력 검증
    if (!nickname || !content) {
        showCourseMessage('닉네임과 답글 내용을 입력해주세요.', 'warning');
        return;
    }
    
    if (nickname.length > 5) {
        showCourseMessage('닉네임은 5글자 이하로 입력해주세요.', 'warning');
        return;
    }
    
    // 비로그인 사용자의 경우 비밀번호 검증
    if (!loggedIn) {
        if (!password || password.length !== 4 || !/^\d{4}$/.test(password)) {
            showCourseMessage('비밀번호는 숫자 4자리로 입력해주세요.', 'warning');
            return;
        }
    }
    
    try {
        // FormData 생성
        const formData = new FormData();
        formData.append('nickname', nickname);
        formData.append('content', content);
        formData.append('parentId', parentId);
        
        if (!loggedIn) {
            formData.append('password', password);
        }
        
        // JWT 토큰 가져오기
        const token = localStorage.getItem('accessToken');
        
        // API 호출
        const response = await fetch('<%=root%>/course/' + COURSE_ID + '/comment', {
            method: 'POST',
            headers: {
                'Authorization': token ? 'Bearer ' + token : ''
            },
            body: formData
        });
        
        const result = await response.json();
        
        if (result.success) {
            showCourseMessage('답글이 등록되었습니다.', 'success');
            
            // 폼 제거
            cancelReplyForm();
            
            // 답글 컨테이너에 새 답글 추가
            const repliesContainer = document.getElementById('replies-' + parentId);
            if (repliesContainer) {
                const newReplyHtml = createReplyHTML(result.comment);
                repliesContainer.insertAdjacentHTML('beforeend', newReplyHtml);
                
                // 부모 댓글의 답글 개수 업데이트
                const replyBtn = document.querySelector(`[data-comment-id="${parentId}"] .reply-btn`);
                if (replyBtn) {
                    const currentCount = parseInt(replyBtn.textContent.match(/\d+/)[0]) || 0;
                    replyBtn.textContent = `답글 ${currentCount + 1}개`;
                    replyBtn.setAttribute('data-expanded', 'true');
                }
            }
            
        } else {
            showCourseMessage(result.message || '답글 등록에 실패했습니다.', 'error');
        }
        
    } catch (error) {
        console.error('답글 작성 오류:', error);
        showCourseMessage('답글 등록 중 오류가 발생했습니다.', 'error');
    }
}

// 답글 폼 취소
function cancelReplyForm() {
    const form = document.querySelector('.reply-form-container');
    if (form) {
        form.remove();
        
        // 답글 컨테이너가 비어있다면 숨기기
        const repliesContainer = form.closest('.replies-container');
        if (repliesContainer && repliesContainer.children.length === 0) {
            repliesContainer.style.display = 'none';
            
            // 버튼 텍스트를 원래대로 복원
            const parentComment = repliesContainer.closest('.comment-item');
            if (parentComment) {
                const replyBtn = parentComment.querySelector('.reply-btn');
                if (replyBtn) {
                    replyBtn.textContent = '답글 0개';
                    replyBtn.setAttribute('data-expanded', 'false');
                }
            }
        }
    }
}

// 댓글 좋아요/싫어요 토글
async function toggleCommentReaction(commentId, reactionType) {
    console.log('댓글 리액션 토글:', { commentId, reactionType });
    
    try {
        // JWT 토큰 가져오기
        const token = localStorage.getItem('accessToken');
        
        const response = await fetch('<%=root%>/course/' + COURSE_ID + '/comment/' + commentId + '/reaction', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Authorization': token ? 'Bearer ' + token : ''
            },
            body: 'reactionType=' + reactionType
        });
        
        const data = await response.json();
        console.log('서버 응답 데이터:', data);
        
        if (data.success) {
            // 해당 댓글의 좋아요/싫어요 수 업데이트 (댓글과 답글 모두 처리)
            let commentElement = document.querySelector(`[data-comment-id="${commentId}"]`);
            
            // 만약 찾지 못했다면, 더 구체적인 선택자로 시도
            if (!commentElement) {
                // 댓글과 답글 모두에서 찾기
                const allComments = document.querySelectorAll('.comment-item');
                for (let comment of allComments) {
                    if (comment.getAttribute('data-comment-id') === commentId.toString()) {
                        commentElement = comment;
                        break;
                    }
                }
            }
            
            console.log('찾은 댓글 요소:', commentElement);
            console.log('현재 DOM의 모든 댓글 요소들:', document.querySelectorAll('.comment-item'));
            
            if (commentElement) {
                // 좋아요/싫어요 개수 업데이트
                const likeCountElement = commentElement.querySelector('.like-count');
                const dislikeCountElement = commentElement.querySelector('.dislike-count');
                
                console.log('찾은 요소들:', {
                    likeCountElement: likeCountElement,
                    dislikeCountElement: dislikeCountElement,
                    dataLikeCount: data.likeCount,
                    dataDislikeCount: data.dislikeCount
                });
                
                if (likeCountElement) {
                    likeCountElement.textContent = data.likeCount || 0;
                    console.log('좋아요 개수 업데이트:', data.likeCount || 0);
                }
                if (dislikeCountElement) {
                    dislikeCountElement.textContent = data.dislikeCount || 0;
                    console.log('싫어요 개수 업데이트:', data.dislikeCount || 0);
                }
                
                // 버튼 상태 업데이트
                const likeBtn = commentElement.querySelector('.comment-like-btn');
                const dislikeBtn = commentElement.querySelector('.comment-dislike-btn');
                
                // 모든 버튼에서 active 클래스 제거
                if (likeBtn) likeBtn.classList.remove('active');
                if (dislikeBtn) dislikeBtn.classList.remove('active');
                
                // 현재 리액션에 따라 active 클래스 추가
                if (data.currentReaction === 'LIKE' && likeBtn) {
                    likeBtn.classList.add('active');
                } else if (data.currentReaction === 'DISLIKE' && dislikeBtn) {
                    dislikeBtn.classList.add('active');
                }
                
                console.log('댓글/답글 리액션 업데이트 완료:', {
                    commentId: commentId,
                    likeCount: data.likeCount,
                    dislikeCount: data.dislikeCount,
                    currentReaction: data.currentReaction
                });
            } else {
                console.error('댓글 요소를 찾을 수 없음:', commentId);
                console.error('현재 DOM의 모든 댓글 ID들:', Array.from(document.querySelectorAll('.comment-item')).map(el => el.getAttribute('data-comment-id')));
            }
            
            console.log('댓글/답글 리액션 처리 성공:', data.action);
            
        } else {
            console.error('댓글/답글 리액션 처리 실패:', data.message);
            showCourseMessage(data.message || '리액션 처리 중 오류가 발생했습니다.', 'error');
        }
        
    } catch (error) {
        console.error('댓글/답글 리액션 처리 오류:', error);
        showCourseMessage('리액션 처리 중 오류가 발생했습니다.', 'error');
    }
}

// 댓글 좋아요
function likeComment(commentId) {
    toggleCommentReaction(commentId, 'LIKE');
}

// 댓글 싫어요
function dislikeComment(commentId) {
    toggleCommentReaction(commentId, 'DISLIKE');
}

// 코스 상세 전용 토스트 메시지 표시 함수
function showCourseMessage(message, type = 'info') {
    // 기존 코스 상세 토스트 메시지 제거
    const existingToast = document.querySelector('.course-toast-message');
    if (existingToast) {
        existingToast.remove();
    }
    
    // 토스트 메시지 생성
    const toast = document.createElement('div');
    toast.className = `course-toast-message course-toast-${type}`;
    toast.textContent = message;
    
    // 스타일 설정
    toast.style.cssText = `
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        padding: 15px 25px;
        border-radius: 8px;
        color: white;
        font-weight: 600;
        font-size: 16px;
        z-index: 10000;
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
        animation: slideIn 0.3s ease-out;
        text-align: center;
        min-width: 300px;
    `;
    
    // 타입별 색상 설정 (투명도 추가)
    if (type === 'error') {
        toast.style.backgroundColor = 'rgba(220, 53, 69, 0.9)';
    } else if (type === 'warning') {
        toast.style.backgroundColor = 'rgba(220, 53, 69, 0.9)';
        toast.style.color = 'white';
    } else if (type === 'success') {
        toast.style.backgroundColor = 'rgba(40, 167, 69, 0.9)';
    } else {
        toast.style.backgroundColor = 'rgba(23, 162, 184, 0.9)';
    }
    
    // 코스 상세 전용 애니메이션 CSS 추가
    if (!document.querySelector('#course-toast-animation')) {
        const style = document.createElement('style');
        style.id = 'course-toast-animation';
        style.textContent = `
            @keyframes courseSlideIn {
                from {
                    transform: translate(-50%, -50%) scale(0.8);
                    opacity: 0;
                }
                to {
                    transform: translate(-50%, -50%) scale(1);
                    opacity: 1;
                }
            }
            @keyframes courseSlideOut {
                from {
                    transform: translate(-50%, -50%) scale(1);
                    opacity: 1;
                }
                to {
                    transform: translate(-50%, -50%) scale(0.8);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);
    }
    
    // DOM에 추가
    document.body.appendChild(toast);
    
    // 2.5초 후 자동 제거
    setTimeout(() => {
        toast.style.animation = 'courseSlideOut 0.3s ease-in';
        setTimeout(() => {
            if (toast.parentNode) {
                toast.remove();
            }
        }, 300);
    }, 2500);
}

// 좋아요/싫어요 토글
async function toggleReaction(courseId, reactionType) {
    console.log('toggleReaction 호출:', { courseId, reactionType });
    
    // 로그인 상태 확인
    const loggedIn = isLoggedIn();
    console.log('로그인 상태:', loggedIn);
    
    if (!loggedIn) {
        showCourseMessage('게시글 좋아요/싫어요는 로그인후 사용 가능합니다', 'error');
        return;
    }
    
    try {
        // JWT 토큰 가져오기
        const token = localStorage.getItem('accessToken');
        if (!token) {
            showCourseMessage('게시글 좋아요/싫어요는 로그인후 사용 가능합니다', 'error');
            return;
        }
        
        // fetchWithAuth 사용 (자동 토큰 갱신 포함)
        let response;
        if (typeof window.fetchWithAuth === 'function') {
            response = await window.fetchWithAuth('<%=root%>/course/' + courseId + '/reaction', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Authorization': 'Bearer ' + token
                },
                body: 'reactionType=' + reactionType
            });
        } else {
            // fallback: 일반 fetch 사용
            response = await fetch('<%=root%>/course/' + courseId + '/reaction', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Authorization': 'Bearer ' + token
                },
                body: 'reactionType=' + reactionType
            });
        }
        
        const data = await response.json();
        
        if (data.success) {
            // 개수 업데이트
            document.querySelector('.like-count').textContent = data.likeCount;
            document.querySelector('.dislike-count').textContent = data.dislikeCount;
            
            // 버튼 상태 업데이트
            const likeBtn = document.getElementById('likeBtn');
            const dislikeBtn = document.getElementById('dislikeBtn');
            
            // 모든 버튼에서 active 클래스 제거
            likeBtn.classList.remove('active');
            dislikeBtn.classList.remove('active');
            
            // 현재 리액션에 따라 active 클래스 추가
            if (data.currentReaction === 'LIKE') {
                likeBtn.classList.add('active');
            } else if (data.currentReaction === 'DISLIKE') {
                dislikeBtn.classList.add('active');
            }
            
            // 성공 시에는 토스트 메시지 표시하지 않음 (조용히 처리)
            console.log('리액션 처리 성공:', data.action);
            
        } else {
            // 에러 메시지 표시
            if (data.requireLogin) {
                showCourseMessage('게시글 좋아요/싫어요는 로그인후 사용 가능합니다', 'error');
            } else {
                showCourseMessage(data.message || '리액션 처리 중 오류가 발생했습니다.', 'error');
            }
        }
    } catch (error) {
        console.error('Error:', error);
        showCourseMessage('리액션 처리 중 오류가 발생했습니다.', 'error');
    }
}

// 코스 작성 시간 계산
function calculateCourseCreatedTime() {
    const timeElement = document.getElementById('courseCreatedTime');
    if (timeElement) {
        const createdAt = timeElement.getAttribute('data-created-at');
        if (createdAt) {
            const timeText = getTimeAgo(createdAt);
            timeElement.textContent = timeText;
        } else {
            timeElement.textContent = '방금전';
        }
    }
}

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    // 코스 작성 시간 계산
    calculateCourseCreatedTime();
    
    // 현재 리액션 상태 설정
    const currentReaction = '${currentReaction}';
    const likeBtn = document.getElementById('likeBtn');
    const dislikeBtn = document.getElementById('dislikeBtn');
    
    if (currentReaction === 'LIKE') {
        likeBtn.classList.add('active');
    } else if (currentReaction === 'DISLIKE') {
        dislikeBtn.classList.add('active');
    }
    
    // 로그인 상태에 따른 버튼 스타일 조정
    updateReactionButtonsStyle();
    
    // 댓글 폼 초기화
    initializeCommentForm();
    
    // 초기 로그인 상태 저장
    previousLoginStatus = isLoggedIn();
    
    // 주기적으로 로그인 상태 확인 (5초마다)
    setInterval(checkLoginStatus, 5000);
    
    // 댓글 목록 로드
    loadComments('latest');
    
    // 초기 댓글 갯수 설정
    const initialCommentCount = parseInt('${course.commentCount}' || '0');
    updateCommentCount(initialCommentCount);
});

// 댓글 폼 초기화
function initializeCommentForm() {
    const loggedIn = isLoggedIn();
    const nicknameInput = document.getElementById('commentNickname');
    const passwordInput = document.getElementById('commentPassword');
    
    if (loggedIn) {
        // 로그인한 사용자: 닉네임 자동 설정
        try {
            const token = localStorage.getItem('accessToken');
            const base64Url = token.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));
            
            const payload = JSON.parse(jsonPayload);
            if (payload.nickname) {
                nicknameInput.value = payload.nickname;
                nicknameInput.readOnly = true;
                nicknameInput.style.backgroundColor = '#f8f9fa';
            }
        } catch (error) {
            console.error('토큰에서 닉네임 추출 실패:', error);
        }
        
        // 비밀번호 필드 숨기기
        passwordInput.style.display = 'none';
        passwordInput.parentElement.style.display = 'none';
        
    } else {
        // 비로그인 사용자: 닉네임 입력 가능
        nicknameInput.readOnly = false;
        nicknameInput.style.backgroundColor = '';
        
        // 비밀번호 필드 표시
        passwordInput.style.display = 'block';
        passwordInput.parentElement.style.display = 'block';
    }
}

// 로그인 상태 체크 및 UI 업데이트
let previousLoginStatus = null;

function checkLoginStatus() {
    const currentLoginStatus = isLoggedIn();
    
    // 로그인 상태가 변경된 경우에만 UI 업데이트
    if (previousLoginStatus !== currentLoginStatus) {
        console.log('로그인 상태 변경 감지:', previousLoginStatus, '->', currentLoginStatus);
        updateReactionButtonsStyle();
        initializeCommentForm();
        previousLoginStatus = currentLoginStatus;
    }
}

// 로그인 상태에 따른 버튼 스타일 업데이트 - 비활성화 제거
function updateReactionButtonsStyle() {
    const likeBtn = document.getElementById('likeBtn');
    const dislikeBtn = document.getElementById('dislikeBtn');
    
    // 로그인하지 않은 사용자도 버튼을 클릭할 수 있도록 비활성화 제거
    likeBtn.disabled = false;
    dislikeBtn.disabled = false;
    
    // 툴팁 제거
    likeBtn.title = '';
    dislikeBtn.title = '';
}

// 댓글 작성
async function submitComment() {
    if (!COURSE_ID || COURSE_ID === 0) {
        showCourseMessage('Course ID가 없습니다.', 'error');
        return;
    }
    
    // 로그인 상태 확인
    const loggedIn = isLoggedIn();
    
    let nickname = '';
    const password = document.getElementById('commentPassword').value;
    const content = document.getElementById('commentContent').value.trim();
    
    if (loggedIn) {
        // 로그인한 사용자: 토큰에서 닉네임 추출
        try {
            const token = localStorage.getItem('accessToken');
            const base64Url = token.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));
            
            const payload = JSON.parse(jsonPayload);
            nickname = payload.nickname || '';
        } catch (error) {
            console.error('토큰에서 닉네임 추출 실패:', error);
            showCourseMessage('사용자 정보를 가져오는데 실패했습니다.', 'error');
            return;
        }
    } else {
        // 비로그인 사용자: 입력 필드에서 닉네임 가져오기
        nickname = document.getElementById('commentNickname').value.trim();
    }
    
    // 입력 검증
    if (!nickname || !content) {
        showCourseMessage('닉네임과 댓글 내용을 입력해주세요.', 'warning');
        return;
    }
    
    if (nickname.length > 5) {
        showCourseMessage('닉네임은 5글자 이하로 입력해주세요.', 'warning');
        return;
    }
    
    // 비로그인 사용자의 경우 비밀번호 검증
    if (!loggedIn) {
        if (!password || password.length !== 4 || !/^\d{4}$/.test(password)) {
            showCourseMessage('비밀번호는 숫자 4자리로 입력해주세요.', 'warning');
            return;
        }
    }
    
    try {
        // FormData 생성
        const formData = new FormData();
        formData.append('nickname', nickname);
        formData.append('content', content);
        
        if (!loggedIn) {
            formData.append('password', password);
        }
        
        // JWT 토큰 가져오기
        const token = localStorage.getItem('accessToken');
        
        // API 호출
        const response = await fetch('<%=root%>/course/' + COURSE_ID + '/comment', {
            method: 'POST',
            headers: {
                'Authorization': token ? 'Bearer ' + token : ''
            },
            body: formData
        });
        
        const result = await response.json();
        
        if (result.success) {
            showCourseMessage('댓글이 등록되었습니다.', 'success');
            
            // 입력 필드 초기화 (로그인 상태에 따라 다르게 처리)
            const loggedIn = isLoggedIn();
            if (loggedIn) {
                // 로그인한 사용자: 닉네임은 유지, 댓글 내용만 초기화
                document.getElementById('commentContent').value = '';
            } else {
                // 비로그인 사용자: 모든 필드 초기화
                document.getElementById('commentNickname').value = '';
                document.getElementById('commentPassword').value = '';
                document.getElementById('commentContent').value = '';
            }
            
            // 댓글 목록 새로고침
            loadComments('latest');
            
        } else {
            showCourseMessage(result.message || '댓글 등록에 실패했습니다.', 'error');
        }
        
    } catch (error) {
        console.error('댓글 작성 오류:', error);
        showCourseMessage('댓글 등록 중 오류가 발생했습니다.', 'error');
    }
}

// 페이지 로드 시 댓글 로드 및 댓글 입력 필드 설정
document.addEventListener('DOMContentLoaded', function() {
    loadComments('latest');
    setupCommentForm();
});

// 댓글 입력 폼 설정
function setupCommentForm() {
    const loggedIn = isLoggedIn();
    const nicknameField = document.getElementById('commentNickname');
    const passwordField = document.getElementById('commentPassword');
    
    if (loggedIn) {
        // 로그인한 사용자: 토큰에서 닉네임 추출하여 설정
        try {
            const token = localStorage.getItem('accessToken');
            const base64Url = token.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));
            
            const payload = JSON.parse(jsonPayload);
            const nickname = payload.nickname || '';
            
            // 닉네임 필드 설정 및 비활성화
            nicknameField.value = nickname;
            nicknameField.readOnly = true;
            nicknameField.style.backgroundColor = '#f8f9fa';
            nicknameField.style.color = '#6c757d';
            
            // 비밀번호 필드 숨기기
            passwordField.style.display = 'none';
            passwordField.parentElement.style.display = 'none';
            
        } catch (error) {
            console.error('토큰에서 닉네임 추출 실패:', error);
            // 토큰 파싱 실패 시 일반 입력 필드로 유지
            nicknameField.readOnly = false;
            passwordField.style.display = 'block';
        }
    } else {
        // 비로그인 사용자: 일반 입력 필드로 설정
        nicknameField.readOnly = false;
        nicknameField.style.backgroundColor = '';
        nicknameField.style.color = '';
        passwordField.style.display = 'block';
        passwordField.parentElement.style.display = 'block';
    }
}

// 삭제 메뉴 표시/숨김
function showDeleteMenu(courseId, authorUserid, userId) {
    const menu = document.getElementById('deleteMenu_' + courseId);
    if (menu.style.display === 'none') {
        menu.style.display = 'block';
    } else {
        menu.style.display = 'none';
    }
}

// 삭제 처리
function deleteCourse(courseId, authorUserid, userId) {
    const userInfo = getUserInfo();
    const currentUserId = userInfo && userInfo.userid ? userInfo.userid : null;
    
    // 로그인된 사용자가 쓴 글인 경우
    if (authorUserid === 'user') {
        // 현재 로그인한 사용자와 글쓴이가 같은지 확인
        if (!currentUserId || currentUserId !== userId) {
            showToast('글쓴이와 ID가 일치해야 삭제 가능합니다', 2500);
            return;
        }
    }
    
    // 비밀번호 확인 모달 표시
    showPasswordModal(courseId, authorUserid, userId);
}

// 비밀번호 확인 모달 표시
function showPasswordModal(courseId, authorUserid, userId) {
    const modal = document.getElementById('passwordModal');
    const title = document.getElementById('passwordModalTitle');
    const input = document.getElementById('passwordModalInput');
    
    // 모달 제목 설정
    if (authorUserid === 'user') {
        title.textContent = '비밀번호를 입력해주세요';
    } else {
        title.textContent = '작성 시 입력한 비밀번호를 입력해주세요';
    }
    
    // 모달에 데이터 저장
    modal.dataset.courseId = courseId;
    modal.dataset.authorUserid = authorUserid;
    modal.dataset.userId = userId;
    
    // 입력 필드 초기화
    input.value = '';
    input.focus();
    
    // 모달 표시
    modal.style.display = 'flex';
}

// 비밀번호 확인 모달 닫기
function closePasswordModal() {
    const modal = document.getElementById('passwordModal');
    modal.style.display = 'none';
}

// 삭제 확인
function confirmDelete() {
    const modal = document.getElementById('passwordModal');
    const input = document.getElementById('passwordModalInput');
    const courseId = modal.dataset.courseId;
    const authorUserid = modal.dataset.authorUserid;
    const userId = modal.dataset.userId;
    const password = input.value;
    
    if (!password || password.length !== 4 || !/^\d{4}$/.test(password)) {
        alert('비밀번호는 숫자 4자리로 입력해주세요.');
        input.focus();
        return;
    }
    
    // JWT 토큰 가져오기
    const token = localStorage.getItem('accessToken');
    
    // 삭제 요청
    fetch('<%=root%>/course/delete', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': token ? 'Bearer ' + token : ''
        },
        body: JSON.stringify({
            courseId: courseId,
            password: password,
            authorUserid: authorUserid,
            userId: userId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showToast('코스가 삭제되었습니다', 2000);
            // 목록 페이지로 이동
            setTimeout(() => {
                window.location.href = '<%=root%>/course';
            }, 1000);
        } else {
            showToast(data.message || '삭제에 실패했습니다', 2500);
        }
    })
    .catch(error => {
        console.error('삭제 오류:', error);
        showToast('삭제 중 오류가 발생했습니다', 2500);
    })
    .finally(() => {
        closePasswordModal();
    });
}

// 토스트 메시지 표시
function showToast(message, duration = 2500) {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = 'toast-message';
    toast.textContent = message;
    
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.style.opacity = '0';
        setTimeout(() => {
            container.removeChild(toast);
        }, 300);
    }, duration);
}

// 댓글 삭제 메뉴 표시/숨김
function showCommentDeleteMenu(commentId, nickname) {
    const menu = document.getElementById('commentDeleteMenu_' + commentId);
    if (menu.style.display === 'none') {
        menu.style.display = 'block';
    } else {
        menu.style.display = 'none';
    }
}

// 댓글 삭제 처리
function deleteComment(commentId, nickname) {
    // 댓글의 author_userid 정보를 가져와서 anonymous인지 확인
    const commentElement = document.querySelector(`[data-comment-id="${commentId}"]`);
    const authorUserid = commentElement ? commentElement.getAttribute('data-author-userid') : null;
    
    // 비밀번호 확인 모달 표시 (author_userid 정보도 함께 전달)
    showCommentPasswordModal(commentId, nickname, authorUserid);
}

// 댓글 비밀번호 확인 모달 표시
function showCommentPasswordModal(commentId, nickname, authorUserid) {
    const modal = document.getElementById('commentPasswordModal');
    const title = document.getElementById('commentPasswordModalTitle');
    const input = document.getElementById('commentPasswordModalInput');
    
    // 로그인 상태 확인
    const loggedIn = isLoggedIn();
    
    // author_userid가 anonymous인 경우 비밀번호 입력 필요
    const isAnonymousComment = authorUserid === 'anonymous';
    
    // 모달 제목 설정
    if (loggedIn && !isAnonymousComment) {
        title.textContent = '댓글을 삭제하시겠습니까?';
        input.style.display = 'none'; // 비밀번호 입력 필드 숨기기
    } else {
        title.textContent = '댓글 삭제를 위한 비밀번호를 입력해주세요';
        input.style.display = 'block'; // 비밀번호 입력 필드 표시
    }
    
    // 모달에 데이터 저장
    modal.dataset.commentId = commentId;
    modal.dataset.nickname = nickname;
    modal.dataset.authorUserid = authorUserid;
    
    // 입력 필드 초기화
    input.value = '';
    
    // 비밀번호 입력이 필요한 경우에만 포커스 설정
    if (isAnonymousComment || !loggedIn) {
        input.focus();
    }
    
    // 모달 표시
    modal.style.display = 'flex';
}

// 댓글 비밀번호 확인 모달 닫기
function closeCommentPasswordModal() {
    const modal = document.getElementById('commentPasswordModal');
    modal.style.display = 'none';
}

// 댓글 삭제 확인
function confirmCommentDelete() {
    const modal = document.getElementById('commentPasswordModal');
    const input = document.getElementById('commentPasswordModalInput');
    const commentId = modal.dataset.commentId;
    const nickname = modal.dataset.nickname;
    const authorUserid = modal.dataset.authorUserid;
    const password = input.value;
    
    // 로그인 상태 확인
    const loggedIn = isLoggedIn();
    
    // author_userid가 anonymous인 경우 비밀번호 입력 필요
    const isAnonymousComment = authorUserid === 'anonymous';
    
    // 비밀번호 입력이 필요한 경우 비밀번호 검증
    if (isAnonymousComment || !loggedIn) {
        if (!password || password.length !== 4 || !/^\d{4}$/.test(password)) {
            alert('비밀번호는 숫자 4자리로 입력해주세요.');
            input.focus();
            return;
        }
    }
    
    // JWT 토큰 가져오기
    const token = localStorage.getItem('accessToken');
    
    // 삭제 요청 데이터 준비
    const requestData = {
        commentId: commentId,
        nickname: nickname,
        authorUserid: authorUserid
    };
    
    // 비밀번호 입력이 필요한 경우에만 비밀번호 포함
    if (isAnonymousComment || !loggedIn) {
        requestData.password = password;
    }
    
    // 삭제 요청
    fetch('<%=root%>/course/comment/delete', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': token ? 'Bearer ' + token : ''
        },
        body: JSON.stringify(requestData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showCourseMessage('댓글이 삭제되었습니다.', 'success');
            // 댓글 목록 새로고침
            loadComments('latest');
        } else {
            showCourseMessage(data.message || '삭제에 실패했습니다.', 'error');
        }
    })
    .catch(error => {
        console.error('댓글 삭제 오류:', error);
        showCourseMessage('삭제 중 오류가 발생했습니다.', 'error');
    })
    .finally(() => {
        closeCommentPasswordModal();
    });
}

// 코스 신고
function reportCourse(courseId) {
    // 로그인 상태 확인
    const loggedIn = isLoggedIn();
    
    if (!loggedIn) {
        // 로그인하지 않은 경우 빨간색 모달로 메시지 표시
        showCourseMessage('신고는 로그인 후 이용 가능합니다.', 'error');
        return;
    }
    
    // 로그인한 경우 신고 모달 표시
    showReportModal(courseId);
}

// 신고 모달 표시
function showReportModal(courseId) {
    const modal = document.getElementById('reportModal');
    const title = document.getElementById('reportModalTitle');
    const reasonSelect = document.getElementById('reportReasonSelect');
    const detailsTextarea = document.getElementById('reportDetailsTextarea');
    
    // 모달 제목 설정
    title.textContent = '코스 신고';
    
    // 모달에 데이터 저장
    modal.dataset.courseId = courseId;
    
    // 입력 필드 초기화
    reasonSelect.value = '';
    detailsTextarea.value = '';
    
    // 모달 표시
    modal.style.display = 'flex';
}

// 신고 모달 닫기
function closeReportModal() {
    const modal = document.getElementById('reportModal');
    modal.style.display = 'none';
}

// 신고 확인
function confirmReport() {
    const modal = document.getElementById('reportModal');
    const courseId = modal.dataset.courseId;
    const reason = document.getElementById('reportReasonSelect').value;
    const details = document.getElementById('reportDetailsTextarea').value;
    
    if (!reason) {
        showCourseMessage('신고 사유를 선택해주세요.', 'warning');
        return;
    }
    
    // JWT 토큰 가져오기
    const token = localStorage.getItem('accessToken');
    
    // 신고 요청
    fetch('<%=root%>/course/report', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': token ? 'Bearer ' + token : ''
        },
        body: JSON.stringify({
            courseId: courseId,
            reason: reason,
            details: details
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showCourseMessage('신고가 접수되었습니다.', 'success');
            closeReportModal();
        } else {
            if (data.requireLogin) {
                showCourseMessage('신고는 로그인 후 이용 가능합니다.', 'error');
            } else {
                showCourseMessage(data.message || '신고 접수에 실패했습니다.', 'error');
            }
        }
    })
    .catch(error => {
        console.error('신고 오류:', error);
        showCourseMessage('신고 중 오류가 발생했습니다.', 'error');
    });
}

// 페이지 클릭 시 메뉴 닫기
document.addEventListener('click', function(e) {
    if (!e.target.closest('.course-detail-menu')) {
        document.querySelectorAll('.course-detail-menu-dropdown').forEach(menu => {
            menu.style.display = 'none';
        });
    }
    if (!e.target.closest('.comment-menu')) {
        document.querySelectorAll('.comment-menu-dropdown').forEach(menu => {
            menu.style.display = 'none';
        });
    }
});
</script>

<!-- 토스트 메시지 컨테이너 -->
<div id="toastContainer" class="toast-container"></div>

<!-- 비밀번호 확인 모달 -->
<div id="passwordModal" class="password-modal">
    <div class="password-modal-content">
        <div class="password-modal-title" id="passwordModalTitle">비밀번호를 입력해주세요</div>
        <input type="password" id="passwordModalInput" class="password-modal-input" placeholder="비밀번호 4자리" maxlength="4" pattern="[0-9]{4}">
        <div class="password-modal-buttons">
            <button class="password-modal-btn confirm" onclick="confirmDelete()">삭제</button>
            <button class="password-modal-btn cancel" onclick="closePasswordModal()">취소</button>
        </div>
    </div>
</div>

<!-- 댓글 삭제용 비밀번호 확인 모달 -->
<div id="commentPasswordModal" class="password-modal">
    <div class="password-modal-content">
        <div class="password-modal-title" id="commentPasswordModalTitle">댓글 삭제를 위한 비밀번호를 입력해주세요</div>
        <input type="password" id="commentPasswordModalInput" class="password-modal-input" placeholder="비밀번호 4자리" maxlength="4" pattern="[0-9]{4}">
        <div class="password-modal-buttons">
            <button class="password-modal-btn confirm" onclick="confirmCommentDelete()">삭제</button>
            <button class="password-modal-btn cancel" onclick="closeCommentPasswordModal()">취소</button>
        </div>
    </div>
</div>

<!-- 코스 신고 모달 -->
<div id="reportModal" class="password-modal">
    <div class="password-modal-content">
        <div class="password-modal-title" id="reportModalTitle">코스 신고</div>
        <div style="margin-bottom: 15px;">
            <label for="reportReasonSelect" style="display: block; margin-bottom: 5px; font-weight: 600;">신고 사유</label>
            <select id="reportReasonSelect" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px;">
                <option value="">신고 사유를 선택해주세요</option>
                <option value="부적절한 내용">부적절한 내용</option>
                <option value="스팸 또는 광고">스팸 또는 광고</option>
                <option value="저작권 침해">저작권 침해</option>
                <option value="개인정보 노출">개인정보 노출</option>
                <option value="기타">기타</option>
            </select>
        </div>
        <div style="margin-bottom: 20px;">
            <label for="reportDetailsTextarea" style="display: block; margin-bottom: 5px; font-weight: 600;">상세 내용 (선택사항)</label>
            <textarea id="reportDetailsTextarea" placeholder="신고 상세 내용을 입력해주세요..." style="width: 100%; height: 100px; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; resize: vertical;"></textarea>
        </div>
        <div class="password-modal-buttons">
            <button class="password-modal-btn confirm" onclick="confirmReport()">신고</button>
            <button class="password-modal-btn cancel" onclick="closeReportModal()">취소</button>
        </div>
    </div>
</div>
