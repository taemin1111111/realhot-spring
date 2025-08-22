<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    String nickname = (String)session.getAttribute("nickname");
    String provider = (String)session.getAttribute("provider");
%>

<!-- MD 전용 CSS -->
<link rel="stylesheet" href="<%=root%>/css/md.css">

<div class="md-container">
    
    <!-- 신뢰도 표시 섹션 -->
    <div class="md-trust-section">
        <div class="md-trust-grid">
            <div class="md-trust-item">
                <div class="md-trust-icon">
                    <i class="bi bi-shield-check"></i>
                </div>
                <div class="md-trust-title">검증된 MD</div>
                <div class="md-trust-desc">모든 MD는 신원이 확인된 검증된 MD입니다</div>
            </div>
            <div class="md-trust-item">
                <div class="md-trust-icon">
                    <i class="bi bi-lock"></i>
                </div>
                <div class="md-trust-title">안전한 예약</div>
                <div class="md-trust-desc">개인정보 보호 및 안전한 예약 시스템</div>
            </div>
            <div class="md-trust-item">
                <div class="md-trust-icon">
                    <i class="bi bi-star"></i>
                </div>
                <div class="md-trust-title">고객 만족</div>
                <div class="md-trust-desc">높은 고객 만족도와 신뢰받는 서비스</div>
            </div>
        </div>
    </div>
    
    <!-- 검색 및 정렬 섹션 -->
    <div class="md-search-section">
        <div class="row g-3 align-items-center">
            <div class="col-md-3">
                <select id="searchType" class="form-select">
                    <option value="all">전체 검색</option>
                    <option value="mdName">MD명 검색</option>
                    <option value="placeName">장소명 검색</option>
                </select>
            </div>
            <div class="col-md-4">
                <div class="input-group">
                    <input type="text" id="searchKeyword" class="form-control" placeholder="검색어를 입력하세요...">
                    <button class="btn btn-outline-primary" onclick="searchMds()">
                        <i class="bi bi-search"></i>
                    </button>
                </div>
            </div>
            <div class="col-md-3">
                <select id="sortOption" class="form-select" onchange="searchMds()">
                    <option value="latest">최신순</option>
                    <option value="popular">인기순 (찜 많은순)</option>
                </select>
            </div>
            <div class="col-md-3">
                <% if("admin".equals(provider)) { %>
                    <button type="button" class="btn btn-success w-100" data-bs-toggle="modal" data-bs-target="#mdRegisterModal">
                        <i class="bi bi-plus-circle me-2"></i> MD 등록
                    </button>
                <% } %>
            </div>
        </div>
    </div>
    
    <!-- MD 카드 섹션 -->
    <div class="md-cards-section mt-4">
        <!-- MD 목록 컨테이너 -->
        <div id="mdListContainer">
            <div class="loading text-center py-5">
                <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">로딩중...</span>
                </div>
                <p class="mt-2">MD 목록을 불러오는 중...</p>
            </div>
        </div>
        
        <!-- 페이지네이션 -->
        <nav id="paginationContainer" class="mt-4" style="display: none;">
            <ul class="pagination justify-content-center" id="pagination">
            </ul>
        </nav>
        
        <!-- 페이지 정보 -->
        <div id="pageInfo" class="text-center text-muted mt-2" style="display: none;">
        </div>
    </div>
</div>

<!-- MD 등록 모달 -->
<div class="modal fade md-modal" id="mdRegisterModal" tabindex="-1" aria-labelledby="mdRegisterModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="mdRegisterModalLabel">MD 등록</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="mdRegisterForm" enctype="multipart/form-data">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="mdName" class="form-label">MD 이름 *</label>
                                <input type="text" class="form-control" id="mdName" name="mdName" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="placeSearch" class="form-label">장소 검색 *</label>
                                <div class="position-relative">
                                    <input type="text" class="form-control" id="placeSearch" 
                                           placeholder="장소명을 입력하세요" autocomplete="off">
                                    <input type="hidden" id="placeId" name="placeId" required>
                                    <div id="placeSearchResults" class="list-group position-absolute w-100" 
                                         style="z-index: 1050; display: none;">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="contact" class="form-label">연락처</label>
                        <input type="text" class="form-control" id="contact" name="contact" 
                               placeholder="인스타 아이디 또는 오픈채팅 링크">
                    </div>
                    
                    <div class="mb-3">
                        <label for="description" class="form-label">소개</label>
                        <textarea class="form-control" id="description" name="description" rows="4" 
                                  placeholder="MD에 대한 간단한 소개나 특징을 적어주세요"></textarea>
                    </div>
                    
                    <div class="mb-3">
                        <label for="photo" class="form-label">사진</label>
                        <input type="file" class="form-control" id="photo" name="photo" accept="image/*">
                        <div class="form-text">선택사항입니다. MD 사진을 업로드해주세요.</div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" onclick="registerMd()">등록</button>
            </div>
        </div>
    </div>
</div>

<script>
let currentPage = 0;
let totalPages = 0;
let totalElements = 0;

// 페이지 로드시 초기화
$(document).ready(function() {
    loadMds();
    setupPlaceAutoComplete();
    
    // Enter 키 검색
    $('#searchKeyword').on('keypress', function(e) {
        if (e.which === 13) {
            searchMds();
        }
    });
    
    // 검색 자동완성 설정
    setupSearchAutocomplete();
});

// MD 목록 로드
function loadMds(page = 0) {
    const keyword = $('#searchKeyword').val();
    const sort = $('#sortOption').val();
    const searchType = $('#searchType').val();
    currentPage = page;

    const params = new URLSearchParams({
        page: page,
        size: 15
    });
    
    if (keyword) params.append('keyword', keyword);
    if (sort) params.append('sort', sort);
    if (searchType) params.append('searchType', searchType);
    
    const apiUrl = '<%=root%>/api/md?' + params.toString();


    
    // JWT 토큰을 헤더에 포함하여 API 호출
    const headers = {};
    const token = localStorage.getItem('accessToken');
    if (token) {
        headers['Authorization'] = 'Bearer ' + token;

    }
    
    $.ajax({
        url: apiUrl,
        method: 'GET',
        headers: headers,
        dataType: 'json',
        success: function(response) {

            if (response.success) {
                displayMds(response.mds || []);
                updatePagination(response.currentPage || 0, response.totalPages || 1, response.totalElements || 0);
            } else {
                showError('MD 목록을 불러오는데 실패했습니다.');
            }
        },
        error: function(xhr, status, error) {

            showError('MD 목록을 불러오는 중 오류가 발생했습니다.');
        }
    });
}

// MD 목록 표시
function displayMds(mds) {
    if (!mds || mds.length === 0) {
        $('#mdListContainer').html(
            '<div class="md-empty-state text-center py-5">' +
                '<div class="md-empty-icon">' +
                    '<i class="bi bi-exclamation-triangle display-1 text-muted"></i>' +
                '</div>' +
                '<h4 class="md-empty-title mt-3">등록된 MD가 없습니다</h4>' +
                '<p class="md-empty-description text-muted">현재 등록된 MD가 없습니다.</p>' +
                '<p class="md-empty-description text-muted">관리자에게 연락해서 MD 등록을 요청해주세요!</p>' +
            '</div>'
        );
        return;
    }


    
    // JWT 토큰 기반 로그인 상태 확인
    const token = localStorage.getItem('accessToken');
    const isLoggedIn = token && token !== 'null' && token !== '';

    
    let html = '<div class="md-cards-grid">';
    mds.forEach(function(md) {

        const isWished = md.isWished || false;
        const wishCount = md.wishCount || 0;

        
        // Model1과 동일한 구조로 변경
        html += '<div class="md-card">' +
                    '<div class="md-verified-badge">' +
                        '<i class="bi bi-shield-check me-1"></i>검증됨' +
                    '</div>';
                    
        // 하트 버튼 항상 표시 (찜 기능은 로그인 시에만 작동)

        html += '<button type="button" class="md-wish-btn ' + (isWished ? 'wished' : '') + '"' +
                ' onclick="toggleMdWish(' + md.mdId + ', this)"' +
                ' data-md-id="' + md.mdId + '"' +
                ' data-wished="' + isWished + '">' +
                    '<i class="bi ' + (isWished ? 'bi-heart-fill' : 'bi-heart') + '"></i>' +
                '</button>';
        
        html += '<div class="md-card-header">';
        if (md.photo && md.photo.trim() !== '') {
            html += '<img src="<%=root%>/uploads/mdphotos/' + md.photo + '" class="md-card-image" alt="MD 사진">';
        } else {
            html += '<div class="md-card-placeholder"><i class="bi bi-person-circle"></i></div>';
        }
        html += '</div>' +
                '<div class="md-card-body">' +
                    '<div class="md-card-title-row">' +
                        
                        '<h5 class="md-card-name">' + md.mdName + '</h5>' +
                        '<div class="md-wish-count">' +
                            '<i class="bi bi-heart-fill me-1"></i>' +
                            '<span class="wish-count-number">' + wishCount + '</span>' +
                        '</div>' +
                    '</div>' +
                    '<div class="md-card-location">' +
                        '<i class="bi bi-geo-alt"></i>' +
                        '<span class="md-card-place">' + (md.placeName || '장소 미정') + '</span>' +
                    '</div>' +
                    '<div class="md-card-address">' +
                        '<i class="bi bi-geo-alt-fill"></i>' +
                        '<span class="address-text">' + (md.address || '') + '</span>' +
                    '</div>';
                    
        if (md.contact && md.contact.trim() !== '') {
            html += '<div class="md-card-contact">' +
                        '<i class="bi bi-telephone"></i>' +
                        '<span class="md-card-contact-text">' + md.contact + '</span>' +
                    '</div>';
        }
        if (md.description && md.description.trim() !== '') {
            html += '<div class="md-card-description">' +
                        '<span class="description-text">연결주소: ' + md.description + '</span>' +
                    '</div>';
        }
        html += '</div>' +
            '</div>';
    });
    html += '</div>';

    $('#mdListContainer').html(html);
}

// 페이지네이션 업데이트
function updatePagination(currentPage, totalPages, totalElements) {
    const pageSize = 15;
    
    if (totalPages <= 1) {
        $('#paginationContainer').hide();
        $('#pageInfo').hide();
        return;
    }

    let html = '';
    
    // 이전 페이지
    if (currentPage > 0) {
        html += '<li class="page-item"><a class="page-link" href="#" onclick="loadMds(' + (currentPage - 1) + ')">이전</a></li>';
    } else {
        html += '<li class="page-item disabled"><span class="page-link">이전</span></li>';
    }
    
    // 페이지 번호들
    const startPage = Math.max(0, currentPage - 2);
    const endPage = Math.min(totalPages - 1, currentPage + 2);
    
    if (startPage > 0) {
        html += '<li class="page-item"><a class="page-link" href="#" onclick="loadMds(0)">1</a></li>';
        if (startPage > 1) {
            html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
        }
    }
    
    for (let i = startPage; i <= endPage; i++) {
        const active = i === currentPage ? ' active' : '';
        html += '<li class="page-item' + active + '"><a class="page-link" href="#" onclick="loadMds(' + i + ')">' + (i + 1) + '</a></li>';
    }
    
    if (endPage < totalPages - 1) {
        if (endPage < totalPages - 2) {
            html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
        }
        html += '<li class="page-item"><a class="page-link" href="#" onclick="loadMds(' + (totalPages - 1) + ')">' + totalPages + '</a></li>';
    }
    
    // 다음 페이지
    if (currentPage < totalPages - 1) {
        html += '<li class="page-item"><a class="page-link" href="#" onclick="loadMds(' + (currentPage + 1) + ')">다음</a></li>';
    } else {
        html += '<li class="page-item disabled"><span class="page-link">다음</span></li>';
    }

    $('#pagination').html(html);
    $('#paginationContainer').show();
    
    // 페이지 정보 표시
    const startItem = currentPage * pageSize + 1;
    const endItem = Math.min((currentPage + 1) * pageSize, totalElements);
    $('#pageInfo').html('<small>총 ' + totalElements + '개의 MD 중 ' + startItem + '-' + endItem + '번째</small>').show();
}

// 검색
function searchMds() {
    loadMds(0);
}

// MD 등록
function registerMd() {
    const form = document.getElementById('mdRegisterForm');
    const formData = new FormData(form);
    
    // 필수 필드 검증
    const mdName = formData.get('mdName');
    const placeId = formData.get('placeId');
    
    if (!mdName || !placeId) {
        showMessage('필수 항목을 모두 입력해주세요.', 'warning');
        return;
    }
    
    $.ajax({
        url: '<%=root%>/api/md/register',
        method: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function(response) {
            if (response.success) {
                showMessage('MD가 성공적으로 등록되었습니다.', 'success');
                $('#mdRegisterModal').modal('hide');
                $('#mdRegisterForm')[0].reset();
                $('#placeId').val('');
                loadMds(currentPage);
            } else {
                showMessage('MD 등록에 실패했습니다: ' + response.message, 'error');
            }
        },
        error: function() {
            showMessage('MD 등록 중 오류가 발생했습니다.', 'error');
        }
    });
}

// MD 찜 토글 - JWT 토큰 기반
function toggleMdWish(mdId, button) {

    
    // JWT 토큰 기반 로그인 확인
    const token = localStorage.getItem('accessToken');
    if (!token || token === 'null' || token === '') {
        showMessage('로그인이 필요합니다.', 'warning');
        return;
    }
    
    const isWished = $(button).attr('data-wished') === 'true';
    const method = isWished ? 'DELETE' : 'POST';
    

    $(button).prop('disabled', true);
    
    const apiUrl = '<%=root%>/api/md/' + mdId + '/wish';

    
    $.ajax({
        url: apiUrl,
        method: method,
        headers: {
            'Authorization': 'Bearer ' + token,
            'Content-Type': 'application/json'
        },
        dataType: 'json',
        success: function(response) {

            if (response.success) {
                const newWished = !isWished;
                $(button).attr('data-wished', newWished);
                

                if (newWished) {
                    $(button).addClass('wished');
                    $(button).find('i').removeClass('bi-heart').addClass('bi-heart-fill');
                } else {
                    $(button).removeClass('wished');
                    $(button).find('i').removeClass('bi-heart-fill').addClass('bi-heart');
                }
                
                $(button).prop('disabled', false);
                // alert 제거 - 사용자 경험 개선

            } else {

                showMessage(response.message, 'success');
                $(button).prop('disabled', false);
            }
        },
        error: function(xhr, status, error) {

            if (xhr.status === 401) {
                showMessage('로그인이 필요합니다.', 'warning');
            } else {
                showMessage('찜하기 처리 중 오류가 발생했습니다.', 'error');
            }
            $(button).prop('disabled', false);
        }
    });
}

// MD 상세보기
function viewMdDetail(mdId) {
    showMessage('MD 상세보기 기능 구현 예정입니다.', 'info');
}

// 장소 자동완성 설정
function setupPlaceAutoComplete() {
    $('#placeSearch').on('input', function() {
        const keyword = $(this).val();
        if (keyword.length >= 2) {
            searchPlaces(keyword);
        } else {
            $('#placeSearchResults').hide();
            $('#placeId').val('');
        }
    });

    // 외부 클릭시 자동완성 숨기기
    $(document).on('click', function(e) {
        if (!$(e.target).closest('#placeSearch, #placeSearchResults').length) {
            $('#placeSearchResults').hide();
        }
    });
}

// 장소 검색
function searchPlaces(keyword) {
    $.ajax({
        url: '<%=root%>/api/places/search?keyword=' + encodeURIComponent(keyword),
        method: 'GET',
        dataType: 'json',
        success: function(response) {
            if (response.success && response.places) {
                displayPlaceResults(response.places);
            }
        },
        error: function() {
            // 임시 더미 데이터 (장소 API가 없을 경우)
            const dummyPlaces = [
                {id: 1, name: '강남역 클럽', address: '서울 강남구'},
                {id: 2, name: '홍대 클럽', address: '서울 마포구'},
                {id: 3, name: '이태원 클럽', address: '서울 용산구'}
            ].filter(place => place.name.includes(keyword));
            displayPlaceResults(dummyPlaces);
        }
    });
}

// 장소 검색 결과 표시
function displayPlaceResults(places) {
    let html = '';
    places.forEach(function(place) {
        html += '<a href="#" class="list-group-item list-group-item-action" onclick="selectPlace(' + place.id + ', \'' + place.name + '\', \'' + (place.address || '') + '\')">' + place.name + (place.address ? ' - ' + place.address : '') + '</a>';
    });
    
    if (html) {
        $('#placeSearchResults').html(html).show();
    } else {
        $('#placeSearchResults').html('<div class="list-group-item">검색 결과가 없습니다.</div>').show();
    }
}

// 장소 선택
function selectPlace(id, name, address) {
    $('#placeId').val(id);
    $('#placeSearch').val(name + (address ? ' - ' + address : ''));
    $('#placeSearchResults').hide();
}

// 검색 자동완성 설정
function setupSearchAutocomplete() {
    let searchTimeout;
    
    $('#searchKeyword').on('input', function() {
        const keyword = $(this).val();
        const searchType = $('#searchType').val();
        
        clearTimeout(searchTimeout);
        
        if (keyword.length >= 2) {
            searchTimeout = setTimeout(function() {
                getSearchSuggestions(keyword, searchType);
            }, 300);
        } else {
            hideSearchSuggestions();
        }
    });
    
    // 외부 클릭시 자동완성 숨기기
    $(document).on('click', function(e) {
        if (!$(e.target).closest('#searchKeyword, .search-suggestions').length) {
            hideSearchSuggestions();
        }
    });
}

// 검색 제안 가져오기
function getSearchSuggestions(keyword, searchType) {
    const params = new URLSearchParams({
        keyword: keyword,
        searchType: searchType,
        limit: 5
    });
    
    const token = localStorage.getItem('accessToken');
    const headers = {};
    if (token) {
        headers['Authorization'] = 'Bearer ' + token;
    }
    
    $.ajax({
        url: '<%=root%>/api/md/suggestions?' + params.toString(),
        method: 'GET',
        headers: headers,
        dataType: 'json',
        success: function(response) {
            if (response.success && response.suggestions) {
                showSearchSuggestions(response.suggestions);
            }
        },
        error: function() {
            // 자동완성 실패시 조용히 무시
        }
    });
}

// 검색 제안 표시
function showSearchSuggestions(suggestions) {
    let html = '<div class="search-suggestions" style="position: absolute; top: 100%; left: 0; right: 0; background: white; border: 1px solid #ddd; border-radius: 8px; max-height: 300px; overflow-y: auto; z-index: 9999; box-shadow: 0 4px 12px rgba(0,0,0,0.15); margin-top: 2px;">';
    
    suggestions.forEach(function(suggestion, index) {
        let suggestionText = suggestion.suggestion || suggestion;
        let suggestionType = suggestion.type || '';
        let typeIcon = '';
        let typeLabel = '';
        
        if (suggestionType === 'mdName') {
            typeIcon = '<i class="bi bi-person-fill me-2 text-primary"></i>';
            typeLabel = '<small class="text-muted ms-auto">MD</small>';
        } else if (suggestionType === 'placeName') {
            typeIcon = '<i class="bi bi-geo-alt-fill me-2 text-success"></i>';
            typeLabel = '<small class="text-muted ms-auto">장소</small>';
        }
        
        let borderClass = index === suggestions.length - 1 ? '' : 'border-bottom: 1px solid #f0f0f0;';
        
        html += '<div class="suggestion-item d-flex align-items-center px-3 py-2" style="cursor: pointer; ' + borderClass + ' transition: all 0.2s ease; color: #212529;" onmouseover="this.style.backgroundColor=\'#e3f2fd\'; this.style.transform=\'translateX(2px)\';" onmouseout="this.style.backgroundColor=\'white\'; this.style.transform=\'translateX(0)\';" onclick="selectSuggestion(\'' + suggestionText.replace("'", "\\'") + '\')">' + 
                typeIcon + 
                '<span class="flex-grow-1 fw-medium" style="color: #212529;">' + suggestionText + '</span>' + 
                typeLabel + 
                '</div>';
    });
    
    html += '</div>';
    
    // 기존 제안 제거
    $('.search-suggestions').remove();
    
    // 검색 input 그룹에 상대 위치 설정하고 제안 추가
    $('#searchKeyword').closest('.input-group').css('position', 'relative').append(html);
}

// 검색 제안 선택
function selectSuggestion(suggestion) {
    $('#searchKeyword').val(suggestion);
    hideSearchSuggestions();
    searchMds();
}

// 검색 제안 숨기기
function hideSearchSuggestions() {
    $('.search-suggestions').remove();
}

// 사용자 친화적 메시지 표시
function showMessage(message, type = 'info') {
    // 기존 메시지 제거
    $('.toast-message').remove();
    
    let iconClass = '';
    let bgClass = '';
    
    switch(type) {
        case 'success':
            iconClass = 'bi-check-circle-fill';
            bgClass = 'bg-success';
            break;
        case 'error':
            iconClass = 'bi-exclamation-triangle-fill';
            bgClass = 'bg-danger';
            break;
        case 'warning':
            iconClass = 'bi-exclamation-circle-fill';
            bgClass = 'bg-warning';
            break;
        default:
            iconClass = 'bi-info-circle-fill';
            bgClass = 'bg-info';
    }
    
    const toastHtml = `
        <div class="toast-message position-fixed top-0 start-50 translate-middle-x mt-3" style="z-index: 10000;">
            <div class="alert ${bgClass} text-white d-flex align-items-center border-0 shadow" role="alert">
                <i class="bi ${iconClass} me-2"></i>
                <span>${message}</span>
                <button type="button" class="btn-close btn-close-white ms-auto" onclick="$(this).closest('.toast-message').remove()"></button>
            </div>
        </div>
    `;
    
    $('body').append(toastHtml);
    
    // 3초 후 자동 제거
    setTimeout(() => {
        $('.toast-message').fadeOut(300, function() {
            $(this).remove();
        });
    }, 3000);
}

// 오류 표시
function showError(message) {
    $('#mdListContainer').html(
        '<div class="alert alert-danger text-center">' +
            '<h5><i class="bi bi-exclamation-triangle"></i> 오류</h5>' +
            '<p>' + message + '</p>' +
            '<button class="btn btn-primary" onclick="loadMds()">다시 시도</button>' +
        '</div>'
    );
}
</script>