<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
%>
    <div class="container community-container">
    <!-- 카테고리 헤더 -->
    <div class="community-header">
        <h2 class="community-title">💬 이야기 나누기</h2>
        <p class="community-subtitle">관심 있는 주제를 선택해보세요</p>
    </div>

        <!-- 카테고리 그리드 (기존 community.css 스타일 사용) -->
        <div class="category-grid" id="category-grid">
            <div class="text-center" style="grid-column: 1 / -1;">
                <div class="spinner-border" role="status">
                    <span class="visually-hidden">로딩중...</span>
                </div>
                <h5 class="mt-3">카테고리를 불러오는 중...</h5>
                <p class="text-muted">기존 community_category 테이블에서 로딩 중...</p>
            </div>
        </div>
        
        <!-- 선택된 카테고리의 게시글 목록 -->
        <div id="posts-section" style="display: none; margin-top: 30px;">
            <div id="posts-container">
                <!-- 게시글 목록이 여기에 동적으로 로드됩니다 -->
            </div>
        </div>
    </div>
</div>

<script>
        // 페이지 로드시 Spring API로 실제 데이터 로드
        $(document).ready(function() {
            loadCategoriesFromDatabase();
        });

        // 기존 데이터베이스에서 카테고리 로드
        function loadCategoriesFromDatabase() {
            $.ajax({
                url: '<%=root%>/api/community/categories',
                method: 'GET',
                dataType: 'json',
                timeout: 10000, // 10초 타임아웃
                success: function(response) {
                    console.log('API 응답:', response);
                    
                    if (response.success && response.categories && response.categories.length > 0) {
                        displayRealCategories(response.categories);
                    } else {
                        showError('카테고리 데이터가 없습니다. 데이터베이스를 확인해주세요.');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('API 호출 실패:', {
                        status: xhr.status,
                        statusText: xhr.statusText,
                        error: error,
                        responseText: xhr.responseText
                    });
                    
                    let errorMsg = '서버 연결 실패';
                    if (xhr.status === 404) {
                        errorMsg = 'API 엔드포인트를 찾을 수 없습니다 (/api/community/categories)';
                    } else if (xhr.status === 500) {
                        errorMsg = '서버 내부 오류가 발생했습니다';
                    }
                    
                    showError(errorMsg + '. 관리자에게 문의하세요.');
        }
    });
}

        // 실제 카테고리 데이터 표시 (기존 community.css 스타일 사용)
        function displayRealCategories(categories) {
            console.log('카테고리 표시:', categories);
            
            let html = '';
            
            categories.forEach(function(category) {
                html += '<div class="category-card" data-category-id="' + category.id + '">' +
                            '<div class="category-icon">' +
                                (category.icon || '💬') +
                            '</div>' +
                            '<div class="category-name">' + category.name + '</div>' +
                            '<div class="category-description">' + (category.description || category.name + ' 카테고리입니다.') + '</div>' +
                            '<button class="category-btn" onclick="goToCategoryPosts(' + category.id + ', \'' + category.name + '\')">' +
                                '구경가기 (' + (category.postCount || 0) + ')' +
                            '</button>' +
                        '</div>';
            });

            $('#category-grid').html(html);
        }

        // 카테고리별 게시글을 같은 페이지에서 표시
        function goToCategoryPosts(categoryId, categoryName) {
            console.log(`카테고리 선택: ID=${categoryId}, Name=${categoryName}`);
            
            // 선택된 카테고리 하이라이트
            $('.category-card').removeClass('selected');
            $(`[data-category-id="${categoryId}"]`).addClass('selected');
            
            // 게시글 섹션 표시
            $('#posts-section').show();
            
            // 게시글 목록 로드
            loadCategoryPosts(categoryId, categoryName);
        }
        
        // 카테고리별 게시글 목록 로드
        function loadCategoryPosts(categoryId, categoryName) {
            $('#posts-container').html('<div class="loading">게시글을 불러오는 중...</div>');
            
            $.ajax({
                url: '<%=root%>/api/community/posts',
                method: 'GET',
                data: {
                    categoryId: categoryId,
                    page: 1,
                    sort: 'latest',
                    perPage: 10
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        displayCategoryPosts(response, categoryName);
                    } else {
                        $('#posts-container').html('<div class="error">게시글을 불러올 수 없습니다.</div>');
                    }
                },
                error: function() {
                    $('#posts-container').html('<div class="error">서버 연결 실패</div>');
                }
            });
        }
        
        // 게시글 목록 표시
        function displayCategoryPosts(data, categoryName) {
            const { posts, totalCount } = data;
            
            let html = '<div class="posts-header">' +
                        '<h4>📝 ' + categoryName + ' (' + totalCount + '개)</h4>' +
                        '<button class="btn btn-primary" onclick="goToWritePage()">글쓰기</button>' +
                       '</div>';
            
            if (posts && posts.length > 0) {
                html += '<div class="posts-list">';
                posts.forEach(function(post) {
                    html += '<div class="post-item" onclick="goToPostDetail(' + post.id + ')">' +
                            '<h5>' + post.title + '</h5>' +
                            '<p>' + (post.content ? post.content.substring(0, 100) + '...' : '') + '</p>' +
                            '<div class="post-meta">' +
                                '<span>👤 ' + (post.nickname || '익명') + '</span>' +
                                '<span>📅 ' + formatDate(post.createdAt) + '</span>' +
                                '<span>👁️ ' + (post.viewCount || 0) + '</span>' +
                                '<span>💬 ' + (post.commentCount || 0) + '</span>' +
                            '</div>' +
                            '</div>';
                });
                html += '</div>';
            } else {
                html += '<div class="no-posts">아직 게시글이 없습니다.</div>';
            }
            
            $('#posts-container').html(html);
        }
        
        // 게시글 상세 페이지로 이동
        function goToPostDetail(postId) {
            window.location.href = '<%=root%>/?main=community/hpost_detail.jsp&id=' + postId;
        }
        
        // 글쓰기 페이지로 이동
        function goToWritePage() {
            window.location.href = '<%=root%>/?main=community/hpost_insert.jsp';
        }
        
        // 날짜 포맷팅
        function formatDate(dateString) {
            if (!dateString) return '';
            const date = new Date(dateString);
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            return month + '/' + day;
        }

        // 오류 표시 (기존 CSS 스타일 사용)
        function showError(message) {
            $('#category-grid').html(
                '<div class="text-center" style="grid-column: 1 / -1; padding: 50px 20px;">' +
                    '<i class="bi bi-exclamation-triangle" style="font-size: 3rem; color: #dc3545; margin-bottom: 20px;"></i>' +
                    '<h5>문제가 발생했습니다</h5>' +
                    '<p class="mb-4">' + message + '</p>' +
                    '<button class="category-btn" onclick="loadCategoriesFromDatabase()" style="max-width: 200px; margin: 0 auto;">' +
                        '<i class="bi bi-arrow-clockwise"></i> 다시 시도' +
                    '</button>' +
                    '<hr class="my-4">' +
                    '<div class="alert alert-info text-start" style="max-width: 600px; margin: 20px auto;">' +
                        '<h6>기술적 정보:</h6>' +
                        '<ul class="mb-0">' +
                            '<li>API 엔드포인트: <code>/api/community/categories</code></li>' +
                            '<li>데이터베이스 테이블: <code>community_category</code></li>' +
                            '<li>서비스: <code>CommunityCategoryService</code></li>' +
                            '<li>매퍼: <code>CommunityCategoryMapper</code></li>' +
                        '</ul>' +
                    '</div>' +
                '</div>'
            );
        }

        // 전역 함수 노출
        window.goToCategoryPosts = goToCategoryPosts;
        window.loadCategoriesFromDatabase = loadCategoriesFromDatabase;
</script>