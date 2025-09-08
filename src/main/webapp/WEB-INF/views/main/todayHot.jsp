<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>오늘 핫</title>
</head>
<body>

<div class="today-hot-section">
  <h5 class="today-hot-title">
    <img src="/hotplace/logo/lank.png" alt="랭크 로고" class="rank-logo">
    오늘 핫
  </h5>
  
  <!-- 순위 그리드 -->
  <div class="today-hot-grid collapsed" id="todayHotGrid">
    <!-- 로딩 상태 -->
    <div class="ranking-card loading-card" id="loadingCard">
      <div class="loading-spinner"></div>
      <span>순위 데이터 로딩 중...</span>
    </div>
  </div>
  
  <!-- 펼치기/접기 버튼 -->
  <button id="toggleButton" class="toggle-button" onclick="toggleRanking()">
    <span class="icon">▼</span>
    <span class="text">더 보기</span>
  </button>
</div>

<script>
// 오늘 핫 순위 데이터 로드
async function loadTodayHotRanking() {
    const grid = document.getElementById('todayHotGrid');
    const loadingCard = document.getElementById('loadingCard');
    
    try {
        // 로딩 상태 표시
        grid.innerHTML = '';
        for (let i = 1; i <= 10; i++) {
            const loadingCard = document.createElement('div');
            loadingCard.className = 'ranking-card loading-card';
            loadingCard.innerHTML = `
                <div class="loading-spinner"></div>
                <span>로딩 중...</span>
            `;
            grid.appendChild(loadingCard);
        }
        
        // 실제 API 호출
        const rankingData = await fetchRealTodayHotData();
        
        // 그리드 업데이트 (10개 순위 모두 표시)
        grid.innerHTML = '';
        
        // 1-10위까지 모두 렌더링 (데이터가 없으면 빈 카드 표시)
        for (let i = 0; i < 10; i++) {
            const rank = i + 1;
            const item = rankingData[i] || null;
            const card = createRankingCard(rank, item);
            grid.appendChild(card);
        }
        
        // 초기에는 5위까지만 보이도록 설정
        setTimeout(() => {
            showTop5Only();
        }, 100);
        
    } catch (error) {
        console.error('순위 데이터 로드 실패:', error);
        showErrorState();
    }
}

// 순위 카드 생성
function createRankingCard(rank, data) {
    const card = document.createElement('div');
    card.className = 'ranking-card rank-' + rank;
    
    // 데이터가 없는 경우 (빈 순위)
    if (!data) {
        card.className += ' empty';
        
        // 순위 표시 (메달 제거)
        let rankDisplay = rank + '위';
        
    card.innerHTML = 
        '<div class="rank-header">' +
            '<div class="rank-number">' + rankDisplay + '</div>' +
            '<div class="vote-percentage">투표해주세요!</div>' +
        '</div>' +
        '<div class="place-name">아직 ' + rank + '위가 없습니다.</div>' +
        '<div class="vote-stats">' +
            '<div class="stat-item">#투표대기중</div>' +
        '</div>';
    
    // 빈 카드는 클릭 불가
    card.style.cursor = 'default';
    return card;
    }
    
    // 데이터가 있는 경우
    const percentage = data.percentage || 0;
    const placeName = data.placeName || '알 수 없음';
    const congestion = data.congestion || '정보 없음';
    const waitTime = data.waitTime || '정보 없음';
    const genderRatio = formatGenderRatio(data.genderRatio || '정보 없음');
    const placeId = data.placeId || null;
    
    // 순위 표시 (메달 제거)
    let rankDisplay = rank + '위';
    
    card.innerHTML = 
        '<div class="rank-header">' +
            '<div class="rank-number">' + rankDisplay + '</div>' +
            '<div class="vote-percentage">🔥' + percentage + '%</div>' +
        '</div>' +
        '<div class="place-name">' + placeName + '</div>' +
        '<div class="vote-stats">' +
            '<div class="stat-item">#혼잡도:' + congestion + '</div>' +
            '<div class="stat-item">#대기시간:' + waitTime + '</div>' +
            '<div class="stat-item">#성비:' + genderRatio + '</div>' +
        '</div>';
    
    // 데이터가 있는 카드는 클릭 가능하도록 설정
    if (placeId) {
        card.classList.add('clickable');
        card.onclick = function() {
        // 메인 페이지로 이동하면서 placeId 파라미터 전달
        window.location.href = '/hotplace/?placeId=' + placeId;
        };
    }
    
    return card;
}


// 에러 상태 표시
function showErrorState() {
    const grid = document.getElementById('todayHotGrid');
    grid.innerHTML = '';
    
    for (let i = 1; i <= 10; i++) {
        const errorCard = document.createElement('div');
        errorCard.className = 'ranking-card error-card';
        errorCard.innerHTML = `
            <div>데이터 로드 실패</div>
            <div style="font-size: 0.8rem; margin-top: 4px;">새로고침해주세요</div>
        `;
        grid.appendChild(errorCard);
    }
}

// 페이지 로드 시 순위 데이터 로드
document.addEventListener('DOMContentLoaded', function() {
    loadTodayHotRanking();
    
    // 5분마다 데이터 새로고침
    setInterval(loadTodayHotRanking, 5 * 60 * 1000);
});

// 실제 API 호출 함수 (Redis 캐싱 기반)
async function fetchRealTodayHotData() {
    try {
        const response = await fetch('/hotplace/api/today-hot/ranking', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': 'application/json'
            }
        });
        
        if (!response.ok) {
            throw new Error('HTTP error! status: ' + response.status);
        }
        
        const data = await response.json();
        
        if (data.success && data.rankings) {
            console.log('오늘 핫 랭킹 데이터 로드 성공:', data.rankings.length, '개');
            return data.rankings;
        } else {
            throw new Error(data.error || '랭킹 데이터를 가져올 수 없습니다.');
        }
        
        } catch (error) {
            console.error('API 호출 실패:', error);
            throw error;
        }
}

// 5위까지만 보이기
function showTop5Only() {
    const grid = document.getElementById('todayHotGrid');
    const toggleButton = document.getElementById('toggleButton');
    const cards = grid.querySelectorAll('.ranking-card');
    
    // 모든 카드를 숨기고 1-5위만 보이게 하기
    cards.forEach((card, index) => {
        if (index < 5) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
    
    grid.classList.remove('expanded');
    grid.classList.add('collapsed');
    
    // 버튼 텍스트 변경
    toggleButton.querySelector('.text').textContent = '더 보기 (6-10위)';
    toggleButton.classList.remove('expanded');
}

// 10위까지 모두 보이기
function showAll10() {
    const grid = document.getElementById('todayHotGrid');
    const toggleButton = document.getElementById('toggleButton');
    const cards = grid.querySelectorAll('.ranking-card');
    
    // 모든 카드를 보이게 하기
    cards.forEach(card => {
        card.style.display = 'block';
    });
    
    grid.classList.remove('collapsed');
    grid.classList.add('expanded');
    
    // 버튼 텍스트 변경
    toggleButton.querySelector('.text').textContent = '접기 (1-5위만)';
    toggleButton.classList.add('expanded');
}

// 펼치기/접기 토글 함수
function toggleRanking() {
    const grid = document.getElementById('todayHotGrid');
    
    if (grid.classList.contains('collapsed')) {
        showAll10();
    } else {
        showTop5Only();
    }
}

// 성비 표시 포맷팅 함수
function formatGenderRatio(genderRatio) {
    if (!genderRatio || genderRatio === '정보 없음' || genderRatio === '데이터없음') {
        return genderRatio;
    }
    
    switch(genderRatio) {
        case '남초':
            return '남자↑';
        case '여초':
            return '여자↑';
        case '반반':
            return '반반';
        default:
            return genderRatio;
    }
}


</script>

</body>
</html>