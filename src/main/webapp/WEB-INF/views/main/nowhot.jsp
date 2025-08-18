<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.wherehot.spring.entity.*" %>
<%
    String root = request.getContextPath();
    List<Category> categoryList = (List<Category>) request.getAttribute("categoryList");
    if (categoryList == null) {
        categoryList = new ArrayList<>();
    }
%>

<h5 class="fw-bold mb-3">🔥 지금 핫한 투표</h5>

<!-- 클럽 정보 부분 (동적으로 변경됨) -->
<div id="hotplaceInfoSection">
  <div id="voteGuide" class="vote-guide-container">
    <i class="bi bi-geo-alt vote-guide-icon"></i>
    <div class="vote-guide-title">먼저 지도를 클릭해서</div>
    <div class="vote-guide-title">위치를 선택해주세요 !!</div>
    <div class="vote-guide-subtitle">(위치를 선택해야 투표가 가능합니다)</div>
    <button id="pickLocationBtn" class="pick-location-btn">
      <i class="bi bi-geo-alt-fill"></i>
      지정하기
    </button>
  </div>
  
  <div id="hotplaceInfo" class="hotplace-info mb-3 p-3 rounded" style="display: none;">
    <h6 class="fw-bold mb-1" id="voteHotplaceName"></h6>
    <p class="mb-2 small" id="voteHotplaceAddress"></p>
    <span class="badge bg-light text-dark" id="voteCategoryBadge"></span>
  </div>
</div>

<!-- 투표 폼 (항상 보임) -->
<form id="voteForm">
  <input type="hidden" id="voteHotplaceId" name="hotplaceId">
  
  <!-- 1번 질문 -->
  <div class="mb-3">
    <label class="form-label fw-bold">1. 지금 사람 많음?</label>
    <div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="crowd" id="crowd1" value="1">
        <label class="form-check-label" for="crowd1">한산함</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="crowd" id="crowd2" value="2">
        <label class="form-check-label" for="crowd2">적당함</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="crowd" id="crowd3" value="3">
        <label class="form-check-label" for="crowd3">붐빔</label>
      </div>
    </div>
  </div>

  <!-- 2번 질문 -->
  <div class="mb-3">
    <label class="form-label fw-bold">2. 줄 서야 함? (대기 있음?)</label>
    <div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="wait" id="wait1" value="1">
        <label class="form-check-label" for="wait1">바로입장</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="wait" id="wait2" value="2">
        <label class="form-check-label" for="wait2">10분정도</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="wait" id="wait3" value="3">
        <label class="form-check-label" for="wait3">30분</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="wait" id="wait4" value="4">
        <label class="form-check-label" for="wait4">1시간 이상</label>
      </div>
    </div>
  </div>

  <!-- 3번 질문 -->
  <div class="mb-3">
    <label class="form-label fw-bold">3. 남녀 성비 어때?</label>
    <div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="gender" id="gender1" value="1">
        <label class="form-check-label" for="gender1">여초</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="gender" id="gender2" value="2">
        <label class="form-check-label" for="gender2">반반</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="gender" id="gender3" value="3">
        <label class="form-check-label" for="gender3">남초</label>
      </div>
    </div>
  </div>

  <button type="submit" class="btn btn-primary btn-sm w-100">
    <i class="bi bi-fire"></i> 투표하기
  </button>
</form>

<!-- 상태 메시지 -->
<div id="statusMessage" class="mt-3"></div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('voteForm');
    const statusMessage = document.getElementById('statusMessage');
    
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        const formData = new FormData(form);
        const hotplaceId = formData.get('hotplaceId');
        const crowd = formData.get('crowd');
        const wait = formData.get('wait');
        const gender = formData.get('gender');
        
        // 검증
        if (!hotplaceId) {
            showMessage('먼저 지도에서 장소를 선택해주세요.', 'warning');
            return;
        }
        
        if (!crowd || !wait || !gender) {
            showMessage('모든 질문에 답변해주세요.', 'warning');
            return;
        }
        
        // JWT 토큰 가져오기
        const token = localStorage.getItem('accessToken');
        
        // Spring API 호출 (JWT 토큰 포함)
        const data = new URLSearchParams();
        data.append('hotplaceId', hotplaceId);  // VoteController의 파라미터명에 맞춤
        data.append('crowd', crowd);
        data.append('gender', gender);
        data.append('wait', wait);
        
        const headers = {
            'Content-Type': 'application/x-www-form-urlencoded'
        };
        
        // 토큰이 있으면 Authorization 헤더 추가
        if (token) {
            headers['Authorization'] = 'Bearer ' + token;
            console.log('로그인 사용자 투표:', token.substring(0, 20) + '...');
        } else {
            console.log('익명 사용자 투표 (IP 기반)');
        }
        
        fetch('<%=root%>/api/vote/now-hot', {  // 올바른 API 엔드포인트
            method: 'POST',
            headers: headers,
            body: data
        })
        .then(response => response.json())
        .then(result => {
            console.log('투표 응답:', result);
            
            if (result.success) {
                showMessage('투표가 완료되었습니다! 감사합니다.', 'success');
                form.reset();
                // 선택된 장소 정보도 초기화
                document.getElementById('hotplaceInfo').style.display = 'none';
                document.getElementById('voteGuide').style.display = 'block';
                document.getElementById('voteHotplaceId').value = '';
                
                // 투표 통계가 있으면 콘솔에 출력
                if (result.stats) {
                    console.log('업데이트된 투표 통계:', result.stats);
                }
            } else {
                showMessage(result.message || '투표에 실패했습니다.', 'error');
            }
        })
        .catch(error => {
            console.error('투표 오류:', error);
            showMessage('투표 중 오류가 발생했습니다.', 'error');
        });
    });
    
    function showMessage(message, type) {
        let alertClass = 'alert-info';
        if (type === 'success') alertClass = 'alert-success';
        else if (type === 'error') alertClass = 'alert-danger';
        else if (type === 'warning') alertClass = 'alert-warning';
        
        statusMessage.innerHTML = '<div class="alert ' + alertClass + ' alert-dismissible fade show" role="alert">' +
            message +
            '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
        '</div>';
        
        // 3초 후 자동 제거
        setTimeout(() => {
            statusMessage.innerHTML = '';
        }, 3000);
    }
});

// 외부에서 호출 가능한 함수 (지도에서 장소 선택 시)
function showVoteForm(hotplaceId, name, address, categoryId) {
    document.getElementById('voteHotplaceId').value = hotplaceId;
    document.getElementById('voteHotplaceName').textContent = name;
    document.getElementById('voteHotplaceAddress').textContent = address;
    
    // 카테고리 표시
    const categoryNames = {1: '클럽', 2: '헌팅포차', 3: '라운지', 4: '포차'};
    document.getElementById('voteCategoryBadge').textContent = categoryNames[categoryId] || '기타';
    
    // UI 전환
    document.getElementById('voteGuide').style.display = 'none';
    document.getElementById('hotplaceInfo').style.display = 'block';
}

// 위치 선택 버튼 이벤트
document.getElementById('pickLocationBtn').addEventListener('click', function() {
    if (typeof showVoteSection === 'function') {
        // main.jsp의 showVoteSection 함수 호출 (지도 표시)
        alert('지도에서 장소를 클릭해주세요.');
    } else {
        alert('지도 기능을 사용할 수 없습니다.');
    }
});
</script>

<style>
.vote-guide-container {
    text-align: center;
    padding: 40px 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 15px;
    color: white;
    margin-bottom: 20px;
}

.vote-guide-icon {
    font-size: 3rem;
    margin-bottom: 15px;
    opacity: 0.9;
}

.vote-guide-title {
    font-size: 1.2rem;
    font-weight: 600;
    margin-bottom: 5px;
}

.vote-guide-subtitle {
    font-size: 0.9rem;
    opacity: 0.8;
    margin-bottom: 20px;
}

.pick-location-btn {
    background: rgba(255,255,255,0.2);
    border: 2px solid rgba(255,255,255,0.3);
    color: white;
    padding: 10px 20px;
    border-radius: 25px;
    font-weight: 500;
    transition: all 0.3s ease;
}

.pick-location-btn:hover {
    background: rgba(255,255,255,0.3);
    border-color: rgba(255,255,255,0.5);
    color: white;
    transform: translateY(-2px);
}

.hotplace-info {
    background: #f8f9fa;
    border: 1px solid #e9ecef;
}

.form-check-input:checked {
    background-color: #667eea;
    border-color: #667eea;
}

.btn-primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    padding: 12px;
    font-weight: 600;
}

.btn-primary:hover {
    background: linear-gradient(135deg, #5a6fd8 0%, #6a4190 100%);
    transform: translateY(-1px);
}
</style>