<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String root = request.getContextPath();
%>

<!-- hpostdetail.css 링크 -->
<link rel="stylesheet" href="<c:url value='/css/hpostdetail.css'/>">



<!-- 메인 컨텐츠 -->
<div class="container mt-5 hpost-container">
    
    <!-- 핫플썰 제목 -->
    <div class="hpost-title">
        <h2>핫플썰</h2>
    </div>
    
    <!-- 게시글 상세 내용 -->
    <div class="hpost-detail">
        <c:if test="${not empty hpost}">
            <!-- 게시글 헤더 -->
            <div class="hpost-detail-header">
                <div class="hpost-detail-title-row">
                    <h3 class="hpost-detail-title">${hpost.title}</h3>
                    <div class="hpost-detail-menu">
                        <button class="hpost-detail-menu-btn" onclick="showHpostMenu()">⋯</button>
                        <div class="hpost-detail-menu-dropdown" id="hpostMenuDropdown" style="display: none;">
                            <div class="hpost-detail-menu-item" onclick="showReportModal()">신고</div>
                            <div class="hpost-detail-menu-item" onclick="showHpostDeleteModal()">삭제</div>
                        </div>
                    </div>
                </div>
                <div class="hpost-detail-info">
                    <div class="hpost-detail-nickname">${hpost.nickname}</div>
                    <div class="hpost-detail-meta">
                        <span class="hpost-detail-date">${hpost.formattedTime}</span>
                        <span class="hpost-detail-views"><i class="bi bi-eye text-muted"></i> ${hpost.views}</span>
                    </div>
                </div>
            </div>
            
            <!-- 사진 출력 -->
            <div class="hpost-detail-photos">
                <c:if test="${not empty hpost.photo1}">
                    <img src="<c:url value='/uploads/hpostsave/${hpost.photo1}'/>" alt="사진1" class="hpost-detail-photo" onclick="openPhotoModal(0)">
                </c:if>
                <c:if test="${not empty hpost.photo2}">
                    <img src="<c:url value='/uploads/hpostsave/${hpost.photo2}'/>" alt="사진2" class="hpost-detail-photo" onclick="openPhotoModal(1)">
                </c:if>
                <c:if test="${not empty hpost.photo3}">
                    <img src="<c:url value='/uploads/hpostsave/${hpost.photo3}'/>" alt="사진3" class="hpost-detail-photo" onclick="openPhotoModal(2)">
                </c:if>
            </div>
            
            <!-- 게시글 내용 -->
            <div class="hpost-detail-content">
                <p>${hpost.content}</p>
            </div>
            
            <!-- 좋아요/싫어요 버튼 -->
            <div class="hpost-detail-actions">
                <button class="hpost-detail-like-btn" id="likeBtn" onclick="processVote('like')">
                    <i class="bi bi-hand-thumbs-up"></i> <span class="badge" id="likeCount">${likeCount}</span>
                </button>
                <button class="hpost-detail-dislike-btn" id="dislikeBtn" onclick="processVote('dislike')">
                    <i class="bi bi-hand-thumbs-down"></i> <span class="badge" id="dislikeCount">${dislikeCount}</span>
                </button>
            </div>
            
            <!-- 구분선 -->
            <hr class="hpost-detail-divider">

            <!-- 댓글 섹션 -->
            <div class="hpost-comments-section">
                <!-- 댓글 갯수 -->
                <div class="hpost-comment-count-container">
                    <div class="hpost-comment-count-box">
                        <span class="hpost-comment-count-text">댓글 <span id="comment-count-display">0</span></span>
                    </div>
                </div>
                
                <!-- 댓글 입력 -->
                <div class="hpost-comment-form">
                    <div class="hpost-comment-input-row">
                        <div class="hpost-comment-left-column">
                            <input type="text" class="hpost-comment-nickname" id="commentNickname" placeholder="닉네임" maxlength="5" />
                            <input type="password" class="hpost-comment-password" id="commentPassword" placeholder="비밀번호 (숫자 4자리)" maxlength="4" pattern="[0-9]{4}" />
                        </div>
                        <div class="hpost-comment-right-section">
                            <textarea class="hpost-comment-content" id="commentContent" placeholder="댓글을 입력하세요..."></textarea>
                            <button class="hpost-comment-submit-btn" onclick="submitComment()">댓글 작성</button>
                        </div>
                    </div>
                </div>
                
                <!-- 정렬 버튼 -->
                <div class="hpost-comments-sort-container">
                    <div class="hpost-comments-sort-buttons">
                        <button class="hpost-sort-btn active" onclick="loadComments('latest')">최신순</button>
                        <button class="hpost-sort-btn" onclick="loadComments('popular')">인기순</button>
                    </div>
                </div>
                
                <!-- 댓글 목록 -->
                <div class="hpost-comments">
                    <div id="commentsList" class="hpost-comments-list">
                        <!-- 댓글들이 여기에 동적으로 로드됩니다 -->
                    </div>
                </div>
            </div>

        </c:if>
        
        <c:if test="${empty hpost}">
            <div class="text-center py-5">
                <p>게시글을 찾을 수 없습니다.</p>
                <button class="btn btn-primary" onclick="location.href='/hpost'">
                    <i class="bi bi-arrow-left"></i> 목록으로
                </button>
            </div>
        </c:if>
    </div>
</div>

<!-- 사진 모달 -->
<div class="photo-modal" id="photoModal">
    <div class="photo-modal-content">
        <span class="photo-modal-close" onclick="closePhotoModal()">&times;</span>
        <button class="photo-nav-btn photo-nav-prev" onclick="changePhoto(-1)">&#10094;</button>
        <button class="photo-nav-btn photo-nav-next" onclick="changePhoto(1)">&#10095;</button>
        <img id="modalPhoto" src="" alt="확대된 사진" class="photo-modal-img">
    </div>
</div>

<!-- 댓글 비밀번호 확인 모달 -->
<div class="modal" id="commentPasswordModal" style="display: none;">
    <div class="modal-content">
        <h3 id="commentPasswordModalTitle">댓글 삭제를 위한 비밀번호를 입력해주세요</h3>
        <input type="password" id="commentPasswordModalInput" placeholder="비밀번호 (숫자 4자리)" maxlength="4" pattern="[0-9]{4}">
        <div class="modal-buttons">
            <button onclick="confirmCommentDelete()" class="btn btn-danger">삭제</button>
            <button onclick="closeCommentPasswordModal()" class="btn btn-secondary">취소</button>
        </div>
    </div>
</div>

<!-- 게시글 삭제 비밀번호 확인 모달 -->
<div class="modal" id="hpostDeleteModal" style="display: none;">
    <div class="modal-content">
        <h3>게시글 삭제를 위한 비밀번호를 입력해주세요</h3>
        <input type="password" id="hpostDeletePasswordInput" placeholder="비밀번호 (숫자 4자리)" maxlength="4" pattern="[0-9]{4}">
        <div class="modal-buttons">
            <button onclick="deleteHpost()" class="btn btn-danger">삭제</button>
            <button onclick="closeHpostDeleteModal()" class="btn btn-secondary">취소</button>
        </div>
    </div>
</div>

<script>
// 전역 변수 설정
let HPOST_ID = parseInt('${hpost.id}');
if (isNaN(HPOST_ID) || HPOST_ID <= 0) {
    HPOST_ID = 0;
} else {
    // HPOST_ID 설정 완료
}

// 현재 댓글 정렬 상태
let currentCommentSort = 'latest';

// 로그인 상태 변경 감지 및 댓글 폼 업데이트 함수
function updateCommentFormOnLoginChange() {
    setupCommentForm();
}

// 전역 함수로 등록 (다른 페이지에서 호출 가능)
window.updateCommentFormOnLoginChange = updateCommentFormOnLoginChange;

// hpostData 설정
window.hpostData = {
    id: HPOST_ID || 0,
    title: '${hpost.title}' || '',
    content: '${hpost.content}' || '',
    nickname: '${hpost.nickname}' || '',
    likes: parseInt('${hpost.likes}' || '0'),
    dislikes: parseInt('${hpost.dislikes}' || '0'),
    views: parseInt('${hpost.views}' || '0'),
    formattedTime: '${hpost.formattedTime}' || '',
    photo1: '${hpost.photo1}' || '',
    photo2: '${hpost.photo2}' || '',
    photo3: '${hpost.photo3}' || ''
};

// hpostData 설정 완료

// 로그인 상태 확인 함수
function isLoggedIn() {
    const token = localStorage.getItem('accessToken');
    if (!token) {
        return false;
    }
    
    try {
        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        
        const payload = JSON.parse(jsonPayload);
        return true;
    } catch (error) {
        return false;
    }
}

// 사진 배열 생성
const photos = [
    <c:if test="${not empty hpost.photo1}">'<c:url value="/uploads/hpostsave/${hpost.photo1}"/>'</c:if>
    <c:if test="${not empty hpost.photo2}">, '<c:url value="/uploads/hpostsave/${hpost.photo2}"/>'</c:if>
    <c:if test="${not empty hpost.photo3}">, '<c:url value="/uploads/hpostsave/${hpost.photo3}"/>'</c:if>
].filter(photo => photo);

let currentPhotoIndex = 0;

// 사진 모달 관련 함수들
function openPhotoModal(index) {
    currentPhotoIndex = index;
    const modal = document.getElementById('photoModal');
    const modalImg = document.getElementById('modalPhoto');
    
    modalImg.src = photos[index];
    modal.style.display = 'flex';
    updateNavButtons();
}

function closePhotoModal() {
    document.getElementById('photoModal').style.display = 'none';
}

function changePhoto(direction) {
    currentPhotoIndex += direction;
    
    if (currentPhotoIndex < 0) {
        currentPhotoIndex = photos.length - 1;
    } else if (currentPhotoIndex >= photos.length) {
        currentPhotoIndex = 0;
    }
    
    document.getElementById('modalPhoto').src = photos[currentPhotoIndex];
    updateNavButtons();
}

function updateNavButtons() {
    const prevBtn = document.querySelector('.photo-nav-prev');
    const nextBtn = document.querySelector('.photo-nav-next');
    
    if (photos.length <= 1) {
        prevBtn.style.display = 'none';
        nextBtn.style.display = 'none';
    } else {
        prevBtn.style.display = 'block';
        nextBtn.style.display = 'block';
    }
}

// 투표 처리 함수
async function processVote(voteType) {
    
    try {
        const token = localStorage.getItem('accessToken');
        const baseUrl = '<%=root%>';
        const url = baseUrl + '/hpost/' + HPOST_ID + '/vote';
        
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Authorization': token ? 'Bearer ' + token : ''
            },
            body: 'voteType=' + voteType
        });
        
        const data = await response.json();
        
        if (data.success) {
            updateVoteUI({
                likes: data.likes || 0,
                dislikes: data.dislikes || 0,
                voteStatus: data.userVoteStatus || data.voteStatus || 'none'
            });
            
            setTimeout(loadVoteStatistics, 100);
            setTimeout(() => {
                checkUserVoteStatus();
            }, 200);
            
            // 투표 성공
        } else {
            alert(data.message || '투표 처리 중 오류가 발생했습니다.');
        }
        
    } catch (error) {
        alert('투표 처리 중 오류가 발생했습니다.');
    }
}

// 투표 통계 로드
async function loadVoteStatistics() {
    if (!HPOST_ID || HPOST_ID === 0) {
        // HPOST_ID가 유효하지 않음
        return;
    }
    
    // 투표 통계 로드 시작
    
    try {
        const baseUrl = '<%=root%>';
        const url = baseUrl + '/hpost/' + HPOST_ID + '/vote-stats';
        
        const response = await fetch(url);
        
        if (!response.ok) {
            // HTTP 오류
            return;
        }
        
        const result = await response.json();
        
        if (result.success) {
            
            updateVoteUI({
                likes: result.likes || 0,
                dislikes: result.dislikes || 0,
                voteStatus: result.userVoteStatus || result.voteStatus || 'none'
            });
            
            setTimeout(() => {
                checkUserVoteStatus();
            }, 100);
        } else {
            // 투표 통계 로드 실패
        }
        
    } catch (error) {
        // 투표 통계 로드 오류 무시
    }
}

// 투표 UI 업데이트
function updateVoteUI(result) {
    const likeBtn = document.getElementById('likeBtn');
    const dislikeBtn = document.getElementById('dislikeBtn');
    const likeCount = document.getElementById('likeCount');
    const dislikeCount = document.getElementById('dislikeCount');
    
    // 좋아요/싫어요 수 업데이트
    if (result.likes !== undefined) {
        if (likeCount) {
            likeCount.textContent = result.likes;
        }
    } else {
        // result.likes가 undefined
    }
    
    if (result.dislikes !== undefined) {
        if (dislikeCount) {
            dislikeCount.textContent = result.dislikes;
        }
    } else {
        // result.dislikes가 undefined
    }
    
    // 사용자 투표 상태에 따른 버튼 스타일 업데이트
    const userVoteStatus = result.voteStatus;
    
    if (likeBtn) likeBtn.classList.remove('active');
    if (dislikeBtn) dislikeBtn.classList.remove('active');
    
    if (userVoteStatus === 'like' && likeBtn) {
        likeBtn.classList.add('active');
        // 좋아요 버튼 활성화
    } else if (userVoteStatus === 'dislike' && dislikeBtn) {
        dislikeBtn.classList.add('active');
        // 싫어요 버튼 활성화
    }
    
    // 투표 UI 업데이트 완료
}

// 사용자 투표 상태 확인
async function checkUserVoteStatus() {
    if (!HPOST_ID || HPOST_ID === 0) {
        // HPOST_ID가 유효하지 않음
        return;
    }
    
    // 사용자 투표 상태 확인 시작
    
    try {
        const baseUrl = '<%=root%>';
        const endpoint = baseUrl + '/hpost/' + HPOST_ID + '/vote-status';
        
        const token = localStorage.getItem('accessToken');
        
        const response = await fetch(endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Authorization': token ? 'Bearer ' + token : ''
            }
        });
        
        if (!response.ok) {
            // HTTP 오류
            return;
        }
        
        const result = await response.json();
        
        if (result.success) {
            const likeBtn = document.getElementById('likeBtn');
            const dislikeBtn = document.getElementById('dislikeBtn');
            
            if (likeBtn) likeBtn.classList.remove('active');
            if (dislikeBtn) dislikeBtn.classList.remove('active');
            
            if (result.voteStatus === 'like' && likeBtn) {
                likeBtn.classList.add('active');
            } else if (result.voteStatus === 'dislike' && dislikeBtn) {
                dislikeBtn.classList.add('active');
            }
        } else {
            // 투표 상태 확인 실패
        }
        
    } catch (error) {
        // 투표 상태 확인 오류 무시
    }
}

// 댓글 관련 함수들
function getTimeAgo(createdAt) {
    if (!createdAt) return '';
    const createdDate = new Date(createdAt);
    const now = new Date();
    const diffMs = now - createdDate;
    
    if (diffMs < 60000) {
        return '방금전';
    } else if (diffMs < 3600000) {
        const minutes = Math.floor(diffMs / 60000);
        return minutes + '분전';
    } else if (diffMs < 86400000) {
        const hours = Math.floor(diffMs / 3600000);
        return hours + '시간전';
    } else {
        const days = Math.floor(diffMs / 86400000);
        return days + '일전';
    }
}

function updateCommentCount(count) {
    const countDisplay = document.getElementById('comment-count-display');
    if (countDisplay) {
        countDisplay.textContent = count;
    }
}

function displayComments(comments, sortType = 'latest') {
    const commentsList = document.getElementById('commentsList');
    
    if (!comments || comments.length === 0) {
        commentsList.innerHTML = '<div class="no-comments">아직 댓글이 없습니다.</div>';
        updateCommentCount(0);
        return;
    }
    
    let sortedComments = [...comments];
    
    if (sortType === 'latest') {
        // 최신순: 생성 시간 기준 내림차순
        sortedComments.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    } else if (sortType === 'popular') {
        // 인기순: 좋아요 수 기준 내림차순, 같으면 최신순
        sortedComments.sort((a, b) => {
            const aLikes = a.likes || 0;
            const bLikes = b.likes || 0;
            // 댓글 좋아요 수 비교
            
            if (aLikes !== bLikes) {
                return bLikes - aLikes; // 좋아요 많은 순
            } else {
                return new Date(b.createdAt) - new Date(a.createdAt); // 같으면 최신순
            }
        });
        // 인기순 정렬 적용
    }
    
    // 정렬된 댓글
    
    let html = '';
    sortedComments.forEach((comment) => {
        html += createCommentHTML(comment);
    });
    
    commentsList.innerHTML = html;
    updateCommentCount(sortedComments.length);
    
    // 정렬 버튼 상태 업데이트
    updateSortButtons(sortType);
}

function createCommentHTML(comment) {
    const timeAgo = getTimeAgo(comment.createdAt);
    
    // authorUserid가 없으면 'anonymous'로 설정 (비로그인 사용자)
    const authorUserid = comment.authorUserid || comment.idAddress || 'anonymous';
    
    return '<div class="hpost-comment-item" data-comment-id="' + comment.id + '" data-author-userid="' + authorUserid + '">' +
        '<div class="hpost-comment-header">' +
            '<span class="hpost-comment-display-nickname">' + (comment.nickname || '') + '</span>' +
            '<div class="hpost-comment-menu" onclick="showCommentDeleteMenu(' + comment.id + ', \'' + (comment.nickname || '') + '\')">' +
                '<span class="hpost-comment-menu-dots">⋯</span>' +
                '<div class="hpost-comment-menu-dropdown" id="commentDeleteMenu_' + comment.id + '" style="display: none;">' +
                    '<div class="hpost-comment-menu-item" onclick="deleteComment(' + comment.id + ', \'' + (comment.nickname || '') + '\')">삭제</div>' +
                '</div>' +
            '</div>' +
        '</div>' +
        '<div class="hpost-comment-display-content">' +
            (comment.content || '') +
        '</div>' +
        '<div class="hpost-comment-footer">' +
            '<div class="hpost-comment-info">' +
                '<span class="hpost-comment-time">' + timeAgo + '</span>' +
            '</div>' +
            '<div class="hpost-comment-reactions">' +
                '<button class="hpost-comment-like-btn' + (comment.userReaction === 'LIKE' ? ' active' : '') + '" onclick="likeComment(' + comment.id + ')">' +
                    '👍 <span class="like-count">' + (comment.likes || 0) + '</span>' +
                '</button>' +
                '<button class="hpost-comment-dislike-btn' + (comment.userReaction === 'DISLIKE' ? ' active' : '') + '" onclick="dislikeComment(' + comment.id + ')">' +
                    '👎 <span class="dislike-count">' + (comment.dislikes || 0) + '</span>' +
                '</button>' +
            '</div>' +
        '</div>' +
    '</div>';
}

function updateSortButtons(activeSort) {
    const sortButtons = document.querySelectorAll('.hpost-sort-btn');
    
    sortButtons.forEach(btn => {
        btn.classList.remove('active');
        if ((activeSort === 'latest' && btn.textContent.includes('최신순')) ||
            (activeSort === 'popular' && btn.textContent.includes('인기순'))) {
            btn.classList.add('active');
        }
    });
}

async function loadComments(sort = 'latest') {
    try {
        if (!HPOST_ID || HPOST_ID === 0) {
            document.getElementById('commentsList').innerHTML = '<div class="no-comments">HPOST ID를 찾을 수 없습니다.</div>';
            return;
        }
        
        // 현재 정렬 상태 업데이트
        currentCommentSort = sort;
        
        const url = '<%=root%>/hpost/' + HPOST_ID + '/comments?sort=' + sort;
        const response = await fetch(url);
        const data = await response.json();
        
        if (data.success && data.comments) {
            displayComments(data.comments, sort);
        } else {
            // 댓글 로드 실패
            document.getElementById('commentsList').innerHTML = '<div class="no-comments">댓글을 불러오는데 실패했습니다.</div>';
        }
        
    } catch (error) {
        // 댓글 로드 오류
        document.getElementById('commentsList').innerHTML = '<div class="no-comments">댓글을 불러오는데 실패했습니다: ' + error.message + '</div>';
    }
}

function setupCommentForm() {
    const loggedIn = isLoggedIn();
    const nicknameField = document.getElementById('commentNickname');
    const passwordField = document.getElementById('commentPassword');
    const commentForm = document.querySelector('.hpost-comment-form');
    
    if (loggedIn) {
        try {
            const token = localStorage.getItem('accessToken');
            const base64Url = token.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));
            
            const payload = JSON.parse(jsonPayload);
            const nickname = payload.nickname || '';
            
            nicknameField.value = nickname;
            nicknameField.readOnly = true;
            nicknameField.style.backgroundColor = '#f8f9fa';
            nicknameField.classList.add('hidden');
            passwordField.classList.add('hidden');
            
            // 로그인 상태 CSS 클래스 추가
            if (commentForm) {
                commentForm.classList.remove('not-logged-in');
                commentForm.classList.add('logged-in');
            }
            
        } catch (error) {
            // 토큰에서 닉네임 추출 실패
            nicknameField.value = '';
            nicknameField.readOnly = false;
            nicknameField.style.backgroundColor = '';
            nicknameField.classList.remove('hidden');
            passwordField.classList.remove('hidden');
            
            // 오류 발생 시 비로그인 상태로 처리
            if (commentForm) {
                commentForm.classList.remove('logged-in');
                commentForm.classList.add('not-logged-in');
            }
        }
    } else {
        nicknameField.value = '';
        nicknameField.readOnly = false;
        nicknameField.style.backgroundColor = '';
        nicknameField.classList.remove('hidden');
        passwordField.classList.remove('hidden');
        
        // 비로그인 상태 CSS 클래스 추가
        if (commentForm) {
            commentForm.classList.remove('logged-in');
            commentForm.classList.add('not-logged-in');
        }
    }
}

async function submitComment() {
    if (!HPOST_ID || HPOST_ID === 0) {
        alert('HPOST ID가 없습니다.');
        return;
    }
    
    const loggedIn = isLoggedIn();
    
    let nickname = '';
    const password = document.getElementById('commentPassword').value;
    const content = document.getElementById('commentContent').value.trim();
    
    if (loggedIn) {
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
            // 토큰에서 닉네임 추출 실패
            alert('사용자 정보를 가져오는데 실패했습니다.');
            return;
        }
    } else {
        nickname = document.getElementById('commentNickname').value.trim();
    }
    
    if (!nickname || !content) {
        alert('닉네임과 댓글 내용을 입력해주세요.');
        return;
    }
    
    if (nickname.length > 5) {
        alert('닉네임은 5글자 이하로 입력해주세요.');
        return;
    }
    
    if (!loggedIn) {
        if (!password || password.length !== 4 || !/^\d{4}$/.test(password)) {
            alert('비밀번호는 숫자 4자리로 입력해주세요.');
            return;
        }
    }
    
    try {
        const formData = new FormData();
        formData.append('nickname', nickname);
        formData.append('content', content);
        
        if (!loggedIn) {
            formData.append('password', password);
        }
        
        const token = localStorage.getItem('accessToken');
        
        const response = await fetch('<%=root%>/hpost/' + HPOST_ID + '/comment', {
            method: 'POST',
            headers: {
                'Authorization': token ? 'Bearer ' + token : ''
            },
            body: formData
        });
        
        const result = await response.json();
        
        if (result.success) {
            alert('댓글이 등록되었습니다.');
            
            if (loggedIn) {
                document.getElementById('commentContent').value = '';
            } else {
                document.getElementById('commentNickname').value = '';
                document.getElementById('commentPassword').value = '';
                document.getElementById('commentContent').value = '';
            }
            
            loadComments(currentCommentSort);
            
        } else {
            alert(result.message || '댓글 등록에 실패했습니다.');
        }
        
    } catch (error) {
        // 댓글 작성 오류
        alert('댓글 작성 중 오류가 발생했습니다.');
    }
}

// 댓글 리액션 관련 함수들
async function toggleCommentReaction(commentId, reactionType) {
    try {
        const token = localStorage.getItem('accessToken');
        const baseUrl = '<%=root%>';
        const endpoint = baseUrl + '/hpost/comment/' + commentId + '/reaction';
        
        const response = await fetch(endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Authorization': token ? 'Bearer ' + token : ''
            },
            body: 'reactionType=' + reactionType
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        
        if (data.success) {
            // 댓글 리액션 성공
            
            setTimeout(() => {
                let commentElement = document.querySelector(`[data-comment-id="${commentId}"]`);
                
                if (commentElement) {
                    const likeCountElement = commentElement.querySelector('.like-count');
                    const dislikeCountElement = commentElement.querySelector('.dislike-count');
                    
                    if (likeCountElement && data.likeCount !== undefined) {
                        likeCountElement.textContent = data.likeCount;
                    }
                    
                    if (dislikeCountElement && data.dislikeCount !== undefined) {
                        dislikeCountElement.textContent = data.dislikeCount;
                    }
                    
                    const likeBtn = commentElement.querySelector('.hpost-comment-like-btn');
                    const dislikeBtn = commentElement.querySelector('.hpost-comment-dislike-btn');
                    
                    // 모든 버튼에서 active 클래스 제거
                    if (likeBtn) likeBtn.classList.remove('active');
                    if (dislikeBtn) dislikeBtn.classList.remove('active');
                    
                    // 현재 리액션에 따라 active 클래스 추가
                    if (data.userReaction === 'LIKE' && likeBtn) {
                        likeBtn.classList.add('active');
                        // 좋아요 버튼 활성화
                    } else if (data.userReaction === 'DISLIKE' && dislikeBtn) {
                        dislikeBtn.classList.add('active');
                        // 싫어요 버튼 활성화
                    } else {
                        // 리액션 없음 (취소됨)
                    }
                } else {
                    loadComments(currentCommentSort);
                }
            }, 100);
        } else {
            // 댓글 리액션 처리 실패
        }
    } catch (error) {
        // 댓글 리액션 처리 오류
    }
}

function likeComment(commentId) {
    toggleCommentReaction(commentId, 'LIKE');
}

function dislikeComment(commentId) {
    toggleCommentReaction(commentId, 'DISLIKE');
}

// 댓글 삭제 관련 함수들
function showCommentDeleteMenu(commentId, nickname) {
    const menu = document.getElementById('commentDeleteMenu_' + commentId);
    if (menu) {
        document.querySelectorAll('.hpost-comment-menu-dropdown').forEach(m => {
            if (m.id !== 'commentDeleteMenu_' + commentId) {
                m.style.display = 'none';
            }
        });
        
        menu.style.display = menu.style.display === 'none' ? 'block' : 'none';
    }
}

function deleteComment(commentId, nickname) {
    const commentElement = document.querySelector(`[data-comment-id="${commentId}"]`);
    const authorUserid = commentElement ? commentElement.getAttribute('data-author-userid') : null;
    
    // 댓글 삭제 요청
    
    showCommentPasswordModal(commentId, nickname, authorUserid);
}

function showCommentPasswordModal(commentId, nickname, authorUserid) {
    const modal = document.getElementById('commentPasswordModal');
    const title = document.getElementById('commentPasswordModalTitle');
    const input = document.getElementById('commentPasswordModalInput');
    
    const loggedIn = isLoggedIn();
    // authorUserid가 IP 주소 형태(숫자.숫자.숫자.숫자)이거나 'anonymous'이면 비로그인 사용자
    const isAnonymousComment = authorUserid === 'anonymous' || 
                              (authorUserid && /^\d+\.\d+\.\d+\.\d+$/.test(authorUserid));
    
    // 댓글 삭제 모달 표시
    
    if (loggedIn && !isAnonymousComment) {
        title.textContent = '댓글을 삭제하시겠습니까?';
        input.style.display = 'none';
    } else {
        title.textContent = '댓글 삭제를 위한 비밀번호를 입력해주세요';
        input.style.display = 'block';
    }
    
    modal.dataset.commentId = commentId;
    modal.dataset.nickname = nickname;
    modal.dataset.authorUserid = authorUserid;
    
    input.value = '';
    
    if (isAnonymousComment || !loggedIn) {
        input.focus();
    }
    
    modal.style.display = 'flex';
}

function closeCommentPasswordModal() {
    const modal = document.getElementById('commentPasswordModal');
    modal.style.display = 'none';
}

function confirmCommentDelete() {
    const modal = document.getElementById('commentPasswordModal');
    const input = document.getElementById('commentPasswordModalInput');
    const commentId = modal.dataset.commentId;
    const nickname = modal.dataset.nickname;
    const authorUserid = modal.dataset.authorUserid;
    const password = input.value;
    
    const loggedIn = isLoggedIn();
    // authorUserid가 IP 주소 형태(숫자.숫자.숫자.숫자)이거나 'anonymous'이면 비로그인 사용자
    const isAnonymousComment = authorUserid === 'anonymous' || 
                              (authorUserid && /^\d+\.\d+\.\d+\.\d+$/.test(authorUserid));
    
    if (isAnonymousComment || !loggedIn) {
        if (!password || password.length !== 4 || !/^\d{4}$/.test(password)) {
            alert('비밀번호는 숫자 4자리로 입력해주세요.');
            input.focus();
            return;
        }
    }
    
    try {
        const baseUrl = '<%=root%>';
        const url = baseUrl + '/hpost/' + HPOST_ID + '/comment/' + commentId;
        // 로그인 상태 확인
        
        const formData = new URLSearchParams();
        formData.append('nickname', nickname);
        
        if (isAnonymousComment || !loggedIn) {
            formData.append('password', password);
        }
        
        const token = localStorage.getItem('accessToken');
        
        fetch(url, {
            method: 'DELETE',
            headers: {
                'Authorization': token ? 'Bearer ' + token : ''
            },
            body: formData
        })
        .then(response => {
            // 댓글 삭제 응답 상태
            return response.json();
        })
        .then(data => {
            // 댓글 삭제 응답 데이터
            if (data.success) {
                alert('댓글이 삭제되었습니다.');
                closeCommentPasswordModal();
                loadComments(currentCommentSort);
            } else {
                alert(data.message || '댓글 삭제에 실패했습니다.');
            }
        })
        .catch(error => {
            // 댓글 삭제 오류
            alert('댓글 삭제 중 오류가 발생했습니다.');
        });
    } catch (error) {
        // 댓글 삭제 처리 오류
        alert('댓글 삭제 처리 중 오류가 발생했습니다.');
    }
}

// 사진 크기 조정 함수들
function adjustPhotoSize(photo) {
    const img = new Image();
    img.onload = function() {
        const aspectRatio = this.width / this.height;
        
        if (aspectRatio < 1) {
            const maxWidth = 300;
            const maxHeight = 400;
            const ratio = Math.min(maxWidth / this.width, maxHeight / this.height);
            const newWidth = this.width * ratio;
            const newHeight = this.height * ratio;
            
            photo.style.width = newWidth + 'px';
            photo.style.height = newHeight + 'px';
        } else {
            const maxWidth = 800;
            const maxHeight = 500;
            const ratio = Math.min(maxWidth / this.width, maxHeight / this.height);
            const newWidth = this.width * ratio;
            const newHeight = this.height * ratio;
            
            photo.style.width = newWidth + 'px';
            photo.style.height = newHeight + 'px';
        }
    };
    img.src = photo.src;
}

function adjustPhotoLayout() {
    const photoContainer = document.querySelector('.hpost-detail-photos');
    const photos = photoContainer.querySelectorAll('.hpost-detail-photo');
    
    let hasVerticalPhotos = false;
    
    photos.forEach(function(photo) {
        if (photo.complete) {
            const aspectRatio = photo.naturalWidth / photo.naturalHeight;
            if (aspectRatio < 1) {
                hasVerticalPhotos = true;
            }
        }
    });
    
    if (hasVerticalPhotos) {
        photoContainer.classList.add('horizontal-layout');
    } else {
        photoContainer.classList.remove('horizontal-layout');
    }
}

// 이벤트 리스너들
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closePhotoModal();
    } else if (event.key === 'ArrowLeft') {
        changePhoto(-1);
    } else if (event.key === 'ArrowRight') {
        changePhoto(1);
    }
});

document.getElementById('photoModal').addEventListener('click', function(event) {
    if (event.target === this) {
        closePhotoModal();
    }
});

// 클릭 이벤트로 메뉴 외부 클릭 시 메뉴 숨기기
document.addEventListener('click', function(event) {
    if (!event.target.closest('.hpost-comment-menu')) {
        document.querySelectorAll('.hpost-comment-menu-dropdown').forEach(menu => {
            menu.style.display = 'none';
        });
    }
    
    // 게시글 메뉴 외부 클릭 시 메뉴 숨기기
    if (!event.target.closest('.hpost-detail-menu')) {
        const hpostMenu = document.getElementById('hpostMenuDropdown');
        if (hpostMenu) {
            hpostMenu.style.display = 'none';
        }
    }
});

// 게시글 메뉴 표시/숨기기
function showHpostMenu() {
    const menu = document.getElementById('hpostMenuDropdown');
    if (menu) {
        menu.style.display = menu.style.display === 'none' ? 'block' : 'none';
    }
}

// 게시글 삭제 모달 표시
function showHpostDeleteModal() {
    const modal = document.getElementById('hpostDeleteModal');
    const input = document.getElementById('hpostDeletePasswordInput');
    
    if (modal && input) {
        modal.style.display = 'flex';
        input.value = '';
        input.focus();
        
        // 메뉴 숨기기
        const menu = document.getElementById('hpostMenuDropdown');
        if (menu) {
            menu.style.display = 'none';
        }
    }
}

// 게시글 삭제 모달 닫기
function closeHpostDeleteModal() {
    const modal = document.getElementById('hpostDeleteModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

// 게시글 삭제 실행
async function deleteHpost() {
    // deleteHpost 함수 시작
    
    if (!HPOST_ID || HPOST_ID === 0 || isNaN(HPOST_ID)) {
        // HPOST_ID가 유효하지 않음
        alert('게시글 ID가 유효하지 않습니다. 페이지를 새로고침해주세요.');
        return;
    }
    
    const password = document.getElementById('hpostDeletePasswordInput').value;
    
    if (!password || password.length !== 4 || !/^\d{4}$/.test(password)) {
        alert('비밀번호는 숫자 4자리로 입력해주세요.');
        return;
    }
    
    try {
        const baseUrl = '<%=root%>';
        const url = baseUrl + '/hpost/' + HPOST_ID + '/delete';
        
        const response = await fetch(url, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                password: password
            })
        });
        
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`HTTP error! status: ${response.status}, response: ${errorText}`);
        }
        
        const data = await response.json();
        
        if (data.success) {
            alert('게시글이 삭제되었습니다.');
            // 목록 페이지로 이동
            window.location.href = baseUrl + '/hpost';
        } else {
            alert(data.message || '게시글 삭제에 실패했습니다. 비밀번호를 확인해주세요.');
        }
    } catch (error) {
        // 게시글 삭제 오류
        alert('게시글 삭제 중 오류가 발생했습니다: ' + error.message);
    } finally {
        closeHpostDeleteModal();
    }
}

// 신고 모달 표시
function showReportModal() {
    const userInfo = getUserInfoFromToken();
    if (!userInfo) {
        showToast('신고는 로그인한 사용자만 가능합니다', 2500);
        return;
    }
    
    // 모달 표시
    const reportModal = document.getElementById('reportModal');
    reportModal.style.display = 'flex';
}

// 신고 모달 닫기
function closeReportModal() {
    const reportModal = document.getElementById('reportModal');
    reportModal.style.display = 'none';
    // 폼 초기화
    document.getElementById('reportReason').value = '';
    document.getElementById('reportContent').value = '';
}

// 신고 제출
async function submitReport() {
    const reason = document.getElementById('reportReason').value;
    const content = document.getElementById('reportContent').value;
    
    if (!reason || !content) {
        alert('신고 사유와 내용을 모두 입력해주세요.');
        return;
    }
    
    const userInfo = getUserInfoFromToken();
    if (!userInfo) {
        showToast('신고는 로그인한 사용자만 가능합니다', 2500);
        return;
    }
    
    try {
        const baseUrl = '<%=root%>';
        const url = baseUrl + '/hpost/report';
        
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + localStorage.getItem('accessToken')
            },
            body: JSON.stringify({
                postId: HPOST_ID,
                reason: reason,
                content: content
            })
        });
        
        if (response.ok) {
            const data = await response.json();
            if (data.success) {
                showToast('신고가 접수되었습니다', 2500);
                // 모달 닫기
                closeReportModal();
            } else {
                showToast(data.message || '신고 접수에 실패했습니다', 2500);
            }
        } else {
            showToast('신고 접수 중 오류가 발생했습니다', 2500);
        }
    } catch (error) {
        // 신고 오류
        showToast('신고 접수 중 오류가 발생했습니다', 2500);
    }
}

// 토스트 메시지 표시
function showToast(message, duration = 2500) {
    const toast = document.getElementById('toast');
    const toastContent = toast.querySelector('.toast-content');
    
    toastContent.textContent = message;
    toast.style.display = 'block';
    
    setTimeout(() => {
        toast.style.display = 'none';
    }, duration);
}

// 페이지 초기화
document.addEventListener('DOMContentLoaded', function() {
    
    // HPOST_ID 재확인
    if (!HPOST_ID || HPOST_ID === 0) {
        const hpostIdFromJSP = parseInt('${hpost.id}');
        // JSP에서 직접 가져온 hpost.id
        if (!isNaN(hpostIdFromJSP) && hpostIdFromJSP > 0) {
            HPOST_ID = hpostIdFromJSP;
            // HPOST_ID 재설정 완료
        }
    }
    
    // 사진 관련 UI 설정
    const photoContainer = document.querySelector('.hpost-detail-photos');
    if (photoContainer) {
        const photoCount = photoContainer.querySelectorAll('img').length;
        photoContainer.classList.add('photo-count-' + photoCount);
        
        const photos = document.querySelectorAll('.hpost-detail-photo');
        photos.forEach(function(photo) {
            photo.addEventListener('load', function() {
                adjustPhotoSize(this);
                adjustPhotoLayout();
            });
            if (photo.complete) {
                adjustPhotoSize(photo);
                adjustPhotoLayout();
            }
        });
        setTimeout(adjustPhotoLayout, 100);
    }

    // 댓글 폼 UI 설정
    setupCommentForm();
    
    // 댓글 로드 (현재 정렬 상태 유지)
    loadComments(currentCommentSort);
    
    // 투표 상태 및 통계 초기 로드 (지연 시간 단축)
    setTimeout(() => {
        loadVoteStatistics();
        checkUserVoteStatus();
    }, 200);
});
</script>

<!-- 신고 모달 -->
<div id="reportModal" class="password-modal">
    <div class="password-modal-content">
        <div class="password-modal-title" id="reportModalTitle">게시글 신고</div>
        <div style="margin-bottom: 15px;">
            <label for="reportReason" style="display: block; margin-bottom: 5px; font-weight: 600;">신고 사유</label>
            <select id="reportReason" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px;">
                <option value="">신고 사유를 선택해주세요</option>
                <option value="스팸">스팸</option>
                <option value="부적절한 내용">부적절한 내용</option>
                <option value="욕설/비방">욕설/비방</option>
                <option value="저작권 침해">저작권 침해</option>
                <option value="기타">기타</option>
            </select>
        </div>
        <div style="margin-bottom: 20px;">
            <label for="reportContent" style="display: block; margin-bottom: 5px; font-weight: 600;">상세 내용</label>
            <textarea id="reportContent" placeholder="신고 상세 내용을 입력해주세요..." style="width: 100%; height: 100px; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; resize: vertical;" required></textarea>
        </div>
        <div class="password-modal-buttons">
            <button class="password-modal-btn confirm" onclick="submitReport()">신고</button>
            <button class="password-modal-btn cancel" onclick="closeReportModal()">취소</button>
        </div>
    </div>
</div>

<!-- 토스트 메시지 -->
<div id="toast" class="toast-message" style="display: none;">
    <div class="toast-content"></div>
</div>
