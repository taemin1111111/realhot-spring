<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hpost.HpostDto" %>
<%@ page import="hottalk_comment.Hottalk_CommentDao" %>


<%
    String root = request.getContextPath();
    HpostDao dao = new HpostDao();
    Hottalk_CommentDao commentDao = new Hottalk_CommentDao();
    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd HH:mm");
    
    
    // 페이징 처리
    int perPage = 30; // 페이지당 30개 글
    int currentPage = 1;
    if(request.getParameter("page") != null) {
        try {
            currentPage = Integer.parseInt(request.getParameter("page"));
        } catch(NumberFormatException e) {
            currentPage = 1;
        }
    }
    int start = (currentPage - 1) * perPage;
    
    // 카테고리 ID 처리
    int categoryId = 1; // 기본값
    if(request.getParameter("category") != null) {
        try {
            categoryId = Integer.parseInt(request.getParameter("category"));
        } catch(NumberFormatException e) {
            categoryId = 1;
        }
    }
    
    // 정렬 타입 처리
    String sortType = request.getParameter("sort");
    List<HpostDto> posts;
    int totalCount;
    
    if("popular".equals(sortType)) {
        // 인기글 정렬
        posts = dao.getPopularPostsByCategory(categoryId, start, perPage);
        totalCount = dao.getTotalCountByCategory(categoryId);
    } else {
        // 최신순 정렬 (기본)
        posts = dao.getPostsByCategory(categoryId, start, perPage);
        totalCount = dao.getTotalCountByCategory(categoryId);
    }
    
    int totalPages = (int) Math.ceil((double) totalCount / perPage);
    
    // 카테고리별 아이콘과 제목 설정
    String categoryIcon = "❤️";
    String categoryName = "헌팅썰";
    
    switch(categoryId) {
        case 1:
            categoryIcon = "❤️";
            categoryName = "헌팅썰";
            break;
        case 2:
            categoryIcon = "📍";
            categoryName = "코스 추천";
            break;
        case 3:
            categoryIcon = "👥";
            categoryName = "같이 갈래";
            break;
        default:
            categoryIcon = "💬";
            categoryName = "커뮤니티";
            break;
    }
%>

<div class="category-posts">
    <h3 class="posts-category-title"><%= "popular".equals(sortType) ? "🔥 " + categoryName + " 인기글" : categoryIcon + " " + categoryName %></h3>
    <div class="posts-controls">
        <div class="sort-buttons">
            <button type="button" class="sort-btn <%= "popular".equals(sortType) ? "" : "active" %>" onclick="changeSortInList('latest')">최신순</button>
            <button type="button" class="sort-btn <%= "popular".equals(sortType) ? "active" : "" %>" onclick="changeSortInList('popular')">인기글</button>
        </div>
        <button type="button" onclick="loadWriteForm()" class="write-btn-small">글쓰기</button>
    </div>
    <div class="posts-table-header">
        <% if("popular".equals(sortType)) { %>
            <div class="col-rank">순위</div>
        <% } %>
        <div class="col-nickname">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;닉네임</div>
        <div class="col-title">제목</div>
        <div class="col-likes">좋아요</div>
        <div class="col-dislikes">싫어요</div>
        <div class="col-comments">댓글수</div>
        <div class="col-views">조회수</div>
        <div class="col-date">글쓴 날짜</div>
    </div>
    <div class="posts-list">
        <% if(totalCount > 0 && posts != null && !posts.isEmpty()) {
            for(int i = 0; i < posts.size(); i++) {
                HpostDto post = posts.get(i);
                int rank = start + i + 1; %>
                <div class="posts-table-row" id="post<%= post.getId() %>">
                    <% if("popular".equals(sortType)) { %>
                        <div class="col-rank" style="color: #ff6b6b; font-weight: bold;"><%= rank %>위</div>
                    <% } %>
                    <div class="col-nickname">
                        <% if(post.getUserid() != null && !post.getUserid().isEmpty() && !post.getUserid().equals("null")) { %>
                            ⭐ <%= post.getNickname() != null ? post.getNickname() : post.getUserid() %>
                        <% } else { %>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%= post.getNickname() != null ? post.getNickname() : "" %>
                        <% } %>
                    </div>
                    <div class="col-title">
                        <a href="javascript:void(0)" onclick="loadPostDetail(<%= post.getId() %>)"><%= post.getTitle() %></a>
                    </div>
                    <div class="col-likes">👍 <%= post.getLikes() %></div>
                    <div class="col-dislikes">👎 <%= post.getDislikes() %></div>
                    <div class="col-comments">💬 <%= commentDao.getCommentCountByPostId(post.getId()) %></div>
                    <div class="col-views">👁️ <%= post.getViews() %></div>
                    <div class="col-date"><%= post.getCreated_at() != null ? sdf.format(post.getCreated_at()) : "" %></div>
                </div>
        <%  }
        } else { %>
            <div class="posts-table-row no-posts-row">
                <div class="col-nickname"></div>
                <div class="col-title" style="text-align:center; color:#aaa;" colspan="5">아직 글이 없습니다.</div>
                <div class="col-likes"></div>
                <div class="col-dislikes"></div>
                <div class="col-views"></div>
                <div class="col-date"></div>
            </div>
        <% } %>
    </div>
    
    <!-- 페이징 처리 -->
    <% if(totalPages > 1) { %>
        <div class="pagination">
            <% if(currentPage > 1) { %>
                <a href="javascript:void(0)" onclick="loadPage(<%= currentPage - 1 %>)" class="page-btn">← 이전</a>
            <% } %>
            
            <% 
            // 페이징 범위 계산 (최대 10개 페이지만 표시)
            int startPage = Math.max(1, currentPage - 4);
            int endPage = Math.min(totalPages, startPage + 9);
            if(endPage - startPage < 9) {
                startPage = Math.max(1, endPage - 9);
            }
            
            for(int i = startPage; i <= endPage; i++) { %>
                <% if(i == currentPage) { %>
                    <span class="page-btn active"><%= i %></span>
                <% } else { %>
                    <a href="javascript:void(0)" onclick="loadPage(<%= i %>)" class="page-btn"><%= i %></a>
                <% } %>
            <% } %>
            
            <% if(currentPage < totalPages) { %>
                <a href="javascript:void(0)" onclick="loadPage(<%= currentPage + 1 %>)" class="page-btn">다음 →</a>
            <% } %>
        </div>
    <% } %>
</div>

<script>
function loadPage(page) {
    // 현재 정렬 상태 확인
    const activeSortBtn = document.querySelector('.sort-btn.active');
    const sortType = activeSortBtn && activeSortBtn.textContent.includes('인기글') ? 'popular' : 'latest';
    
    // AJAX로 페이지 로드
    const url = '<%=root%>/community/hpost_list.jsp?page=' + page + 
                (sortType === 'popular' ? '&sort=popular' : '') +
                (categoryId !== 1 ? '&category=' + categoryId : '');
    
    fetch(url)
        .then(response => response.text())
        .then(html => {
            document.getElementById('posts-container').innerHTML = html;
        })
        .catch(() => {
            // 에러 처리
        });
}

// 전역 변수 사용 (cumain.jsp에서 선언됨)
if (typeof window.currentSort === 'undefined') {
    window.currentSort = '<%= sortType == null ? "latest" : sortType %>';
}

function changeSortInList(sortType) {
    // 현재 정렬 타입과 같으면 리턴 (불필요한 요청 방지)
    if (window.currentSort === sortType) return;
    
    // 버튼 active 상태 변경 (즉시 반영)
    document.querySelectorAll('.sort-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
    
    // 현재 정렬 상태 업데이트
    window.currentSort = sortType;
    
    // 부드러운 전환 효과
    const container = document.getElementById('posts-container');
    container.classList.add('loading-transition');
    
    // API를 통해 정렬된 목록 로드 (Controller 사용)
    const url = '<%=root%>/api/community/posts?sort=' + sortType + '&category=' + <%= categoryId %>;
    
    fetch(url)
        .then(response => response.text())
        .then(html => {
            // 부드러운 교체
            setTimeout(() => {
                container.innerHTML = html;
                container.classList.remove('loading-transition');
            }, 200);
        })
        .catch(() => {
            // 에러 처리
            container.classList.remove('loading-transition');
            console.error('정렬 변경 중 오류 발생');
        });
}

// loadWriteForm과 loadPostDetail은 cumain.jsp에서 이미 정의됨

// 페이지 로드 시 해시(#postID)가 있으면 해당 글로 스크롤
window.addEventListener('DOMContentLoaded', function() {
    if (location.hash && location.hash.startsWith('#post')) {
        var el = document.querySelector(location.hash);
        if (el) {
            el.scrollIntoView({behavior: 'smooth', block: 'center'});
            el.style.background = '#f3f6ff';
            setTimeout(function() { el.style.background = ''; }, 1500);
        }
    }
});
</script> 