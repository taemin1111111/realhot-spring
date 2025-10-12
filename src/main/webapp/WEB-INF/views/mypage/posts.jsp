<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = "";
%>
<!-- 마이페이지 전용 CSS -->
<link rel="stylesheet" href="<%=root%>/css/mypage.css">

<div class="posts-container">
    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2>내 게시글</h2>
                    <a href="<%=root%>/mypage" class="btn btn-outline-primary">
                        ← 마이페이지로
                    </a>
                </div>
                
                <!-- 게시글 타입 필터 -->
                <div class="post-type-filter mb-4">
                    <div class="d-flex flex-wrap gap-2">
                        <button class="post-type-filter-btn active" data-type="all">
                            <i class="bi bi-collection me-1"></i>전체
                        </button>
                                                 <button class="post-type-filter-btn marker-course" data-type="course">
                             코스
                         </button>
                         <button class="post-type-filter-btn marker-hottalk" data-type="hottalk">
                             핫톡
                         </button>
                    </div>
                </div>
                
                <!-- 게시글 목록 -->
                <div id="posts-container">
                    <div class="text-center p-5">
                        <div class="card border-0 shadow-sm">
                            <div class="card-body p-5">
                                <div class="spinner-border text-primary mb-3" style="width: 3rem; height: 3rem;" role="status">
                                    <span class="visually-hidden">로딩 중...</span>
                                </div>
                                <h5 class="text-muted">게시글을 불러오는 중입니다...</h5>
                                <p class="text-muted mb-0">잠시만 기다려주세요</p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- 페이지네이션 -->
                <nav id="pagination" class="mt-4" style="display: none;">
                    <ul class="pagination justify-content-center">
                    </ul>
                </nav>
            </div>
        </div>
    </div>

    <script>
        let currentPage = 1;
        const pageSize = 10;
        let postsData = null;
        let currentPostType = 'all';
        
        $(document).ready(function() {
            // JWT 토큰 확인
            const token = getJwtToken();
            if (!token) {
                alert('로그인이 필요합니다.');
                window.location.href = '<%=root%>/';
                return;
            }
            
            loadPosts();
            
            // 게시글 타입 필터 버튼 클릭 이벤트
            $('.post-type-filter-btn').on('click', function() {
                const postType = $(this).data('type');
                filterByPostType(postType);
            });
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
        
        // 게시글 타입별 필터링
        function filterByPostType(postType) {
            currentPostType = postType;
            currentPage = 1;
            
            // 버튼 활성화 상태 변경
            $('.post-type-filter-btn').removeClass('active');
            $(`.post-type-filter-btn[data-type="${postType}"]`).addClass('active');
            
            // 게시글 목록 다시 로드
            loadPosts();
        }
        
        // 게시글 목록 로드
        function loadPosts(page = 1) {
            currentPage = page;
            
            $.ajax({
                url: '<%=root%>/mypage/api/posts',
                method: 'GET',
                headers: getRequestHeaders(),
                data: {
                    page: page,
                    size: pageSize,
                    type: currentPostType
                },
                success: function(response) {
                    displayPosts(response);
                    displayPagination(response);
                },
                error: function(xhr, status, error) {
                    console.error('게시글 목록 로드 오류:', error);
                    if (xhr.status === 401) {
                        alert('인증이 만료되었습니다. 다시 로그인해주세요.');
                        localStorage.removeItem('accessToken');
                        window.location.href = '<%=root%>/';
                    } else {
                        $('#posts-container').html(`
                            <div class="alert alert-danger">
                                <i class="bi bi-exclamation-triangle"></i>
                                게시글을 불러올 수 없습니다.
                            </div>
                        `);
                    }
                }
            });
        }
        
        // 게시글 목록 표시
        function displayPosts(data) {
            const container = $('#posts-container');
            
            // 전역 변수에 데이터 저장
            postsData = data;
            
            // 데이터가 배열인지 객체인지 확인
            let postsArray = data;
            if (data.posts && Array.isArray(data.posts)) {
                postsArray = data.posts;
            } else if (Array.isArray(data)) {
                postsArray = data;
            } else {
                console.error('예상치 못한 데이터 구조:', data);
                return;
            }
            
                         // 게시글 타입별 필터링 적용 (서버에서 이미 필터링됨)
             // 클라이언트에서는 추가 필터링 불필요
            
            if (!postsArray || postsArray.length === 0) {
                let message = '';
                if (currentPostType === 'all') {
                    message = '<span class="text-muted" style="font-size: 4rem;">📝</span>' +
                        '<h4 class="mt-3 text-muted">아직 작성한 게시글이 없어요</h4>' +
                        '<p class="text-muted mb-4">첫 번째 게시글을 작성해보세요!</p>';
                } else {
                    // 게시글 타입별 메시지
                    let postTypeDisplayName = '';
                    
                    if (currentPostType === 'course') {
                        postTypeDisplayName = '코스';
                    } else if (currentPostType === 'hottalk') {
                        postTypeDisplayName = '핫톡';
                    } else {
                        postTypeDisplayName = '선택된 게시글 타입';
                    }
                    
                    message = '<span class="text-muted" style="font-size: 4rem;">🔍</span>' +
                        '<h4 class="mt-3 text-muted">' + postTypeDisplayName + ' 게시글이 없습니다</h4>' +
                        '<p class="text-muted mb-4">다른 게시글 타입을 선택하거나 새로운 게시글을 작성해보세요!</p>';
                }
                
                if (currentPostType === 'all') {
                    // 전체 게시글 타입일 때만 버튼들 표시
                    const allPostTypeHtml = '<div class="text-center p-5">' +
                        '<div class="card border-0 shadow-sm">' +
                        '<div class="card-body p-5">' +
                        message +
                        '<div class="d-grid gap-2 d-md-flex justify-content-md-center">' +
                        '<a href="<%=root%>/course" class="btn btn-primary btn-lg">' +
                        '🚀 코스 작성하기' +
                        '</a>' +
                        '<a href="<%=root%>/hottalk" class="btn btn-success btn-lg">' +
                        '💬 핫톡 작성하기' +
                        '</a>' +
                        '<a href="<%=root%>/mypage" class="btn btn-outline-secondary btn-lg">' +
                        '← 마이페이지로 돌아가기' +
                        '</a>' +
                        '</div>' +
                        '</div>' +
                        '</div>' +
                        '</div>';
                    container.html(allPostTypeHtml);
                } else {
                    // 특정 게시글 타입일 때는 메시지만 표시
                    const postTypeHtml = '<div class="text-center p-5">' +
                        '<div class="card border-0 shadow-sm">' +
                        '<div class="card-body p-5">' +
                        message +
                        '</div>' +
                        '</div>' +
                        '</div>';
                    container.html(postTypeHtml);
                }
                
                return;
            }
            
            let html = '<div class="row g-3">';
            
            postsArray.forEach(function(item, index) {
                // 게시글 타입별 헤더 클래스 결정
                let headerClass = 'card-header text-white text-center py-2';
                if (item.post_type === 'course') {
                    headerClass += ' category-course';
                } else if (item.post_type === 'hottalk') {
                    headerClass += ' category-hottalk';
                } else {
                    headerClass += ' bg-primary';
                }
                
                // 게시글 타입별 배지 추가
                let typeBadge = '';
                if (item.post_type === 'course') {
                    typeBadge = '<span class="badge bg-info ms-2">코스</span>';
                } else if (item.post_type === 'hottalk') {
                    typeBadge = '<span class="badge bg-dark ms-2">핫톡</span>';
                }
                
                const itemHtml = '<div class="col-md-6 col-lg-4">' +
                    '<div class="card h-100 shadow-sm">' +
                    '<div class="' + headerClass + '">' +
                    '<h6 class="card-title mb-0">' + ((item.title && item.title.length > 20) ? (item.title.substring(0, 20) + '...') : (item.title || '제목 없음')) + typeBadge + '</h6>' +
                    '</div>' +
                    '<div class="card-body d-flex flex-column">' +
                    '<div class="mb-3">' +
                    '<div class="d-flex align-items-center mb-2">' +
                    '<i class="bi bi-eye text-muted me-2"></i>' +
                    '<small class="text-muted">조회수: ' + (item.view_count || item.views || 0) + '</small>' +
                    '</div>' +
                    '<div class="d-flex align-items-center mb-2">' +
                    '<i class="bi bi-chat-dots text-muted me-2"></i>' +
                    '<small class="text-muted">댓글수: ' + (item.comment_count || 0) + '</small>' +
                    '</div>' +
                    '<div class="d-flex align-items-center mb-2">' +
                    '<i class="bi bi-hand-thumbs-up text-muted me-2"></i>' +
                    '<small class="text-muted">좋아요: ' + (item.like_count || item.likes || 0) + '</small>' +
                    '</div>' +
                    '<div class="d-flex align-items-center mb-2">' +
                    '<i class="bi bi-hand-thumbs-down text-muted me-2"></i>' +
                    '<small class="text-muted">싫어요: ' + (item.dislike_count || item.dislikes || 0) + '</small>' +
                    '</div>' +
                    '<div class="d-flex align-items-center mb-3">' +
                    '<i class="bi bi-calendar3 text-muted me-2"></i>' +
                    '<small class="text-muted">작성일: ' + (item.regdate ? new Date(item.regdate).toLocaleDateString('ko-KR') : '날짜 없음') + '</small>' +
                    '</div>' +
                    '</div>' +
                    
                    '<div class="mt-auto">' +
                    '<div class="d-grid gap-2">' +
                    '<button class="btn btn-primary btn-sm ' + (item.post_type === 'course' ? 'category-course' : 'category-hottalk') + '" onclick="goToPost(\'' + item.post_type + '\', ' + (item.id || 0) + ')">' +
                    '<i class="bi bi-arrow-right"></i> 게시글 보기' +
                    '</button>' +
                    '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>';
                
                html += itemHtml;
            });
            
            html += '</div>';
            container.html(html);
        }
        
        // 페이지네이션 표시
        function displayPagination(data) {
            if (data.totalPages <= 1) {
                $('#pagination').hide();
                return;
            }
            
            const pagination = $('#pagination ul');
            let html = '';
            
            // 이전 페이지
            if (data.currentPage > 1) {
                html += `
                    <li class="page-item">
                        <a class="page-link" href="#" onclick="loadPosts(${data.currentPage - 1})">
                            ←
                        </a>
                    </li>
                `;
            }
            
            // 페이지 번호들
            for (let i = 1; i <= data.totalPages; i++) {
                if (i === data.currentPage) {
                    html += `<li class="page-item active"><span class="page-link">${i}</span></li>`;
                } else {
                    html += `<li class="page-item"><a class="page-link" href="#" onclick="loadPosts(${i})">${i}</a></li>`;
                }
            }
            
            // 다음 페이지
            if (data.currentPage < data.totalPages) {
                html += `
                    <li class="page-item">
                        <a class="page-link" href="#" onclick="loadPosts(${data.currentPage + 1})">
                            →
                        </a>
                    </li>
                `;
            }
            
            pagination.html(html);
            $('#pagination').show();
        }
        
        // 게시글로 이동
        function goToPost(postType, postId) {
            if (!postId || postId === 0) {
                alert('게시글 ID가 유효하지 않습니다.');
                return;
            }
            
                         let url = '';
             if (postType === 'course') {
                 url = '<%=root%>/course/' + postId;
             } else if (postType === 'hottalk') {
                 url = '<%=root%>/hpost/' + postId;
             } else {
                 alert('알 수 없는 게시글 타입입니다.');
                 return;
             }
            
            window.location.href = url;
        }
    </script>
</div>
