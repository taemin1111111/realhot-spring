<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- mypage.css 링크 추가 -->
<link href="${pageContext.request.contextPath}/css/mypage.css" rel="stylesheet">

<div class="mdwish-container">
    <!-- 헤더 -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0">나의 MD 찜</h2>
        <a href="<%=request.getContextPath()%>/mypage" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left me-2"></i>마이페이지로
        </a>
    </div>

    <!-- MD 찜 목록 -->
    <div id="mdWishListContainer">
        <!-- MD 찜 목록이 여기에 동적으로 로드됩니다 -->
    </div>

    <!-- 페이지네이션 -->
    <nav aria-label="MD 찜 페이지네이션" id="paginationContainer" class="mt-4">
        <!-- 페이지네이션이 여기에 동적으로 로드됩니다 -->
    </nav>

    <!-- 로딩 스피너 -->
    <div id="loadingSpinner" class="text-center py-5" style="display: none;">
        <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">로딩 중...</span>
        </div>
    </div>

    <!-- 데이터가 없을 때 메시지 -->
    <div id="noDataMessage" class="text-center py-5" style="display: none;">
        <i class="bi bi-heart text-muted" style="font-size: 3rem;"></i>
        <h5 class="text-muted mt-3">아직 찜한 MD가 없습니다</h5>
        <p class="text-muted">마음에 드는 MD를 찜해보세요!</p>
        <a href="<%=request.getContextPath()%>/md" class="btn btn-primary">
            <i class="bi bi-search me-2"></i>MD 둘러보기
        </a>
    </div>
</div>

<script>
    let currentPage = 1;
    let currentSize = 10;

    // 페이지 로드 시 MD 찜 목록 로드
    $(document).ready(function() {
        loadMdWishList(1);
    });

    // MD 찜 목록 로드
    function loadMdWishList(page) {
        currentPage = page;
        
        // 로딩 스피너 표시
        $('#loadingSpinner').show();
        $('#mdWishListContainer').hide();
        $('#noDataMessage').hide();
        
        $.ajax({
            url: '<%=request.getContextPath()%>/mypage/api/mdwish',
            method: 'GET',
            headers: getRequestHeaders(),
            data: {
                page: page,
                size: currentSize
            },
            success: function(response) {
                console.log('MD 찜 목록 조회 성공:', response);
                
                if (response.mdWishList && response.mdWishList.length > 0) {
                    displayMdWishList(response.mdWishList);
                    displayPagination(response.currentPage, response.totalPages);
                    $('#mdWishListContainer').show();
                } else {
                    $('#noDataMessage').show();
                }
            },
            error: function(xhr, status, error) {
                console.error('MD 찜 목록 조회 오류:', error);
                if (xhr.status === 401) {
                    alert('로그인이 필요합니다.');
                    window.location.href = '<%=request.getContextPath()%>/login';
                } else {
                    alert('MD 찜 목록을 불러오는데 실패했습니다.');
                }
            },
            complete: function() {
                $('#loadingSpinner').hide();
            }
        });
    }

    // MD 찜 목록 표시
    function displayMdWishList(mdWishList) {
        const container = $('#mdWishListContainer');
        let html = '';
        
        mdWishList.forEach(function(item) {
            console.log('MD 아이템 데이터:', item); // 디버깅용
            
            const placeName = item.placeName || '가게명 없음';
            const placeAddress = item.placeAddress || '주소 없음';
            const contact = item.contact || '연락처 없음';
            const description = item.description || '설명이 없습니다.';
            const createdAt = item.createdAt ? new Date(item.createdAt).toLocaleDateString('ko-KR') : '';
            const wishDate = formatDate(item.wishDate);
            
            html += '<div class="col-md-6 col-lg-4 mb-4">' +
                '<div class="card-box clubmd-md-card">' +
                    '<div class="clubmd-md-card-body">' +
                        '<div class="clubmd-md-photo-container mb-3">' +
                            (item.photo ? 
                                '<img src="' + item.photo + '" alt="' + item.mdName + '" class="clubmd-md-photo">' : 
                                '<div class="clubmd-md-photo-placeholder"><i class="bi bi-person-circle"></i></div>'
                            ) +
                        '</div>' +
                        '<div class="clubmd-md-info">' +
                            '<h5 class="clubmd-md-name mb-2">' + item.mdName + '</h5>' +
                            '<div class="clubmd-md-place mb-2">' +
                                '<span class="clubmd-place-name">' + placeName + '</span>' +
                                '<span class="clubmd-place-address">(' + placeAddress + ')</span>' +
                            '</div>' +
                            '<div class="clubmd-md-contact mb-2">' +
                                '<i class="bi bi-telephone me-1"></i>' +
                                '<span>' + contact + '</span>' +
                            '</div>' +
                            '<p class="clubmd-md-description mb-2">' + description + '</p>' +
                            '<div class="clubmd-md-date mb-2">' +
                                '<small class="text-muted">MD 등록일: ' + createdAt + '</small>' +
                            '</div>' +
                            '<div class="clubmd-md-wish-date">' +
                                '<small class="text-muted">찜한 날짜: ' + wishDate + '</small>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="clubmd-md-actions d-flex justify-content-center mt-3">' +
                        '<button class="btn btn-outline-primary btn-sm me-2" onclick="viewMd(' + item.mdId + ')">' +
                            '<i class="bi bi-eye me-1"></i>보기' +
                        '</button>' +
                        '<button class="btn btn-outline-danger btn-sm" onclick="removeMdWish(' + item.wishId + ')">' +
                            '<i class="bi bi-heart-fill me-1"></i>찜 해제' +
                        '</button>' +
                    '</div>' +
                '</div>' +
            '</div>';
        });
        
        // row로 감싸기
        if (html) {
            html = '<div class="row">' + html + '</div>';
        }
        
        container.html(html);
    }

    // 페이지네이션 표시
    function displayPagination(currentPage, totalPages) {
        const container = $('#paginationContainer');
        
        if (totalPages <= 1) {
            container.html('');
            return;
        }
        
        let html = '<ul class="pagination justify-content-center">';
        
        // 이전 페이지 버튼
        if (currentPage > 1) {
            html += `<li class="page-item"><a class="page-link" href="#" onclick="loadMdWishList(${currentPage - 1})">이전</a></li>`;
        }
        
        // 페이지 번호들
        for (let i = 1; i <= totalPages; i++) {
            if (i === currentPage) {
                html += `<li class="page-item active"><span class="page-link">${i}</span></li>`;
            } else {
                html += `<li class="page-item"><a class="page-link" href="#" onclick="loadMdWishList(${i})">${i}</a></li>`;
            }
        }
        
        // 다음 페이지 버튼
        if (currentPage < totalPages) {
            html += `<li class="page-item"><a class="page-link" href="#" onclick="loadMdWishList(${currentPage + 1})">다음</a></li>`;
        }
        
        html += '</ul>';
        container.html(html);
    }

    // MD 상세 보기
    function viewMd(mdId) {
        window.location.href = '<%=request.getContextPath()%>/md';
    }

    // MD 찜 해제
    function removeMdWish(wishId) {
        if (!confirm('정말로 이 MD 찜을 해제하시겠습니까?')) {
            return;
        }
        
        $.ajax({
            url: '<%=request.getContextPath()%>/mypage/api/mdwish/' + wishId,
            method: 'DELETE',
            headers: getRequestHeaders(),
            success: function(response) {
                if (response.success) {
                    alert('MD 찜이 해제되었습니다.');
                    loadMdWishList(currentPage); // 현재 페이지 새로고침
                } else {
                    alert('MD 찜 해제에 실패했습니다.');
                }
            },
            error: function(xhr, status, error) {
                console.error('MD 찜 해제 오류:', error);
                if (xhr.status === 401) {
                    alert('로그인이 필요합니다.');
                    window.location.href = '<%=request.getContextPath()%>/login';
                } else {
                    alert('MD 찜 해제에 실패했습니다.');
                }
            }
        });
    }

    // 날짜 포맷팅
    function formatDate(dateString) {
        if (!dateString) return '';
        
        const date = new Date(dateString);
        const now = new Date();
        const diffTime = Math.abs(now - date);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffDays === 1) {
            return '오늘';
        } else if (diffDays === 2) {
            return '어제';
        } else if (diffDays <= 7) {
            return diffDays - 1 + '일 전';
        } else {
            return date.toLocaleDateString('ko-KR');
        }
    }

    // JWT 토큰 헤더 가져오기
    function getRequestHeaders() {
        const token = localStorage.getItem('accessToken');
        return {
            'Authorization': 'Bearer ' + token,
            'Content-Type': 'application/json'
        };
    }
</script>
