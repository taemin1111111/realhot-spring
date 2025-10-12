<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>오늘의 핫</title>
</head>
<body>

<div class="today-hot-section">
  <!-- 오늘의 핫 타이틀 -->
  <div class="today-hot-title">
    <img src="<%=request.getContextPath()%>/logo/fire.png" alt="핫 로고" class="fire-logo">
    <span class="title-text">오늘의 핫</span>
  </div>
  
  <!-- 랭킹 리스트 -->
  <div class="today-hot-list" id="todayHotList">
    <!-- 로딩 상태 -->
    <div class="loading-container">
      <div class="loading-spinner"></div>
      <span>랭킹 데이터 로딩 중..</span>
    </div>
  </div>
  
  <!-- 더보기 버튼 -->
  <button id="toggleButton" class="toggle-button" onclick="toggleRanking()">
    <span class="toggle-text">더보기</span>
    <span class="toggle-icon">▼</span>
  </button>
  
</div>

<script>
// 전역 변수 (todayHot 네임스페이스)
let todayHotRankingExpanded = false;
let rankingData = [];
let updateInterval;

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    loadTodayHotRanking();
    startAutoUpdate();
});

// 오늘의 핫 랭킹 데이터 로드
async function loadTodayHotRanking() {
    const list = document.getElementById('todayHotList');
    
    try {
        // 로딩 상태 표시
        showLoadingState();
        
        // API 호출
        const response = await fetch('<%=request.getContextPath()%>/api/today-hot/ranking', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        const result = await response.json();
        
        if (result.success) {
            rankingData = result.rankings || [];
            renderRankingList();
        } else {
            showErrorState(result.error || '데이터를 불러오는데 실패했습니다.');
        }
        
    } catch (error) {
        console.error('Error loading today hot ranking:', error);
        showErrorState('네트워크 오류가 발생했습니다.');
    }
}

// 로딩 상태 표시
function showLoadingState() {
    const list = document.getElementById('todayHotList');
    list.innerHTML = 
        '<div class="loading-container">' +
            '<div class="loading-spinner"></div>' +
            '<span>랭킹 데이터 로딩 중..</span>' +
        '</div>';
}

// 에러 상태 표시
function showErrorState(message) {
    const list = document.getElementById('todayHotList');
    list.innerHTML = 
        '<div class="error-container">' +
            '<div class="error-icon">⚠️</div>' +
            '<span>' + message + '</span>' +
        '</div>';
}

// 랭킹 리스트 렌더링
function renderRankingList() {
    const list = document.getElementById('todayHotList');
    list.innerHTML = '';
    
    // 표시할 랭킹 수 결정 (1-3위 또는 1-12위)
    const displayCount = todayHotRankingExpanded ? Math.min(rankingData.length, 12) : Math.min(rankingData.length, 3);
    
    for (let i = 0; i < displayCount; i++) {
        const rank = i + 1;
        const data = rankingData[i];
        
        if (data) {
            const item = createRankingItem(rank, data);
            list.appendChild(item);
        } else {
            // 빈 랭킹 표시
            const item = createEmptyRankingItem(rank);
            list.appendChild(item);
        }
    }
    
    // 빈 랭킹이 있으면 나머지도 채움
    for (let i = displayCount; i < (todayHotRankingExpanded ? 12 : 3); i++) {
        const rank = i + 1;
        const item = createEmptyRankingItem(rank);
        list.appendChild(item);
    }
}

// 랭킹 아이템 생성
function createRankingItem(rank, data) {
    const item = document.createElement('div');
    item.className = 'ranking-item';
    item.setAttribute('data-rank', rank);
    
    // 카테고리명 변환 (영어명)
    const categoryName = convertCategoryName(data.categoryName);
    
    // 지역명 처리 (예: 강남구, 강남 등)
    const regionName = data.regionName || '정보없음';
    
    // 혼잡도, 대기시간, 남비 정보 처리
    const congestion = data.congestion || '정보없음';
    const waitTime = data.waitTime || '정보없음';
    const genderRatio = data.genderRatio || '정보없음';
    
    // 퍼센트값
    const percentage = data.percentage || 0;
    
    // HOT 태그는 1, 2, 3위에만 표시
    const hotTagHtml = rank <= 3 ? '<span class="hot-tag">HOT</span>' : '';
    
    item.innerHTML = 
        '<div class="rank-number">' + rank + '</div>' +
        '<div class="place-info">' +
            '<div class="place-name-line">' +
                '<span class="place-name">' + data.placeName + ' - ' + categoryName + '</span>' +
                '<span class="location-text">' + regionName + '</span>' +
                hotTagHtml +
            '</div>' +
            '<div class="place-stats">' +
                '<span class="stat-tag congestion-tag">#혼잡도:' + congestion + '</span>' +
                '<span class="stat-tag wait-tag">#대기시간:' + waitTime + '</span>' +
                '<span class="stat-tag gender-tag">#남비:' + genderRatio + '</span>' +
            '</div>' +
        '</div>' +
        '<div class="hot-score">' +
            '<span class="fire-icon">🔥</span>' +
            '<span class="percentage">' + percentage + '%</span>' +
        '</div>';
    
    // 클릭 이벤트 추가 - 해당 가게로 지도 이동 및 상세 정보 표시
    item.style.cursor = 'pointer';
    item.onclick = function() {
        focusOnPlace(data.placeId);
    };
    
    // 호버 효과 추가
    item.onmouseenter = function() {
        this.style.backgroundColor = 'rgba(0,0,0,0.02)';
        this.style.transform = 'translateY(-1px)';
        this.style.transition = 'all 0.2s ease';
    };
    
    item.onmouseleave = function() {
        this.style.backgroundColor = '';
        this.style.transform = 'translateY(0)';
    };
    
    return item;
}

// 빈 랭킹 아이템 생성
function createEmptyRankingItem(rank) {
    const item = document.createElement('div');
    item.className = 'ranking-item empty';
    item.setAttribute('data-rank', rank);
    
    // HOT 태그는 1, 2, 3위에만 표시
    const hotTagHtml = rank <= 3 ? '<span class="hot-tag">HOT</span>' : '';
    
    item.innerHTML = 
        '<div class="rank-number">' + rank + '</div>' +
        '<div class="place-info">' +
            '<div class="place-name-line">' +
                '<span class="place-name">투표해주세요! - 랭킹 집계중</span>' +
                '<span class="location-text">집계중</span>' +
                hotTagHtml +
            '</div>' +
            '<div class="place-stats">' +
                '<span class="stat-tag">#투표하기중</span>' +
            '</div>' +
        '</div>' +
        '<div class="hot-score">' +
            '<span class="fire-icon">🔥</span>' +
            '<span class="percentage">0%</span>' +
        '</div>';
    
    return item;
}

// 카테고리명 변환
function convertCategoryName(categoryName) {
    const categoryMap = {
        'club': '클럽',
        'hunting': '헌팅포차',
        'lounge': '라운지',
        'pocha': '포차',
        'guesthouse': '게스트하우스'
    };
    
    return categoryMap[categoryName] || categoryName || '카테고리';
}

// 더보기 토글 함수
function toggleRanking() {
    todayHotRankingExpanded = !todayHotRankingExpanded;
    
    const button = document.getElementById('toggleButton');
    const textSpan = button.querySelector('.toggle-text');
    const iconSpan = button.querySelector('.toggle-icon');
    
    if (todayHotRankingExpanded) {
        textSpan.textContent = '접기';
        iconSpan.textContent = '▲';
        button.classList.add('expanded');
    } else {
        textSpan.textContent = '더보기';
        iconSpan.textContent = '▼';
        button.classList.remove('expanded');
    }
    
    // 애니메이션과 함께 리스트 리렌더링
    const list = document.getElementById('todayHotList');
    list.style.opacity = '0.7';
    
    setTimeout(() => {
        renderRankingList();
        list.style.opacity = '1';
    }, 150);
}


// 자동 업데이트 시작 (5분마다)
function startAutoUpdate() {
    updateInterval = setInterval(() => {
        loadTodayHotRanking();
    }, 5 * 60 * 1000); // 5분 = 5 * 60 * 1000ms
}

// 페이지 언로드 시 타이머 정리
window.addEventListener('beforeunload', function() {
    if (updateInterval) {
        clearInterval(updateInterval);
    }
});

// 전역 함수로 노출 (필요한 곳에서 호출 가능)
window.loadTodayHotRanking = loadTodayHotRanking;
window.toggleRanking = toggleRanking;

</script>

</body>
</html>