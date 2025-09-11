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
            <div class="col-md-6" style="position: relative;">
                <input type="text" class="form-control" id="searchKeyword" placeholder="검색어를 입력하세요..." autocomplete="off">
                <div id="searchSuggestions" class="search-suggestions" style="display: none;"></div>
            </div>
            <div class="col-md-2">
                <button class="btn btn-primary w-100" onclick="searchMds()">
                    <i class="bi bi-search"></i> 검색
                </button>
            </div>
        </div>
    </div>
    
    <!-- 정렬 버튼과 관리자 기능 -->
    <div class="mb-3 d-flex justify-content-between align-items-center">
        <div>
            <button type="button" id="sortLatest" class="btn btn-outline-secondary me-2" onclick="loadMds(1, 'latest')">전체</button>
            <button type="button" id="sortPopular" class="btn btn-outline-secondary me-2" onclick="loadMds(1, 'popular')">인기순</button>
            <button type="button" class="btn btn-success" onclick="openKakaoChat()">
                <i class="bi bi-chat-dots"></i> MD 등록 문의
            </button>
        </div>
        
        <!-- 관리자만 보이는 MD 추가 버튼 (완전 오른쪽 끝) -->
        <div>
            <button type="button" id="admin-md-add" class="btn btn-outline-secondary" onclick="openMdAddModal()" style="display: none;">
                <i class="bi bi-plus-circle"></i> MD 추가
            </button>
        </div>
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

<!-- MD 추가 모달 -->
<div id="mdAddModal" class="modal-overlay" style="display: none;">
    <div class="modal-content">
        <div class="modal-header">
            <h5 class="modal-title">
                <i class="bi bi-plus-circle me-2"></i>MD 추가
            </h5>
            <button type="button" class="modal-close" onclick="closeMdAddModal()">&times;</button>
        </div>
        <div class="modal-body">
            <form id="mdAddForm">
                <div class="mb-3">
                    <label for="mdName" class="form-label">MD 이름 <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="mdName" name="mdName" required>
                </div>
                
                <div class="mb-3" style="position: relative;">
                    <label for="placeId" class="form-label">가게 선택 <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="placeId" name="placeId" placeholder="가게명을 검색하세요..." required>
                    <div id="placeSearchResults" class="search-results" style="display: none;"></div>
                </div>
                
                <div class="mb-3">
                    <label for="contact" class="form-label">연락처</label>
                    <input type="text" class="form-control" id="contact" name="contact" placeholder="예: 010-1234-5678">
                </div>
                
                <div class="mb-3">
                    <label for="description" class="form-label">MD 소개</label>
                    <textarea class="form-control" id="description" name="description" rows="4" placeholder="MD에 대한 소개를 입력하세요..."></textarea>
                </div>
                
                <div class="mb-3">
                    <label for="mdPhoto" class="form-label">MD 사진</label>
                    <input type="file" class="form-control" id="mdPhoto" name="mdPhoto" accept="image/*">
                    <div class="form-text">JPG, PNG 파일만 업로드 가능합니다.</div>
                </div>
                
                <div class="mb-3">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="isVisible" name="isVisible" checked>
                        <label class="form-check-label" for="isVisible">
                            즉시 공개
                        </label>
                    </div>
                </div>
            </form>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="closeMdAddModal()">취소</button>
            <button type="button" class="btn btn-primary" onclick="submitMdAdd()">
                <i class="bi bi-check-circle me-1"></i>MD 추가
            </button>
        </div>
    </div>
</div>

<!-- MD 수정 모달 -->
<div id="mdEditModal" class="modal-overlay" style="display: none;">
    <div class="modal-content">
        <div class="modal-header">
            <h5 class="modal-title">
                <i class="bi bi-pencil-square me-2"></i>MD 수정
            </h5>
            <button type="button" class="modal-close" onclick="closeMdEditModal()">&times;</button>
        </div>
        <div class="modal-body">
            <form id="mdEditForm">
                <div class="mb-3">
                    <label for="editMdName" class="form-label">MD 이름 <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="editMdName" name="editMdName" required>
                </div>
                
                <div class="mb-3" style="position: relative;">
                    <label for="editPlaceId" class="form-label">가게 선택 <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="editPlaceId" name="editPlaceId" placeholder="가게명을 검색하세요..." required>
                    <div id="editPlaceSearchResults" class="search-results" style="display: none;"></div>
                </div>
                
                <div class="mb-3">
                    <label for="editContact" class="form-label">연락처</label>
                    <input type="text" class="form-control" id="editContact" name="editContact" placeholder="예: 010-1234-5678">
                </div>
                
                <div class="mb-3">
                    <label for="editDescription" class="form-label">MD 소개</label>
                    <textarea class="form-control" id="editDescription" name="editDescription" rows="4" placeholder="MD에 대한 소개를 입력하세요..."></textarea>
                </div>
                
                <div class="mb-3">
                    <label for="editMdPhoto" class="form-label">MD 사진</label>
                    <input type="file" class="form-control" id="editMdPhoto" name="editMdPhoto" accept="image/*">
                    <div class="form-text">새로운 사진을 선택하면 기존 사진이 교체됩니다.</div>
                </div>
                
                <div class="mb-3">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="editIsVisible" name="editIsVisible">
                        <label class="form-check-label" for="editIsVisible">
                            공개 상태
                        </label>
                    </div>
                </div>
            </form>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="closeMdEditModal()">취소</button>
            <button type="button" class="btn btn-primary" onclick="submitMdEdit()">
                <i class="bi bi-check-circle me-1"></i>수정 완료
            </button>
        </div>
    </div>
</div>

<!-- MD 삭제 확인 모달 -->
<div id="mdDeleteModal" class="modal-overlay" style="display: none;">
    <div class="modal-content">
        <div class="modal-header">
            <h5 class="modal-title">
                <i class="bi bi-exclamation-triangle me-2 text-warning"></i>MD 삭제 확인
            </h5>
            <button type="button" class="modal-close" onclick="closeMdDeleteModal()">&times;</button>
        </div>
        <div class="modal-body">
            <div class="text-center">
                <i class="bi bi-exclamation-triangle display-4 text-warning mb-3"></i>
                <h5>정말로 이 MD를 삭제하시겠습니까?</h5>
                <p class="text-muted mb-3">
                    <strong id="deleteMdName"></strong> MD를 삭제하면<br>
                    관련된 찜 목록과 사진 파일도 함께 삭제됩니다.
                </p>
                <div class="alert alert-warning">
                    <i class="bi bi-info-circle me-2"></i>
                    <strong>주의:</strong> 이 작업은 되돌릴 수 없습니다.
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="closeMdDeleteModal()">
                <i class="bi bi-x-circle me-1"></i>취소
            </button>
            <button type="button" class="btn btn-danger" onclick="confirmDeleteMd()">
                <i class="bi bi-trash me-1"></i>삭제
            </button>
        </div>
    </div>
</div>

<script>
    let currentPage = 1;
    let currentSort = 'latest';
    let currentKeyword = '';
    let currentSearchType = 'all';

    // 페이지 로드 시 MD 목록 로드
    $(document).ready(function() {
        
        // body에 clubmd-page 클래스 추가 (푸터 전체 너비를 위해)
        $('body').addClass('clubmd-page');
        
        // 별들 먼저 생성
        setTimeout(function() {
            createStars();
        }, 100);
        
        // 관리자 권한 확인
        checkAdminPermission();
        
        // MD 목록 로드
        loadMds(1, 'latest');
        
        // 가게 검색 이벤트 리스너
        let selectedPlaceId = null;
        let searchTimeout = null;
        
        document.getElementById('placeId').addEventListener('input', function() {
            const query = this.value.trim();
            
            // 기존 타이머 클리어
            if (searchTimeout) {
                clearTimeout(searchTimeout);
            }
            
            if (query.length >= 2) {
                // 300ms 후에 검색 실행 (타이핑 중단 후)
                searchTimeout = setTimeout(() => {
                    searchHotplaces(query);
                }, 300);
            } else {
                hideSearchResults();
                selectedPlaceId = null;
            }
        });
        
        // 검색 결과 외부 클릭 시 숨기기
        document.addEventListener('click', function(e) {
            if (!e.target.closest('#placeId') && !e.target.closest('#placeSearchResults')) {
                hideSearchResults();
            }
        });
    });

    // 별들 생성 함수 - 완전 새로 작성
    function createStars() {
        // 별들 컨테이너 찾기
        const starsContainer = document.getElementById('starsContainer');
        if (!starsContainer) {
            return;
        }
        
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
            
        }
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
            let message = '';
            let detailMessage = '';
            
            if (currentKeyword && currentKeyword.trim() !== '') {
                // 검색 결과가 없는 경우
                message = '해당하는 MD가 없습니다';
                detailMessage = '검색어 "' + currentKeyword + '"에 대한 결과를 찾을 수 없습니다.';
            } else {
                // 일반적으로 MD가 없는 경우
                message = '등록된 MD가 없습니다';
                detailMessage = '현재 등록된 MD가 없습니다.';
            }
            
            $('#mdListContainer').html(
                '<div class="card-box text-center py-5">' +
                    '<div>' +
                        '<i class="bi bi-exclamation-triangle display-1" style="color: #000000;"></i>' +
                    '</div>' +
                    '<h4 class="mt-3" style="color: #000000;">' + message + '</h4>' +
                    '<p class="text-muted-small" style="color: #ffffff;">' + detailMessage + '</p>' +
                '</div>'
            );
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
                                '<img src="' + '${pageContext.request.contextPath}' + md.photo + '" alt="' + md.mdName + '" class="clubmd-md-photo">' : 
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
                                '<span class="clubmd-contact-link" onclick="openContact(\'' + contact + '\')" style="cursor: pointer; color: #007bff; text-decoration: underline;">' + contact + '</span>' +
                            '</div>' +
                            '<div class="clubmd-md-description-container mb-2">' +
                                '<p class="clubmd-md-description text-center">' + description + '</p>' +
                            '</div>' +
                            '<div class="clubmd-md-date">' +
                                '<small class="text-muted">MD 등록일: ' + createdAt + '</small>' +
                            '</div>' +
                            '<div class="clubmd-md-admin-actions mt-2" style="display: none;">' +
                                '<button type="button" class="btn btn-sm btn-outline-primary me-2" onclick="openMdEditModal(' + md.mdId + ')">' +
                                    '<i class="bi bi-pencil-square me-1"></i>수정' +
                                '</button>' +
                                '<button type="button" class="btn btn-sm btn-outline-danger" onclick="deleteMd(' + md.mdId + ', \'' + md.mdName + '\')">' +
                                    '<i class="bi bi-trash me-1"></i>삭제' +
                                '</button>' +
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
        
        // MD 카드 생성 후 관리자 권한 다시 확인
        checkAdminPermission();
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
        hideSearchSuggestions();
        loadMds(1, currentSort);
    }
    
    // 검색 자동완성 기능
    let searchTimeout;
    $(document).ready(function() {
        // 검색어 입력 이벤트
        $('#searchKeyword').on('input', function() {
            const query = $(this).val().trim();
            const searchType = $('#searchType').val();
            
            // 이전 타이머 클리어
            clearTimeout(searchTimeout);
            
            if (query.length >= 2) {
                // 300ms 후에 자동완성 요청
                searchTimeout = setTimeout(function() {
                    loadSearchSuggestions(query, searchType);
                }, 300);
            } else {
                hideSearchSuggestions();
            }
        });
        
        // 검색 타입 변경 시 자동완성 업데이트
        $('#searchType').on('change', function() {
            const query = $('#searchKeyword').val().trim();
            if (query.length >= 2) {
                loadSearchSuggestions(query, $(this).val());
            }
        });
        
        // 자동완성 항목 클릭 이벤트
        $(document).on('click', '.search-suggestion-item', function() {
            const suggestionText = $(this).data('text');
            $('#searchKeyword').val(suggestionText);
            hideSearchSuggestions();
            searchMds();
        });
        
        // 다른 곳 클릭 시 자동완성 숨기기
        $(document).on('click', function(e) {
            if (!$(e.target).closest('#searchKeyword, #searchSuggestions').length) {
                hideSearchSuggestions();
            }
        });
    });
    
    // 검색 자동완성 로드
    function loadSearchSuggestions(query, searchType) {
        $.ajax({
            url: '${pageContext.request.contextPath}/md/api/search-suggestions',
            method: 'GET',
            data: {
                keyword: query,
                searchType: searchType
            },
            success: function(response) {
                if (response.success) {
                    displaySearchSuggestions(response.suggestions);
                }
            },
            error: function() {
                hideSearchSuggestions();
            }
        });
    }
    
    // 검색 자동완성 표시
    function displaySearchSuggestions(suggestions) {
        const container = $('#searchSuggestions');
        container.empty();
        
        if (suggestions && suggestions.length > 0) {
            suggestions.forEach(function(suggestion) {
                const item = $('<div class="search-suggestion-item"></div>')
                    .data('text', suggestion.text)
                    .html(
                        '<span class="suggestion-type">[' + suggestion.type + ']</span>' +
                        '<span class="suggestion-text">' + suggestion.text + '</span>' +
                        (suggestion.detail ? '<span class="suggestion-detail">' + suggestion.detail + '</span>' : '')
                    );
                container.append(item);
            });
            container.show();
        } else {
            hideSearchSuggestions();
        }
    }
    
    // 검색 자동완성 숨기기
    function hideSearchSuggestions() {
        $('#searchSuggestions').hide();
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

    // 관리자 권한 확인
    function checkAdminPermission() {
        const token = localStorage.getItem('accessToken');
        if (!token) {
            console.log('토큰이 없음 - 관리자 버튼 숨김');
            $('#admin-md-add').hide();
            $('.clubmd-md-admin-actions').hide();
            return;
        }
        
        try {
            // JWT 토큰 파싱
            const payload = JSON.parse(atob(token.split('.')[1]));
            
            // 관리자 권한 확인 (provider가 'admin'인 경우만)
            const isAdmin = payload.provider === 'admin';
            
            if (isAdmin) {
                $('#admin-md-add').show();
                $('.clubmd-md-admin-actions').show();
            } else {
                // 일반 사용자 - 관리자 버튼 숨김
                $('#admin-md-add').hide();
                $('.clubmd-md-admin-actions').hide();
            }
        } catch (error) {
            // JWT 토큰 파싱 실패
            $('#admin-md-add').hide();
            $('.clubmd-md-admin-actions').hide();
        }
    }

    // MD 추가 모달 열기
    function openMdAddModal() {
        // 관리자 권한 재확인
        const token = localStorage.getItem('accessToken');
        if (!token) {
            showError('로그인이 필요합니다.');
            return;
        }
        
        try {
            const payload = JSON.parse(atob(token.split('.')[1]));
            const isAdmin = payload.provider === 'admin';
            
            if (!isAdmin) {
                showError('관리자 권한이 필요합니다.');
                return;
            }
        } catch (error) {
            showError('권한 확인에 실패했습니다.');
            return;
        }
        
        // 폼 초기화
        document.getElementById('mdAddForm').reset();
        document.getElementById('isVisible').checked = true;
        selectedPlaceId = null;
        
        // 모달 표시
        const modal = document.getElementById('mdAddModal');
        modal.style.display = 'flex';
        modal.classList.add('show');
    }

    // 가게 검색
    function searchHotplaces(query) {
        $.ajax({
            url: '${pageContext.request.contextPath}/md/api/hotplaces/search',
            method: 'GET',
            data: { keyword: query },
            success: function(response) {
                if (response.success) {
                    displaySearchResults(response.hotplaces);
                } else {
                    hideSearchResults();
                }
            },
            error: function() {
                hideSearchResults();
            }
        });
    }
    
    // 검색 결과 표시
    function displaySearchResults(hotplaces) {
        const resultsContainer = document.getElementById('placeSearchResults');
        
        if (hotplaces.length === 0) {
            resultsContainer.innerHTML = '<div class="search-result-item">검색 결과가 없습니다.</div>';
        } else {
            let html = '';
            hotplaces.forEach(function(hotplace) {
                html += '<div class="search-result-item" data-place-id="' + hotplace.placeId + '" data-place-name="' + hotplace.placeName + '">' +
                    '<div class="place-name">' + hotplace.placeName + '</div>' +
                    '<div class="place-address">' + hotplace.placeAddress + '</div>' +
                '</div>';
            });
            resultsContainer.innerHTML = html;
            
            // 검색 결과 클릭 이벤트
            resultsContainer.querySelectorAll('.search-result-item').forEach(function(item) {
                item.addEventListener('click', function() {
                    const placeId = this.getAttribute('data-place-id');
                    const placeName = this.getAttribute('data-place-name');
                    
                    document.getElementById('placeId').value = placeName;
                    selectedPlaceId = placeId;
                    hideSearchResults();
                });
            });
        }
        
        resultsContainer.style.display = 'block';
    }
    
    // 검색 결과 숨기기
    function hideSearchResults() {
        document.getElementById('placeSearchResults').style.display = 'none';
    }

    // MD 추가 모달 닫기
    function closeMdAddModal() {
        const modal = document.getElementById('mdAddModal');
        modal.style.display = 'none';
        modal.classList.remove('show');
    }

    // MD 추가 제출
    function submitMdAdd() {
        const form = document.getElementById('mdAddForm');
        const formData = new FormData(form);
        
        // 필수 필드 검증
        const mdName = document.getElementById('mdName').value.trim();
        
        if (!mdName) {
            showError('MD 이름을 입력해주세요.');
            return;
        }
        
        if (!selectedPlaceId) {
            showError('가게를 선택해주세요.');
            return;
        }
        
        // 토큰 가져오기
        const token = localStorage.getItem('accessToken');
        if (!token) {
            showError('로그인이 필요합니다.');
            return;
        }
        
        // 버튼 비활성화
        const submitBtn = document.querySelector('#mdAddModal .btn-primary');
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="bi bi-hourglass-split me-1"></i>추가 중...';
        
        // FormData에 placeId 추가
        formData.set('placeId', selectedPlaceId);
        
        // AJAX 요청
        $.ajax({
            url: '${pageContext.request.contextPath}/md/api/add',
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + token
            },
            data: formData,
            processData: false,
            contentType: false,
            success: function(response) {
                if (response.success) {
                    showToast('MD가 성공적으로 추가되었습니다!', 'success');
                    closeMdAddModal();
                    loadMds(currentPage, currentSort); // 목록 새로고침
                } else {
                    showError(response.message || 'MD 추가에 실패했습니다.');
                }
            },
            error: function(xhr, status, error) {
                console.error('MD 추가 오류:', error);
                showError('서버 오류가 발생했습니다.');
            },
            complete: function() {
                // 버튼 복원
                submitBtn.disabled = false;
                submitBtn.innerHTML = '<i class="bi bi-check-circle me-1"></i>MD 추가';
            }
        });
    }

    // MD 수정 모달 열기
    function openMdEditModal(mdId) {
        // 관리자 권한 재확인
        const token = localStorage.getItem('accessToken');
        if (!token) {
            showError('로그인이 필요합니다.');
            return;
        }
        
        try {
            const payload = JSON.parse(atob(token.split('.')[1]));
            if (payload.provider !== 'admin') {
                showError('관리자 권한이 필요합니다.');
                return;
            }
        } catch (error) {
            showError('권한 확인에 실패했습니다.');
            return;
        }
        
        // MD 정보 로드
        loadMdForEdit(mdId);
        
        // 모달 표시
        const modal = document.getElementById('mdEditModal');
        modal.style.display = 'flex';
        modal.classList.add('show');
    }

    // MD 수정 모달 닫기
    function closeMdEditModal() {
        const modal = document.getElementById('mdEditModal');
        modal.style.display = 'none';
        modal.classList.remove('show');
    }

    // MD 정보 로드 (수정용)
    function loadMdForEdit(mdId) {
        $.ajax({
            url: '${pageContext.request.contextPath}/md/api/' + mdId,
            method: 'GET',
            success: function(response) {
                if (response.success) {
                    const md = response.md;
                    document.getElementById('editMdName').value = md.mdName;
                    document.getElementById('editContact').value = md.contact || '';
                    document.getElementById('editDescription').value = md.description || '';
                    document.getElementById('editIsVisible').checked = md.isVisible;
                    
                    // 가게 정보 설정
                    document.getElementById('editPlaceId').value = md.placeName;
                    selectedEditPlaceId = md.placeId;
                    
                    // 현재 수정 중인 MD ID 저장
                    currentEditMdId = mdId;
                } else {
                    showError('MD 정보를 불러오는데 실패했습니다.');
                }
            },
            error: function() {
                showError('MD 정보를 불러오는데 실패했습니다.');
            }
        });
    }

    // MD 수정 제출
    function submitMdEdit() {
        const form = document.getElementById('mdEditForm');
        const formData = new FormData(form);
        
        // 필수 필드 검증
        const mdName = document.getElementById('editMdName').value.trim();
        
        if (!mdName) {
            showError('MD 이름을 입력해주세요.');
            return;
        }
        
        if (!selectedEditPlaceId) {
            showError('가게를 선택해주세요.');
            return;
        }
        
        // 토큰 가져오기
        const token = localStorage.getItem('accessToken');
        if (!token) {
            showError('로그인이 필요합니다.');
            return;
        }
        
        // 버튼 비활성화
        const submitBtn = document.querySelector('#mdEditModal .btn-primary');
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="bi bi-hourglass-split me-1"></i>수정 중...';
        
        // FormData에 placeId 추가
        formData.set('placeId', selectedEditPlaceId);
        
        // AJAX 요청
        $.ajax({
            url: '${pageContext.request.contextPath}/md/api/edit/' + currentEditMdId,
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + token
            },
            data: formData,
            processData: false,
            contentType: false,
            success: function(response) {
                if (response.success) {
                    showToast('MD가 성공적으로 수정되었습니다!', 'success');
                    closeMdEditModal();
                    loadMds(currentPage, currentSort); // 목록 새로고침
                } else {
                    showError(response.message || 'MD 수정에 실패했습니다.');
                }
            },
            error: function(xhr, status, error) {
                console.error('MD 수정 오류:', error);
                showError('서버 오류가 발생했습니다.');
            },
            complete: function() {
                // 버튼 복원
                submitBtn.disabled = false;
                submitBtn.innerHTML = '<i class="bi bi-check-circle me-1"></i>수정 완료';
            }
        });
    }

    // MD 수정용 변수들
    let selectedEditPlaceId = null;
    let currentEditMdId = null;
    let editSearchTimeout = null;
    
    // MD 수정용 가게 검색 이벤트 리스너
    document.getElementById('editPlaceId').addEventListener('input', function() {
        const query = this.value.trim();
        
        if (editSearchTimeout) {
            clearTimeout(editSearchTimeout);
        }
        
        if (query.length >= 2) {
            editSearchTimeout = setTimeout(() => {
                searchHotplacesForEdit(query);
            }, 300);
        } else {
            hideEditSearchResults();
            selectedEditPlaceId = null;
        }
    });
    
    // MD 수정용 가게 검색
    function searchHotplacesForEdit(query) {
        $.ajax({
            url: '${pageContext.request.contextPath}/md/api/hotplaces/search',
            method: 'GET',
            data: { keyword: query },
            success: function(response) {
                if (response.success) {
                    displayEditSearchResults(response.hotplaces);
                } else {
                    hideEditSearchResults();
                }
            },
            error: function() {
                hideEditSearchResults();
            }
        });
    }
    
    // MD 수정용 검색 결과 표시
    function displayEditSearchResults(hotplaces) {
        const resultsContainer = document.getElementById('editPlaceSearchResults');
        
        if (hotplaces.length === 0) {
            resultsContainer.innerHTML = '<div class="search-result-item">검색 결과가 없습니다.</div>';
        } else {
            let html = '';
            hotplaces.forEach(function(hotplace) {
                html += '<div class="search-result-item" data-place-id="' + hotplace.placeId + '" data-place-name="' + hotplace.placeName + '">' +
                    '<div class="place-name">' + hotplace.placeName + '</div>' +
                    '<div class="place-address">' + hotplace.placeAddress + '</div>' +
                '</div>';
            });
            resultsContainer.innerHTML = html;
            
            // 검색 결과 클릭 이벤트
            resultsContainer.querySelectorAll('.search-result-item').forEach(function(item) {
                item.addEventListener('click', function() {
                    const placeId = this.getAttribute('data-place-id');
                    const placeName = this.getAttribute('data-place-name');
                    
                    document.getElementById('editPlaceId').value = placeName;
                    selectedEditPlaceId = placeId;
                    hideEditSearchResults();
                });
            });
        }
        
        resultsContainer.style.display = 'block';
    }
    
    // MD 수정용 검색 결과 숨기기
    function hideEditSearchResults() {
        document.getElementById('editPlaceSearchResults').style.display = 'none';
    }
    
    // MD 삭제 관련 변수
    let deleteMdId = null;
    
    // MD 삭제 모달 열기
    function deleteMd(mdId, mdName) {
        // 관리자 권한 재확인
        const token = localStorage.getItem('accessToken');
        if (!token) {
            showError('로그인이 필요합니다.');
            return;
        }
        
        try {
            const payload = JSON.parse(atob(token.split('.')[1]));
            if (payload.provider !== 'admin') {
                showError('관리자 권한이 필요합니다.');
                return;
            }
        } catch (error) {
            showError('권한 확인에 실패했습니다.');
            return;
        }
        
        deleteMdId = mdId;
        document.getElementById('deleteMdName').textContent = mdName;
        
        const modal = document.getElementById('mdDeleteModal');
        modal.style.display = 'flex';
        modal.classList.add('show');
    }
    
    // MD 삭제 모달 닫기
    function closeMdDeleteModal() {
        const modal = document.getElementById('mdDeleteModal');
        modal.style.display = 'none';
        modal.classList.remove('show');
        deleteMdId = null;
    }
    
    // MD 삭제 확인
    function confirmDeleteMd() {
        if (!deleteMdId) {
            showError('삭제할 MD 정보가 없습니다.');
            return;
        }
        
        const token = localStorage.getItem('accessToken');
        if (!token) {
            showError('로그인이 필요합니다.');
            return;
        }
        
        // 삭제 버튼 비활성화
        const deleteBtn = document.querySelector('#mdDeleteModal .btn-danger');
        deleteBtn.disabled = true;
        deleteBtn.innerHTML = '<i class="bi bi-hourglass-split me-1"></i>삭제 중...';
        
        $.ajax({
            url: '${pageContext.request.contextPath}/md/api/delete/' + deleteMdId,
            method: 'DELETE',
            headers: {
                'Authorization': 'Bearer ' + token,
                'Content-Type': 'application/json'
            },
            success: function(response) {
                if (response.success) {
                    showToast('MD가 성공적으로 삭제되었습니다!', 'success');
                    closeMdDeleteModal();
                    loadMds(currentPage, currentSort); // 목록 새로고침
                } else {
                    showError(response.message || 'MD 삭제에 실패했습니다.');
                }
            },
            error: function(xhr, status, error) {
                console.error('MD 삭제 오류:', error);
                if (xhr.status === 403) {
                    showError('관리자 권한이 필요합니다.');
                } else if (xhr.status === 404) {
                    showError('삭제할 MD를 찾을 수 없습니다.');
                } else {
                    showError('MD 삭제 중 오류가 발생했습니다.');
                }
            },
            complete: function() {
                // 버튼 상태 복원
                deleteBtn.disabled = false;
                deleteBtn.innerHTML = '<i class="bi bi-trash me-1"></i>삭제';
            }
        });
    }
    
    // 카카오톡 오픈채팅 링크 열기
    function openKakaoChat() {
        const kakaoChatUrl = 'https://open.kakao.com/o/s5nnTWQh';
        window.open(kakaoChatUrl, '_blank');
    }

    // 연락처 클릭 처리 (카카오톡 오픈채팅 등)
    function openContact(contact) {
        if (!contact) {
            return;
        }
        
        // 카카오톡 오픈채팅 링크인지 확인
        if (contact.includes('open.kakao.com') || contact.includes('kakaotalk://')) {
            // 카카오톡 링크인 경우 새 창에서 열기
            window.open(contact, '_blank');
        } else if (contact.startsWith('http://') || contact.startsWith('https://')) {
            // 일반 URL인 경우 새 창에서 열기
            window.open(contact, '_blank');
        } else if (contact.includes('@')) {
            // 이메일인 경우
            window.location.href = 'mailto:' + contact;
        } else if (contact.match(/^[0-9-+\s()]+$/)) {
            // 전화번호인 경우
            window.location.href = 'tel:' + contact;
        } else {
            // 기타 텍스트인 경우 클립보드에 복사
            navigator.clipboard.writeText(contact).then(function() {
                showToast('연락처가 클립보드에 복사되었습니다: ' + contact, 'info');
            }).catch(function() {
                showToast('연락처: ' + contact, 'info');
            });
        }
    }
</script>