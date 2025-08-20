<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- REST API 방식으로 완전 변환: Model1 DAO/DTO 제거 --%>

<%
    String root = request.getContextPath();
    String postId = request.getParameter("id");
    if (postId == null) {
        response.sendRedirect(root + "/community");
        return;
    }
%>

<div class="post-detail-container" id="post-detail-container">
    <!-- 게시글 상세는 REST API를 통해 동적으로 로드됩니다 -->
    <div class="loading">게시글을 불러오는 중...</div>
</div>

<!-- 이미지 모달 -->
<div id="imageModal" class="image-modal" onclick="closeImageModal()">
    <div class="image-modal-content">
        <span class="image-modal-close">&times;</span>
        <img id="modalImage" src="" alt="이미지">
        <div class="image-modal-nav">
            <button id="prevImage" onclick="changeModalImage(-1)">&lt;</button>
            <button id="nextImage" onclick="changeModalImage(1)">&gt;</button>
        </div>
    </div>
</div>

<script>
// 전역 변수
let currentPost = null;
let currentImages = [];
let currentImageIndex = 0;

// 페이지 로드 시 게시글 상세 정보 로드
document.addEventListener('DOMContentLoaded', function() {
    const postId = '<%= postId %>';
    if (postId && postId !== 'null') {
        loadPostDetail(postId);
    } else {
        document.getElementById('post-detail-container').innerHTML = 
            '<div class="error">올바르지 않은 게시글 ID입니다.</div>';
    }
});

// REST API를 통한 게시글 상세 조회
function loadPostDetail(postId) {
    const url = '<%=root%>/api/community/post/' + postId;
    
    fetch(url)
        .then(response => response.json())
        .then(data => {
            if (data.success !== false) {
                currentPost = data;
                renderPostDetail(data);
                loadComments(postId);
            } else {
                document.getElementById('post-detail-container').innerHTML = 
                    '<div class="error">게시글을 찾을 수 없습니다: ' + (data.message || '') + '</div>';
            }
        })
        .catch(error => {
            console.error('게시글 로드 오류:', error);
            document.getElementById('post-detail-container').innerHTML = 
                '<div class="error">게시글을 불러오는 중 오류가 발생했습니다.</div>';
        });
}

// 게시글 상세 렌더링
function renderPostDetail(post) {
    const categoryInfo = getCategoryInfo(post.categoryId);
    const formattedDate = formatDateTime(post.createdAt);
    
    // 이미지 배열 생성
    currentImages = [];
    if (post.photo1) currentImages.push(post.photo1);
    if (post.photo2) currentImages.push(post.photo2);
    if (post.photo3) currentImages.push(post.photo3);
    
    let html = `
        <div class="post-header">
            <div class="post-header-top">
                <button class="delete-btn-small" onclick="deletePost(${post.id})">
                    삭제
                </button>
            </div>
            <h1 class="post-title">${post.title}</h1>
            <div class="post-meta">
                <div class="post-info">
                    <span class="post-author">작성자: 
                        ${post.authorId && post.authorId !== 'null' ? 
                            '⭐ ' + (post.authorNickname || post.authorId) : 
                            (post.authorNickname || '')}
                    </span>
                    <span class="post-date">작성일: ${formattedDate}</span>
                    <span class="post-views">👁️ 조회수: ${post.viewCount || 0}</span>
                </div>
                <button class="report-btn-small" onclick="reportPost(${post.id})">
                    🚨 신고
                </button>
            </div>
        </div>
        
        <div class="post-content">
            <div class="content-text">
                ${post.content.replace(/\\n/g, '<br>')}
            </div>
            
            ${currentImages.length > 0 ? `
                <div class="post-photos">
                    ${currentImages.map((photo, index) => `
                        <img src="<%=root%>/api/community/images/${photo}" 
                             alt="첨부사진${index + 1}" 
                             class="post-photo" 
                             loading="lazy" 
                             onclick="openImageModal('<%=root%>/api/community/images/${photo}', ${index})">
                    `).join('')}
                </div>
            ` : ''}
        </div>
        
        <div class="post-actions">
            <div class="reaction-buttons">
                <button class="like-btn" onclick="votePost(${post.id}, 'like')">
                    👍 좋아요 (<span id="likes-count">${post.likeCount || 0}</span>)
                </button>
                <button class="dislike-btn" onclick="votePost(${post.id}, 'dislike')">
                    👎 싫어요 (<span id="dislikes-count">${post.dislikeCount || 0}</span>)
                </button>
            </div>
        </div>

        <!-- 댓글 입력 폼 -->
        <div class="comment-section">
            <form id="commentForm" class="comment-form" onsubmit="return false;">
                <div class="comment-input-container">
                    <textarea 
                        id="commentContent" 
                        placeholder="댓글을 입력하세요..." 
                        rows="3"
                        style="width: 100%; resize: vertical; padding: 10px; border: 1px solid #ddd; border-radius: 4px;"
                    ></textarea>
                    <button type="button" onclick="addComment()" class="comment-submit-btn">
                        댓글 작성
                    </button>
                </div>
            </form>
            
            <!-- 댓글 목록 -->
            <div id="comments-container">
                <div class="loading">댓글을 불러오는 중...</div>
            </div>
        </div>
    `;
    
    document.getElementById('post-detail-container').innerHTML = html;
}

// 댓글 목록 로드
function loadComments(postId) {
    const url = '<%=root%>/api/community/post/' + postId + '/comments';
    
    fetch(url)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                renderComments(data.comments || []);
            } else {
                document.getElementById('comments-container').innerHTML = 
                    '<div class="no-comments">댓글이 없습니다.</div>';
            }
        })
        .catch(error => {
            console.error('댓글 로드 오류:', error);
            document.getElementById('comments-container').innerHTML = 
                '<div class="error">댓글을 불러오는 중 오류가 발생했습니다.</div>';
        });
}

// 댓글 목록 렌더링
function renderComments(comments) {
    if (!comments || comments.length === 0) {
        document.getElementById('comments-container').innerHTML = 
            '<div class="no-comments">아직 댓글이 없습니다.</div>';
        return;
    }
    
    let html = '<div class="comments-list">';
    
    comments.forEach(comment => {
        const formattedDate = formatDateTime(comment.createdAt);
        html += `
            <div class="comment-item" id="comment-${comment.id}">
                <div class="comment-header">
                    <span class="comment-author">
                        ${comment.authorId && comment.authorId !== 'null' ? 
                            '⭐ ' + (comment.nickname || comment.authorId) : 
                            (comment.nickname || '')}
                    </span>
                    <span class="comment-date">${formattedDate}</span>
                </div>
                <div class="comment-content">
                    ${comment.content.replace(/\\n/g, '<br>')}
                </div>
                <div class="comment-actions">
                    <button onclick="voteComment(${comment.id}, 'like')" class="comment-vote-btn">
                        👍 ${comment.likeCount || 0}
                    </button>
                    <button onclick="voteComment(${comment.id}, 'dislike')" class="comment-vote-btn">
                        👎 ${comment.dislikeCount || 0}
                    </button>
                </div>
            </div>
        `;
    });
    
    html += '</div>';
    document.getElementById('comments-container').innerHTML = html;
}

// 게시글 투표
function votePost(postId, action) {
    const url = '<%=root%>/api/community/post/' + postId + '/vote';
    
    fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=' + action
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            document.getElementById('likes-count').textContent = data.likeCount;
            document.getElementById('dislikes-count').textContent = data.dislikeCount;
            alert(data.message);
        } else {
            alert(data.message || '투표 중 오류가 발생했습니다.');
        }
    })
    .catch(error => {
        console.error('투표 오류:', error);
        alert('투표 중 오류가 발생했습니다.');
    });
}

// 댓글 투표
function voteComment(commentId, action) {
    const url = '<%=root%>/api/community/comment/' + commentId + '/vote';
    
    fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=' + action
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // 댓글 목록 새로고침
            loadComments('<%= postId %>');
            alert(data.message);
        } else {
            alert(data.message || '댓글 투표 중 오류가 발생했습니다.');
        }
    })
    .catch(error => {
        console.error('댓글 투표 오류:', error);
        alert('댓글 투표 중 오류가 발생했습니다.');
    });
}

// 댓글 작성
function addComment() {
    const content = document.getElementById('commentContent').value.trim();
    if (!content) {
        alert('댓글 내용을 입력해주세요.');
        return;
    }
    
    const url = '<%=root%>/api/community/post/<%= postId %>/comment';
    
    fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'content=' + encodeURIComponent(content)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            document.getElementById('commentContent').value = '';
            loadComments('<%= postId %>');
            alert('댓글이 작성되었습니다.');
        } else {
            alert(data.message || '댓글 작성 중 오류가 발생했습니다.');
        }
    })
    .catch(error => {
        console.error('댓글 작성 오류:', error);
        alert('댓글 작성 중 오류가 발생했습니다.');
    });
}

// 게시글 삭제
function deletePost(postId) {
    if (!confirm('정말로 이 게시글을 삭제하시겠습니까?')) {
        return;
    }
    
    const url = '<%=root%>/api/community/post/' + postId;
    
    fetch(url, {
        method: 'DELETE'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('게시글이 삭제되었습니다.');
            window.location.href = '<%=root%>/community';
        } else {
            alert(data.message || '게시글 삭제 중 오류가 발생했습니다.');
        }
    })
    .catch(error => {
        console.error('게시글 삭제 오류:', error);
        alert('게시글 삭제 중 오류가 발생했습니다.');
    });
}

// 게시글 신고
function reportPost(postId) {
    const reason = prompt('신고 사유를 입력해주세요:');
    if (!reason) return;
    
    const url = '<%=root%>/api/community/post/' + postId + '/report';
    
    fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'reason=' + encodeURIComponent(reason)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('신고가 접수되었습니다.');
        } else {
            alert(data.message || '신고 처리 중 오류가 발생했습니다.');
        }
    })
    .catch(error => {
        console.error('신고 오류:', error);
        alert('신고 처리 중 오류가 발생했습니다.');
    });
}

// 이미지 모달 관련 함수들
function openImageModal(imageSrc, index) {
    document.getElementById('modalImage').src = imageSrc;
    document.getElementById('imageModal').style.display = 'block';
    currentImageIndex = index;
    
    // 네비게이션 버튼 표시/숨김
    document.getElementById('prevImage').style.display = currentImages.length > 1 ? 'block' : 'none';
    document.getElementById('nextImage').style.display = currentImages.length > 1 ? 'block' : 'none';
}

function closeImageModal() {
    document.getElementById('imageModal').style.display = 'none';
}

function changeModalImage(direction) {
    currentImageIndex += direction;
    if (currentImageIndex < 0) currentImageIndex = currentImages.length - 1;
    if (currentImageIndex >= currentImages.length) currentImageIndex = 0;
    
    const newSrc = '<%=root%>/api/community/images/' + currentImages[currentImageIndex];
    document.getElementById('modalImage').src = newSrc;
}

// 유틸리티 함수들
function getCategoryInfo(categoryId) {
    const categories = {
        1: { icon: '❤️', name: '헌팅썰' },
        2: { icon: '📍', name: '코스 추천' },
        3: { icon: '👥', name: '같이 갈래' }
    };
    return categories[categoryId] || { icon: '💬', name: '커뮤니티' };
}

function formatDateTime(dateString) {
    if (!dateString) return '';
    
    const date = new Date(dateString);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    
    return `${year}-${month}-${day} ${hours}:${minutes}`;
}

// CSS 추가
const style = document.createElement('style');
style.textContent = `
    .post-detail-container {
        max-width: 800px;
        margin: 0 auto;
        padding: 20px;
    }
    
    .post-header {
        margin-bottom: 20px;
        border-bottom: 1px solid #eee;
        padding-bottom: 15px;
    }
    
    .post-header-top {
        text-align: right;
        margin-bottom: 10px;
    }
    
    .post-title {
        font-size: 24px;
        font-weight: bold;
        margin: 10px 0;
    }
    
    .post-meta {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 14px;
        color: #666;
    }
    
    .post-info span {
        margin-right: 15px;
    }
    
    .post-content {
        margin-bottom: 20px;
    }
    
    .content-text {
        line-height: 1.6;
        margin-bottom: 15px;
    }
    
    .post-photos {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
    }
    
    .post-photo {
        max-width: 200px;
        max-height: 200px;
        cursor: pointer;
        border-radius: 4px;
    }
    
    .post-actions {
        margin-bottom: 30px;
        text-align: center;
    }
    
    .reaction-buttons button {
        margin: 0 10px;
        padding: 8px 16px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }
    
    .like-btn {
        background: #4CAF50;
        color: white;
    }
    
    .dislike-btn {
        background: #f44336;
        color: white;
    }
    
    .comment-section {
        border-top: 1px solid #eee;
        padding-top: 20px;
    }
    
    .comment-input-container {
        display: flex;
        flex-direction: column;
        gap: 10px;
        margin-bottom: 20px;
    }
    
    .comment-submit-btn {
        align-self: flex-end;
        padding: 8px 16px;
        background: #2196F3;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }
    
    .comment-item {
        border-bottom: 1px solid #f0f0f0;
        padding: 15px 0;
    }
    
    .comment-header {
        display: flex;
        justify-content: space-between;
        margin-bottom: 8px;
        font-size: 14px;
    }
    
    .comment-author {
        font-weight: bold;
    }
    
    .comment-date {
        color: #666;
    }
    
    .comment-content {
        margin-bottom: 10px;
        line-height: 1.5;
    }
    
    .comment-actions button {
        margin-right: 10px;
        padding: 4px 8px;
        border: 1px solid #ddd;
        background: white;
        border-radius: 4px;
        cursor: pointer;
        font-size: 12px;
    }
    
    .image-modal {
        display: none;
        position: fixed;
        z-index: 1000;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0,0,0,0.9);
    }
    
    .image-modal-content {
        position: relative;
        margin: auto;
        display: block;
        width: 80%;
        max-width: 700px;
        top: 50%;
        transform: translateY(-50%);
    }
    
    .image-modal-content img {
        width: 100%;
        height: auto;
    }
    
    .image-modal-close {
        position: absolute;
        top: 15px;
        right: 35px;
        color: #f1f1f1;
        font-size: 40px;
        font-weight: bold;
        cursor: pointer;
    }
    
    .image-modal-nav button {
        position: absolute;
        top: 50%;
        background: rgba(0,0,0,0.5);
        color: white;
        border: none;
        padding: 10px 15px;
        cursor: pointer;
        font-size: 18px;
    }
    
    #prevImage {
        left: 15px;
    }
    
    #nextImage {
        right: 15px;
    }
    
    .loading, .error, .no-comments {
        text-align: center;
        padding: 20px;
        color: #666;
    }
    
    .error {
        color: #ff6b6b;
        background: #fff5f5;
        border: 1px solid #ffebee;
        border-radius: 4px;
    }
`;
document.head.appendChild(style);
</script>