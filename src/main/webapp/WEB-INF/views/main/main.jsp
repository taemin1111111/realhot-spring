<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String root = request.getContextPath();
    
    // Controller에서 전달받은 데이터 사용
    @SuppressWarnings("unchecked")
    List<Object> hotplaceList = (List<Object>) request.getAttribute("hotplaceList");
    if (hotplaceList == null) hotplaceList = new ArrayList<>();
    
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> sigunguCenterList = (List<Map<String, Object>>) request.getAttribute("sigunguCenterList");
    if (sigunguCenterList == null) sigunguCenterList = new ArrayList<>();
    
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> sigunguCategoryCountList = (List<Map<String, Object>>) request.getAttribute("sigunguCategoryCountList");
    if (sigunguCategoryCountList == null) sigunguCategoryCountList = new ArrayList<>();
    
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> regionCenters = (List<Map<String, Object>>) request.getAttribute("regionCenters");
    if (regionCenters == null) regionCenters = new ArrayList<>();
    
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> regionCategoryCounts = (List<Map<String, Object>>) request.getAttribute("regionCategoryCounts");
    if (regionCategoryCounts == null) regionCategoryCounts = new ArrayList<>();
    
    @SuppressWarnings("unchecked")
    List<String> regionNameList = (List<String>) request.getAttribute("regionNameList");
    if (regionNameList == null) regionNameList = new ArrayList<>();
    
    @SuppressWarnings("unchecked")
    List<String> hotplaceNameList = (List<String>) request.getAttribute("hotplaceNameList");
    if (hotplaceNameList == null) hotplaceNameList = new ArrayList<>();
    
    // 평점 관련 데이터 제거
    
    @SuppressWarnings("unchecked")
    Map<String, Integer> dongToRegionIdMapping = (Map<String, Integer>) request.getAttribute("dongToRegionIdMapping");
    if (dongToRegionIdMapping == null) dongToRegionIdMapping = new HashMap<>();
    
    // JWT 토큰 기반 인증으로 완전히 변경 - 서버 사이드에서는 세션 체크 안함
    // 로그인 상태는 클라이언트 JavaScript에서 JWT 토큰으로 확인
%>

<!-- Kakao Map SDK -->
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=9c8d14f1fa7135d1f77778321b1e25fa&libraries=services"></script>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/all.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/main.css">

<div class="main-container">
  <div class="row gx-4 gy-4 align-items-stretch">
    <div class="col-md-9">
      <div class="card-box h-100" style="min-height:600px; display:flex; flex-direction:column; position:relative;">
        <div style="text-align: center;">
          <img src="<%=root%>/logo/hotmap.png" alt="핫플 지도" style="max-width: 70px; height: auto; object-fit: contain; margin-bottom: 0; margin-top: -16px; display: block; margin-left: auto; margin-right: auto;">
          <p class="text-muted-small mb-3" style="display: inline-block; margin-top: -8px;">지금 가장 핫한 장소들을 지도로 한눈에 확인해보세요.</p>
        </div>
        <button onclick="moveToCurrentLocation()" class="btn btn-sm btn-outline-primary mb-3 d-flex align-items-center gap-1 map-location-btn" style="width:110px; min-width:unset; padding: 4px 10px; font-size: 0.85rem; border-radius: 18px; display: block; margin-left: 0; float: left;">
          <i class="bi bi-crosshair"></i>
          내 위치
        </button>
        <div id="map" style="width:100%; height:600px; border-radius:12px; position:relative;">
          <div id="categoryFilterBar" style="position:absolute; top:16px; left:16px; z-index:10; display:flex; gap:8px;">
            <button class="category-filter-btn active" data-category="all">전체</button>
            <button class="category-filter-btn marker-club" data-category="1">C</button>
            <button class="category-filter-btn marker-hunting" data-category="2">H</button>
            <button class="category-filter-btn marker-lounge" data-category="3">L</button>
            <button class="category-filter-btn marker-pocha" data-category="4">P</button>
          </div>
          <!-- 오른쪽 패널 토글 버튼 및 패널 -->
          <button id="rightPanelToggleBtn" style="position:absolute; top:50%; right:0; transform:translateY(-50%); z-index:20; background:#fff; border-radius:8px 0 0 8px; border:1.5px solid #ddd; border-right:none; width:36px; height:56px; box-shadow:0 2px 8px rgba(0,0,0,0.10); display:flex; align-items:center; justify-content:center; font-size:1.5rem; cursor:pointer; transition:background 0.15s;">&lt;</button>
          <div id="rightPanel" style="position:absolute; top:0; right:0; height:100%; width:360px; max-width:90vw; background:#fff; box-shadow:-2px 0 16px rgba(0,0,0,0.10); z-index:30; border-radius:16px 0 0 16px; transform:translateX(100%); transition:transform 0.35s cubic-bezier(.77,0,.18,1); display:flex; flex-direction:column;">
            <button id="rightPanelCloseBtn" style="position:absolute; left:-36px; top:50%; transform:translateY(-50%); width:36px; height:56px; background:#fff; border-radius:8px 0 0 8px; border:1.5px solid #ddd; border-left:none; box-shadow:0 2px 8px rgba(0,0,0,0.10); display:flex; align-items:center; justify-content:center; font-size:1.5rem; cursor:pointer; display:none;">&gt;</button>
            <!-- 검색창 -->
            <div id="searchBar" style="position:sticky; top:0; background:#fff; z-index:10; padding:24px 20px 12px 20px; box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <!-- 검색 타입 드롭다운 -->
              <style>
                .search-type-dropdown { position:relative; }
                .search-type-btn { display:flex; align-items:center; gap:4px; background:#f5f6fa; border:1.5px solid #e0e0e0; border-radius:16px; font-size:0.93rem; font-weight:500; color:#222; padding:0 10px; height:32px; min-width:54px; max-width:70px; cursor:pointer; transition:border 0.18s, background 0.18s; outline:none; white-space:nowrap; }
                .search-type-btn:focus, .search-type-btn.active { border:1.5px solid #1275E0; background:#fff; }
                .search-type-arrow { font-size:1em; color:#888; margin-left:2px; }
                .search-type-list { position:absolute; top:110%; left:0; min-width:54px; background:#fff; border:1.5px solid #e0e0e0; border-radius:10px; box-shadow:0 4px 16px rgba(0,0,0,0.08); z-index:10; display:none; flex-direction:column; padding:2px 0; }
                .search-type-list.show { display:flex; }
                .search-type-item { padding:6px 14px; font-size:0.93rem; color:#222; background:none; border:none; text-align:left; cursor:pointer; transition:background 0.13s; white-space:nowrap; }
                .search-type-item:hover, .search-type-item.selected { background:#f0f4fa; color:#1275E0; }
              </style>
              <form style="display:flex; align-items:center; gap:8px; position:relative; min-width:0;" onsubmit="return false;">
                  <div class="search-type-dropdown" id="searchTypeDropdown" style="flex:0 0 60px; min-width:54px; max-width:70px;">
                    <button type="button" class="search-type-btn" id="searchTypeBtn" style="width:100%; min-width:54px; max-width:70px; justify-content:center;">
                      <span id="searchTypeText">지역</span>
                      <span class="search-type-arrow">&#9660;</span>
                    </button>
                    <div class="search-type-list" id="searchTypeList">
                      <button type="button" class="search-type-item selected" data-type="지역">지역</button>
                      <button type="button" class="search-type-item" data-type="가게">가게</button>
                    </div>
                  </div>
                  <div style="position:relative; flex:1; min-width:0;">
                    <input type="text" id="searchInput" placeholder="지역, 장소 검색 가능" style="width:100%; height:44px; border-radius:24px; border:1.5px solid #e0e0e0; background:#fafbfc; font-size:1.08rem; padding:0 44px 0 18px; box-shadow:0 2px 8px rgba(0,0,0,0.03); outline:none; transition:border 0.18s; min-width:0;" autocomplete="off" />
                    <button id="searchBtn" type="submit" style="position:absolute; right:12px; top:50%; transform:translateY(-50%); background:none; border:none; outline:none; cursor:pointer; font-size:1.35rem; color:#1275E0; display:flex; align-items:center; justify-content:center; padding:0; width:28px; height:28px;">
                      <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="currentColor" viewBox="0 0 16 16"><path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001c.03.04.062.078.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1.007 1.007 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0z"/></svg>
                    </button>
                    <div id="autocompleteList" style="position:absolute; left:0; top:46px; width:100%; background:rgba(255,255,255,0.97); border-radius:14px; box-shadow:0 4px 16px rgba(0,0,0,0.10); z-index:30; display:none; flex-direction:column; overflow:hidden; border:1.5px solid #e0e0e0;"></div>
                  </div>
                </form>
            </div>
            <div id="categoryCountsBar" style="display:none;"></div>
            <div style="padding:24px 20px 20px 20px; flex:1; overflow-y:auto; display:flex; flex-direction:column; align-items:center; justify-content:center;">
              <div id="searchResultBox" style="width:100%; flex:1; min-height:0; height:100%; background:#f5f5f5; border-radius:12px; display:flex; flex-direction:column; align-items:center; justify-content:flex-start; color:#888; font-size:1.2rem; padding:0; overflow-y:auto;"></div>
            </div>
          </div>
        </div>
        <div class="text-end mt-2">
          <a href="<%=root%>/map/full.jsp" class="text-info">지도 전체 보기 →</a>
        </div>
      </div>
    </div>
    
    <!-- 투표 섹션 -->
    <div class="col-md-3">
      <div class="card-box h-100" style="min-height:600px;">
        <jsp:include page="nowhot.jsp" />
      </div>
    </div>
  </div>
  
  <!-- 헌팅썰 인기글 섹션 -->
  <div class="row mt-5">
    <div class="col-12">
      <jsp:include page="hunting_popular.jsp" />
    </div>
  </div>
</div>

<jsp:include page="todayHot.jsp" />

<script>
  var root = '<%=root%>';
  // JWT 기반 인증으로 변경 - 클라이언트에서 토큰을 통해 확인
  var isLoggedIn = false; // JavaScript에서 JWT 토큰으로 확인
  var loginUserId = '';   // JavaScript에서 JWT 토큰으로 확인  
  var isAdmin = false;    // JavaScript에서 서버 API 호출로 확인
  
  // JWT 토큰에서 로그인 정보 확인 (title.jsp와 일관성 유지)
  function initAuthStatus() {
    const token = localStorage.getItem('accessToken');
    if (token && typeof token === 'string' && token.split('.').length === 3) {
      try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        const currentTime = Date.now() / 1000;
        
        if (payload.exp > currentTime) {
          isLoggedIn = true;
          loginUserId = payload.sub || '';
          console.log('로그인 상태 확인:', loginUserId);
          
          // 관리자 확인을 위한 서버 API 호출 (자동 토큰 갱신 포함)
          let adminCheckPromise;
          if (typeof window.fetchWithAuth === 'function') {
            adminCheckPromise = window.fetchWithAuth(root + '/api/auth/check-admin');
          } else {
            adminCheckPromise = fetch(root + '/api/auth/check-admin', {
              method: 'GET',
              headers: {
                'Authorization': 'Bearer ' + token,
                'Content-Type': 'application/json'
              }
            });
          }
          
          adminCheckPromise
          .then(response => response.json())
          .then(data => {
            if (data.isAdmin) {
              isAdmin = true;
              console.log('관리자 권한 확인됨:', data);
              
              // 관리자 UI 요소들 활성화
              updateAdminUI();
            } else {
              console.log('일반 사용자:', data);
            }
          })
          .catch(error => console.log('관리자 확인 실패:', error));
        } else {
          // 토큰 만료 시 정리
          localStorage.removeItem('accessToken');
          isLoggedIn = false;
          loginUserId = '';
          isAdmin = false;
        }
      } catch (error) {
        console.log('JWT 토큰 파싱 오류:', error);
        localStorage.removeItem('accessToken');
        isLoggedIn = false;
        loginUserId = '';
        isAdmin = false;
      }
    }
  }
  
  // 페이지 로드 시 인증 상태 확인
  initAuthStatus();
  
  // 토큰 갱신 타이머 설정 (title.jsp에서 설정되지 않은 경우를 대비)
  if (typeof window.setupTokenRefreshTimer === 'function') {
    window.setupTokenRefreshTimer();
  }
  
  // 관리자 UI 업데이트 함수
  function updateAdminUI() {
    // InfoWindow에서 관리자 버튼들이 제대로 표시되도록 설정
    console.log('관리자 UI 활성화');
    
    // 기존 InfoWindow들을 재설정하여 관리자 버튼이 나타나도록 함
    hotplaceMarkers.forEach(function(marker, idx) {
      if (marker.categoryId === 1) { // 클럽 카테고리만
        const place = hotplaces[idx];
        if (place) {
          // InfoWindow 내용 업데이트
          const newInfoContent = generateInfoWindowContent(place);
          hotplaceInfoWindows[idx].setContent(newInfoContent);
        }
      }
    });
  }
  
  // InfoWindow 내용 생성 함수 (관리자 권한 반영)
  function generateInfoWindowContent(place) {
    const heartHtml = isLoggedIn ? `<i class="bi bi-heart wish-heart" data-place-id="${place.id}" style="position:absolute;top:12px;right:12px;z-index:10;"></i>` : '';
    
    return ''
      + '<div class="infoWindow" style="position:relative; padding:0; font-size:clamp(12px, 2vw, 16px); line-height:1.4; border-radius:12px; overflow:hidden; box-sizing:border-box;">'
      + '<div class="place-images-container" style="position:relative; width:100%; background:#f8f9fa; display:flex; align-items:center; justify-content:center; color:#6c757d; font-size:clamp(11px, 1.5vw, 13px);" data-place-id="' + place.id + '">이미지 로딩 중...</div>'
      + '<div style="padding:clamp(16px, 3vw, 20px);">'
      + '<div class="place-name-wish-container">'
      + '<strong style="font-size:clamp(14px, 2.5vw, 18px); word-break:break-word;">' + place.name + '</strong>'
      + '<span style="color:#e91e63; font-size:clamp(12px, 2vw, 14px); white-space:nowrap;">💖<span class="wish-count-' + place.id + '" style="color:#e91e63; font-weight:600;">로딩중...</span>명</span>'
      + '</div>'
      + '<div style="margin-bottom:clamp(10px, 2vw, 14px); color:#888; font-size:clamp(10px, 1.8vw, 12px); word-break:break-word;" id="voteTrends-' + place.id + '">📊 역대 투표: 로딩중...</div>'
      + '<div style="margin-bottom:clamp(10px, 2vw, 14px); color:#666; font-size:clamp(11px, 2vw, 13px); word-break:break-word; line-height:1.3;">' + place.address + '</div>'
      + '<div style="color:#9c27b0; font-weight:600; margin-bottom:clamp(10px, 2vw, 14px); font-size:clamp(11px, 2vw, 13px); word-break:break-word;" id="genres-' + place.id + '">🎵 장르: 로딩중...</div>'
      + '<div class="action-buttons-container"><a href="#" onclick="showVoteSection(' + place.id + ', \'' + place.name + '\', \'' + place.address + '\', ' + place.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-weight:500; font-size:clamp(12px, 2vw, 14px); white-space:nowrap; padding:10px 16px; background:#f0f8ff; border-radius:8px; border:1px solid #e3f2fd;">🔥 투표하기</a>'
      + (isAdmin && place.categoryId === 1 ? '<a href="#" onclick="openGenreEditModal(' + place.id + ', \'' + place.name + '\'); return false;" style="color:#ff6b35; text-decoration:none; font-size:clamp(10px, 1.8vw, 12px); white-space:nowrap; padding:8px 14px; background:#fff3e0; border-radius:6px; border:1px solid #ffe0b2;">✏️ 장르 편집</a>' : '') + '</div>'
      + '</div>'
      + '</div>';
  }
  
  var regionNameList = [<% for(int i=0;i<regionNameList.size();i++){ %>'<%=regionNameList.get(i).replace("'", "\\'")%>'<% if(i<regionNameList.size()-1){%>,<%}}%>];
  var hotplaceNameList = [<% for(int i=0;i<hotplaceNameList.size();i++){ %>'<%=hotplaceNameList.get(i).replace("'", "\\'")%>'<% if(i<hotplaceNameList.size()-1){%>,<%}}%>];
  
  // URL 파라미터에서 lat, lng 가져오기
  var urlParams = new URLSearchParams(window.location.search);
  var targetLat = urlParams.get('lat');
  var targetLng = urlParams.get('lng');
  
  // URL 파라미터가 있으면 해당 위치로 이동할 준비
  if (targetLat && targetLng) {
    console.log('URL 파라미터 감지: lat=' + targetLat + ', lng=' + targetLng);
  }
  
  // 평점 관련 데이터 제거
  var regionRatings = {};
  
  var dongToRegionId = {
    <% for(java.util.Map.Entry<String, Integer> entry : dongToRegionIdMapping.entrySet()) { %>
      '<%=entry.getKey()%>': <%=entry.getValue()%>,
    <% } %>
  };
  
  // window에 전역 변수들 추가
  window.dongToRegionId = dongToRegionId;
  window.regionCategoryCounts = regionCategoryCounts;
  window.hotplaces = hotplaces;
  // 평점 관련 데이터 제거

  // JSP 변수들을 JavaScript로 전달
  var hotplaces = [<% for (int i = 0; i < hotplaceList.size(); i++) { 
    Object obj = hotplaceList.get(i);
    if (obj instanceof com.wherehot.spring.entity.Hotplace) {
      com.wherehot.spring.entity.Hotplace hotplace = (com.wherehot.spring.entity.Hotplace) obj;
      // 장르 정보는 별도로 조회하도록 변경 (Hotplace Entity에서 제거됨)
  %>{id:<%=hotplace.getId()%>, name:'<%=hotplace.getName().replace("'", "\\'")%>', categoryId:<%=hotplace.getCategoryId()%>, address:'<%=hotplace.getAddress().replace("'", "\\'")%>', lat:<%=hotplace.getLat()%>, lng:<%=hotplace.getLng()%>, regionId:<%=hotplace.getRegionId()%>}<% if (i < hotplaceList.size() - 1) { %>,<% } } }%>];
  
  var rootPath = '<%=root%>';
  var sigunguCenters = [<% for (int i = 0; i < sigunguCenterList.size(); i++) { Map<String, Object> row = sigunguCenterList.get(i); %>{sido:'<%=row.get("sido")%>', sigungu:'<%=row.get("sigungu")%>', lat:<%=row.get("lat")%>, lng:<%=row.get("lng")%>}<% if (i < sigunguCenterList.size() - 1) { %>,<% } %><% } %>];
  var sigunguCategoryCounts = [<% for (int i = 0; i < sigunguCategoryCountList.size(); i++) { Map<String, Object> row = sigunguCategoryCountList.get(i); %>{sigungu:'<%=row.get("sigungu")%>', lat:<%=row.get("lat")%>, lng:<%=row.get("lng")%>, clubCount:<%=row.get("clubCount")%>, huntingCount:<%=row.get("huntingCount")%>, loungeCount:<%=row.get("loungeCount")%>, pochaCount:<%=row.get("pochaCount")%>}<% if (i < sigunguCategoryCountList.size() - 1) { %>,<% } %><% } %>];
  var regionCenters = [<% for (int i = 0; i < regionCenters.size(); i++) { Map<String, Object> row = regionCenters.get(i); %>{id:<%=row.get("id")%>, sido:'<%=row.get("sido")%>', sigungu:'<%=row.get("sigungu")%>', dong:'<%=row.get("dong")%>', lat:<%=row.get("lat")%>, lng:<%=row.get("lng")%>}<% if (i < regionCenters.size() - 1) { %>,<% } %><% } %>];
  var regionCategoryCounts = [<% for (int i = 0; i < regionCategoryCounts.size(); i++) { Map<String, Object> row = regionCategoryCounts.get(i); %>{region_id:<%=row.get("region_id")%>, clubCount:<%=row.get("clubCount")%>, huntingCount:<%=row.get("huntingCount")%>, loungeCount:<%=row.get("loungeCount")%>, pochaCount:<%=row.get("pochaCount")%>}<% if (i < regionCategoryCounts.size() - 1) { %>,<% } %><% } %>];

  var mapContainer = document.getElementById('map');
  var mapOptions = {
    center: new kakao.maps.LatLng(37.5665, 126.9780),
    level: 7
  };
  var map = new kakao.maps.Map(mapContainer, mapOptions);

  // URL 파라미터가 있으면 해당 위치로 이동
  if (targetLat && targetLng) {
    console.log('URL 파라미터 감지: lat=' + targetLat + ', lng=' + targetLng);
    var targetPosition = new kakao.maps.LatLng(parseFloat(targetLat), parseFloat(targetLng));
    map.setCenter(targetPosition);
    map.setLevel(5); // 줌 레벨 조정
  }

  // 마커/오버레이 배열
  var hotplaceMarkers = [], hotplaceLabels = [], hotplaceInfoWindows = [];
  var hotplaceCategoryIds = [];
  var guOverlays = [], guCountOverlays = [];
  var dongOverlays = [], dongCountOverlays = [];
  var openInfoWindow = null;
  var openRegionCountOverlay = null;

  // 핫플 마커/상호명/인포윈도우 생성
  hotplaces.forEach(function(place) {
    var markerClass = '', markerText = '';
    switch(place.categoryId) {
      case 1: markerClass = 'marker-club'; markerText = 'C'; break;
      case 2: markerClass = 'marker-hunting'; markerText = 'H'; break;
      case 3: markerClass = 'marker-lounge'; markerText = 'L'; break;
      case 4: markerClass = 'marker-pocha'; markerText = 'P'; break;
      default: markerClass = 'marker-club'; markerText = 'C';
    }
    
    var canvas = document.createElement('canvas');
    canvas.width = 32; canvas.height = 32;
    var ctx = canvas.getContext('2d');
    var gradient;
    switch(place.categoryId) {
      case 1: gradient = ctx.createRadialGradient(16,16,0,16,16,16); gradient.addColorStop(0,'#9c27b0'); gradient.addColorStop(1,'#ba68c8'); break;
      case 2: gradient = ctx.createRadialGradient(16,16,0,16,16,16); gradient.addColorStop(0,'#f44336'); gradient.addColorStop(1,'#ef5350'); break;
      case 3: gradient = ctx.createRadialGradient(16,16,0,16,16,16); gradient.addColorStop(0,'#4caf50'); gradient.addColorStop(1,'#66bb6a'); break;
      case 4: gradient = ctx.createRadialGradient(16,16,0,16,16,16); gradient.addColorStop(0,'#8d6e63'); gradient.addColorStop(1,'#a1887f'); break;
    }
    ctx.fillStyle = gradient;
    ctx.beginPath(); ctx.arc(16,16,16,0,2*Math.PI); ctx.fill();
    ctx.shadowColor = 'rgba(0,0,0,0.3)'; ctx.shadowBlur = 4; ctx.shadowOffsetX = 2; ctx.shadowOffsetY = 2;
    ctx.fillStyle = 'white'; ctx.font = 'bold 14px Arial'; ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText(markerText, 16, 16);
    
    var markerImage = new kakao.maps.MarkerImage(canvas.toDataURL(), new kakao.maps.Size(32, 32));
    var marker = new kakao.maps.Marker({ map: null, position: new kakao.maps.LatLng(place.lat, place.lng), image: markerImage });
    var labelOverlay = new kakao.maps.CustomOverlay({ content: '<div class="marker-label">' + place.name + '</div>', position: new kakao.maps.LatLng(place.lat, place.lng), xAnchor: 0.5, yAnchor: 0, map: null });
    
    // 하트 아이콘(위시리스트) 추가: 오른쪽 위 (i 태그, .wish-heart)
    var heartHtml = isLoggedIn ? `<i class="bi bi-heart wish-heart" data-place-id="${place.id}" style="position:absolute;top:12px;right:12px;z-index:10;"></i>` : '';
    var infoContent = ''
      + '<div class="infoWindow" style="position:relative; padding:0; font-size:clamp(12px, 2vw, 16px); line-height:1.4; border-radius:12px; overflow:hidden; box-sizing:border-box;">'
      + '<div class="place-images-container" style="position:relative; width:100%; background:#f8f9fa; display:flex; align-items:center; justify-content:center; color:#6c757d; font-size:clamp(11px, 1.5vw, 13px);" data-place-id="' + place.id + '">이미지 로딩 중...</div>'
      + '<div style="padding:clamp(16px, 3vw, 20px);">'
      + '<div class="place-name-wish-container">'
      + '<strong style="font-size:clamp(14px, 2.5vw, 18px); word-break:break-word;">' + place.name + '</strong>'
      + '<span style="color:#e91e63; font-size:clamp(12px, 2vw, 14px); white-space:nowrap;">💖<span class="wish-count-' + place.id + '" style="color:#e91e63; font-weight:600;">로딩중...</span>명</span>'
      + '</div>'
      + '<div style="margin-bottom:clamp(10px, 2vw, 14px); color:#888; font-size:clamp(10px, 1.8vw, 12px); word-break:break-word;" id="voteTrends-' + place.id + '">📊 역대 투표: 로딩중...</div>'
      + '<div style="margin-bottom:clamp(10px, 2vw, 14px); color:#666; font-size:clamp(11px, 2vw, 13px); word-break:break-word; line-height:1.3;">' + place.address + '</div>'
      + '<div style="color:#9c27b0; font-weight:600; margin-bottom:clamp(10px, 2vw, 14px); font-size:clamp(11px, 2vw, 13px); word-break:break-word;" id="genres-' + place.id + '">🎵 장르: 로딩중...</div>'
      + '<div class="action-buttons-container"><a href="#" onclick="showVoteSection(' + place.id + ', \'' + place.name + '\', \'' + place.address + '\', ' + place.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-weight:500; font-size:clamp(12px, 2vw, 14px); white-space:nowrap; padding:10px 16px; background:#f0f8ff; border-radius:8px; border:1px solid #e3f2fd;">🔥 투표하기</a>'
      + (isAdmin && place.categoryId === 1 ? '<a href="#" onclick="openGenreEditModal(' + place.id + ', \'' + place.name + '\'); return false;" style="color:#ff6b35; text-decoration:none; font-size:clamp(10px, 1.8vw, 12px); white-space:nowrap; padding:8px 14px; background:#fff3e0; border-radius:6px; border:1px solid #ffe0b2;">✏️ 장르 편집</a>' : '') + '</div>'
      + '</div>'
      + '</div>';
      
    var infowindow = new kakao.maps.InfoWindow({ content: infoContent });
    
    kakao.maps.event.addListener(marker, 'click', function() {
      if (openInfoWindow) openInfoWindow.close();
      infowindow.open(map, marker);
      openInfoWindow = infowindow;
      // InfoWindow가 열린 후, 하트 태그와 이미지 로드
      setTimeout(function() {
        var iwEls = document.getElementsByClassName('infoWindow');
        if (iwEls.length > 0) {
          var iw = iwEls[0];
          // 기존 하트가 있으면 제거
          var oldHeart = iw.querySelector('.wish-heart');
          if (oldHeart) oldHeart.remove();
          // 하트 태그 동적으로 생성
          var heart = document.createElement('i');
          heart.className = 'bi bi-heart wish-heart';
          heart.setAttribute('data-place-id', place.id);
          heart.style.position = 'absolute';
          heart.style.top = '12px';
          heart.style.right = '12px';
          heart.style.zIndex = '10';
          iw.appendChild(heart);
          // 로그인 여부에 따라 클릭 이벤트 분기
          if (!isLoggedIn) {
            heart.onclick = function() {
              showToast('위시리스트는 로그인 후 사용할 수 있어요. 간편하게 로그인하고 저장해보세요!', 'error');
            };
          } else {
            // 하트 상태 동기화 및 이벤트 연결
            setupWishHeartByClass(place.id);
          }
          
          // 하트 태그와 동일한 방식으로 이미지 컨테이너 찾기
          const imageContainer = iw.querySelector('.place-images-container');
          if (imageContainer) {
            // DOM이 완전히 준비될 때까지 대기
            setTimeout(function() {
              loadPlaceImages(place.id);
            }, 300);
          }
          
          // 위시리스트 개수 로드
          setTimeout(function() {
            loadWishCount(place.id);
          }, 400);
          
          // 투표 현황 로드
          setTimeout(function() {
            loadVoteTrends(place.id);
          }, 500);
          
          // 장르 정보 로드
          setTimeout(function() {
            loadGenreInfo(place.id);
          }, 600);
          
          // 관리자용 버튼들 추가 (하트와 같은 위치에)
          if (isAdmin) {
            // + 버튼 (이미지 추가)
            var addBtn = document.createElement('button');
            addBtn.onclick = function() { openImageUploadModal(place.id); };
            addBtn.style.cssText = 'position:absolute; top:12px; right:50px; background:#1275E0; color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:18px; font-weight:bold; box-shadow:0 2px 8px rgba(0,0,0,0.3); z-index:10;';
            addBtn.innerHTML = '+';
            iw.appendChild(addBtn);
            
            // 수정 버튼 (이미지 관리)
            var editBtn = document.createElement('button');
            editBtn.onclick = function() { openImageManageModal(place.id); };
            editBtn.style.cssText = 'position:absolute; top:12px; right:88px; background:#ff6b35; color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:14px; font-weight:bold; box-shadow:0 2px 8px rgba(0,0,0,0.3); z-index:10;';
            editBtn.innerHTML = '✏️';
            iw.appendChild(editBtn);
          }
        }
      }, 100);
    });
    
    marker.categoryId = place.categoryId;
    hotplaceMarkers.push(marker);
    hotplaceLabels.push(labelOverlay);
    hotplaceInfoWindows.push(infowindow);
    hotplaceCategoryIds.push(place.categoryId);
  });

  // 카테고리 필터 버튼 클릭 이벤트
  document.addEventListener('DOMContentLoaded', function() {
    var filterBtns = document.querySelectorAll('.category-filter-btn');
    filterBtns.forEach(function(btn) {
      btn.onclick = function() {
        filterBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        var cat = btn.getAttribute('data-category');
        
        hotplaceMarkers.forEach(function(marker, idx) {
          if (cat === 'all' || String(marker.categoryId) === cat) {
            marker.setMap(map);
            if (hotplaceLabels[idx]) hotplaceLabels[idx].setMap(map);
          } else {
            marker.setMap(null);
            if (hotplaceLabels[idx]) hotplaceLabels[idx].setMap(null);
          }
        });
      };
    });
  });

  // 구 오버레이 생성
  sigunguCenters.forEach(function(center) {
    var overlay = new kakao.maps.CustomOverlay({
      content: '<div class="region-label">' + center.sigungu + '</div>',
      position: new kakao.maps.LatLng(center.lat, center.lng),
      xAnchor: 0.5, yAnchor: 0.5, map: null
    });
    guOverlays.push(overlay);
    
    var count = sigunguCategoryCounts.find(c => c.sigungu === center.sigungu);
    var content = '<div class="region-counts">'
      + (count && count.clubCount ? '<span class="region-count-marker marker-club">C <span class="count">' + count.clubCount + '</span></span>' : '')
      + (count && count.huntingCount ? '<span class="region-count-marker marker-hunting">H <span class="count">' + count.huntingCount + '</span></span>' : '')
      + (count && count.loungeCount ? '<span class="region-count-marker marker-lounge">L <span class="count">' + count.loungeCount + '</span></span>' : '')
      + (count && count.pochaCount ? '<span class="region-count-marker marker-pocha">P <span class="count">' + count.pochaCount + '</span></span>' : '')
      + '</div>';
    var countOverlay = new kakao.maps.CustomOverlay({
      content: content,
      position: new kakao.maps.LatLng(center.lat, center.lng),
      xAnchor: 0.5, yAnchor: 1, map: null
    });
    guCountOverlays.push(countOverlay);
  });

  // 동 오버레이 생성
  regionCenters.forEach(function(center) {
    var overlay = new kakao.maps.CustomOverlay({
      content: '<div class="region-label" style="cursor:pointer;" onclick="openRightPanelAndShowDongList(\'' + center.dong + '\')">' + center.dong + '</div>',
      position: new kakao.maps.LatLng(center.lat, center.lng),
      xAnchor: 0.5, yAnchor: 0.5, map: null
    });
    dongOverlays.push(overlay);
  });

  // 지도 레벨별 표시/숨김 토글
  function updateMapOverlays() {
    var level = map.getLevel();
    
    hotplaceMarkers.forEach(m => m.setMap(null));
    hotplaceLabels.forEach(l => l.setMap(null));
    guOverlays.forEach(o => o.setMap(null));
    guCountOverlays.forEach(o => o.setMap(null));
    dongOverlays.forEach(o => o.setMap(null));
    dongCountOverlays.forEach(o => o.setMap(null));
    
    if (openRegionCountOverlay) {
      openRegionCountOverlay.setMap(null);
      openRegionCountOverlay = null;
    }
    
    if (level >= 10) {
      guOverlays.forEach(o => o.setMap(map));
    } else if (level >= 6) {
      dongOverlays.forEach(o => o.setMap(map));
    } else {
      hotplaceMarkers.forEach(m => m.setMap(map));
      hotplaceLabels.forEach(l => l.setMap(map));
    }
  }

  kakao.maps.event.addListener(map, 'zoom_changed', updateMapOverlays);
  updateMapOverlays();

  // 구 오버레이 클릭 이벤트
  guOverlays.forEach(function(overlay, idx) {
    kakao.maps.event.addListener(overlay, 'click', function() {
      if (openRegionCountOverlay) openRegionCountOverlay.setMap(null);
      guCountOverlays[idx].setMap(map);
      openRegionCountOverlay = guCountOverlays[idx];
    });
  });

  // 지도 빈 공간 클릭 시 인포윈도우/카테고리 오버레이 닫기
  kakao.maps.event.addListener(map, 'click', function() {
    if (openInfoWindow) {
      openInfoWindow.close();
      openInfoWindow = null;
    }
    if (openRegionCountOverlay) {
      openRegionCountOverlay.setMap(null);
      openRegionCountOverlay = null;
    }
  });

  function moveToCurrentLocation() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(pos) {
        var loc = new kakao.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
        map.setCenter(loc);
        map.setLevel(5);
        new kakao.maps.Marker({ position: loc, map: map });
      }, function() {
        alert('위치 정보를 가져올 수 없습니다.');
      });
    } else {
      alert('이 브라우저에서는 위치 정보가 지원되지 않습니다.');
    }
  }

  // 투표 섹션 표시 함수
  function showVoteSection(hotplaceId, name, address, categoryId) {
    if (typeof showVoteForm === 'function') {
      showVoteForm(hotplaceId, name, address, categoryId);
    }
  }

  // 하트 상태 동기화 및 클릭 이벤트 (class 기반)
  function setupWishHeartByClass(placeId, retryCount = 0) {
    var hearts = document.getElementsByClassName('wish-heart');
    var found = false;
    Array.from(hearts).forEach(function(heart) {
      if (heart.getAttribute('data-place-id') == placeId) {
        found = true;
        // JWT 토큰 가져오기
        var token = localStorage.getItem('accessToken');
        
        // 찜 여부 확인 (Spring API 호출)
        fetch(rootPath + '/api/main/wish', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': token ? 'Bearer ' + token : ''
          },
          body: 'action=check&placeId=' + placeId
        })
          .then(res => res.json())
          .then(data => {
            if (data.result === true) {
              heart.classList.add('on');
              heart.classList.remove('bi-heart');
              heart.classList.add('bi-heart-fill');
            } else {
              heart.classList.remove('on');
              heart.classList.remove('bi-heart-fill');
              heart.classList.add('bi-heart');
            }
          });
        // 찜/찜 해제 이벤트
        heart.onclick = function() {
          var isWished = heart.classList.contains('on');
          var action = isWished ? 'remove' : 'add';
          fetch(rootPath + '/api/main/wish', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': token ? 'Bearer ' + token : ''
            },
            body: 'action=' + action + '&placeId=' + placeId
          })
            .then(res => res.json())
            .then(data => {
              if (data.result === true) {
                if (isWished) {
                  heart.classList.remove('on');
                  heart.classList.remove('bi-heart-fill');
                  heart.classList.add('bi-heart');
                } else {
                  heart.classList.add('on');
                  heart.classList.remove('bi-heart');
                  heart.classList.add('bi-heart-fill');
                }
              }
            });
        };
      }
    });
    if (!found && retryCount < 5) {
      setTimeout(function() {
        setupWishHeartByClass(placeId, retryCount + 1);
      }, 100);
    }
  }

  // 오른쪽 패널 토글 기능 (버튼 위치 동적 변경)
  document.addEventListener('DOMContentLoaded', function() {
    var openBtn = document.getElementById('rightPanelToggleBtn');
    var closeBtn = document.getElementById('rightPanelCloseBtn');
    var panel = document.getElementById('rightPanel');
    // 초기 상태: 패널 닫힘, < 버튼만 지도 오른쪽 끝에 보임
    panel.style.transform = 'translateX(100%)';
    openBtn.style.display = 'flex';
    closeBtn.style.display = 'none';
    openBtn.innerHTML = '&lt;';
    openBtn.onclick = function() {
      panel.style.transform = 'translateX(0)';
      openBtn.style.display = 'none';
      closeBtn.style.display = 'flex';
    };
    closeBtn.onclick = function() {
      panel.style.transform = 'translateX(100%)';
      closeBtn.style.display = 'none';
      setTimeout(function() { openBtn.style.display = 'flex'; }, 350);
    };
    
    // 검색 타입 드롭다운 동작
    var searchTypeBtn = document.getElementById('searchTypeBtn');
    var searchTypeList = document.getElementById('searchTypeList');
    var searchTypeText = document.getElementById('searchTypeText');
    var searchTypeItems = searchTypeList.querySelectorAll('.search-type-item');
    var dropdownOpen = false;
    searchTypeBtn.onclick = function(e) {
      e.stopPropagation();
      dropdownOpen = !dropdownOpen;
      searchTypeList.classList.toggle('show', dropdownOpen);
      searchTypeBtn.classList.toggle('active', dropdownOpen);
    };
    searchTypeItems.forEach(function(item) {
      item.onclick = function(e) {
        e.stopPropagation();
        searchTypeItems.forEach(i => i.classList.remove('selected'));
        item.classList.add('selected');
        searchTypeText.textContent = item.getAttribute('data-type');
        dropdownOpen = false;
        searchTypeList.classList.remove('show');
        searchTypeBtn.classList.remove('active');
      };
    });
    document.addEventListener('click', function() {
      dropdownOpen = false;
      searchTypeList.classList.remove('show');
      searchTypeBtn.classList.remove('active');
    });
    
    // 자동완성(오토컴플릿) UI/로직
    var searchInput = document.getElementById('searchInput');
    var autocompleteList = document.getElementById('autocompleteList');
    var searchTypeText = document.getElementById('searchTypeText');
    function showAutocompleteList() {
      var keyword = searchInput.value.trim();
      if (!keyword) { autocompleteList.style.display = 'none'; return; }
      var type = searchTypeText.textContent;
      var list = (type === '지역') ? regionNameList : hotplaceNameList;
      var filtered = list.filter(function(item) {
        return item && item.toLowerCase().indexOf(keyword.toLowerCase()) !== -1;
      }).slice(0, 8); // 최대 8개
      if (filtered.length === 0) { autocompleteList.style.display = 'none'; return; }
      autocompleteList.innerHTML = filtered.map(function(item) {
        return '<div class="autocomplete-item" style="padding:10px 18px; font-size:1.04rem; color:#222 !important; cursor:pointer; transition:background 0.13s; border-bottom:1px solid #f3f3f3; background:transparent;">' + (item && item.length > 0 ? item : '(빈값)') + '</div>';
      }).join('');
      autocompleteList.style.display = 'flex';
      // 항목 클릭 시 입력창에 반영
      Array.from(autocompleteList.children).forEach(function(child) {
        child.onclick = function() {
          searchInput.value = child.textContent;
          autocompleteList.style.display = 'none';
        };
      });
    }
    searchInput.addEventListener('input', showAutocompleteList);
    searchInput.addEventListener('focus', showAutocompleteList);
    searchInput.addEventListener('blur', function() {
      setTimeout(function() { autocompleteList.style.display = 'none'; }, 120);
    });
    // 스타일: hover 효과
    var style = document.createElement('style');
    style.innerHTML = `.autocomplete-item:hover { background: #f0f4fa !important; color: #1275E0 !important; }`;
    document.head.appendChild(style);
  });

  // 전역 함수들
  window.openRightPanelAndShowDongList = function(dong) {
    var panel = document.getElementById('rightPanel');
    var openBtn = document.getElementById('rightPanelToggleBtn');
    var closeBtn = document.getElementById('rightPanelCloseBtn');
    panel.style.transform = 'translateX(0)';
    if (openBtn) openBtn.style.display = 'none';
    if (closeBtn) closeBtn.style.display = 'flex';
    
    window.renderHotplaceListByDong(dong, null);
  }

  window.selectedDong = null;
  window.selectedCategory = null;

  // 검색 결과 렌더링 함수 추가
  document.addEventListener('DOMContentLoaded', function() {
    var searchResultBox = document.getElementById('searchResultBox');
    var searchInput = document.getElementById('searchInput');
    
    // window에 searchResultBox 추가
    window.searchResultBox = searchResultBox;
    
    function renderSearchResult() {
      var keyword = searchInput.value.trim();
      var type = document.getElementById('searchTypeText').textContent;
      var list = (type === '지역') ? regionNameList : hotplaceNameList;
      var filtered = list.filter(function(item) {
        return item && item.toLowerCase().indexOf(keyword.toLowerCase()) !== -1;
      });
      
      // 카테고리 바 표시/숨김
      var catBar = document.getElementById('categoryCountsBar');
      if (type === '가게') {
        catBar.style.display = 'none';
      }
      if (!keyword) {
        searchResultBox.innerHTML = '<div style="color:#bbb; text-align:center; padding:40px 0;">검색어를 입력해 주세요.</div>';
        return;
      }
      if (filtered.length === 0) {
        searchResultBox.innerHTML = '<div style="color:#bbb; text-align:center; padding:40px 0;">검색 결과가 없습니다.</div>';
        return;
      }
      if (type === '지역') {
        // 지역명 리스트를 네이버 스타일로, 클릭 시 해당 지역의 핫플 리스트 출력
        searchResultBox.innerHTML = filtered.map(function(dong, idx) {
          var regionId = dongToRegionId[dong];
          var count = regionCategoryCounts.find(function(c) { return String(c.region_id) === String(regionId); });
          var countHtml = '';
          if (count) {
            countHtml = '<span style="margin-left:10px; font-size:0.98rem; color:#888; display:inline-flex; gap:7px; align-items:center;">'
              + '<span style="color:#9c27b0; font-weight:600;">C:' + (typeof count.clubCount === 'number' ? count.clubCount : 0) + '</span>'
              + '<span style="color:#f44336; font-weight:600; margin-left:4px;">H:' + (typeof count.huntingCount === 'number' ? count.huntingCount : 0) + '</span>'
              + '<span style="color:#4caf50; font-weight:600; margin-left:4px;">L:' + (typeof count.loungeCount === 'number' ? count.loungeCount : 0) + '</span>'
              + '<span style="color:#8d6e63; font-weight:600; margin-left:4px;">P:' + (typeof count.pochaCount === 'number' ? count.pochaCount : 0) + '</span>'
              + '</span>';
          }
          return '<div class="region-search-item" style="width:92%; margin:'
            + (idx === 0 ? '14px' : '0') + ' auto 10px auto; background:#fff; border-radius:8px; box-shadow:0 2px 8px rgba(0,0,0,0.04); padding:16px 18px; color:#222; font-size:1.08rem; display:flex; align-items:center; cursor:pointer; transition:background 0.13s;">'
            + '<span class="region-name" style="color:#1275E0; font-weight:600; font-size:1.13rem; cursor:pointer; display:flex; align-items:center; white-space:nowrap;">' + dong + '</span>'
            + countHtml
            + '</div>';
        }).join('');
        // 지역명 클릭 이벤트 바인딩
        Array.from(document.getElementsByClassName('region-search-item')).forEach(function(item) {
          var dong = item.querySelector('.region-name').textContent;
          // 평점 부분 제거 (예: "홍대입구 (★ 5.0)" -> "홍대입구")
          dong = dong.replace(/\s*\([^)]*\)\s*$/, '');
          item.onclick = function() {
            renderHotplaceListByDong(dong);
          };
        });
      } else {
        // 가게명 리스트를 카드 형태로 출력
        var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차'};
        var matchedHotplaces = window.hotplaces.filter(function(h) {
          return filtered.includes(h.name);
        });
        searchResultBox.innerHTML = matchedHotplaces.map(function(h) {
          var heartHtml = isLoggedIn ? '<i class="bi bi-heart wish-heart" data-place-id="'+h.id+'" style="font-size:1.25rem; color:#e74c3c; cursor:pointer;"></i>' : '<i class="bi bi-heart wish-heart" style="font-size:1.25rem; color:#bbb; cursor:pointer;"></i>';
          var voteButtonHtml = '<a href="#" onclick="showVoteSection(' + h.id + ', \'' + h.name + '\', \'' + h.address + '\', ' + h.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-size:0.95rem;">🔥 투표</a>';
          var genreHtml = (h.genres && h.genres !== '') ? '<div style="color:#9c27b0; font-weight:600; margin-top:2px; font-size:0.9rem;">🎵 장르: ' + h.genres + '</div>' : '';
          return '<div class="hotplace-list-card">'
            + '<div style="flex:1; min-width:0;">'
            +   '<div style="display:flex; align-items:center; gap:6px;">'
            +     '<span class="hotplace-name" style="color:#1275E0; font-weight:600; cursor:pointer;">' + h.name + '</span>'
            +     '<span class="hotplace-category" style="color:#888; margin-left:4px;">' + (categoryMap[h.categoryId]||'') + '</span>'
            +   '</div>'
            +   '<div class="hotplace-address" style="color:#666; margin-top:2px;">' + h.address + '</div>'
            + genreHtml
            + '</div>'
            + '<div class="hotplace-card-heart">' + heartHtml + '</div>'
            + '<div class="hotplace-card-actions">' + voteButtonHtml + '</div>'
            + '</div>';
        }).join('');
        setTimeout(function() {
          Array.from(document.getElementsByClassName('hotplace-list-card')).forEach(function(card) {
            var heart = card.querySelector('.wish-heart');
            var placeName = card.querySelector('.hotplace-name').textContent;
            var place = matchedHotplaces.find(function(h) { return h.name === placeName; });
            if (!heart || !place) return;
            if (!isLoggedIn) {
              heart.onclick = function() {
                showToast('위시리스트는 로그인 후 사용할 수 있어요. 간편하게 로그인하고 저장해보세요!', 'error');
              };
            } else {
              heart.setAttribute('data-place-id', place.id);
              setupWishHeartByClass(place.id);
            }
            // 가게명/카테고리 클릭 시 지도 이동
            function moveToHotplace(e) {
              e.stopPropagation();
              var latlng = new kakao.maps.LatLng(place.lat, place.lng);
              map.setLevel(5);
              map.setCenter(latlng);
            }
            var placeNameEl = card.querySelector('.hotplace-name');
            var placeCategoryEl = card.querySelector('.hotplace-category');
            placeNameEl.style.cursor = 'pointer';
            placeCategoryEl.style.cursor = 'pointer';
            placeNameEl.onclick = moveToHotplace;
            placeCategoryEl.onclick = moveToHotplace;
          });
        }, 100);
      }
    }
    
    // 검색 버튼/엔터 이벤트
    var searchForm = searchInput.closest('form');
    searchForm.onsubmit = function(e) {
      e.preventDefault();
      renderSearchResult();
    };
    document.getElementById('searchBtn').onclick = function(e) {
      e.preventDefault();
      renderSearchResult();
    };
  });

  // 전역에 선언: 동(지역)별 핫플 리스트 네이버 스타일로 출력
  window.renderHotplaceListByDong = function(dong, categoryId) {
    window.selectedDong = dong;
    window.selectedCategory = categoryId || null;
    var regionId = window.dongToRegionId[dong];
    
    var catBar = document.getElementById('categoryCountsBar');
    if (!regionId) {
      catBar.style.display = 'none';
      window.searchResultBox.innerHTML = '<div style="color:#bbb; text-align:center; padding:40px 0;">해당 지역의 핫플레이스가 없습니다.</div>';
      return;
    }
    var filtered = window.hotplaces.filter(function(h) {
      if (h.regionId !== regionId) return false;
      if (categoryId && String(h.categoryId) !== String(categoryId)) return false;
      return true;
    });
    // 카테고리별 개수는 항상 표시 (0이어도)
    var count = (window.regionCategoryCounts || []).find(function(c) { return String(c.region_id) === String(regionId); }) || {};
    var clubCount = (typeof count.clubCount === 'number') ? count.clubCount : 0;
    var huntingCount = (typeof count.huntingCount === 'number') ? count.huntingCount : 0;
    var loungeCount = (typeof count.loungeCount === 'number') ? count.loungeCount : 0;
    var pochaCount = (typeof count.pochaCount === 'number') ? count.pochaCount : 0;
    var catHtml = '<div class="dong-category-counts-bar">'
      + '<span class="category-ball marker-club' + (categoryId==1?' active':'') + '" data-category="1">C</span> <span class="cat-count-num" style="color:#9c27b0;">' + clubCount + '</span>'
      + '<span class="category-ball marker-hunting' + (categoryId==2?' active':'') + '" data-category="2">H</span> <span class="cat-count-num" style="color:#f44336;">' + huntingCount + '</span>'
      + '<span class="category-ball marker-lounge' + (categoryId==3?' active':'') + '" data-category="3">L</span> <span class="cat-count-num" style="color:#4caf50;">' + loungeCount + '</span>'
      + '<span class="category-ball marker-pocha' + (categoryId==4?' active':'') + '" data-category="4">P</span> <span class="cat-count-num" style="color:#8d6e63;">' + pochaCount + '</span>'
      + '</div>';
    catBar.innerHTML = catHtml;
    catBar.style.display = 'flex';
    // 카테고리 원 클릭 이벤트 바인딩
    Array.from(catBar.getElementsByClassName('category-ball')).forEach(function(ball) {
      ball.onclick = function() {
        var cat = ball.getAttribute('data-category');
        if (window.selectedCategory && String(window.selectedCategory) === String(cat)) {
          window.renderHotplaceListByDong(dong, null); // 전체
        } else {
          window.renderHotplaceListByDong(dong, cat);
        }
      };
    });
    
    var dongTitle = '<div style="font-size:1.13rem; font-weight:600; color:#1275E0; margin:14px 0 8px 0; display:flex; align-items:center;">지역: ' + dong + '</div>';
    if (filtered.length === 0) {
      window.searchResultBox.innerHTML = dongTitle + '<div style="color:#bbb; text-align:center; padding:40px 0;">해당 지역의 핫플레이스가 없습니다.</div>';
      return;
    }
    var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차'};
    window.searchResultBox.innerHTML = dongTitle + filtered.map(function(h) {
      var heartHtml = isLoggedIn ? '<i class="bi bi-heart wish-heart" data-place-id="'+h.id+'" style="font-size:1.25rem; color:#e74c3c; cursor:pointer;"></i>' : '<i class="bi bi-heart wish-heart" style="font-size:1.25rem; color:#bbb; cursor:pointer;"></i>';
      var voteButtonHtml = '<a href="#" onclick="showVoteSection(' + h.id + ', \'' + h.name + '\', \'' + h.address + '\', ' + h.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-size:0.95rem;">🔥 투표</a>';
      var genreHtml = (h.genres && h.genres !== '') ? '<div style="color:#9c27b0; font-weight:600; margin-top:2px; font-size:0.9rem;">장르: ' + h.genres + '</div>' : '';
      return '<div class="hotplace-list-card">'
        + '<div style="flex:1; min-width:0;">'
        +   '<div style="display:flex; align-items:center; gap:6px;">'
        +     '<span class="hotplace-name" style="color:#1275E0; font-weight:600; cursor:pointer;">' + h.name + '</span>'
        +     '<span class="hotplace-category" style="color:#888; margin-left:4px;">' + (categoryMap[h.categoryId]||'') + '</span>'
        +   '</div>'
        +   '<div class="hotplace-address" style="color:#666; margin-top:2px;">' + h.address + '</div>'
        + genreHtml
        + '</div>'
        + '<div class="hotplace-card-heart">' + heartHtml + '</div>'
        + '<div class="hotplace-card-actions">' + voteButtonHtml + '</div>'
        + '</div>';
    }).join('');
    setTimeout(function() {
      Array.from(document.getElementsByClassName('hotplace-list-card')).forEach(function(card) {
        var heart = card.querySelector('.wish-heart');
        var placeName = card.querySelector('.hotplace-name').textContent;
        var place = filtered.find(function(h) { return h.name === placeName; });
        if (!heart || !place) return;
        if (!isLoggedIn) {
          heart.onclick = function() {
            showToast('위시리스트는 로그인 후 사용할 수 있어요. 간편하게 로그인하고 저장해보세요!', 'error');
          };
        } else {
          heart.setAttribute('data-place-id', place.id);
          setupWishHeartByClass(place.id);
        }
        // 가게명/카테고리 클릭 시 지도 이동
        function moveToHotplace(e) {
          e.stopPropagation();
          var latlng = new kakao.maps.LatLng(place.lat, place.lng);
          map.setLevel(5);
          map.setCenter(latlng);
        }
        var placeNameEl = card.querySelector('.hotplace-name');
        var placeCategoryEl = card.querySelector('.hotplace-category');
        placeNameEl.style.cursor = 'pointer';
        placeCategoryEl.style.cursor = 'pointer';
        placeNameEl.onclick = moveToHotplace;
        placeCategoryEl.onclick = moveToHotplace;
      });
    }, 100);
  }

  // 스타일
  var style = document.createElement('style');
  style.innerHTML = `
    /* 동/구 라벨은 클릭 가능해야 하므로 pointer-events: auto */
    .region-label {
      pointer-events: auto !important;
    }
    /* 카테고리 개수 오버레이만 클릭 막기 */
    .region-counts, .dong-category-counts {
      pointer-events: none !important;
    }
    /* 지도 위치 버튼 스타일 개선 */
    .map-location-btn {
      width: 110px !important;
      min-width: unset !important;
      padding: 4px 10px !important;
      font-size: 0.85rem !important;
      border-radius: 18px !important;
      box-shadow: 0 2px 8px rgba(0,0,0,0.08);
      background: #fff;
      color: #1275E0;
      border: 1.5px solid #1275E0;
      transition: background 0.15s, color 0.15s;
      display: block !important;
      margin-left: 0 !important;
      float: left !important;
    }
    .map-location-btn:hover {
      background: #1275E0;
      color: #fff;
    }
    /* 카테고리 필터 버튼 스타일 (마커 스타일과 동일) */
    .category-filter-btn {
      border: none;
      outline: none;
      border-radius: 50px;
      padding: 4px 12px;
      font-size: 0.92rem;
      font-weight: bold;
      color: #fff;
      background: #bbb;
      cursor: pointer;
      transition: background 0.18s, color 0.18s, box-shadow 0.18s;
      box-shadow: 0 2px 8px rgba(0,0,0,0.10);
      opacity: 0.82;
      min-width: 32px;
      min-height: 32px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .category-filter-btn.active {
      border: 2.5px solid #222;
      opacity: 1;
      color: #222;
      background: #fff;
    }
    .category-filter-btn.marker-club { background: linear-gradient(135deg, #9c27b0, #ba68c8); color: #fff; }
    .category-filter-btn.marker-hunting { background: linear-gradient(135deg, #f44336, #ef5350); color: #fff; }
    .category-filter-btn.marker-lounge { background: linear-gradient(135deg, #4caf50, #66bb6a); color: #fff; }
    .category-filter-btn.marker-pocha { background: linear-gradient(135deg, #8d6e63, #a1887f); color: #fff; }
    .category-filter-btn:not(.active):hover {
      filter: brightness(1.08);
      opacity: 1;
    }
  `;
  document.head.appendChild(style);

  /* 추가 스타일 */
  var panelStyle = document.createElement('style');
  panelStyle.innerHTML = `
    #rightPanel::-webkit-scrollbar { width: 8px; background: #f5f5f5; }
    #rightPanel::-webkit-scrollbar-thumb { background: #ddd; border-radius: 4px; }
    #searchBar input:focus { border:1.5px solid #1275E0; background:#fff; }
    #searchBar input::placeholder { color:#bbb; font-weight:400; }
    #searchBar { box-shadow:0 2px 8px rgba(0,0,0,0.04); border-radius:16px 16px 0 0; }
  `;
  document.head.appendChild(panelStyle);

  // ================================
  // 플레이스홀더 함수들 (필요한 JSP 파일들이 구현되면 완전히 작동)
  // ================================

  // showToast 함수 정의 (개선된 토스트 UI)
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

  // 이미지 로드 함수 (Spring API 호출)
  function loadPlaceImages(placeId, retryCount = 0) {
    const containers = document.querySelectorAll('.place-images-container[data-place-id="' + placeId + '"]');
    
    if (containers.length === 0) {
      if (retryCount < 3) {
        setTimeout(() => loadPlaceImages(placeId, retryCount + 1), 200);
      }
      return;
    }
    
    // Spring API 호출
    fetch(root + '/api/main/place-images?placeId=' + placeId)
      .then(response => response.json())
      .then(data => {
        containers.forEach(container => {
          if (data.success && data.images && data.images.length > 0) {
            // 이미지가 있는 경우 - 대표 이미지 표시
            const currentImage = data.images[0];
            const timestamp = Date.now();
            
            let imageHtml = '<div class="place-image-slider" style="position:relative; width:100%; height:100%;">' +
              '<img src="' + root + currentImage.imagePath + '?t=' + timestamp + '" alt="장소 이미지" ' +
                   'style="width:100%; height:100%; object-fit:cover; cursor:pointer;" ' +
                   'onclick="openImageModal(\'' + root + currentImage.imagePath + '\', ' + placeId + ', 0)">' +
              
              (data.images.length > 1 ? 
                '<button class="image-nav-btn prev-btn" onclick="changeImage(' + placeId + ', ' + data.images.length + ', 0, -1)" ' +
                        'style="position:absolute; left:10px; top:50%; transform:translateY(-50%); background:rgba(0,0,0,0.6); color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:16px;">‹</button>' +
                '<button class="image-nav-btn next-btn" onclick="changeImage(' + placeId + ', ' + data.images.length + ', 0, 1)" ' +
                        'style="position:absolute; right:10px; top:50%; transform:translateY(-50%); background:rgba(0,0,0,0.6); color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:16px;">›</button>'
              : '') +
              
              '<div style="position:absolute; bottom:10px; right:10px; background:rgba(0,0,0,0.7); color:white; padding:4px 8px; border-radius:12px; font-size:11px;">' +
                '1 / ' + data.images.length +
              '</div>' +
            '</div>';
            
            container.innerHTML = imageHtml;
          } else {
            // 이미지가 없는 경우
            container.innerHTML = '<div class="no-images" style="position:relative; width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:#f8f9fa; color:#6c757d; font-size:13px;">' +
              '<div style="text-align:center;">' +
                '<div style="font-size:48px; margin-bottom:8px;">📷</div>' +
                '<div>사진이 없습니다</div>' +
              '</div>' +
            '</div>';
          }
        });
      })
      .catch(error => {
        console.error('이미지 로드 오류:', error);
        containers.forEach(container => {
          container.innerHTML = '<div class="no-images" style="padding:20px; text-align:center; background:#f8f9fa; border-radius:8px; color:#6c757d; font-size:13px;">이미지 로드 실패</div>';
        });
      });
  }

  // 위시리스트 개수 로드 함수 (Spring API 호출)
  function loadWishCount(placeId) {
    const wishCountElement = document.querySelector('.wish-count-' + placeId);
    if (!wishCountElement) return;
    
    // Spring API 호출
    fetch(root + '/api/main/wish-count', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'placeId=' + placeId
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        wishCountElement.textContent = data.count;
      } else {
        wishCountElement.textContent = '0';
      }
    })
    .catch(error => {
      console.error('위시리스트 개수 로드 오류:', error);
      wishCountElement.textContent = '0';
    });
  }

  // 투표 현황 로드 함수 (Spring API 호출)
  function loadVoteTrends(placeId) {
    const trendsElement = document.getElementById('voteTrends-' + placeId);
    if (!trendsElement) return;
    
    // Spring API 호출
    fetch(root + '/api/main/vote-trends', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'placeId=' + placeId
    })
    .then(response => response.json())
    .then(data => {
      if (data.success && data.trends) {
        const trends = data.trends;
        
        const congestionText = trends.congestion || '데이터없음';
        const genderRatioText = trends.genderRatio || '데이터없음';
        const waitTimeText = trends.waitTime || '데이터없음';
        
        trendsElement.innerHTML = '📊 역대 투표:<br>' +
          '<span style="color:#888; font-size:11px;">' +
          '#혼잡도:' + congestionText + ' ' +
          '#성비:' + genderRatioText + ' ' +
          '#대기시간:' + waitTimeText +
          '</span>';
      } else {
        trendsElement.innerHTML = '📊 역대 투표: 투표 데이터 없음';
      }
    })
    .catch(error => {
      console.error('투표 현황 로드 오류:', error);
      trendsElement.innerHTML = '📊 역대 투표: 로드 실패';
    });
  }

  // 장르 정보 로드 함수 (Spring API 호출)
  function loadGenreInfo(placeId) {
    const genresElement = document.getElementById('genres-' + placeId);
    if (!genresElement) return;
    
    // Spring API 호출
    fetch(root + '/api/main/genre', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'action=getGenres&placeId=' + placeId
    })
    .then(response => response.json())
    .then(data => {
      if (data.success && data.genres) {
        // 선택된 장르들만 필터링
        const selectedGenres = data.genres.filter(genre => genre.isSelected);
        
        if (selectedGenres.length > 0) {
          const genreNames = selectedGenres.map(genre => genre.genreName).join(', ');
          genresElement.innerHTML = '🎵 장르: ' + genreNames;
        } else {
          genresElement.innerHTML = '🎵 장르: 미분류';
        }
      } else {
        genresElement.innerHTML = '🎵 장르: 미분류';
      }
    })
    .catch(error => {
      console.error('장르 정보 로드 오류:', error);
      genresElement.innerHTML = '🎵 장르: 로드 실패';
    });
  }

  // 이미지 업로드 모달 (Spring API 기반)
  function openImageUploadModal(placeId) {
    const modal = document.createElement('div');
    modal.id = 'imageUploadModal';
    modal.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.8);
      z-index: 10000;
      display: flex;
      align-items: center;
      justify-content: center;
    `;
    
    modal.innerHTML = '<div style="background:white; padding:24px; border-radius:12px; max-width:500px; width:90%; max-height:90%; overflow-y:auto;">' +
      '<div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">' +
        '<h3 style="margin:0; color:#333;">이미지 추가</h3>' +
        '<button onclick="closeImageUploadModal()" style="background:none; border:none; font-size:24px; cursor:pointer; color:#666;">&times;</button>' +
      '</div>' +
      
      '<form id="imageUploadForm" action="' + root + '/api/main/upload-images" method="post" enctype="multipart/form-data">' +
        '<input type="hidden" name="place_id" value="' + placeId + '">' +
        '<div style="margin-bottom:16px;">' +
          '<label style="display:block; margin-bottom:8px; font-weight:500; color:#333;">이미지 파일 선택 (여러장 가능)</label>' +
          '<input type="file" name="images" multiple accept="image/*" style="width:100%; padding:8px; border:1px solid #ddd; border-radius:6px;" required>' +
        '</div>' +
        
        '<div style="display:flex; gap:8px; justify-content:flex-end;">' +
          '<button type="button" onclick="closeImageUploadModal()" style="background:#6c757d; color:white; border:none; padding:10px 20px; border-radius:6px; cursor:pointer;">취소</button>' +
          '<button type="submit" style="background:#1275E0; color:white; border:none; padding:10px 20px; border-radius:6px; cursor:pointer;">업로드</button>' +
        '</div>' +
      '</form>' +
    '</div>';
    
    document.body.appendChild(modal);
    
    // 폼 제출 이벤트 (JWT 토큰 포함)
    document.getElementById('imageUploadForm').onsubmit = function(e) {
      e.preventDefault();
      
      const token = localStorage.getItem('accessToken');
      const formData = new FormData(this);
      
      fetch(root + '/api/main/upload-images', {
        method: 'POST',
        headers: {
          'Authorization': token ? 'Bearer ' + token : ''
        },
        body: formData
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          showToast('이미지가 성공적으로 업로드되었습니다.', 'success');
          closeImageUploadModal();
          // 이미지 새로고침
          setTimeout(() => loadPlaceImages(placeId), 500);
        } else {
          showToast(data.message || '이미지 업로드에 실패했습니다.', 'error');
        }
      })
      .catch(error => {
        showToast('이미지 업로드 중 오류가 발생했습니다: ' + error.message, 'error');
      });
    };
  }

  // 이미지 관리 모달 (Spring API 기반)
  function openImageManageModal(placeId) {
    const modal = document.createElement('div');
    modal.id = 'imageManageModal';
    modal.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.8);
      z-index: 10000;
      display: flex;
      align-items: center;
      justify-content: center;
    `;
    
    modal.innerHTML = '<div style="background:white; padding:24px; border-radius:12px; max-width:800px; width:90%; max-height:90%; overflow-y:auto;">' +
      '<div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">' +
        '<h3 style="margin:0; color:#333;">이미지 관리</h3>' +
        '<button onclick="closeImageManageModal()" style="background:none; border:none; font-size:24px; cursor:pointer; color:#666;">&times;</button>' +
      '</div>' +
      
      '<div id="imageManageContent" style="min-height:200px; display:flex; align-items:center; justify-content:center; color:#666;">' +
        '<div>이미지 로딩 중...</div>' +
      '</div>' +
    '</div>';
    
    document.body.appendChild(modal);
    
    // 이미지 목록 로드
    loadImagesForManagement(placeId);
  }

  // 장르 편집 모달 (Spring API 기반)
  function openGenreEditModal(placeId, placeName) {
    // 장르 목록 가져오기 (POST 방식으로 변경)
    fetch(root + '/api/main/genre', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'action=getGenres&placeId=' + placeId
    })
    .then(response => response.json())
    .then(data => {
      if(data.success) {
        showGenreEditModal(placeId, placeName, data.genres);
      } else {
        showToast('장르 목록을 불러오는데 실패했습니다.', 'error');
      }
    })
    .catch(error => {
      showToast('장르 목록을 불러오는데 실패했습니다: ' + error.message, 'error');
    });
  }

  // 이미지 모달 (플레이스홀더)
  function openImageModal(imagePath, placeId, currentIndex) {
    window.open(imagePath, '_blank');
  }

  function closeImageModal() {
    // 플레이스홀더
  }

  function changeImage(placeId, totalImages, currentIndex, direction) {
    // 플레이스홀더
  }

  function changeModalImage(direction) {
    // 플레이스홀더
  }

  // 모달 닫기 함수들
  function closeImageUploadModal() {
    const modal = document.getElementById('imageUploadModal');
    if (modal) modal.remove();
  }

  function closeImageManageModal() {
    const modal = document.getElementById('imageManageModal');
    if (modal) modal.remove();
  }

  // 이미지 관리용 헬퍼 함수들
  function loadImagesForManagement(placeId) {
    const contentDiv = document.getElementById('imageManageContent');
    if (!contentDiv) return;
    
    fetch(root + '/api/main/place-images?placeId=' + placeId)
      .then(response => response.json())
      .then(data => {
        if (data.success && data.images && data.images.length > 0) {
          // 이미지가 있는 경우 - 그리드 형태로 표시
          let imagesHtml = '<div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(200px, 1fr)); gap:16px; margin-bottom:20px;">';
          
          data.images.forEach((image, index) => {
            const timestamp = Date.now();
            
            // 대표사진 변경 버튼 (1번이 아닌 이미지에만 표시)
            const mainImageButton = image.imageOrder !== 1 ? 
              '<button onclick="setAsMainImage(' + image.id + ', ' + placeId + ')" ' +
              'style="background:#28a745; color:white; border:none; padding:6px 12px; border-radius:4px; cursor:pointer; font-size:12px; margin-left:4px;">대표사진</button>' : '';
            
            imagesHtml += '<div style="position:relative; border:1px solid #ddd; border-radius:8px; overflow:hidden; background:#f8f9fa;">' +
              '<img src="' + root + image.imagePath + '?t=' + timestamp + '" ' +
                   'style="width:100%; height:150px; object-fit:cover;" alt="이미지 ' + (index + 1) + '">' +
              '<div style="padding:12px; text-align:center;">' +
                '<div style="font-size:12px; color:#666; margin-bottom:8px;">순서: ' + image.imageOrder + '</div>' +
                '<div style="display:flex; gap:4px; justify-content:center;">' +
                  '<button onclick="deleteImage(' + image.id + ', ' + placeId + ')" ' +
                          'style="background:#dc3545; color:white; border:none; padding:6px 12px; border-radius:4px; cursor:pointer; font-size:12px;">삭제</button>' +
                  mainImageButton +
                '</div>' +
              '</div>' +
            '</div>';
          });
          
          imagesHtml += '</div>';
          contentDiv.innerHTML = imagesHtml;
        } else {
          // 이미지가 없는 경우
          contentDiv.innerHTML = '<div style="text-align:center; color:#666;">' +
            '<div style="font-size:48px; margin-bottom:16px;">📷</div>' +
            '<div>등록된 이미지가 없습니다</div>' +
          '</div>';
        }
      })
      .catch(error => {
        console.error('이미지 로드 오류:', error);
        contentDiv.innerHTML = '<div style="text-align:center; color:#dc3545;">이미지 로드에 실패했습니다</div>';
      });
  }

  // 이미지 삭제 함수 (Spring API)
  function deleteImage(imageId, placeId) {
    if (!confirm('정말로 이 이미지를 삭제하시겠습니까?')) return;
    
    const token = localStorage.getItem('accessToken');
    
    fetch(root + '/api/main/delete-image', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': token ? 'Bearer ' + token : ''
      },
      body: 'imageId=' + imageId
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // 성공 시 이미지 목록 새로고침
        loadImagesForManagement(placeId);
        
        // InfoWindow의 이미지도 새로고침
        setTimeout(() => loadPlaceImages(placeId), 500);
        
        showToast('이미지가 성공적으로 삭제되었습니다.', 'success');
      } else {
        showToast(data.message || '이미지 삭제에 실패했습니다.', 'error');
      }
    })
    .catch(error => {
      showToast('이미지 삭제 중 오류가 발생했습니다: ' + error.message, 'error');
    });
  }

  // 대표사진 변경 함수 (Spring API)
  function setAsMainImage(imageId, placeId) {
    const token = localStorage.getItem('accessToken');
    
    fetch(root + '/api/main/set-main-image', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': token ? 'Bearer ' + token : ''
      },
      body: 'imageId=' + imageId + '&placeId=' + placeId
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // 성공 시 이미지 목록 새로고침
        loadImagesForManagement(placeId);
        
        // InfoWindow의 이미지도 새로고침
        setTimeout(() => loadPlaceImages(placeId), 500);
        
        showToast('대표사진이 성공적으로 변경되었습니다.', 'success');
      } else {
        showToast(data.message || '대표사진 변경에 실패했습니다.', 'error');
      }
    })
    .catch(error => {
      showToast('대표사진 변경 중 오류가 발생했습니다: ' + error.message, 'error');
    });
  }

  // 장르 편집 모달 표시 함수
  function showGenreEditModal(placeId, placeName, genres) {
    const modal = document.createElement('div');
    modal.id = 'genreEditModal';
    modal.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.5);
      z-index: 10000;
      display: flex;
      align-items: center;
      justify-content: center;
    `;
    
    let genreListHtml = '';
    genres.forEach(genre => {
      genreListHtml += '<div class="genre-item' + (genre.isSelected ? ' selected' : '') + '" ' +
                      'onclick="toggleGenreSelection(' + genre.genreId + ', \'' + genre.genreName + '\', this)" ' +
                      'style="padding:8px 16px; border:2px solid ' + (genre.isSelected ? '#1275E0' : '#e0e0e0') + '; ' +
                      'border-radius:20px; background:' + (genre.isSelected ? '#1275E0' : 'white') + '; ' +
                      'color:' + (genre.isSelected ? 'white' : '#222') + '; cursor:pointer; transition:all 0.2s; ' +
                      'font-size:0.9rem; margin:4px; display:inline-block;">' + genre.genreName + '</div>';
    });
    
    modal.innerHTML = '<div style="background:white; border-radius:16px; padding:24px; width:90%; max-width:500px; max-height:80vh; overflow-y:auto; box-shadow:0 8px 32px rgba(0,0,0,0.2);">' +
      '<div style="font-size:1.3rem; font-weight:600; margin-bottom:20px; color:#333;">장르 편집</div>' +
      '<div style="margin-bottom:16px; color:#666; font-size:0.95rem;">' + placeName + '</div>' +
      '<div style="margin-bottom:20px;">' + genreListHtml + '</div>' +
      '<div style="display:flex; gap:12px; justify-content:flex-end; margin-top:20px;">' +
        '<button onclick="closeGenreEditModal()" style="padding:10px 20px; border:none; border-radius:8px; cursor:pointer; font-weight:500; transition:all 0.2s; background:#f5f5f5; color:#666;">취소</button>' +
        '<button onclick="saveGenreChanges(' + placeId + ')" style="padding:10px 20px; border:none; border-radius:8px; cursor:pointer; font-weight:500; transition:all 0.2s; background:#1275E0; color:white;">저장</button>' +
      '</div>' +
    '</div>';
    
    document.body.appendChild(modal);
    
    // 모달 외부 클릭 시 닫기
    modal.addEventListener('click', function(e) {
      if(e.target === this) {
        closeGenreEditModal();
      }
    });
  }

  function closeGenreEditModal() {
    const modal = document.getElementById('genreEditModal');
    if (modal) modal.remove();
  }

  var genreChanges = { added: [], removed: [] };

  function toggleGenreSelection(genreId, genreName, element) {
    const isSelected = element.classList.contains('selected');
    
    if(isSelected) {
      // 선택 해제
      element.classList.remove('selected');
      element.style.borderColor = '#e0e0e0';
      element.style.background = 'white';
      element.style.color = '#222';
      genreChanges.removed.push(genreId);
      // 추가 목록에서 제거
      const addIndex = genreChanges.added.indexOf(genreId);
      if(addIndex > -1) {
        genreChanges.added.splice(addIndex, 1);
      }
    } else {
      // 선택
      element.classList.add('selected');
      element.style.borderColor = '#1275E0';
      element.style.background = '#1275E0';
      element.style.color = 'white';
      genreChanges.added.push(genreId);
      // 제거 목록에서 제거
      const removeIndex = genreChanges.removed.indexOf(genreId);
      if(removeIndex > -1) {
        genreChanges.removed.splice(removeIndex, 1);
      }
    }
  }

  function saveGenreChanges(placeId) {
    if(genreChanges.added.length === 0 && genreChanges.removed.length === 0) {
      closeGenreEditModal();
      return;
    }
    
    const token = localStorage.getItem('accessToken');
    
    // 추가할 장르들
    const addPromises = genreChanges.added.map(genreId => 
      fetch(root + '/api/main/genre', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': token ? 'Bearer ' + token : ''
        },
        body: 'action=add&placeId=' + placeId + '&genreId=' + genreId
      }).then(response => response.json())
    );
    
    // 제거할 장르들
    const removePromises = genreChanges.removed.map(genreId => 
      fetch(root + '/api/main/genre', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': token ? 'Bearer ' + token : ''
        },
        body: 'action=remove&placeId=' + placeId + '&genreId=' + genreId
      }).then(response => response.json())
    );
    
    Promise.all([...addPromises, ...removePromises])
      .then(results => {
        const success = results.every(result => result.success);
        if(success) {
          showToast('장르가 성공적으로 업데이트되었습니다.', 'success');
          closeGenreEditModal();
          // 페이지 새로고침으로 장르 정보 업데이트
          setTimeout(() => location.reload(), 1000);
        } else {
          showToast('장르 업데이트 중 오류가 발생했습니다.', 'error');
        }
      })
      .catch(error => {
        showToast('장르 업데이트 중 오류가 발생했습니다: ' + error.message, 'error');
      });
    
    // 변경사항 초기화
    genreChanges = { added: [], removed: [] };
  }
</script>

<style>
  #rightPanel { display: flex; flex-direction: column; height: 100%; }
  #searchBar { flex-shrink: 0; z-index: 10 !important; }
  #autocompleteList { z-index: 30 !important; }
  #searchResultBox { flex: 1; min-height:0; height:100%; }
  .hotplace-list-card {
    width: 94%;
    margin: 18px auto 0 auto;
    background: #fff;
    border-radius: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    padding: 14px 14px 10px 14px;
    display: flex;
    align-items: flex-start;
    position: relative;
    gap: 10px;
  }
  .hotplace-card-heart {
    position: absolute;
    right: 14px;
    top: 12px;
    z-index: 2;
  }
  .hotplace-card-actions {
    position: absolute;
    right: 14px;
    bottom: 10px;
    display: flex;
    align-items: center;
    gap: 8px;
    z-index: 2;
  }
  .hotplace-list-card .hotplace-name {
    font-size: 1.08rem;
  }
  .hotplace-list-card .hotplace-category {
    font-size: 0.97rem;
  }
  .hotplace-list-card .hotplace-address {
    font-size: 0.98rem;
  }
  .category-ball {
    display:inline-flex;
    align-items:center;
    justify-content:center;
    width:24px;
    height:24px;
    border-radius:50%;
    font-size:1.02rem;
    font-weight:700;
    color:#fff;
    margin-right:4px;
    box-shadow:0 1px 4px rgba(0,0,0,0.08);
    border:2px solid #fff;
  }
  .category-ball.marker-club { background:linear-gradient(135deg,#9c27b0,#ba68c8); }
  .category-ball.marker-hunting { background:linear-gradient(135deg,#f44336,#ef5350); }
  .category-ball.marker-lounge { background:linear-gradient(135deg,#4caf50,#66bb6a); }
  .category-ball.marker-pocha { background:linear-gradient(135deg,#8d6e63,#a1887f); }
  .category-ball.active {
    border: 2.5px solid #1275E0;
    box-shadow: 0 0 0 3px #e3f0ff;
    filter: brightness(1.08);
  }
  #categoryCountsBar {
    position: sticky;
    top: 72px;
    z-index: 1 !important;
    background: #fff;
    padding: 12px 20px 4px 20px;
    min-height: 36px;
    display: flex;
    align-items: center;
    gap: 18px;
    border-radius: 0 0 16px 16px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  }
  .dong-category-counts-bar {
    display: flex;
    gap: 18px;
    align-items: center;
    width: 100%;
  }
  .cat-count-num {
    font-weight: 600;
    font-size: 1.08rem;
    margin-right: 8px;
  }
</style>
