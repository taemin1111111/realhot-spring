<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    String root = "";
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> regions = (List<Map<String, Object>>) request.getAttribute("regions");
%>

<style>
  body { font-family: system-ui, sans-serif; padding: 16px; background: #f5f5f5; margin: 0; }
  .container { max-width: 1600px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
  
  /* 검색 섹션 */
  .search-section { margin-bottom: 20px; padding: 16px; background: #e3f2fd; border-radius: 8px; border-left: 4px solid #2196f3; }
  .search-section h3 { margin: 0 0 16px 0; color: #1976d2; font-size: 18px; }
  .search-row { display: flex; gap: 12px; margin: 8px 0; align-items: center; }
  .search-row > label { width: 100px; font-weight: 600; color: #333; font-size: 14px; }
  .search-row input, .search-row select { flex: 1; padding: 8px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; }
  .search-row input:focus, .search-row select:focus { outline: none; border-color: #2196f3; }
  .search-buttons { display: flex; gap: 12px; margin-top: 12px; }
  .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 14px; }
  .btn-primary { background: #2196f3; color: white; }
  .btn-primary:hover { background: #1976d2; }
  .btn-info { background: #00bcd4; color: white; }
  .btn-info:hover { background: #0097a7; }
  
  /* 지도 섹션 */
  .map-section { margin: 20px 0; }
  .map-section h3 { margin: 0 0 12px 0; color: #333; font-size: 18px; }
  #map { width: 100%; height: 600px; border: 2px solid #ddd; border-radius: 8px; }
  
  /* 저장 섹션 */
  .save-section { margin-top: 20px; padding: 16px; background: #f3e5f5; border-radius: 8px; border-left: 4px solid #9c27b0; }
  .save-section h3 { margin: 0 0 16px 0; color: #7b1fa2; font-size: 18px; }
  .save-row { display: flex; gap: 12px; margin: 8px 0; align-items: center; }
  .save-row > label { width: 100px; font-weight: 600; color: #333; font-size: 14px; }
  .save-row input, .save-row select { flex: 1; padding: 8px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; }
  .save-row input:focus, .save-row select:focus { outline: none; border-color: #9c27b0; }
  .save-row input[readonly] { background: #f5f5f5; color: #666; }
  .coordinates { display: flex; gap: 8px; }
  .coordinates input { flex: 1; }
  .btn-success { background: #4caf50; color: white; }
  .btn-success:hover { background: #388e3c; }
  
  .status-message { padding: 12px; border-radius: 6px; margin: 12px 0; display: none; }
  .status-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
  .status-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
  .region-info { font-size: 12px; color: #666; margin-top: 4px; }
</style>

<div class="container">
  <h2 style="margin-bottom: 24px; color: #333;"> 핫플레이스 등록 (관리자 전용)</h2>
  
  <div id="statusMessage" class="status-message"></div>
  
  <!-- 검색 섹션 -->
  <div class="search-section">
    <h3> 장소 검색</h3>
    <div class="search-row">
      <label>검색 지역</label>
      <select id="regionSelect">
        <option value="">지역을 선택하세요</option>
        <% if (regions != null) { %>
          <% for (Map<String, Object> region : regions) { %>
            <option value="<%= region.get("id") %>" 
                    data-lat="<%= region.get("lat") %>" 
                    data-lng="<%= region.get("lng") %>"
                    data-sido="<%= region.get("sido") %>"
                    data-sigungu="<%= region.get("sigungu") %>">
              <%= region.get("sido") %> <%= region.get("sigungu") %>
            </option>
          <% } %>
        <% } %>
      </select>
    </div>
    
    <div class="search-row">
      <label>검색 반경</label>
      <select id="radiusSelect">
        <option value="500">500m</option>
        <option value="1000" selected>1km</option>
        <option value="2000">2km</option>
        <option value="3000">3km</option>
        <option value="5000">5km</option>
      </select>
    </div>
    
    <div class="search-row">
      <label>검색 타입</label>
      <select id="searchTypeSelect">
        <option value="0">전체</option>
        <option value="1">클럽</option>
        <option value="2">헌팅포차</option>
        <option value="3">라운지</option>
        <option value="4">포차거리</option>
      </select>
    </div>
    
    <div class="search-row">
      <label>장소명 검색</label>
      <input type="text" id="searchName" placeholder="검색할 장소명을 입력하세요" style="flex: 1; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
    </div>
    
    <div class="search-buttons">
      <button type="button" class="btn btn-primary" id="btnSearch"> 장소명 검색</button>
      <button type="button" class="btn btn-info" id="btnCategorySearch"> 카테고리 검색</button>
    </div>
  </div>
  
  <!-- 지도 섹션 -->
  <div class="map-section">
    <h3>지도 (마커 클릭 시 아래 저장 폼에 자동 입력)</h3>
    <div id="map"></div>
  </div>
  
  <!-- 저장 섹션 -->
  <div class="save-section">
    <h3> DB 저장</h3>
    <form id="hotplaceForm" method="post" action="<%=root%>/admin/hotplace/insert">
      <div class="save-row">
        <label>장소명*</label>
        <input type="text" id="name" name="name" placeholder="마커 클릭 시 자동 입력" required>
      </div>
      
      <div class="save-row">
        <label>주소*</label>
        <input type="text" id="address" name="address" placeholder="마커 클릭 시 자동 입력" required>
      </div>
      
      <div class="save-row">
        <label>카테고리*</label>
        <select id="categorySelect" name="category_id" required>
          <option value="1">클럽</option>
          <option value="2">헌팅포차</option>
          <option value="3">라운지</option>
          <option value="4">포차거리</option>
        </select>
      </div>
      
      <div class="save-row">
        <label>지역 ID*</label>
        <input type="text" id="region_id" name="region_id" placeholder="마커 클릭 시 자동 입력" required>
      </div>
      
      <div class="save-row">
        <label>좌표</label>
        <div class="coordinates">
          <input type="text" id="lat" name="lat" placeholder="위도" required readonly>
          <input type="text" id="lng" name="lng" placeholder="경도" required readonly>
        </div>
      </div>
      
      <div class="search-buttons">
        <button type="submit" class="btn btn-success" id="btnSubmit"> DB 저장</button>
      </div>
    </form>
  </div>
</div>

<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=9c8d14f1fa7135d1f77778321b1e25fa&libraries=services"></script>
<script>
  // 전역 변수
  var map, geocoder, places, marker;
  var currentRegion = null;
  var markers = []; // 카테고리 검색 결과 마커들
  var selectedMarker = null; // 현재 선택된 마커
  var existingPlaces = []; // DB에 이미 있는 장소들
  
  // 페이지 로드 시 초기화
  function waitForKakao() {
    if (typeof kakao !== 'undefined' && kakao.maps) {
      initializeMap();
      setupEventListeners();
    } else {
      setTimeout(waitForKakao, 100);
    }
  }
  
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', waitForKakao);
  } else {
    waitForKakao();
  }
  
  // 지도 초기화
  function initializeMap() {
    console.log('지도 초기화 시작...');
    
    // 기본 중심점 (서울 시청)
    var defaultCenter = new kakao.maps.LatLng(37.5665, 126.9780);
    
    map = new kakao.maps.Map(document.getElementById('map'), {
      center: defaultCenter,
      level: 6
    });
    
    console.log('지도 생성 완료');
    
    geocoder = new kakao.maps.services.Geocoder();
    places = new kakao.maps.services.Places();
    marker = new kakao.maps.Marker({ map: map });
    
    console.log('지도 서비스 초기화 완료');
    
    // DB에 있는 장소들 가져오기
    loadExistingPlaces();
  }
  
  // 이벤트 리스너 설정
  function setupEventListeners() {
    console.log('이벤트 리스너 설정 시작...');
    // 지역 선택 변경
    document.getElementById('regionSelect').addEventListener('change', function() {
      var selectedOption = this.options[this.selectedIndex];
      if (selectedOption.value) {
        var lat = parseFloat(selectedOption.dataset.lat);
        var lng = parseFloat(selectedOption.dataset.lng);
        var sido = selectedOption.dataset.sido;
        var sigungu = selectedOption.dataset.sigungu;
        
        currentRegion = { lat: lat, lng: lng, sido: sido, sigungu: sigungu };
        
        // 지도 중심점 변경
        var newCenter = new kakao.maps.LatLng(lat, lng);
        map.setCenter(newCenter);
        map.setLevel(4);
        
        // 지역 정보 표시
        showRegionInfo(sido, sigungu);
        
        // 카테고리 자동 설정
        setCategoryByRegion(sigungu);
      }
    });
    
    // 검색 버튼
    document.getElementById('btnSearch').addEventListener('click', searchPlace);
    
    // 카테고리 검색 버튼
    document.getElementById('btnCategorySearch').addEventListener('click', searchByCategory);
    
    // 지도 클릭 (핑이 튀지 않도록 수정)
    kakao.maps.event.addListener(map, 'click', function(e) {
      console.log('지도 클릭됨!');
      var latLng = e.latLng;
      
      // 메인 마커만 이동 (검색 마커들은 그대로)
      marker.setPosition(latLng);
      
      // 좌표 입력
      document.getElementById('lat').value = latLng.getLat().toFixed(6);
      document.getElementById('lng').value = latLng.getLng().toFixed(6);
      
      // 역지오코딩으로 주소 가져오기
      geocoder.coord2Address(latLng.getLng(), latLng.getLat(), function(result, status) {
        if (status === kakao.maps.services.Status.OK && result[0]) {
          var address = result[0].road_address ? 
                       result[0].road_address.address_name : 
                       result[0].address.address_name;
          if (address) {
            document.getElementById('address').value = address;
          }
        }
      });
      
      // 장소명은 비워두기 (사용자가 직접 입력)
      document.getElementById('name').value = '';
      
      showMessage('지도를 클릭했습니다. 장소명을 직접 입력하세요.', 'success');
    });
    
    // 지도 오른쪽 클릭 (마커 선택 해제)
    kakao.maps.event.addListener(map, 'rightclick', function(e) {
      console.log('지도 오른쪽 클릭됨!');
      if (selectedMarker) {
        // 선택된 마커의 인포윈도우 닫기
        if (selectedMarker.infowindow) {
          selectedMarker.infowindow.close();
        }
        selectedMarker = null;
        showMessage('마커 선택이 해제되었습니다.', 'success');
      }
    });
    
    // 폼 제출
    document.getElementById('hotplaceForm').addEventListener('submit', function(e) {
      e.preventDefault();
      submitForm();
    });
    
    console.log('이벤트 리스너 설정 완료');
  }
  
  // 장소 검색 (서울 전체에서 검색)
  function searchPlace() {
    var name = document.getElementById('searchName').value.trim();
    if (!name) {
      showMessage('장소명을 입력해주세요.', 'error');
      return;
    }
    
    console.log('장소명 검색 시작:', name);
    
    // 기존 마커들 제거
    clearMarkers();
    
    // 서울에서만 검색 (파라미터 없이 검색 후 필터링)
    var seoulCenter = new kakao.maps.LatLng(37.5665, 126.9780);
    
    places.keywordSearch(name, function(data, status) {
      console.log('장소명 검색 API 응답:', status, data);
      
      if (status !== kakao.maps.services.Status.OK || data.length === 0) {
        console.log('검색 실패 또는 결과 없음:', status, data);
        showMessage('검색 결과가 없습니다. 다른 키워드로 시도해보세요.', 'error');
        return;
      }
      
      console.log('장소명 검색 결과:', data.length + '개');
      console.log('검색된 장소들:', data.map(function(p) { return p.place_name; }));
      
      // 서울 내 장소만 필터링 (주소 기반)
      var seoulResults = data.filter(function(place) {
        var address = (place.road_address_name || place.address_name || '').toLowerCase();
        var placeName = (place.place_name || '').toLowerCase();
        
        // 주소에 "서울"이 포함되어 있거나, 장소명에 "서울"이 포함된 경우
        var isInSeoul = address.includes('서울') || placeName.includes('서울');
        
        if (!isInSeoul) {
          console.log('서울 외 지역 제외:', place.place_name, address);
        } else {
          console.log('서울 내 장소 확인:', place.place_name, address);
        }
        
        return isInSeoul;
      });
      
      console.log('서울 내 장소:', seoulResults.length + '개');
      
      if (seoulResults.length === 0) {
        showMessage('서울 내에서 검색 결과가 없습니다.', 'error');
        return;
      }
      
      // 서울 내 결과만 마커로 표시
      displaySearchResults(seoulResults, seoulCenter, 50000, true);
      
      // 지도 중심을 서울로 이동
      map.setCenter(seoulCenter);
      map.setLevel(8);
      
      showMessage('서울에서 장소를 ' + seoulResults.length + '개 찾았습니다!', 'success');
      
    });
  }
  
  // 지역별 카테고리 자동 설정
  function setCategoryByRegion(sigungu) {
    var categorySelect = document.getElementById('categorySelect');
    
    if (sigungu.includes('마포') || sigungu.includes('서대문')) {
      categorySelect.value = '1'; // 클럽
    } else if (sigungu.includes('강남') || sigungu.includes('서초')) {
      categorySelect.value = '2'; // 레스토랑
    } else if (sigungu.includes('중구') || sigungu.includes('종로')) {
      categorySelect.value = '4'; // 포차거리
    }
  }
  
  // 카테고리별 검색
  function searchByCategory() {
    if (!currentRegion) {
      showMessage('지역을 먼저 선택해주세요.', 'error');
      return;
    }
    
    var searchType = document.getElementById('searchTypeSelect').value;
    var radius = parseInt(document.getElementById('radiusSelect').value);
    var center = new kakao.maps.LatLng(currentRegion.lat, currentRegion.lng);
    
    // 기존 마커들 제거
    clearMarkers();
    
    // 검색 타입에 따라 다른 검색 방식 사용
    if (searchType === '1') {
      // 클럽 검색
      searchClubs(center, radius);
    } else if (searchType === '2') {
      // 헌팅포차 검색
      searchHuntingPocha(center, radius);
    } else if (searchType === '3') {
      // 라운지 검색
      searchLounge(center, radius);
    } else if (searchType === '4') {
      // 포차거리 검색
      searchPochaStreet(center, radius);
    }
  }
  
  // 클럽 전용 검색 (키워드 검색 사용)
  function searchClubs(center, radius) {
    var clubKeywords = ['클럽', '나이트클럽', 'club', 'nightclub', '디스코', '펜타포트', 'NB2', '퍼플', '오렌지', '레드', '블루'];
    searchByKeywords(clubKeywords, center, radius, '클럽');
  }
  
  // 헌팅포차 검색
  function searchHuntingPocha(center, radius) {
    var pochaKeywords = ['헌팅포차', '포차', '막걸리', '치킨', '닭발', '족발', '보쌈'];
    searchByKeywords(pochaKeywords, center, radius, '헌팅포차');
  }
  
  // 라운지 검색
  function searchLounge(center, radius) {
    var loungeKeywords = ['라운지', 'lounge', '바', 'bar', '칵테일', '위스키', '와인'];
    searchByKeywords(loungeKeywords, center, radius, '라운지');
  }
  
  // 포차거리 검색
  function searchPochaStreet(center, radius) {
    var streetKeywords = ['포차거리', '포차', '막걸리', '치킨', '닭발', '족발', '보쌈', '포장마차'];
    searchByKeywords(streetKeywords, center, radius, '포차거리');
  }
  
  // 키워드 검색 공통 함수
  function searchByKeywords(keywords, center, radius, categoryName) {
    var allResults = [];
    var completedSearches = 0;
    
    keywords.forEach(function(keyword) {
      places.keywordSearch(keyword, function(data, status) {
        if (status === kakao.maps.services.Status.OK) {
          // 결과를 allResults에 추가
          data.forEach(function(place) {
            // 중복 제거 (같은 장소명이면 제외)
            var isDuplicate = allResults.some(function(existing) {
              return existing.place_name === place.place_name;
            });
            if (!isDuplicate) {
              allResults.push(place);
            }
          });
        }
        
        completedSearches++;
        if (completedSearches === keywords.length) {
          // 모든 검색 완료 후 결과 표시
          displaySearchResults(allResults, center, radius, false);
          showMessage('총 ' + allResults.length + '개의 ' + categoryName + '을(를) 찾았습니다.', 'success');
        }
      }, {
        location: center,
        radius: radius
      });
    });
  }
  
  // 카테고리 코드 매핑 (카카오맵 API 실제 코드)
  function getCategoryCode(categoryId) {
    var categoryMap = {
      '1': 'CT1', // 클럽/나이트클럽
      '2': 'FD6', // 음식점
      '3': 'MT1', // 대형마트
      '4': 'FD6', // 포차거리 (음식점으로 검색)
      '5': 'CE7', // 카페
      '6': 'AT4'  // 관광명소
    };
    return categoryMap[categoryId];
  }
  
  // 검색 결과 표시 (카테고리 + 장소명 검색 공통)
  function displaySearchResults(data, center, radius, isNameSearch) {
    var bounds = new kakao.maps.LatLngBounds();
    var searchType = document.getElementById('searchTypeSelect').value;
    
    for (var i = 0; i < data.length; i++) {
      var place = data[i];
      var lat = parseFloat(place.y);
      var lng = parseFloat(place.x);
      var latLng = new kakao.maps.LatLng(lat, lng);
      
      // 반경 내 장소만 표시
      var distance = getDistance(center, latLng);
      if (distance <= radius) {
        // 검색 타입에 따른 필터링 (카테고리 검색일 때만, 장소명 검색은 필터링 없음)
        if (!isNameSearch) {
          if (searchType === '1' && !isClub(place)) {
            continue; // 클럽이 아니면 건너뛰기
          } else if (searchType === '2' && !isHuntingPocha(place)) {
            continue; // 헌팅포차가 아니면 건너뛰기
          } else if (searchType === '3' && !isLounge(place)) {
            continue; // 라운지가 아니면 건너뛰기
          } else if (searchType === '4' && !isPochaStreet(place)) {
            continue; // 포차거리가 아니면 건너뛰기
          }
          // searchType === '0' (전체)일 때는 필터링 없음
        }
        
        // DB에 있는 장소인지 확인
        var isInDB = isPlaceInDB(place.place_name, lat, lng);
        
         // 마커 생성 (DB에 있으면 빨간색, 없으면 기본색)
         var markerOptions = {
           position: latLng,
           map: map
         };
         
         // DB에 있으면 빨간색 마커 사용
         if (isInDB) {
           try {
             markerOptions.image = createRedMarker();
           } catch (e) {
             console.log('마커 이미지 생성 실패, 기본 마커 사용:', e);
           }
         }
         
         var marker = new kakao.maps.Marker(markerOptions);
         
         // 마커 생성 로그
         if (isInDB) {
           console.log('🔴 빨간색 마커 생성:', place.place_name);
         } else {
           console.log('🔵 기본 마커 생성:', place.place_name);
         }
        
        // 인포윈도우 생성 (로딩 상태)
        var dbStatus = isInDB ? '<span style="color:#f44336; font-weight:bold;">✓ DB에 등록됨</span>' : '<span style="color:#666;">DB에 없음</span>';
        var infowindow = new kakao.maps.InfoWindow({
          content: '<div style="padding:10px; font-size:12px; min-width:200px;">' + 
                   '<div style="font-weight:bold; margin-bottom:5px;">' + place.place_name + '</div>' +
                   '<div style="color:#666; margin-bottom:5px;">' + (place.category_name || '') + '</div>' +
                   '<div style="margin-bottom:5px;">' + dbStatus + '</div>' +
                   '<div style="color:#999; font-size:11px;">로딩 중...</div>' +
                   '</div>'
        });
        
        // 마커 클릭 이벤트 (클로저 문제 해결)
        (function(placeData, markerInstance, infowindowInstance, latLngInstance) {
          kakao.maps.event.addListener(markerInstance, 'click', function() {
            console.log('마커 클릭된 장소:', placeData.place_name);
            
            // 기존 선택된 마커 해제
            if (selectedMarker && selectedMarker !== markerInstance) {
              if (selectedMarker.infowindow) {
                selectedMarker.infowindow.close();
              }
            }
            
            // 현재 마커를 선택된 마커로 설정
            selectedMarker = markerInstance;
            
            // 장소 상세 정보 가져오기
            loadPlaceDetails(placeData, markerInstance);
            
            // 폼에 장소 정보 자동 입력
            fillFormWithPlace(placeData);
            
            // 지도 중심을 부드럽게 이동
            map.panTo(latLngInstance);
          });
        })(place, marker, infowindow, latLng);
        
        // 마커에 인포윈도우 저장
        marker.infowindow = infowindow;
        markers.push(marker);
        
        // 지도 범위에 추가
        bounds.extend(latLng);
      }
    }
    
    // 지도 범위 조정
    if (markers.length > 0) {
      map.setBounds(bounds);
    }
  }
  
  // 클럽인지 확인하는 함수 (엄격한 필터링)
  function isClub(place) {
    var placeName = place.place_name.toLowerCase();
    var categoryName = (place.category_name || '').toLowerCase();
    
    console.log('클럽 필터링 체크:', placeName, categoryName);
    
    // 1. 카테고리가 '나이트,클럽'이 아니면 false
    if (!categoryName.includes('나이트') || !categoryName.includes('클럽')) {
      console.log('❌ 카테고리가 나이트,클럽이 아님:', categoryName);
      return false;
    }
    
    // 2. 클럽이 아닌 키워드 (제외할 것들) - 더 엄격하게
    var excludeKeywords = [
      '공연장', '연극극장', '극장', '영화관', '카페', '레스토랑', '음식점', 
      '호텔', '펜션', '모텔', '서비스', '산업', '전문대행', '공간대여',
      '오렌지', '퍼플', '레드', '블루', '그린', '옐로우', '핑크'
    ];
    
    // 제외 키워드가 있으면 false
    for (var i = 0; i < excludeKeywords.length; i++) {
      if (placeName.includes(excludeKeywords[i]) || categoryName.includes(excludeKeywords[i])) {
        console.log('❌ 제외 키워드 발견:', excludeKeywords[i]);
        return false;
      }
    }
    
    // 3. 클럽 관련 키워드 (허용할 것들)
    var clubKeywords = [
      '클럽', '나이트클럽', 'club', 'nightclub', '디스코', '펜타포트', 
      'nb2', 'nb', 'ff', '몽스', '레이저', '헨즈', '싱크홀', '어썸'
    ];
    
    // 클럽 키워드가 있으면 true
    for (var i = 0; i < clubKeywords.length; i++) {
      if (placeName.includes(clubKeywords[i])) {
        console.log('✅ 클럽 키워드 발견:', clubKeywords[i]);
        return true;
      }
    }
    
    console.log('❌ 클럽 키워드 없음');
    return false;
  }
  
  // 헌팅포차인지 확인하는 함수
  function isHuntingPocha(place) {
    var placeName = place.place_name.toLowerCase();
    var categoryName = (place.category_name || '').toLowerCase();
    
    // 헌팅포차 관련 키워드
    var huntingKeywords = ['헌팅포차', '헌팅', '포차', '포장마차', '막걸리', '소주'];
    
    for (var i = 0; i < huntingKeywords.length; i++) {
      if (placeName.includes(huntingKeywords[i]) || categoryName.includes(huntingKeywords[i])) {
        return true;
      }
    }
    
    return false;
  }
  
  // 라운지인지 확인하는 함수
  function isLounge(place) {
    var placeName = place.place_name.toLowerCase();
    var categoryName = (place.category_name || '').toLowerCase();
    
    // 라운지 관련 키워드
    var loungeKeywords = ['라운지', 'lounge', '바', 'bar', '칵테일', '위스키'];
    
    for (var i = 0; i < loungeKeywords.length; i++) {
      if (placeName.includes(loungeKeywords[i]) || categoryName.includes(loungeKeywords[i])) {
        return true;
      }
    }
    
    return false;
  }
  
  // 포차거리인지 확인하는 함수
  function isPochaStreet(place) {
    var placeName = place.place_name.toLowerCase();
    var categoryName = (place.category_name || '').toLowerCase();
    
    // 포차거리 관련 키워드
    var pochaKeywords = ['포차거리', '포차', '거리', '야시장', '먹자골목'];
    
    for (var i = 0; i < pochaKeywords.length; i++) {
      if (placeName.includes(pochaKeywords[i]) || categoryName.includes(pochaKeywords[i])) {
        return true;
      }
    }
    
    return false;
  }
  
  // 두 지점 간의 거리 계산 (미터)
  function getDistance(latLng1, latLng2) {
    var R = 6371e3; // 지구 반지름 (미터)
    var φ1 = latLng1.getLat() * Math.PI/180;
    var φ2 = latLng2.getLat() * Math.PI/180;
    var Δφ = (latLng2.getLat()-latLng1.getLat()) * Math.PI/180;
    var Δλ = (latLng2.getLng()-latLng1.getLng()) * Math.PI/180;

    var a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
            Math.cos(φ1) * Math.cos(φ2) *
            Math.sin(Δλ/2) * Math.sin(Δλ/2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

    return R * c; // 미터
  }
  
  // 마커들 제거
  function clearMarkers() {
    markers.forEach(function(marker) {
      marker.setMap(null);
    });
    markers = [];
  }
  
  // 장소 상세 정보 가져오기
  function loadPlaceDetails(place, markerInstance) {
    console.log('장소 상세 정보 로드 시작:', place.place_name);
    
    // 카카오맵 API로 장소 상세 정보 가져오기
    var placeId = place.id;
    if (!placeId) {
      console.log('place_id가 없음, 장소명으로 재검색');
      // place_id가 없으면 장소명으로 다시 검색
      places.keywordSearch(place.place_name, function(data, status) {
        console.log('재검색 결과:', status, data.length);
        if (status === kakao.maps.services.Status.OK && data.length > 0) {
          var detailedPlace = data[0];
          console.log('상세 정보:', detailedPlace);
          updateInfoWindow(detailedPlace, markerInstance);
        } else {
          console.log('재검색 실패, 기본 정보로 표시');
          updateInfoWindow(place, markerInstance);
        }
      }, {
        location: new kakao.maps.LatLng(place.y, place.x),
        radius: 100
      });
    } else {
      console.log('place_id 있음, 직접 상세 정보 요청');
      // place_id가 있으면 직접 상세 정보 요청
      updateInfoWindow(place, markerInstance);
    }
  }
  
  // 인포윈도우 업데이트
  function updateInfoWindow(place, markerInstance) {
    var content = '<div style="padding:15px; font-size:12px; max-width:300px;">';
    
    // 장소명
    content += '<div style="font-weight:bold; font-size:14px; margin-bottom:8px; color:#333;">' + place.place_name + '</div>';
    
    // 카테고리
    if (place.category_name) {
      content += '<div style="color:#666; margin-bottom:5px;">📂 ' + place.category_name + '</div>';
    }
    
    // 주소
    if (place.road_address_name) {
      content += '<div style="color:#666; margin-bottom:5px;">📍 ' + place.road_address_name + '</div>';
    } else if (place.address_name) {
      content += '<div style="color:#666; margin-bottom:5px;">📍 ' + place.address_name + '</div>';
    }
    
    // 전화번호
    if (place.phone) {
      content += '<div style="color:#666; margin-bottom:5px;">📞 ' + place.phone + '</div>';
    }
    
    // 평점 및 리뷰 수
    if (place.rating) {
      content += '<div style="margin-bottom:8px;">';
      content += '<span style="color:#ff6b35; font-weight:bold;">⭐ ' + place.rating + '</span>';
      if (place.review_count) {
        content += ' <span style="color:#666;">(' + place.review_count + '개 리뷰)</span>';
      }
      content += '</div>';
    }
    
    // 사진 (첫 번째 사진만 표시)
    if (place.place_url) {
      content += '<div style="margin-bottom:8px;">';
      content += '<a href="' + place.place_url + '" target="_blank" style="color:#2196f3; text-decoration:none; font-size:11px;">📷 카카오맵에서 사진 보기</a>';
      content += '</div>';
    }
    
    // 리뷰 링크
    if (place.place_url) {
      content += '<div style="margin-bottom:8px;">';
      content += '<a href="' + place.place_url + '" target="_blank" style="color:#2196f3; text-decoration:none; font-size:11px;">💬 리뷰 보기</a>';
      content += '</div>';
    }
    
    // 영업시간
    if (place.open_time) {
      content += '<div style="color:#666; font-size:11px; margin-bottom:5px;">🕒 ' + place.open_time + '</div>';
    }
    
    // 웹사이트
    if (place.homepage) {
      content += '<div style="margin-bottom:5px;">';
      content += '<a href="' + place.homepage + '" target="_blank" style="color:#2196f3; text-decoration:none; font-size:11px;">🌐 웹사이트</a>';
      content += '</div>';
    }
    
    // DB 상태 표시
    var isInDB = isPlaceInDB(place.place_name, parseFloat(place.y), parseFloat(place.x));
    var dbStatus = isInDB ? '<span style="color:#f44336; font-weight:bold;">✓ DB에 등록됨</span>' : '<span style="color:#666;">DB에 없음</span>';
    content += '<div style="margin-top:8px; padding-top:8px; border-top:1px solid #eee;">';
    content += '<div style="font-weight:bold; font-size:11px;">' + dbStatus + '</div>';
    content += '</div>';
    
    content += '</div>';
    
    // 인포윈도우 내용 업데이트 및 열기
    markerInstance.infowindow.setContent(content);
    markerInstance.infowindow.open(map, markerInstance);
  }
  
  // 폼에 장소 정보 자동 입력
  function fillFormWithPlace(place) {
    console.log('마커 클릭된 장소:', place.place_name); // 디버깅용
    
    // 장소명 입력
    document.getElementById('name').value = place.place_name;
    
    // 주소 입력
    document.getElementById('address').value = place.road_address_name || place.address_name || '';
    
    // 좌표 입력
    document.getElementById('lat').value = parseFloat(place.y).toFixed(6);
    document.getElementById('lng').value = parseFloat(place.x).toFixed(6);
    
    // 지역 ID 자동 설정 (현재 선택된 지역)
    var regionSelect = document.getElementById('regionSelect');
    if (regionSelect.value) {
      document.getElementById('region_id').value = regionSelect.value;
    }
    
    // 카테고리 자동 설정 (검색 타입에 따라)
    var searchType = document.getElementById('searchTypeSelect').value;
    document.getElementById('categorySelect').value = searchType;
    
    // 메인 마커도 해당 위치로 이동 (핑이 튀는 문제 해결)
    var latLng = new kakao.maps.LatLng(parseFloat(place.y), parseFloat(place.x));
    marker.setPosition(latLng);
    
    // 지도 중심을 클릭한 마커로 이동 (부드럽게)
    map.panTo(latLng);
    
    showMessage('장소 정보가 자동으로 입력되었습니다: ' + place.place_name, 'success');
  }
  
  // 지역 정보 표시
  function showRegionInfo(sido, sigungu) {
    var regionInfo = document.querySelector('.region-info');
    if (!regionInfo) {
      regionInfo = document.createElement('div');
      regionInfo.className = 'region-info';
      document.getElementById('regionSelect').parentNode.appendChild(regionInfo);
    }
    regionInfo.textContent = '선택된 지역: ' + sido + ' ' + sigungu;
  }
  
  // 폼 제출
  function submitForm() {
    var form = document.getElementById('hotplaceForm');
    var formData = new FormData(form);
    
    fetch('<%=root%>/admin/hotplace/insert', {
      method: 'POST',
      body: formData
    })
    .then(function(response) {
      return response.json();
    })
    .then(function(data) {
      if (data.success) {
        showMessage(data.message, 'success');
        // 폼 초기화
        form.reset();
        marker.setMap(null);
        marker = new kakao.maps.Marker({ map: map });
      } else {
        showMessage(data.message, 'error');
      }
    })
    .catch(function(error) {
      console.error('Error:', error);
      showMessage('서버 오류가 발생했습니다.', 'error');
    });
  }
  
  // DB에 있는 장소들 가져오기 (hotplace_info 테이블에서)
  function loadExistingPlaces() {
    console.log('DB 장소 로드 시작...');
    console.log('API URL:', '<%=root%>/admin/hotplace/list');
    
    fetch('<%=root%>/admin/hotplace/list')
      .then(function(response) {
        console.log('API 응답 상태:', response.status);
        if (!response.ok) {
          throw new Error('HTTP ' + response.status);
        }
        return response.json();
      })
      .then(function(data) {
        console.log('API 응답 데이터:', data);
        if (data && data.success) {
          existingPlaces = data.hotplaces || [];
          console.log('DB에 있는 장소 수:', existingPlaces.length);
          console.log('DB 장소 목록:', existingPlaces.map(function(p) { return p.name; }));
        } else {
          console.error('DB 장소 로드 실패:', data ? data.message : '응답 데이터 없음');
          existingPlaces = [];
        }
      })
      .catch(function(error) {
        console.error('기존 장소 로드 실패:', error);
        console.log('API 호출 실패, 테스트 데이터로 초기화');
        // API가 실패하면 테스트용 데이터로 초기화
        existingPlaces = [
          { name: '클럽FF', lat: 37.55339, lng: 126.91892 },
          { name: '몽스', lat: 37.55339, lng: 126.91892 },
          { name: 'NB2', lat: 37.55339, lng: 126.91892 },
          { name: '펜타포트', lat: 37.55339, lng: 126.91892 }
        ];
        console.log('테스트 데이터로 초기화:', existingPlaces.length + '개');
      });
  }
  
  // 장소가 DB에 있는지 확인 (좌표로만 비교)
  function isPlaceInDB(placeName, lat, lng) {
    return existingPlaces.some(function(existingPlace) {
      // 좌표만 비교 (0.0001도 이내면 같은 장소로 간주)
      var coordMatch = Math.abs(existingPlace.lat - lat) < 0.0001 && 
                      Math.abs(existingPlace.lng - lng) < 0.0001;
      
      // 매칭된 경우만 로그 출력
      if (coordMatch) {
        console.log('✅ DB 매칭 성공 (좌표):', {
          kakao: placeName,
          db: existingPlace.name,
          kakaoCoord: { lat: lat, lng: lng },
          dbCoord: { lat: existingPlace.lat, lng: existingPlace.lng }
        });
      }
      
      return coordMatch;
    });
  }
  
   // 빨간색 마커 생성 (간단한 방식)
   function createRedMarker() {
     // 빨간색 원형 마커 이미지 생성
     var imageSrc = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(`
       <svg width="30" height="30" xmlns="http://www.w3.org/2000/svg">
         <circle cx="15" cy="15" r="12" fill="#f44336" stroke="white" stroke-width="2"/>
       </svg>
     `);
     
     var imageSize = new kakao.maps.Size(30, 30);
     var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize);
     
     return markerImage;
   }
  
  // 메시지 표시
  function showMessage(message, type) {
    var messageDiv = document.getElementById('statusMessage');
    messageDiv.textContent = message;
    messageDiv.className = 'status-message status-' + type;
    messageDiv.style.display = 'block';
    
    // 3초 후 자동 숨김
    setTimeout(function() {
      messageDiv.style.display = 'none';
    }, 3000);
  }
</script>
