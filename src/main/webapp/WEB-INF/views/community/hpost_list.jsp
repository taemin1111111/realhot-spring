<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 완전한 REST API 방식으로 변환: Model1 DAO/DTO 제거 --%>

<%
    String root = request.getContextPath();
%>

<div class="category-posts" id="posts-container">
    <!-- 게시글 목록은 REST API를 통해 동적으로 로드됩니다 -->
    <div class="loading">게시글을 불러오는 중...</div>
</div>

<script>
// 전역 변수
window.currentSort = 'latest';
window.currentCategory = 1;
window.currentPage = 1;

// 페이지 로드 시 게시글 목록 로드
document.addEventListener('DOMContentLoaded', function() {
    // URL 파라미터에서 카테고리와 정렬 정보 가져오기
    const urlParams = new URLSearchParams(window.location.search);
    window.currentCategory = parseInt(urlParams.get('category')) || 1;
    window.currentSort = urlParams.get('sort') || 'latest';
    window.currentPage = parseInt(urlParams.get('page')) || 1;
    
    loadPostList();
});

// REST API를 통한 게시글 목록 로드
function loadPostList(page = window.currentPage, sort = window.currentSort, categoryId = window.currentCategory) {
    const url = '<%=root%>/api/community/posts?' + 
                'categoryId=' + categoryId + 
                '&page=' + page + 
                '&sort=' + sort + 
                '&perPage=30';
    
    fetch(url)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                renderPostList(data);
                window.currentPage = page;
                window.currentSort = sort;
                window.currentCategory = categoryId;
            } else {
                document.getElementById('posts-container').innerHTML = 
                    '<div class="error">게시글을 불러올 수 없습니다: ' + data.message + '</div>';
            }
        })
        .catch(error => {
            console.error('게시글 로드 오류:', error);
            document.getElementById('posts-container').innerHTML = 
                '<div class="error">게시글을 불러오는 중 오류가 발생했습니다.</div>';
        });
}

// 게시글 목록 렌더링
function renderPostList(data) {
    const { posts, totalCount, totalPages, currentPage, sortType, categoryId, start } = data;
    
    // 카테고리 정보 설정
    const categoryInfo = getCategoryInfo(categoryId);
    
    let html = '<h3 class="posts-category-title">' +
                (sortType === 'popular' ? '🔥 ' + categoryInfo.name + ' 인기글' : categoryInfo.icon + ' ' + categoryInfo.name) +
                '</h3>' +
                '<div class="posts-controls">' +
                    '<div class="sort-buttons">' +
                        '<button type="button" class="sort-btn ' + (sortType !== 'popular' ? 'active' : '') + '" onclick="changeSortInList(\'latest\')">최신순</button>' +
                        '<button type="button" class="sort-btn ' + (sortType === 'popular' ? 'active' : '') + '" onclick="changeSortInList(\'popular\')">인기글</button>' +
                    '</div>' +
                    '<button type="button" onclick="loadWriteForm()" class="write-btn-small">글쓰기</button>' +
                '</div>' +
                '<div class="posts-table-header">' +
                    (sortType === 'popular' ? '<div class="col-rank">순위</div>' : '') +
                    '<div class="col-nickname">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;닉네임</div>' +
                    '<div class="col-title">제목</div>' +
                    '<div class="col-likes">좋아요</div>' +
                    '<div class="col-dislikes">싫어요</div>' +
                    '<div class="col-comments">댓글수</div>' +
                    '<div class="col-views">조회수</div>' +
                    '<div class="col-date">글쓴 날짜</div>' +
                '</div>' +
                '<div class="posts-list">';
    
    if (totalCount > 0 && posts && posts.length > 0) {
        posts.forEach((post, index) => {
            const rank = start + index + 1;
            const formattedDate = formatDate(post.createdAt);
            
            html += '<div class="posts-table-row" id="post' + post.id + '">' +
                        (sortType === 'popular' ? '<div class="col-rank" style="color: #ff6b6b; font-weight: bold;">' + rank + '위</div>' : '') +
                        '<div class="col-nickname">' +
                            (post.authorId && post.authorId !== 'null' ? 
                                '⭐ ' + (post.nickname || post.authorId) : 
                                '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + (post.nickname || '')) +
                        '</div>' +
                        '<div class="col-title">' +
                            '<a href="javascript:void(0)" onclick="loadPostDetail(' + post.id + ')">' + post.title + '</a>' +
                        '</div>' +
                        '<div class="col-likes">👍 ' + (post.likeCount || 0) + '</div>' +
                        '<div class="col-dislikes">👎 ' + (post.dislikeCount || 0) + '</div>' +
                        '<div class="col-comments">💬 ' + (post.commentCount || 0) + '</div>' +
                        '<div class="col-views">👁️ ' + (post.viewCount || 0) + '</div>' +
                        '<div class="col-date">' + formattedDate + '</div>' +
                    '</div>';
        });
    } else {
        html += '<div class="posts-table-row no-posts-row">' +
                    '<div class="col-nickname"></div>' +
                    '<div class="col-title" style="text-align:center; color:#aaa;">아직 글이 없습니다.</div>' +
                    '<div class="col-likes"></div>' +
                    '<div class="col-dislikes"></div>' +
                    '<div class="col-views"></div>' +
                    '<div class="col-date"></div>' +
                '</div>';
    }
    
    html += '</div>';
    
    // 페이징 처리
    if (totalPages > 1) {
        html += '<div class="pagination">';
        
        if (currentPage > 1) {
            html += '<a href="javascript:void(0)" onclick="loadPage(' + (currentPage - 1) + ')" class="page-btn">← 이전</a>';
        }
        
        const startPage = Math.max(1, currentPage - 4);
        const endPage = Math.min(totalPages, startPage + 9);
        
        for (let i = startPage; i <= endPage; i++) {
            if (i === currentPage) {
                html += '<span class="page-btn active">' + i + '</span>';
            } else {
                html += '<a href="javascript:void(0)" onclick="loadPage(' + i + ')" class="page-btn">' + i + '</a>';
            }
        }
        
        if (currentPage < totalPages) {
            html += '<a href="javascript:void(0)" onclick="loadPage(' + (currentPage + 1) + ')" class="page-btn">다음 →</a>';
        }
        
        html += '</div>';
    }
    
    document.getElementById('posts-container').innerHTML = html;
}

// 페이지 변경
function loadPage(page) {
    loadPostList(page, window.currentSort, window.currentCategory);
}

// 정렬 변경
function changeSortInList(sortType) {
    if (window.currentSort === sortType) return;
    
    // 부드러운 전환 효과
    const container = document.getElementById('posts-container');
    container.classList.add('loading-transition');
    
    setTimeout(() => {
        loadPostList(1, sortType, window.currentCategory);
        container.classList.remove('loading-transition');
    }, 200);
}

// 카테고리 정보 반환
function getCategoryInfo(categoryId) {
    const categories = {
        1: { icon: '❤️', name: '헌팅썰' },
        2: { icon: '📍', name: '코스 추천' },
        3: { icon: '👥', name: '같이 갈래' }
    };
    return categories[categoryId] || { icon: '💬', name: '커뮤니티' };
}

// 날짜 포맷팅
function formatDate(dateString) {
    if (!dateString) return '';
    
    const date = new Date(dateString);
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    
    return `${month}/${day} ${hours}:${minutes}`;
}

// 페이지 로드 시 해시(#postID)가 있으면 해당 글로 스크롤
window.addEventListener('DOMContentLoaded', function() {
    if (location.hash && location.hash.startsWith('#post')) {
        setTimeout(() => {
            const el = document.querySelector(location.hash);
            if (el) {
                el.scrollIntoView({behavior: 'smooth', block: 'center'});
                el.style.background = '#f3f6ff';
                setTimeout(() => el.style.background = '', 1500);
            }
        }, 1000); // 게시글 로드 후 스크롤
    }
});

// CSS 추가
const style = document.createElement('style');
style.textContent = `
    .loading-transition {
        opacity: 0.5;
        transition: opacity 0.2s ease;
    }
    .loading {
        text-align: center;
        padding: 20px;
        color: #666;
    }
    .error {
        text-align: center;
        padding: 20px;
        color: #ff6b6b;
        background: #fff5f5;
        border: 1px solid #ffebee;
        border-radius: 4px;
        margin: 10px 0;
    }
`;
document.head.appendChild(style);
</script>