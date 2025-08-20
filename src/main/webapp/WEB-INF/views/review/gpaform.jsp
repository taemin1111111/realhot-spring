<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- Spring REST API 방식으로 변환: Model1 DAO/DTO 제거 --%>

<%
    String root = request.getContextPath();
%>

<div class="main-container text-white" id="review-container">
    <!-- 지역별 평점 데이터는 REST API를 통해 동적으로 로드됩니다 -->
    <div class="loading">지역 데이터를 불러오는 중...</div>
</div>

<jsp:include page="reviewModal.jsp" />

<div id="toast" style="position:fixed; top:20px; left:50%; transform:translateX(-50%); z-index:9999; display:none; padding:10px 20px; color:white; border-radius:5px;"></div>

<script>
const root = "<%=root%>";
let currentRegion = "";
let currentIsSigungu = false;
let regionNameList = []; // 자동완성용 지역명 목록
let regionMap = {}; // 지역 계층 구조

// 페이지 로드 시 지역 데이터 로드
document.addEventListener('DOMContentLoaded', function() {
    loadRegionStructure();
    loadRegionNames();
});

// REST API를 통한 지역 구조 데이터 로드
function loadRegionStructure() {
    // 지역 계층 구조 API가 없으므로 간단한 구조로 대체
    renderRegionInterface();
}

// REST API를 통한 지역명 목록 로드
function loadRegionNames() {
    const url = root + '/api/reviews/regions/names';
    
    fetch(url, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('지역명을 불러올 수 없습니다.');
        }
        return response.json();
    })
    .then(data => {
        regionNameList = data || [];
        console.log('지역명 로드 완료:', regionNameList.length + '개');
    })
    .catch(error => {
        console.error('지역명 로드 실패:', error);
        regionNameList = []; // 빈 배열로 초기화
    });
}

// 지역 인터페이스 렌더링
function renderRegionInterface() {
    const html = `
        <div class="section-title mb-4">
            <img src="${root}/logo/fire.png"> <span style="color: white;">지역별 평점 보기</span>
        </div>
        
        <div class="search-box input-group mb-4" style="position: relative;">
            <input type="text" class="form-control" placeholder="지역명을 검색하세요" id="searchInput">
            <button class="btn btn-outline-light" type="button" onclick="searchRegion()">
                <i class="bi bi-search"></i>
            </button>
            <!-- 자동완성 드롭다운 -->
            <div id="autocompleteList" style="position: absolute; top: 100%; left: 0; right: 0; background: white; border: 1px solid #ddd; border-radius: 0 0 8px 8px; max-height: 200px; overflow-y: auto; z-index: 1000; display: none; box-shadow: 0 4px 8px rgba(0,0,0,0.1);"></div>
            </div>
            
        <!-- 주요 지역 빠른 선택 -->
        <div class="quick-regions mb-4">
            <h5 style="color: white; margin-bottom: 15px;">🔥 인기 지역</h5>
            <div class="row">
                <div class="col-md-3 mb-2">
                    <button class="btn btn-outline-light w-100" onclick="loadRegionData('강남구', true)">강남구</button>
                </div>
                <div class="col-md-3 mb-2">
                    <button class="btn btn-outline-light w-100" onclick="loadRegionData('홍대', false)">홍대</button>
                </div>
                <div class="col-md-3 mb-2">
                    <button class="btn btn-outline-light w-100" onclick="loadRegionData('명동', false)">명동</button>
                </div>
                <div class="col-md-3 mb-2">
                    <button class="btn btn-outline-light w-100" onclick="loadRegionData('이태원', false)">이태원</button>
                </div>
                <div class="col-md-3 mb-2">
                    <button class="btn btn-outline-light w-100" onclick="loadRegionData('신사동', false)">신사동</button>
                </div>
                <div class="col-md-3 mb-2">
                    <button class="btn btn-outline-light w-100" onclick="loadRegionData('연남동', false)">연남동</button>
                </div>
                <div class="col-md-3 mb-2">
                    <button class="btn btn-outline-light w-100" onclick="loadRegionData('성수동', false)">성수동</button>
                </div>
                <div class="col-md-3 mb-2">
                    <button class="btn btn-outline-light w-100" onclick="loadRegionData('건대', false)">건대</button>
                </div>
            </div>
        </div>

        <div id="result-box" class="mt-5"></div>
    `;
    
    document.getElementById('review-container').innerHTML = html;
    
    // 이벤트 리스너 등록
    setupEventListeners();
}

// 이벤트 리스너 설정
function setupEventListeners() {
    const searchInput = document.getElementById('searchInput');
    const autocompleteList = document.getElementById('autocompleteList');
    
    if (searchInput) {
        // 입력 시 자동완성 표시
        searchInput.addEventListener('input', showAutocompleteList);
        searchInput.addEventListener('focus', showAutocompleteList);
        
        // 포커스 아웃 시 자동완성 숨김
        searchInput.addEventListener('blur', function() {
            setTimeout(function() { 
                if (autocompleteList) {
                    autocompleteList.style.display = 'none'; 
                }
            }, 120);
        });
        
        // Enter 키로 검색
        searchInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                searchRegion();
            }
        });
    }
}

// 지역 데이터 로드 (Spring API 호출)
function loadRegionData(region, isSigungu, event) {
    if (event) event.preventDefault();
    
    currentRegion = region;
    currentIsSigungu = isSigungu;

    const url = root + "/api/reviews/regions/data?region=" + encodeURIComponent(region) + "&isSigungu=" + isSigungu;
    
    fetch(url, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('지역 데이터를 불러올 수 없습니다.');
        }
        return response.json();
    })
    .then(data => {
        renderRegionData(data, region);
        // 스크롤 이동
        const resultBox = document.getElementById("result-box");
        if (resultBox) {
            resultBox.scrollIntoView({ behavior: "smooth" });
        }
    })
    .catch(error => {
        console.error("지역 데이터 불러오기 실패:", error);
        document.getElementById("result-box").innerHTML = 
            '<div class="alert alert-warning">지역 데이터를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.</div>';
    });
}

// 지역 데이터 렌더링
function renderRegionData(data, region) {
    const reviews = data.reviews || [];
    const avgRating = data.avgRating || 0;
    const totalCount = data.totalCount || 0;
    
    let html = `
        <div class="region-data-container">
            <div class="region-header mb-4">
                <h3 style="color: white;">📍 ${region}</h3>
                <div class="region-stats">
                    <span class="badge bg-warning text-dark me-2">⭐ ${avgRating.toFixed(1)}점</span>
                    <span class="badge bg-info text-dark">총 ${totalCount}개 리뷰</span>
                </div>
            </div>
            
            <!-- 카테고리 필터 -->
            <div class="category-filters mb-4">
                <button class="btn btn-outline-light custom-filter filter-btn active" data-category="0" onclick="filterReviews(0)">전체</button>
                <button class="btn btn-outline-light custom-filter filter-btn" data-category="1" onclick="filterReviews(1)">맛집</button>
                <button class="btn btn-outline-light custom-filter filter-btn" data-category="2" onclick="filterReviews(2)">카페</button>
                <button class="btn btn-outline-light custom-filter filter-btn" data-category="3" onclick="filterReviews(3)">술집</button>
                <button class="btn btn-outline-light custom-filter filter-btn" data-category="4" onclick="filterReviews(4)">관광지</button>
            </div>
            
            <!-- 리뷰 작성 버튼 -->
            <div class="review-write-section mb-4">
                <button class="btn btn-primary" onclick="openReviewModal('${region}', ${isSigungu})">
                    ✏️ 리뷰 작성하기
                </button>
            </div>
            
            <!-- 리뷰 목록 -->
            <div class="reviews-list">`;
    
    if (reviews.length === 0) {
        html += `
                <div class="no-reviews text-center py-5">
                    <h5 style="color: white;">📝 첫 번째 리뷰를 작성해보세요!</h5>
                    <p style="color: #ccc;">아직 이 지역에 대한 리뷰가 없습니다.</p>
                </div>`;
    } else {
        reviews.forEach(review => {
            const stars = '⭐'.repeat(review.stars || 1);
            const formattedDate = formatDate(review.createdAt || review.sysdate);
            
            html += `
                <div class="review-item mb-3 p-3" style="background: rgba(255,255,255,0.1); border-radius: 8px;">
                    <div class="review-header d-flex justify-content-between align-items-center mb-2">
                        <div>
                            <span class="stars">${stars}</span>
                            <span class="reviewer-name ms-2" style="color: #ffd700;">${review.nickname || review.authorId || '익명'}</span>
                        </div>
                        <small style="color: #ccc;">${formattedDate}</small>
                    </div>
                    <div class="review-content mb-2" style="color: white;">
                        ${review.content || review.review || '내용 없음'}
                    </div>
                    <div class="review-actions">
                        <button class="btn btn-sm btn-outline-light" onclick="recommendReview(${review.num || review.id})">
                            👍 추천 <span id="good-count-${review.num || review.id}">${review.good || review.recommendCount || 0}</span>
                        </button>
                    </div>
                </div>`;
        });
    }
    
    html += `
            </div>
        </div>`;
    
    document.getElementById("result-box").innerHTML = html;
}

// 카테고리별 리뷰 필터링
function filterReviews(categoryId) {
    // 버튼 active 토글
    document.querySelectorAll(".custom-filter")
            .forEach(function(btn) { btn.classList.remove("active"); });
    const btn = document.querySelector('.filter-btn[data-category="' + categoryId + '"]');
    if (btn) btn.classList.add("active");

    const url = root + "/api/reviews/regions/data"
              + "?region=" + encodeURIComponent(currentRegion)
              + "&isSigungu=" + currentIsSigungu
              + "&category=" + categoryId;

    fetch(url, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        renderRegionData(data, currentRegion);
    })
    .catch(error => {
        console.error("필터링 데이터 불러오기 실패:", error);
        showToast("필터링 중 오류가 발생했습니다.", "error");
    });
}

// 리뷰 추천 (Spring API 호출)
function recommendReview(reviewNum) {
    const url = root + "/api/reviews/" + reviewNum + "/recommend";
    
    fetch(url, {
        method: "POST",
        headers: {
            'Content-Type': 'application/json'
        },
        credentials: "same-origin"
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            const countElement = document.getElementById("good-count-" + reviewNum);
            if (countElement) {
                countElement.innerText = data.good;
            }
            showToast("추천 완료!", "success");
        } else {
            showToast(data.message || "추천 실패", "error");
        }
    })
    .catch(error => {
        console.error("추천 오류:", error);
        showToast("서버 오류가 발생했습니다.", "error");
    });
}

// 리뷰 모달 열기
function openReviewModal(region, isSigungu) {
    const hgIdInput = document.getElementById("hgIdInput");
    const regionInput = document.getElementById("regionInput");
    const isSigunguInput = document.getElementById("isSigunguInput");
    
    if (hgIdInput) hgIdInput.value = region;
    if (regionInput) regionInput.value = region;
    if (isSigunguInput) isSigunguInput.value = isSigungu;
    
    const modalElement = document.getElementById('reviewModal');
    if (modalElement && typeof bootstrap !== 'undefined') {
        const modal = new bootstrap.Modal(modalElement);
        modal.show();
    } else {
        // Bootstrap이 없는 경우 간단한 alert
        alert('리뷰 작성 기능을 준비 중입니다.');
    }
}

// 자동완성 기능
function showAutocompleteList() {
    const searchInput = document.getElementById('searchInput');
    const autocompleteList = document.getElementById('autocompleteList');
    
    if (!searchInput || !autocompleteList) return;
    
    const keyword = searchInput.value.trim();
    
    if (!keyword) { 
        autocompleteList.style.display = 'none'; 
        return; 
    }
    
    // 지역명에서 키워드와 일치하는 항목 필터링
    const filtered = regionNameList.filter(function(item) {
        return item && item.toLowerCase().indexOf(keyword.toLowerCase()) !== -1;
    }).slice(0, 8); // 최대 8개
    
    if (filtered.length === 0) { 
        autocompleteList.style.display = 'none'; 
        return; 
    }
    
    // 자동완성 리스트 생성
    autocompleteList.innerHTML = filtered.map(function(item) {
        return '<div class="autocomplete-item" style="padding:10px 18px; font-size:1.04rem; color:#222 !important; cursor:pointer; transition:background 0.13s; border-bottom:1px solid #f3f3f3; background:transparent;">' + item + '</div>';
    }).join('');
    
    autocompleteList.style.display = 'block';
    
    // 항목 클릭 시 입력창에 반영
    Array.from(autocompleteList.children).forEach(function(child) {
        child.onclick = function() {
            searchInput.value = child.textContent;
            autocompleteList.style.display = 'none';
            searchRegion(); // 자동으로 검색 실행
        };
    });
}

// 검색 기능
function searchRegion() {
    const searchInput = document.getElementById('searchInput');
    if (!searchInput) return;
    
    const keyword = searchInput.value.trim();
    if (!keyword) {
        showToast("지역명을 입력해주세요.", "error");
        return;
    }
    
    // 지역명에서 정확히 일치하는 항목 찾기
    const foundRegion = regionNameList.find(function(item) {
        return item && item.toLowerCase() === keyword.toLowerCase();
    });
    
    if (foundRegion) {
        // 지역 데이터 로드 (동으로 처리)
        loadRegionData(foundRegion, false);
        const autocompleteList = document.getElementById('autocompleteList');
        if (autocompleteList) {
            autocompleteList.style.display = 'none';
        }
    } else {
        showToast("해당 지역을 찾을 수 없습니다.", "error");
    }
}

// 토스트 메시지 표시
function showToast(msg, type) {
    const toast = document.getElementById("toast");
    if (!toast) return;
    
    toast.innerText = msg;
    toast.style.backgroundColor = type === "success" ? "#28a745" : "#dc3545";
    toast.style.display = "block";
    setTimeout(function() {
        toast.style.display = "none";
    }, 2000);
}

// 날짜 포맷팅
function formatDate(dateString) {
    if (!dateString) return '';
    
    const date = new Date(dateString);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    
    return `${year}-${month}-${day}`;
}

// 자동완성 아이템 호버 효과
const style = document.createElement('style');
style.innerHTML = `.autocomplete-item:hover { background: #f0f4fa !important; color: #1275E0 !important; }`;
document.head.appendChild(style);
</script>