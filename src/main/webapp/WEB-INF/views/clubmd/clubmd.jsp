<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 필요한 CSS/JS 링크 추가 -->
<link href="${pageContext.request.contextPath}/css/md.css" rel="stylesheet">

<!-- MD 목록 섹션 -->
<div class="clubmd-page">
    <!-- 우주 배경 -->
    <div class="space-background">
        <!-- 별들 컨테이너 -->
        <div class="stars-container" id="starsContainer"></div>
    </div>
    
    <!-- 메인 콘텐츠 영역 -->
    <div class="clubmd-content-wrapper">
        <div class="main-container">
            <!-- 섹션 타이틀 -->
            <div class="section-title">
                <img src="${pageContext.request.contextPath}/logo/fire.png" alt="MD">
                MD 목록
            </div>

    <!-- 검색 섹션 -->
    <div class="card-box mb-4">
        <div class="row">
            <div class="col-md-4">
                <select class="form-select" id="searchType">
                    <option value="all">전체</option>
                    <option value="mdName">MD명</option>
                    <option value="placeName">장소명</option>
                </select>
            </div>
            <div class="col-md-6">
                <input type="text" class="form-control" id="searchKeyword" placeholder="검색어를 입력하세요...">
            </div>
            <div class="col-md-2">
                <button class="btn btn-primary w-100" onclick="searchMds()">
                    <i class="bi bi-search"></i> 검색
                </button>
            </div>
        </div>
    </div>
    
    <!-- 정렬 버튼 -->
    <div class="mb-3">
        <button type="button" id="sortLatest" class="btn btn-outline-secondary me-2" onclick="loadMds(1, 'latest')">전체</button>
        <button type="button" id="sortPopular" class="btn btn-outline-secondary" onclick="loadMds(1, 'popular')">인기순</button>
    </div>
    
    <!-- MD 목록 컨테이너 -->
    <div id="mdListContainer">
        <!-- MD 목록이 여기에 동적으로 로드됩니다 -->
    </div>
    
    <!-- 페이지네이션 -->
    <nav aria-label="MD 페이지네이션" id="paginationContainer" class="mt-4">
        <!-- 페이지네이션이 여기에 동적으로 로드됩니다 -->
    </nav>
</div>

<!-- 로그인 필요 토스트 메시지 -->
<div id="loginToast" class="toast align-items-center text-white bg-danger border-0" role="alert" aria-live="assertive" aria-atomic="true" style="display: none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 9999;">
    <div class="d-flex">
        <div class="toast-body">
            로그인 후 사용 가능합니다
        </div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
</div>

<script>
    let currentPage = 1;
    let currentSort = 'latest';
    let currentKeyword = '';
    let currentSearchType = 'all';

    // 페이지 로드 시 MD 목록 로드
    $(document).ready(function() {
        console.log('페이지 로드 완료');
        
        // body에 clubmd-page 클래스 추가 (푸터 전체 너비를 위해)
        $('body').addClass('clubmd-page');
        
        // 별들 먼저 생성
        setTimeout(function() {
            createStars();
        }, 100);
        
        // MD 목록 로드
        loadMds(1, 'latest');
    });

    // 별들 생성 함수 - 완전 새로 작성
    function createStars() {
        console.log('별 생성 시작...');
        
        // 별들 컨테이너 찾기
        const starsContainer = document.getElementById('starsContainer');
        if (!starsContainer) {
            console.error('별들 컨테이너를 찾을 수 없습니다!');
            return;
        }
        
        console.log('별들 컨테이너 찾음:', starsContainer);
        
        // 기존 별들 제거
        starsContainer.innerHTML = '';
        
        const starCount = 200; // 별 개수 증가 (전체 화면 채우기)
        
        for (let i = 0; i < starCount; i++) {
            const star = document.createElement('div');
            star.className = 'star';
            
            // 랜덤 위치와 크기
            const size = Math.random() * 2 + 0.5; // 0.5-2.5px로 크기 축소
            const x = Math.random() * 120; // 0-120%로 화면 밖까지 확장
            const y = Math.random() * 120; // 0-120%로 화면 밖까지 확장
            
            // 인라인 스타일로 강제 적용
            star.style.position = 'absolute';
            star.style.width = size + 'px';
            star.style.height = size + 'px';
            star.style.left = x + '%';
            star.style.top = y + '%';
            star.style.background = '#ffffff';
            star.style.borderRadius = '50%';
            star.style.boxShadow = '0 0 6px #ffffff';
            star.style.zIndex = '1000';
            star.style.display = 'block';
            
            starsContainer.appendChild(star);
            
            // 디버깅: 첫 번째 별 확인
            if (i === 0) {
                console.log('첫 번째 별 스타일:', star.style.cssText);
                console.log('첫 번째 별 크기:', star.offsetWidth, 'x', star.offsetHeight);
            }
        }
        
        console.log(`${starCount}개의 별이 생성되었습니다.`);
        console.log('별들 컨테이너 내용:', starsContainer.innerHTML);
    }

    // 정렬 버튼 상태 업데이트
    function updateSortButtons(sort) {
        // 모든 정렬 버튼을 기본 스타일로 초기화
        $('#sortLatest').removeClass('btn-primary').addClass('btn-outline-secondary');
        $('#sortPopular').removeClass('btn-primary').addClass('btn-outline-secondary');
        
        // 현재 선택된 정렬 버튼을 활성화 스타일로 변경
        if (sort === 'latest') {
            $('#sortLatest').removeClass('btn-outline-secondary').addClass('btn-primary');
        } else if (sort === 'popular') {
            $('#sortPopular').removeClass('btn-outline-secondary').addClass('btn-primary');
        }
    }

    // MD 목록 로드
    function loadMds(page, sort = 'latest') {
        currentPage = page;
        currentSort = sort;
        
        // 정렬 버튼 상태 업데이트
        updateSortButtons(sort);
        
        const offset = (page - 1) * 10; // 페이지당 10개
        
        // JWT 토큰 가져오기
        const token = localStorage.getItem('accessToken');
        
        $.ajax({
            url: '${pageContext.request.contextPath}/md/api/list',
            method: 'GET',
            headers: {
                'Authorization': token ? 'Bearer ' + token : ''
            },
            data: {
                page: page - 1,  // Spring Boot는 0부터 시작
                size: 10,
                keyword: currentKeyword,
                searchType: currentSearchType,
                sort: sort
            },
            success: function(response) {
                if (response.success) {
                    displayMds(response.mds || []);
                    updatePagination(response.currentPage || 1, response.totalPages || 1, response.totalElements || 0);
                } else {
                    showError('MD 목록을 불러오는데 실패했습니다.');
                }
            },
            error: function(xhr, status, error) {
                showError('서버 오류가 발생했습니다.');
            }
        });
    }

    // MD 목록 표시
    function displayMds(mds) {
        if (!mds || mds.length === 0) {
            $('#mdListContainer').html(`
                <div class="card-box text-center py-5">
                    <div class="text-muted">
                        <i class="bi bi-exclamation-triangle display-1"></i>
                    </div>
                    <h4 class="mt-3">등록된 MD가 없습니다</h4>
                    <p class="text-muted-small">현재 등록된 MD가 없습니다.</p>
                </div>
            `);
            return;
        }
        
        // JWT 토큰 기반 로그인 상태 확인
        const token = localStorage.getItem('accessToken');
        const isLoggedIn = token && token !== 'null' && token !== '';
        
        let html = '<div class="row">';
        mds.forEach(function(md, index) {
            const isWished = md.wished || false;
            const wishCount = md.wishCount || 0;
            const placeName = md.placeName || '가게명 없음';
            const placeAddress = md.placeAddress || '주소 없음';
            const contact = md.contact || '연락처 없음';
            const description = md.description || '설명이 없습니다.';
            const createdAt = md.createdAt ? new Date(md.createdAt).toLocaleDateString('ko-KR') : '';
            
            html += '<div class="col-md-6 col-lg-4 mb-4">' +
                '<div class="card-box clubmd-md-card">' +
                    '<div class="clubmd-md-card-header position-relative">' +
                        '<div class="clubmd-md-wish-btn ' + (isWished ? 'wished' : '') + '" ' +
                             'data-md-id="' + md.mdId + '" ' +
                             'data-wished="' + isWished + '" ' +
                             'onclick="toggleMdWish(' + md.mdId + ', this)">' +
                            '<i class="bi ' + (isWished ? 'bi-heart-fill text-danger' : 'bi-heart') + '"></i>' +
                        '</div>' +
                    '</div>' +
                    '<div class="clubmd-md-card-body">' +
                        '<div class="clubmd-md-photo-container mb-3">' +
                            (md.photo ? 
                                '<img src="' + md.photo + '" alt="' + md.mdName + '" class="clubmd-md-photo">' : 
                                '<div class="clubmd-md-photo-placeholder"><i class="bi bi-person-circle"></i></div>'
                            ) +
                        '</div>' +
                        '<div class="clubmd-md-info">' +
                            '<h5 class="clubmd-md-name mb-2">' + md.mdName + '</h5>' +
                            '<div class="clubmd-md-place mb-2">' +
                                '<span class="clubmd-place-name">' + placeName + '</span>' +
                                '<span class="clubmd-place-address">(' + placeAddress + ')</span>' +
                            '</div>' +
                            '<div class="clubmd-md-contact mb-2">' +
                                '<i class="bi bi-telephone me-1"></i>' +
                                '<span>' + contact + '</span>' +
                            '</div>' +
                            '<p class="clubmd-md-description mb-2">' + description + '</p>' +
                            '<div class="clubmd-md-date">' +
                                '<small class="text-muted">MD 등록일: ' + createdAt + '</small>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="clubmd-md-wish-count d-flex align-items-center justify-content-center" data-md-id="' + md.mdId + '">' +
                        '<i class="bi bi-heart-fill me-1"></i>' +
                        '<span class="clubmd-wish-count-number fw-bold">' + wishCount + '</span>' +
                    '</div>' +
                '</div>' +
            '</div>';
        });
        html += '</div>';
        
        $('#mdListContainer').html(html);
    }

    // MD 찜하기 토글
    function toggleMdWish(mdId, button) {
        // JWT 토큰 기반 로그인 확인
        const token = localStorage.getItem('accessToken');
        if (!token || token === 'null' || token === '') {
            showLoginToast();
            return;
        }
        
        $(button).prop('disabled', true);
        
        // 항상 POST로 요청 (토글 방식)
        const apiUrl = '${pageContext.request.contextPath}/md/api/' + mdId + '/wish';
        
        $.ajax({
            url: apiUrl,
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + token,
                'Content-Type': 'application/json'
            },
            success: function(response) {
                if (response.success) {
                    // 서버에서 반환된 찜 상태 사용
                    const newWished = response.isWished;
                    
                    // 버튼의 data-wished 속성 업데이트
                    $(button).attr('data-wished', newWished);
                    
                    // 하트 아이콘 변경
                    const heartIcon = $(button).find('i');
                    if (newWished) {
                        // 찜한 상태: 빨간 채워진 하트
                        $(button).addClass('wished');
                        heartIcon.removeClass('bi-heart').addClass('bi-heart-fill text-danger');
                        // CSS 강제 적용
                        heartIcon.css('color', '#dc3545');
                    } else {
                        // 찜하지 않은 상태: 빈 하트
                        $(button).removeClass('wished');
                        heartIcon.removeClass('bi-heart-fill text-danger').addClass('bi-heart');
                        // CSS 강제 적용
                        heartIcon.css('color', '#6c757d');
                    }
                    
                    // 찜 개수 업데이트
                    updateWishCount(mdId, newWished);
                    
                    // 성공 메시지 표시
                    if (newWished) {
                        showToast('찜하기가 완료되었습니다! 💖', 'success');
                    } else {
                        showToast('찜하기가 취소되었습니다.', 'info');
                    }
                    
                    $(button).prop('disabled', false);
                } else {
                    showError(response.message || '찜하기 처리에 실패했습니다.');
                    $(button).prop('disabled', false);
                }
            },
            error: function() {
                showError('서버 오류가 발생했습니다.');
                $(button).prop('disabled', false);
            }
        });
    }

    // 찜 개수 업데이트
    function updateWishCount(mdId, isWished) {
        const wishCountElement = $(`.clubmd-md-wish-count[data-md-id="${mdId}"] .clubmd-wish-count-number`);
        
        if (isWished) {
            // 찜 추가된 경우 개수 증가
            let currentCount = parseInt(wishCountElement.text()) || 0;
            wishCountElement.text(currentCount + 1);
        } else {
            // 찜 제거된 경우 개수 감소
            let currentCount = parseInt(wishCountElement.text()) || 0;
            wishCountElement.text(Math.max(0, currentCount - 1));
        }
    }

    // 토스트 메시지 표시 함수
    function showToast(message, type) {
        // 기존 토스트 제거
        const existingToast = document.querySelector('.toast-message');
        if (existingToast) {
            existingToast.remove();
        }
        
        // 새 토스트 생성
        const toast = document.createElement('div');
        toast.className = 'toast-message';
        toast.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 20px;
            border-radius: 8px;
            color: white;
            font-weight: 500;
            z-index: 10000;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            transform: translateX(100%);
            transition: transform 0.3s ease;
        `;
        
        // 타입에 따른 스타일 설정
        if (type === 'success') {
            toast.style.backgroundColor = '#4caf50';
        } else if (type === 'error') {
            toast.style.backgroundColor = '#f44336';
        } else {
            toast.style.backgroundColor = '#2196f3';
        }
        
        toast.textContent = message;
        document.body.appendChild(toast);
        
        // 애니메이션
        setTimeout(() => {
            toast.style.transform = 'translateX(0)';
        }, 100);
        
        // 자동 제거
        setTimeout(() => {
            toast.style.transform = 'translateX(100%)';
            setTimeout(() => {
                if (toast.parentNode) {
                    toast.remove();
                }
            }, 300);
        }, 3000);
    }

    // 검색
    function searchMds() {
        currentKeyword = $('#searchKeyword').val().trim();
        currentSearchType = $('#searchType').val();
        loadMds(1, currentSort);
    }

    // 페이지네이션 업데이트
    function updatePagination(currentPage, totalPages, totalElements) {
        if (totalPages <= 1) {
            $('#paginationContainer').html('');
            return;
        }

        let html = '<ul class="pagination justify-content-center">';
        
        // 이전 페이지
        if (currentPage > 1) {
            html += `<li class="page-item"><a class="page-link" href="#" onclick="loadMds(${currentPage - 1}, '${currentSort}')">이전</a></li>`;
        }
        
        // 페이지 번호
        for (let i = 1; i <= totalPages; i++) {
            if (i === currentPage) {
                html += `<li class="page-item active"><span class="page-link">${i}</span></li>`;
            } else {
                html += `<li class="page-item"><a class="page-link" href="#" onclick="loadMds(${i}, '${currentSort}')">${i}</a></li>`;
            }
        }
        
        // 다음 페이지
        if (currentPage < totalPages) {
            html += `<li class="page-item"><a class="page-link" href="#" onclick="loadMds(${currentPage + 1}, '${currentSort}')">다음</a></li>`;
        }
        
        html += '</ul>';
        $('#paginationContainer').html(html);
    }

    // 로그인 필요 토스트 표시
    function showLoginToast() {
        const toast = new bootstrap.Toast(document.getElementById('loginToast'));
        toast.show();
        
        // 2.5초 후 자동 숨김
        setTimeout(function() {
            toast.hide();
        }, 2500);
    }

    // 에러 메시지 표시
    function showError(message) {
        alert(message);
    }
</script>