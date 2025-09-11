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
// 아이폰 감지 및 스타일 강제 적용
function detectAndApplyIPhoneStyles() {
    const isIPhone = /iPhone|iPad|iPod/.test(navigator.userAgent) || 
                     (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
    
    if (isIPhone || window.innerWidth <= 500) {
        // 아이폰 감지됨 - 스타일 강제 적용
        
        // CSS 스타일 강제 적용
        const style = document.createElement('style');
        style.innerHTML = `
            .today-hot-section .place-name {
                font-size: 1.4rem !important;
            }
            .today-hot-section .stat-item {
                font-size: 1.2rem !important;
            }
            .today-hot-section .today-hot-title {
                font-size: 2.0rem !important;
            }
            .today-hot-section .rank-logo {
                width: 48px !important;
                height: 48px !important;
            }
            .today-hot-section .rank-number {
                font-size: 1.2rem !important;
            }
            .today-hot-section .vote-percentage {
                font-size: 0.9rem !important;
            }
            .today-hot-section .toggle-button {
                font-size: 1.2rem !important;
            }
            .today-hot-section .today-hot-grid {
                display: grid !important;
                grid-template-columns: repeat(3, 1fr) !important;
                width: 100% !important;
                max-width: 100% !important;
            }
            .today-hot-section .ranking-card {
                width: 100% !important;
                min-width: 0 !important;
                flex: 1 1 33.333% !important;
            }
        `;
        document.head.appendChild(style);
        
        // DOM 요소에 직접 스타일 적용 (더 강력한 방법)
        setTimeout(() => {
            const placeNames = document.querySelectorAll('.place-name');
            const statItems = document.querySelectorAll('.stat-item');
            const titles = document.querySelectorAll('.today-hot-title');
            const rankNumbers = document.querySelectorAll('.rank-number');
            const votePercentages = document.querySelectorAll('.vote-percentage');
            const toggleButtons = document.querySelectorAll('.toggle-button');
            const grids = document.querySelectorAll('.today-hot-grid');
            const cards = document.querySelectorAll('.ranking-card');
            
            placeNames.forEach(el => {
                el.style.setProperty('font-size', '1.4rem', 'important');
            });
            statItems.forEach(el => {
                el.style.setProperty('font-size', '1.2rem', 'important');
            });
            titles.forEach(el => {
                el.style.setProperty('font-size', '2.0rem', 'important');
            });
            
            // 로고 크기 강제 적용
            const logos = document.querySelectorAll('.rank-logo');
            logos.forEach(el => {
                el.style.setProperty('width', '48px', 'important');
                el.style.setProperty('height', '48px', 'important');
            });
            rankNumbers.forEach(el => {
                el.style.setProperty('font-size', '1.2rem', 'important');
            });
            votePercentages.forEach(el => {
                el.style.setProperty('font-size', '0.9rem', 'important');
            });
            toggleButtons.forEach(el => {
                el.style.setProperty('font-size', '1.2rem', 'important');
            });
            
            // 그리드 스타일 강제 적용
            grids.forEach(el => {
                el.style.setProperty('display', 'grid', 'important');
                el.style.setProperty('grid-template-columns', 'repeat(3, 1fr)', 'important');
                el.style.setProperty('width', '100%', 'important');
                el.style.setProperty('max-width', '100%', 'important');
            });
            
            // 카드 스타일 강제 적용
            cards.forEach(el => {
                el.style.setProperty('width', '100%', 'important');
                el.style.setProperty('min-width', '0', 'important');
                el.style.setProperty('flex', '1 1 33.333%', 'important');
            });
        }, 100);
    }
}

// 페이지 로드 시 아이폰 스타일 적용
document.addEventListener('DOMContentLoaded', detectAndApplyIPhoneStyles);

// 오늘 핫 순위 데이터 로드
async function loadTodayHotRanking() {
    const grid = document.getElementById('todayHotGrid');
    const loadingCard = document.getElementById('loadingCard');
    
    try {
        // 로딩 상태 표시
        grid.innerHTML = '';
        for (let i = 1; i <= 12; i++) {
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
        
        // 그리드 업데이트 (12개 순위 모두 표시)
        grid.innerHTML = '';
        
        // 1-12위까지 모두 렌더링 (데이터가 없으면 빈 카드 표시)
        for (let i = 0; i < 12; i++) {
            const rank = i + 1;
            const item = rankingData[i] || null;
            const card = createRankingCard(rank, item);
            grid.appendChild(card);
        }
        
        // 초기에는 3위까지만 보이도록 설정
        setTimeout(() => {
            showTop3Only();
            // 데이터 로드 후 아이폰 스타일 다시 적용
            detectAndApplyIPhoneStyles();
        }, 100);
        
    } catch (error) {
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
            return data.rankings;
        } else {
            throw new Error(data.error || '랭킹 데이터를 가져올 수 없습니다.');
        }
        
        } catch (error) {
            throw error;
        }
}

// 5위까지만 보이기
function showTop3Only() {
    const grid = document.getElementById('todayHotGrid');
    const toggleButton = document.getElementById('toggleButton');
    const cards = grid.querySelectorAll('.ranking-card');
    
    // 모든 카드를 숨기고 1-3위만 보이게 하기
    cards.forEach((card, index) => {
        if (index < 3) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
    
    grid.classList.remove('expanded');
    grid.classList.add('collapsed');
    
    // 버튼 텍스트 변경
    toggleButton.querySelector('.text').textContent = '더 보기 (4-12위)';
    toggleButton.classList.remove('expanded');
}

// 12위까지 모두 보이기
function showAll12() {
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
    toggleButton.querySelector('.text').textContent = '접기 (1-3위만)';
    toggleButton.classList.add('expanded');
}

// 펼치기/접기 토글 함수
function toggleRanking() {
    const grid = document.getElementById('todayHotGrid');
    
    if (grid.classList.contains('collapsed')) {
        showAll12();
    } else {
        showTop3Only();
    }
    
    // 토글 후 아이폰 스타일 다시 적용
    setTimeout(() => {
        detectAndApplyIPhoneStyles();
    }, 50);
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