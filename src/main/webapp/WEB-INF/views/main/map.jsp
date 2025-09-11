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
    
    @SuppressWarnings("unchecked")
    Map<String, Integer> dongToRegionIdMapping = (Map<String, Integer>) request.getAttribute("dongToRegionIdMapping");
    if (dongToRegionIdMapping == null) dongToRegionIdMapping = new HashMap<>();
    
    // 선택된 장소 정보 (placeId 파라미터로 전달된 경우)
    Object selectedPlace = request.getAttribute("selectedPlace");
    Integer placeId = (Integer) request.getAttribute("placeId");
%>

<!-- Kakao Map SDK -->
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=9c8d14f1fa7135d1f77778321b1e25fa&libraries=services"></script>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/main.css">
    
    <style>
        .map-page-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .map-container {
            width: 100%;
            height: 80vh;
            min-height: 600px;
            position: relative;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            z-index: 1;
        }
        
        /* 토글 버튼 영역 클릭 차단 */
        .toggle-button-area {
            position: absolute;
            top: 50%;
            right: 0;
            transform: translateY(-50%);
            width: 50px;
            height: 60px;
            z-index: 1000;
            pointer-events: auto;
        }
        
        #map {
            width: 100%;
            height: 100%;
        }
        
        .map-controls {
            position: absolute;
            top: 20px;
            left: 20px;
            z-index: 10;
            background: transparent;
            border-radius: 10px;
            padding: 15px;
        }
        
        
        .marker-label {
            background: rgba(0,0,0,0.7);
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
            white-space: nowrap;
            pointer-events: none;
        }
        
        .infoWindow {
            max-width: 300px;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }
        
        .place-images-container {
            height: 150px;
            background: #f8f9fa;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #6c757d;
        }
        
        .place-images-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .wish-heart {
            cursor: pointer;
            transition: color 0.2s;
        }
        
        .wish-heart:hover {
            color: #e91e63 !important;
        }
        
        .wish-heart.filled {
            color: #e91e63 !important;
        }
        
        /* 오른쪽 패널 스타일 */
        #rightPanel { display: flex; flex-direction: column; height: 100%; }
        #searchBar { flex-shrink: 0; z-index: 10 !important; }
        #autocompleteList { z-index: 30 !important; }
        #searchResultBox { flex: 1; min-height:0; height:100%; }
        
        #rightPanel::-webkit-scrollbar { width: 8px; background: #f5f5f5; }
        #rightPanel::-webkit-scrollbar-thumb { background: #ddd; border-radius: 4px; }
        #searchBar input:focus { border:1.5px solid #1275E0; background:#fff; }
        #searchBar input::placeholder { color:#bbb; font-weight:400; }
        #searchBar { box-shadow:0 2px 8px rgba(0,0,0,0.04); border-radius:16px 16px 0 0; }
        
        .category-filter {
            display: flex;
            gap: 8px;
            margin-top: 15px;
            justify-content: flex-start;
        }
        
        .map-category-btn {
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
        .map-category-btn.active {
            border: 2.5px solid #000;
            opacity: 1;
            color: #000;
            background: rgba(255,255,255,0.2);
        }
        .map-category-btn.marker-club { background: linear-gradient(135deg, #9c27b0, #ba68c8); color: #fff; }
        .map-category-btn.marker-hunting { background: linear-gradient(135deg, #f44336, #ef5350); color: #fff; }
        .map-category-btn.marker-lounge { background: linear-gradient(135deg, #4caf50, #66bb6a); color: #fff; }
        .map-category-btn.marker-pocha { background: linear-gradient(135deg, #8d6e63, #a1887f); color: #fff; }
        .map-category-btn:not(.active):hover {
            filter: brightness(1.08);
            opacity: 1;
        }
        
        .btn-outline-primary {
            background: transparent !important;
            border: 1.5px solid #1275E0 !important;
            color: #1275E0 !important;
            border-radius: 8px !important;
        }
        .btn-outline-primary:hover {
            background: transparent !important;
            border: 1.5px solid #0d5bb8 !important;
            color: #0d5bb8 !important;
        }
        
        /* 지역 라벨 및 카운트 스타일 */
        .region-label {
            background: rgba(255,255,255,0.9);
            color: #333;
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 20px;
            font-weight: bold;
            white-space: nowrap;
            pointer-events: auto !important;
            box-shadow: 0 2px 6px rgba(0,0,0,0.15);
        }
        
        /* 모바일에서 지역 라벨 크기 증가 */
        @media (max-width: 768px) {
            .region-label {
                font-size: 24px !important;
                padding: 10px 18px !important;
            }
        }
        
        /* 아이폰에서 지역 라벨 크기 더 증가 */
        @media (max-width: 480px) {
            .region-label {
                font-size: 26px !important;
                padding: 12px 20px !important;
            }
        }
        
        /* 아이폰 Safari 전용 - 지역 라벨 크기 최대 증가 */
        @supports (-webkit-touch-callout: none) and (max-width: 991px) {
            .region-label {
                font-size: 28px !important;
                padding: 14px 22px !important;
            }
        }
        
        .region-counts {
            display: flex;
            gap: 4px;
            pointer-events: none !important;
        }
        
        .region-count-marker {
            background: rgba(255,255,255,0.9);
            color: #333;
            padding: 2px 6px;
            border-radius: 3px;
            font-size: 10px;
            font-weight: bold;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .region-count-marker.marker-club { background: #9c27b0; color: white; }
        .region-count-marker.marker-hunting { background: #f44336; color: white; }
        .region-count-marker.marker-lounge { background: #4caf50; color: white; }
        .region-count-marker.marker-pocha { background: #8d6e63; color: white; }
        
        /* 자동완성 스타일 */
        .autocomplete-item:hover {
            background: #f0f4fa !important;
            color: #1275E0 !important;
        }
        
        /* 카테고리 바 스타일 */
        .dong-category-counts-bar {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 16px;
            flex-wrap: wrap;
            width: 100%;
            text-align: center;
            padding: 16px 0 12px 0;
            margin: 8px 0 4px 0;
        }
        
        .category-ball {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            font-size: 12px;
            font-weight: bold;
            color: white;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .category-ball.active {
            transform: scale(1.1);
            box-shadow: 0 2px 8px rgba(0,0,0,0.3);
        }
        
        .cat-count-num {
            font-size: 14px;
            font-weight: 600;
            margin-left: 4px;
        }
        
        /* 핫플레이스 카드 스타일 */
        .hotplace-list-card {
            width: 94%;
            margin: 0 auto 16px auto;
        }
        
        /* 모바일에서 검색 결과 글자 크기 증가 */
        @media (max-width: 768px) {
            .hotplace-list-card {
                padding: 24px !important;
                margin-bottom: 20px !important;
            }
            
            .hotplace-list-card .hotplace-name {
                font-size: 1.3rem !important;
                font-weight: 700 !important;
            }
            
            .hotplace-list-card .hotplace-category {
                font-size: 1rem !important;
                margin-top: 4px !important;
            }
            
            .hotplace-list-card .wish-count {
                font-size: 1rem !important;
                margin-top: 4px !important;
            }
            
            .hotplace-list-card .vote-trends {
                font-size: 1rem !important;
                margin-top: 4px !important;
            }
            
            .hotplace-list-card .vote-details {
                font-size: 0.95rem !important;
                margin-top: 4px !important;
            }
            
            .hotplace-list-card .genre-info {
                font-size: 1rem !important;
                margin-top: 4px !important;
            }
            
            .hotplace-list-card .action-buttons-container a {
                font-size: 1rem !important;
                padding: 12px 18px !important;
            }
            
            .region-item {
                padding: 16px 20px !important;
                margin-bottom: 12px !important;
            }
            
            .region-item > div:first-child {
                font-size: 1.2rem !important;
                font-weight: 700 !important;
            }
            
            .region-item .category-counts {
                font-size: 1rem !important;
            }
            
            .autocomplete-item {
                padding: 16px 20px !important;
                font-size: 1.1rem !important;
            }
            
            #searchResultBox {
                font-size: 1.4rem !important;
            }
            
            #searchResultBox .hotplace-address {
                font-size: 1rem !important;
            }
            
            /* 모바일에서 화살표 버튼 크기 증가 */
            #rightPanelToggleBtn, #rightPanelCloseBtn {
                width: 65px !important;
                height: 85px !important;
                font-size: 2.6rem !important;
            }
            
            /* 모바일에서 내 위치 버튼 크기 증가 - 더 구체적인 선택자 사용 */
            .map-controls .btn-outline-primary,
            .map-page-container .btn-outline-primary,
            .map-controls button.btn-outline-primary {
                font-size: 1.3rem !important;
                padding: 16px 24px !important;
            }
            
            /* 모바일에서 카테고리 필터 버튼 크기 증가 */
            .map-category-btn {
                font-size: 1.4rem !important;
                padding: 18px 22px !important;
                min-width: 65px !important;
                height: 65px !important;
            }
        }
        
        /* 아이폰에서 버튼 크기 더 증가 */
        @media (max-width: 480px) {
            /* 아이폰에서 화살표 버튼 크기 더 증가 */
            #rightPanelToggleBtn, #rightPanelCloseBtn {
                width: 70px !important;
                height: 90px !important;
                font-size: 2.8rem !important;
            }
            
            /* 아이폰에서 내 위치 버튼 크기 더 증가 - 더 구체적인 선택자 사용 */
            .map-controls .btn-outline-primary,
            .map-page-container .btn-outline-primary,
            .map-controls button.btn-outline-primary {
                font-size: 1.4rem !important;
                padding: 18px 26px !important;
            }
            
            /* 아이폰에서 카테고리 필터 버튼 크기 더 증가 */
            .map-category-btn {
                font-size: 1.6rem !important;
                padding: 22px 26px !important;
                min-width: 75px !important;
                height: 75px !important;
            }
        }
        
        /* 아이폰 Safari 전용 스타일 - title.jsp 패턴 적용 */
        @supports (-webkit-touch-callout: none) and (max-width: 991px) {
            /* 아이폰에서 화살표 버튼 크기 최대 증가 */
            #rightPanelToggleBtn, #rightPanelCloseBtn {
                width: 85px !important;
                height: 105px !important;
                font-size: 3.4rem !important;
            }
            
            /* 아이폰에서 내 위치 버튼 크기 최대 증가 */
            .map-controls .btn-outline-primary,
            .map-page-container .btn-outline-primary,
            .map-controls button.btn-outline-primary {
                font-size: 1.8rem !important;
                padding: 24px 32px !important;
            }
            
            /* 아이폰에서 카테고리 필터 버튼 크기 최대 증가 */
            .map-category-btn {
                font-size: 1.8rem !important;
                padding: 24px 28px !important;
                min-width: 85px !important;
                height: 85px !important;
            }
        }
        
        /* 아이폰 Safari 전용 스타일 - 추가 패턴 */
        @supports (-webkit-touch-callout: none) {
            @media (max-width: 500px) {
                /* 아이폰에서 화살표 버튼 크기 최대 증가 */
                #rightPanelToggleBtn, #rightPanelCloseBtn {
                    width: 90px !important !important;
                    height: 110px !important !important;
                    font-size: 3.6rem !important !important;
                }
                
                /* 아이폰에서 내 위치 버튼 크기 최대 증가 - 더 구체적인 선택자 사용 */
                .map-controls .btn-outline-primary,
                .map-page-container .btn-outline-primary,
                .map-controls button.btn-outline-primary {
                    font-size: 2rem !important !important;
                    padding: 26px 34px !important !important;
                }
                
                /* 아이폰에서 카테고리 필터 버튼 크기 최대 증가 */
                .map-category-btn {
                    font-size: 2rem !important !important;
                    padding: 26px 30px !important !important;
                    min-width: 95px !important !important;
                    height: 95px !important !important;
                }
            }
        }
        
        /* 최종 강제 적용 - 모든 아이폰 크기 */
        @media only screen and (max-width: 500px) {
            /* 아이폰에서 화살표 버튼 크기 최대 증가 */
            #rightPanelToggleBtn, #rightPanelCloseBtn {
                width: 95px !important !important;
                height: 115px !important !important;
                font-size: 3.8rem !important !important;
            }
            
            /* 아이폰에서 내 위치 버튼 크기 최대 증가 - 더 구체적인 선택자 사용 */
            .map-controls .btn-outline-primary,
            .map-page-container .btn-outline-primary,
            .map-controls button.btn-outline-primary {
                font-size: 2.2rem !important !important;
                padding: 28px 36px !important !important;
            }
            
            /* 아이폰에서 카테고리 필터 버튼 크기 최대 증가 */
            .map-category-btn {
                font-size: 2.2rem !important !important;
                padding: 28px 32px !important !important;
                min-width: 105px !important !important;
                height: 105px !important !important;
            }
        }
    </style>

<div class="map-page-container">
        <!-- 메인으로 버튼 -->
        <div style="text-align: center; margin-bottom: 20px;">
            <a href="<%=root%>/" class="btn btn-primary">
                <i class="bi bi-house"></i> 메인으로
            </a>
        </div>
        
        <div class="map-container">
            <!-- 지도 -->
            <div id="map"></div>
            
            <!-- 오른쪽 패널 토글 버튼 및 패널 -->
            <div class="toggle-button-area">
                <button id="rightPanelToggleBtn" style="position:absolute; top:50%; right:0; transform:translateY(-50%); z-index:1000; background:#fff; border-radius:8px 0 0 8px; border:1.5px solid #ddd; border-right:none; width:36px; height:56px; box-shadow:0 2px 8px rgba(0,0,0,0.10); display:flex; align-items:center; justify-content:center; font-size:1.5rem; cursor:pointer; transition:background 0.15s; pointer-events:auto;">&lt;</button>
            </div>
            <div id="rightPanel" style="position:absolute; top:0; right:0; height:100%; width:360px; max-width:90vw; background:#fff; box-shadow:-2px 0 16px rgba(0,0,0,0.10); z-index:30; border-radius:16px 0 0 16px; transform:translateX(100%); transition:transform 0.35s cubic-bezier(.77,0,.18,1); display:flex; flex-direction:column;">
                <button id="rightPanelCloseBtn" style="position:absolute; left:-36px; top:50%; transform:translateY(-50%); width:36px; height:56px; background:#fff; border-radius:8px 0 0 8px; border:1.5px solid #ddd; border-left:none; box-shadow:0 2px 8px rgba(0,0,0,0.10); display:flex; align-items:center; justify-content:center; font-size:1.5rem; cursor:pointer; display:none; z-index:1001; pointer-events:auto;">&gt;</button>
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
                        .search-type-item { padding:8px 12px; border:none; background:none; cursor:pointer; font-size:0.93rem; color:#333; text-align:left; transition:background 0.15s; }
                        .search-type-item:hover { background:#f0f4fa; }
                        .search-type-item.selected { background:#1275E0; color:#fff; }
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
                
                <!-- 카테고리 바 -->
                <div id="categoryCountsBar" style="display:none;"></div>
                
                <!-- 검색 결과 영역 -->
                <div style="padding:24px 20px 20px 20px; flex:1; overflow-y:auto; display:flex; flex-direction:column; align-items:center; justify-content:center;">
                    <div id="searchResultBox" style="width:100%; flex:1; min-height:0; height:100%; background:#f5f5f5; border-radius:12px; display:flex; flex-direction:column; align-items:center; justify-content:flex-start; color:#888; font-size:1.2rem; padding:0; overflow-y:auto;"></div>
                </div>
            </div>
            
            <!-- 컨트롤 패널 -->
            <div class="map-controls">
                <div>
                    <button class="btn btn-sm btn-outline-primary" onclick="getCurrentLocation()">
                        <i class="bi bi-geo-alt"></i> 내 위치
                    </button>
                </div>
                
                <!-- 카테고리 필터 -->
                <div class="category-filter">
                    <button class="map-category-btn active" data-category="all">전체</button>
                    <button class="map-category-btn marker-club" data-category="1">C</button>
                    <button class="map-category-btn marker-hunting" data-category="2">H</button>
                    <button class="map-category-btn marker-lounge" data-category="3">L</button>
                    <button class="map-category-btn marker-pocha" data-category="4">P</button>
                </div>
            </div>
            
        </div>
    </div>

    
    <script>
        var root = '<%=root%>';
        var isLoggedIn = false;
        var loginUserId = '';
        var isAdmin = false;
        
        // JWT 토큰 관리 함수들
        function getToken() {
            return localStorage.getItem('accessToken');
        }
        
        function setToken(token) {
            localStorage.setItem('accessToken', token);
        }
        
        function removeToken() {
            localStorage.removeItem('accessToken');
        }
        
        function getTokenPayload() {
            const token = getToken();
            if (!token) return null;
            try {
                const payload = JSON.parse(atob(token.split('.')[1]));
                return payload;
            } catch (e) {
                return null;
            }
        }
        
        // 페이지 로드 시 토큰 확인
        document.addEventListener('DOMContentLoaded', function() {
            const payload = getTokenPayload();
            if (payload && payload.exp * 1000 > Date.now()) {
                isLoggedIn = true;
                loginUserId = payload.sub;
                checkAdminStatus();
            }
        });
        
        function checkAdminStatus() {
            if (!isLoggedIn) return;
            
            fetch(root + '/api/auth/check-admin', {
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + getToken(),
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    isAdmin = data.isAdmin;
                }
            })
            .catch(error => {
                // 관리자 체크 실패 무시
            });
        }
        
        // URL 파라미터 확인
        const urlParams = new URLSearchParams(window.location.search);
        const targetLat = urlParams.get('lat');
        const targetLng = urlParams.get('lng');
        
        // JSP 변수들을 JavaScript로 전달
        var hotplaces = [<% for (int i = 0; i < hotplaceList.size(); i++) { 
            Object obj = hotplaceList.get(i);
            if (obj instanceof com.wherehot.spring.entity.Hotplace) {
                com.wherehot.spring.entity.Hotplace hotplace = (com.wherehot.spring.entity.Hotplace) obj;
            %>{id:<%=hotplace.getId()%>, name:'<%=hotplace.getName().replace("'", "\\'")%>', categoryId:<%=hotplace.getCategoryId()%>, address:'<%=hotplace.getAddress().replace("'", "\\'")%>', lat:<%=hotplace.getLat()%>, lng:<%=hotplace.getLng()%>, regionId:<%=hotplace.getRegionId()%>}<% if (i < hotplaceList.size() - 1) { %>,<% } } }%>];
        
        var rootPath = '<%=root%>';
        var sigunguCenters = [<% for (int i = 0; i < sigunguCenterList.size(); i++) { Map<String, Object> row = sigunguCenterList.get(i); %>{sido:'<%=row.get("sido")%>', sigungu:'<%=row.get("sigungu")%>', lat:<%=row.get("lat")%>, lng:<%=row.get("lng")%>}<% if (i < sigunguCenterList.size() - 1) { %>,<% } %><% } %>];
        var sigunguCategoryCounts = [<% for (int i = 0; i < sigunguCategoryCountList.size(); i++) { Map<String, Object> row = sigunguCategoryCountList.get(i); %>{sigungu:'<%=row.get("sigungu")%>', lat:<%=row.get("lat")%>, lng:<%=row.get("lng")%>, clubCount:<%=row.get("clubCount")%>, huntingCount:<%=row.get("huntingCount")%>, loungeCount:<%=row.get("loungeCount")%>, pochaCount:<%=row.get("pochaCount")%>}<% if (i < sigunguCategoryCountList.size() - 1) { %>,<% } %><% } %>];
        var regionCenters = [<% for (int i = 0; i < regionCenters.size(); i++) { Map<String, Object> row = regionCenters.get(i); %>{id:<%=row.get("id")%>, sido:'<%=row.get("sido")%>', sigungu:'<%=row.get("sigungu")%>', dong:'<%=row.get("dong")%>', lat:<%=row.get("lat")%>, lng:<%=row.get("lng")%>}<% if (i < regionCenters.size() - 1) { %>,<% } %><% } %>];
        var regionCategoryCounts = [<% for (int i = 0; i < regionCategoryCounts.size(); i++) { Map<String, Object> row = regionCategoryCounts.get(i); %>{region_id:<%=row.get("region_id")%>, clubCount:<%=row.get("clubCount")%>, huntingCount:<%=row.get("huntingCount")%>, loungeCount:<%=row.get("loungeCount")%>, pochaCount:<%=row.get("pochaCount")%>}<% if (i < regionCategoryCounts.size() - 1) { %>,<% } %><% } %>];
        
        // 자동완성을 위한 리스트
        var regionNameList = ['서울', <% for(int i=0;i<regionNameList.size();i++){ %>'<%=regionNameList.get(i).replace("'", "\\'")%>'<% if(i<regionNameList.size()-1){%>,<%}}%>];
        var hotplaceNameList = [<% for(int i=0;i<hotplaceNameList.size();i++){ %>'<%=hotplaceNameList.get(i).replace("'", "\\'")%>'<% if(i<hotplaceNameList.size()-1){%>,<%}}%>];
        
        // 변수 로드 확인

        var mapContainer = document.getElementById('map');
        var mapOptions = {
            center: new kakao.maps.LatLng(37.5665, 126.9780),
            level: 7
        };
        var map = new kakao.maps.Map(mapContainer, mapOptions);
        
        // 초기 상태: 가게 마크 숨김
        var showHotplaceMarkers = false;
        
        // URL 파라미터가 있으면 해당 위치로 이동
        if (targetLat && targetLng) {
            var targetPosition = new kakao.maps.LatLng(parseFloat(targetLat), parseFloat(targetLng));
            map.setCenter(targetPosition);
            map.setLevel(5);
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
            
            var heartHtml = isLoggedIn ? '<i class="bi bi-heart wish-heart" data-place-id="' + place.id + '" style="position:absolute;top:12px;right:12px;z-index:10;"></i>' : '';
            var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차'};
            var infoContent = ''
                + '<div class="infoWindow" style="position:relative; padding:0; font-size:clamp(12px, 2vw, 16px); line-height:1.4; border-radius:0; overflow:visible; box-sizing:border-box;">'
                + heartHtml
                + '<div class="place-images-container" style="position:relative; width:100%; background:#f8f9fa; display:flex; align-items:center; justify-content:center; color:#6c757d; font-size:clamp(11px, 1.5vw, 13px);" data-place-id="' + place.id + '">이미지 로딩 중...</div>'
                + '<div style="padding:clamp(16px, 3vw, 20px);">'
                + '<div class="place-name-wish-container" style="display:flex; align-items:center; margin-bottom:8px;">'
                + '<div style="flex:1; min-width:0;">'
                + '<div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">'
                + '<strong style="font-size:clamp(14px, 2.5vw, 18px); word-break:break-word; color:#1275E0; cursor:pointer; flex:1;">' + place.name + '</strong>'
                + '</div>'
                + '<div style="color:#888; font-size:clamp(10px, 1.6vw, 12px); margin-top:2px;">' + (categoryMap[place.categoryId]||'') + '</div>'
                + '<div style="color:#e91e63; font-size:clamp(10px, 1.6vw, 12px); margin-top:2px;">💖<span class="wish-count-' + place.id + '" style="color:#e91e63; font-weight:600;">로딩중...</span>명이 찜했어요</div>'
                + '</div>'
                + '</div>'
                + '<div style="margin-bottom:clamp(10px, 2vw, 14px); color:#888; font-size:clamp(12px, 2.2vw, 14px); word-break:break-word;" id="voteTrends-' + place.id + '">📊 역대 투표: 로딩중...</div>'
                + '<div style="margin-bottom:clamp(10px, 2vw, 14px); color:#888; font-size:clamp(12px, 2.2vw, 14px); word-break:break-word;" id="voteDetails-' + place.id + '">#성비<br>#혼잡도<br>#대기시간</div>'
                + '<div style="margin-bottom:clamp(10px, 2vw, 14px); color:#666; font-size:clamp(12px, 2.2vw, 14px); word-break:break-word; line-height:1.3; display:flex; align-items:center;">' + place.address + '<span onclick="copyAddress(\'' + place.address + '\')" style="cursor:pointer; color:#1275E0; margin-left:2px; display:inline-flex; align-items:center;" title="주소 복사"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></span></div>'
                + (place.categoryId === 1 ? '<div style="color:#9c27b0; font-weight:600; margin-bottom:clamp(10px, 2vw, 14px); font-size:clamp(11px, 2vw, 13px); word-break:break-word;" id="genres-' + place.id + '">🎵 장르: 로딩중...</div>' : '')
                + '<div class="action-buttons-container" style="padding-bottom: 24px !important;"><a href="#" onclick="showVoteSection(' + place.id + ', \'' + place.name + '\', \'' + place.address + '\', ' + place.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-weight:500; font-size:clamp(12px, 2vw, 14px); white-space:nowrap; padding:10px 16px; background:#f0f8ff; border-radius:8px; border:1px solid #e3f2fd;">🔥 투표하기</a>'
                + (isAdmin && place.categoryId === 1 ? '<a href="#" onclick="openGenreEditModal(' + place.id + ', \'' + place.name + '\'); return false;" style="color:#ff6b35; text-decoration:none; font-size:clamp(10px, 1.8vw, 12px); white-space:nowrap; padding:8px 14px; background:#fff3e0; border-radius:6px; border:1px solid #ffe0b2;">✏️ 장르 편집</a>' : '') + '</div>'
                + '</div>'
                + '</div>';
                
            var infowindow = new kakao.maps.InfoWindow({ content: infoContent });
            
            kakao.maps.event.addListener(marker, 'click', function() {
                if (openInfoWindow) openInfoWindow.close();
                infowindow.open(map, marker);
                openInfoWindow = infowindow;
                
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
                        
                        const imageContainer = iw.querySelector('.place-images-container');
                        if (imageContainer) {
                            setTimeout(function() {
                                loadPlaceImages(place.id);
                            }, 300);
                        }
                        
                        setTimeout(function() {
                            loadWishCount(place.id);
                        }, 400);
                        
                        setTimeout(function() {
                            loadVoteTrends(place.id);
                        }, 500);
                        
                        if (place.categoryId === 1) {
                            setTimeout(function() {
                                loadGenreInfo(place.id);
                            }, 600);
                        }
                        
                        if (isAdmin) {
                            var addBtn = document.createElement('button');
                            addBtn.onclick = function() { openImageUploadModal(place.id); };
                            addBtn.style.cssText = 'position:absolute; top:12px; right:50px; background:#1275E0; color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:18px; font-weight:bold; box-shadow:0 2px 8px rgba(0,0,0,0.3); z-index:10;';
                            addBtn.innerHTML = '+';
                            iw.appendChild(addBtn);
                            
                            var editBtn = document.createElement('button');
                            editBtn.onclick = function() { openImageManageModal(place.id); };
                            editBtn.style.cssText = 'position:absolute; top:12px; right:88px; background:#ff6b35; color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:14px; font-weight:bold; box-shadow:0 2px 8px rgba(0,0,0,0.3); z-index:10;';
                            editBtn.innerHTML = '✏️';
                            iw.appendChild(editBtn);
                        }
                    }
                }, 100);
            });
            
            hotplaceMarkers.push(marker);
            hotplaceLabels.push(labelOverlay);
            hotplaceInfoWindows.push(infowindow);
            hotplaceCategoryIds.push(place.categoryId);
        });

        // 카테고리 필터 기능
        function filterByCategory(category) {
            // 가게 마크 표시 활성화
            showHotplaceMarkers = true;
            
            hotplaceMarkers.forEach(function(marker, index) {
                if (category === 'all' || hotplaceCategoryIds[index] == category) {
                    marker.setMap(map);
                    hotplaceLabels[index].setMap(map);
                } else {
                    marker.setMap(null);
                    hotplaceLabels[index].setMap(null);
                }
            });
        }
        
        // 모든 가게 마크 숨기기
        function hideAllHotplaceMarkers() {
            showHotplaceMarkers = false;
            hotplaceMarkers.forEach(function(marker) {
                marker.setMap(null);
            });
            hotplaceLabels.forEach(function(label) {
                label.setMap(null);
            });
        }

        // 카테고리 버튼 이벤트 (토글 기능)
        document.querySelectorAll('.map-category-btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                var category = this.dataset.category;
                var isActive = this.classList.contains('active');
                
                // 모든 버튼에서 active 클래스 제거
                document.querySelectorAll('.map-category-btn').forEach(b => b.classList.remove('active'));
                
                if (isActive) {
                    // 이미 활성화된 버튼을 다시 클릭하면 모든 마크 숨기기
                    hideAllHotplaceMarkers();
                } else {
                    // 새로운 카테고리 선택
                    this.classList.add('active');
                    filterByCategory(category);
                }
            });
        });
        
        // 오른쪽 패널 토글 기능
        document.addEventListener('DOMContentLoaded', function() {
            var openBtn = document.getElementById('rightPanelToggleBtn');
            var closeBtn = document.getElementById('rightPanelCloseBtn');
            var panel = document.getElementById('rightPanel');
            
            // 초기 상태: 패널 닫힘, < 버튼만 지도 오른쪽 끝에 보임
            panel.style.transform = 'translateX(100%)';
            openBtn.style.display = 'flex';
            closeBtn.style.display = 'none';
            openBtn.innerHTML = '&lt;';
            
            // 기존 이벤트 리스너 제거
            openBtn.onclick = null;
            closeBtn.onclick = null;
            
            // 토글 버튼 영역 클릭 차단
            var toggleArea = document.querySelector('.toggle-button-area');
            if (toggleArea) {
                toggleArea.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    e.stopImmediatePropagation();
                    return false;
                });
            }
            
            // 더 강력한 이벤트 처리
            openBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                e.stopImmediatePropagation();
                panel.style.transform = 'translateX(0)';
                openBtn.style.display = 'none';
                closeBtn.style.display = 'flex';
                // 서울 전체 표시
                window.renderHotplaceListBySido('서울', null);
                return false;
            });
            
            closeBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                e.stopImmediatePropagation();
                panel.style.transform = 'translateX(100%)';
                closeBtn.style.display = 'none';
                setTimeout(function() { openBtn.style.display = 'flex'; }, 350);
                return false;
            });
            
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
            
            // 검색 버튼/엔터 이벤트
            var searchInput = document.getElementById('searchInput');
            var searchForm = searchInput.closest('form');
            searchForm.onsubmit = function(e) {
                e.preventDefault();
                renderSearchResult();
            };
            document.getElementById('searchBtn').onclick = function(e) {
                e.preventDefault();
                renderSearchResult();
            };
            
            // 자동완성 기능
            var autocompleteList = document.getElementById('autocompleteList');
            var searchTimeout;
            
            searchInput.oninput = function() {
                clearTimeout(searchTimeout);
                var query = this.value.trim();
                
                searchTimeout = setTimeout(function() {
                    fetchAutocompleteSuggestions(query);
                }, 300);
            };
            
            // 자동완성 제안 클릭 이벤트
            autocompleteList.onclick = function(e) {
                if (e.target.classList.contains('autocomplete-item')) {
                    searchInput.value = e.target.textContent;
                    autocompleteList.style.display = 'none';
                    renderSearchResult();
                }
            };
            
            // 검색창 외부 클릭 시 자동완성 숨기기
            document.addEventListener('click', function(e) {
                if (!searchInput.contains(e.target) && !autocompleteList.contains(e.target)) {
                    autocompleteList.style.display = 'none';
                }
            });
        });
        
        // 자동완성 제안 가져오기
        function fetchAutocompleteSuggestions(query) {
            var searchType = document.getElementById('searchTypeText').textContent;
            var autocompleteList = document.getElementById('autocompleteList');
            
            if (!query || query.length < 2) {
                autocompleteList.style.display = 'none';
                return;
            }
            
            // 변수 존재 확인
            if (typeof regionNameList === 'undefined' || typeof hotplaceNameList === 'undefined') {
                autocompleteList.style.display = 'none';
                return;
            }
            
            var list = (searchType === '지역') ? regionNameList : hotplaceNameList;
            var filtered = list.filter(function(item) {
                return item && item.toLowerCase().indexOf(query.toLowerCase()) !== -1;
            }).slice(0, 8); // 최대 8개
            
            if (filtered.length === 0) {
                autocompleteList.style.display = 'none';
                return;
            }
            
            autocompleteList.innerHTML = filtered.map(function(item) {
                return '<div class="autocomplete-item" style="padding:12px 16px; cursor:pointer; border-bottom:1px solid #f0f0f0; font-size:14px; color:#333; transition:background 0.2s;">' + item + '</div>';
            }).join('');
            autocompleteList.style.display = 'flex';
        }
        
        // 검색 결과 렌더링
        function renderSearchResult() {
            var searchInput = document.getElementById('searchInput');
            var searchType = document.getElementById('searchTypeText').textContent;
            var query = searchInput.value.trim();
            var searchResultBox = document.getElementById('searchResultBox');
            
            // 카테고리 바 표시/숨김
            var catBar = document.getElementById('categoryCountsBar');
            if (searchType === '가게') {
                catBar.style.display = 'none';
            }
            
            if (!query) {
                searchResultBox.innerHTML = '<div style="color:#bbb; text-align:center; padding:40px 0;">검색어를 입력해 주세요.</div>';
                return;
            }
            
            var list = (searchType === '지역') ? regionNameList : hotplaceNameList;
            var filtered = list.filter(function(item) {
                return item && item.toLowerCase().indexOf(query.toLowerCase()) !== -1;
            });
            
            if (filtered.length === 0) {
                searchResultBox.innerHTML = '<div style="color:#bbb; text-align:center; padding:40px 0;">검색 결과가 없습니다.</div>';
                return;
            }
            
            if (searchType === '지역') {
                // 지역명 리스트를 네이버 스타일로, 클릭 시 해당 지역의 핫플 리스트 출력
                searchResultBox.innerHTML = filtered.map(function(dong, idx) {
                    var countHtml = '';
                    
                    if (dong === '서울') {
                        // 서울의 경우 전체 카테고리 개수 계산
                        var seoulRegionIds = [];
                        regionCenters.forEach(function(rc) {
                            if (rc.sido === '서울') {
                                seoulRegionIds.push(rc.id);
                            }
                        });
                        
                        var seoulHotplaces = window.hotplaces.filter(function(h) {
                            return seoulRegionIds.indexOf(h.regionId) !== -1;
                        });
                        
                        var seoulClubCount = seoulHotplaces.filter(h => h.categoryId === 1).length;
                        var seoulHuntingCount = seoulHotplaces.filter(h => h.categoryId === 2).length;
                        var seoulLoungeCount = seoulHotplaces.filter(h => h.categoryId === 3).length;
                        var seoulPochaCount = seoulHotplaces.filter(h => h.categoryId === 4).length;
                        
                        countHtml = '<span style="margin-left:10px; font-size:0.98rem; color:#888; display:inline-flex; gap:7px; align-items:center;">'
                            + (seoulClubCount > 0 ? '<span style="color:#9c27b0;">C:' + seoulClubCount + '</span>' : '')
                            + (seoulHuntingCount > 0 ? '<span style="color:#f44336;">H:' + seoulHuntingCount + '</span>' : '')
                            + (seoulLoungeCount > 0 ? '<span style="color:#4caf50;">L:' + seoulLoungeCount + '</span>' : '')
                            + (seoulPochaCount > 0 ? '<span style="color:#8d6e63;">P:' + seoulPochaCount + '</span>' : '')
                            + '</span>';
                    } else {
                        // 동별 카테고리 개수 계산
                        var region = regionCenters.find(function(rc) { return rc.dong === dong; });
                        if (region) {
                            var dongHotplaces = window.hotplaces.filter(function(h) { return h.regionId === region.id; });
                            var clubCount = dongHotplaces.filter(h => h.categoryId === 1).length;
                            var huntingCount = dongHotplaces.filter(h => h.categoryId === 2).length;
                            var loungeCount = dongHotplaces.filter(h => h.categoryId === 3).length;
                            var pochaCount = dongHotplaces.filter(h => h.categoryId === 4).length;
                            
                            countHtml = '<span style="margin-left:10px; font-size:0.98rem; color:#888; display:inline-flex; gap:7px; align-items:center;">'
                                + (clubCount > 0 ? '<span style="color:#9c27b0;">C:' + clubCount + '</span>' : '')
                                + (huntingCount > 0 ? '<span style="color:#f44336;">H:' + huntingCount + '</span>' : '')
                                + (loungeCount > 0 ? '<span style="color:#4caf50;">L:' + loungeCount + '</span>' : '')
                                + (pochaCount > 0 ? '<span style="color:#8d6e63;">P:' + pochaCount + '</span>' : '')
                                + '</span>';
                        }
                    }
                    
                    return '<div class="region-item" style="padding:12px 16px; border:1px solid #e0e0e0; border-radius:8px; margin-bottom:8px; cursor:pointer; transition:background 0.2s; display:flex; align-items:center; justify-content:space-between;" onclick="openRightPanelAndShowDongList(\'' + dong + '\')">'
                        + '<div style="font-weight:bold; color:#333; font-size:1rem;" class="region-name">' + dong + '</div>'
                        + countHtml
                        + '</div>';
                }).join('');
            } else {
                // 가게명 리스트를 카드 형태로 출력
                var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차'};
                var matchedHotplaces = window.hotplaces.filter(function(h) {
                    return filtered.includes(h.name);
                });
                searchResultBox.innerHTML = matchedHotplaces.map(function(h) {
                    var heartHtml = isLoggedIn ? '<i class="bi bi-heart wish-heart" data-place-id="'+h.id+'" style="font-size:1.25rem; color:#e74c3c; cursor:pointer;"></i>' : '<i class="bi bi-heart wish-heart" style="font-size:1.25rem; color:#bbb; cursor:pointer;"></i>';
                    var voteButtonHtml = '<a href="#" onclick="showVoteSection(' + h.id + ', \'' + h.name + '\', \'' + h.address + '\', ' + h.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-size:0.95rem;">🔥 투표</a>';
                    var genreHtml = (h.categoryId === 1 && h.genres && h.genres !== '') ? '<div style="color:#9c27b0; font-weight:600; margin-top:2px; font-size:0.9rem;">🎵 장르: ' + h.genres + '</div>' : '';
                    return '<div class="hotplace-list-card" style="display:flex; flex-direction:column; padding:18px; margin-bottom:16px; background:white; border-radius:12px; box-shadow:0 2px 8px rgba(0,0,0,0.1);">'
                        + '<div style="flex:1; min-width:0;">'
                        +   '<div style="display:flex; align-items:center; gap:6px;">'
                        +     '<div style="flex:1; min-width:0;">'
                        +       '<div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">'
                        +         '<span class="hotplace-name" style="color:#1275E0; font-weight:600; cursor:pointer; flex:1; font-size:1.1rem;">' + h.name + '</span>'
                        +         '<div style="position:relative;">' + heartHtml + '</div>'
                        +       '</div>'
                        +       '<div class="hotplace-category" style="color:#888; font-size:0.8rem; margin-top:2px;">' + (categoryMap[h.categoryId]||'') + '</div>'
                        +       '<div class="wish-count" style="color:#e91e63; font-size:0.8rem; margin-top:2px;">💖<span class="wish-count-' + h.id + '" style="color:#e91e63; font-weight:600;">로딩중...</span>명이 찜했어요</div>'
                        +     '</div>'
                        +   '</div>'
                        +   '<div class="hotplace-address" style="color:#666; margin-top:2px; display:flex; align-items:center; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">' + h.address + '<span onclick="copyAddress(\'' + h.address + '\')" style="cursor:pointer; color:#1275E0; margin-left:2px; display:inline-flex; align-items:center; flex-shrink:0;" title="주소 복사"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></span></div>'
                        + genreHtml
                        + '</div>'
                        + '<div style="display:flex; justify-content:space-between; align-items:flex-start; margin-top:12px;">'
                        +   '<div style="flex:1;"></div>'
                        +   '<div style="display:flex; align-items:center; gap:12px;">'
                        +     '<div>' + voteButtonHtml + '</div>'
                        +   '</div>'
                        + '</div>'
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
                        loadWishCount(place.id);
                        loadVoteTrends(place.id);
                        if (place.categoryId === 1) {
                            loadGenreInfo(place.id);
                        }
                    });
                }, 100);
            }
        }
        

        // 현재 위치 가져오기
        function getCurrentLocation() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function(position) {
                    var loc = new kakao.maps.LatLng(position.coords.latitude, position.coords.longitude);
                    map.setCenter(loc);
                    map.setLevel(3);
                    new kakao.maps.Marker({ position: loc, map: map });
                });
            } else {
                alert('Geolocation is not supported by this browser.');
            }
        }

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
                // 구 레벨에서는 카테고리 버튼 비활성화
                document.querySelectorAll('.map-category-btn').forEach(b => b.classList.remove('active'));
                showHotplaceMarkers = false;
            } else if (level >= 6) {
                dongOverlays.forEach(o => o.setMap(map));
                // 동 레벨에서는 카테고리 버튼 비활성화
                document.querySelectorAll('.map-category-btn').forEach(b => b.classList.remove('active'));
                showHotplaceMarkers = false;
            } else {
                // 가게 마크 레벨에서는 자동으로 전체 버튼 활성화
                document.querySelectorAll('.map-category-btn').forEach(b => b.classList.remove('active'));
                var allButton = document.querySelector('.map-category-btn[data-category="all"]');
                if (allButton) {
                    allButton.classList.add('active');
                }
                showHotplaceMarkers = true;
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

        // 초기에는 마커 표시하지 않음 (showHotplaceMarkers = false)

        // 중복 호출 방지를 위한 플래그
        window.loadingFlags = window.loadingFlags || {};

        // 토스트 메시지 표시 함수
        function showToast(message, type) {
            // 간단한 토스트 메시지 구현
            const toast = document.createElement('div');
            const backgroundColor = type === 'error' ? '#f44336' : '#4caf50';
            toast.style.cssText = 
                'position: fixed;' +
                'top: 20px;' +
                'right: 20px;' +
                'background: ' + backgroundColor + ';' +
                'color: white;' +
                'padding: 12px 20px;' +
                'border-radius: 8px;' +
                'z-index: 10000;' +
                'font-size: 14px;' +
                'box-shadow: 0 4px 12px rgba(0,0,0,0.3);';
            toast.textContent = message;
            document.body.appendChild(toast);
            
            setTimeout(() => {
                document.body.removeChild(toast);
            }, 3000);
        }

        function copyAddress(address) {
            navigator.clipboard.writeText(address).then(function() {
                showToast('주소가 복사되었습니다!', 'success');
            });
        }

        // 위시리스트 하트 설정 함수
        function setupWishHeartByClass(placeId) {
            const hearts = document.querySelectorAll('.wish-heart[data-place-id="' + placeId + '"]');
            hearts.forEach(heart => {
                // 기존 이벤트 리스너 제거
                heart.onclick = null;
                
                // 위시리스트 상태 확인
                fetch(root + '/api/main/wish', {
                    method: 'POST',
                    headers: {
                        'Authorization': 'Bearer ' + getToken(),
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: 'action=check&placeId=' + placeId
                })
                .then(response => response.json())
                .then(data => {
                    if (data.result) {
                        heart.classList.add('on');
                        heart.classList.remove('bi-heart');
                        heart.classList.add('bi-heart-fill');
                        heart.style.color = '#e91e63';
                    } else {
                        heart.classList.remove('on');
                        heart.classList.remove('bi-heart-fill');
                        heart.classList.add('bi-heart');
                        heart.style.color = '#ccc';
                    }
                })
                .catch(error => {
                    // 위시 체크 오류 무시
                });
                
                // 클릭 이벤트 추가
                heart.onclick = function() {
                    if (!isLoggedIn) {
                        showToast('위시리스트는 로그인 후 사용할 수 있어요. 간편하게 로그인하고 저장해보세요!', 'error');
                        return;
                    }
                    
                    const isWished = heart.classList.contains('on');
                    const action = isWished ? 'remove' : 'add';
                    
                    fetch(root + '/api/main/wish', {
                        method: 'POST',
                        headers: {
                            'Authorization': 'Bearer ' + getToken(),
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: 'action=' + action + '&placeId=' + placeId
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.result) {
                            if (isWished) {
                                heart.classList.remove('on');
                                heart.classList.remove('bi-heart-fill');
                                heart.classList.add('bi-heart');
                                heart.style.color = '#ccc';
                                showToast('위시리스트에서 제거되었습니다.', 'success');
                            } else {
                                heart.classList.add('on');
                                heart.classList.remove('bi-heart');
                                heart.classList.add('bi-heart-fill');
                                heart.style.color = '#e91e63';
                                showToast('위시리스트에 추가되었습니다!', 'success');
                            }
                            // 찜 개수 업데이트
                            updateWishCount(placeId);
                        } else {
                            showToast('처리 중 오류가 발생했습니다.', 'error');
                        }
                    })
                    .catch(error => {
                        showToast('처리 중 오류가 발생했습니다.', 'error');
                    });
                };
            });
        }

        // 이미지 로드 함수
        function loadPlaceImages(placeId, retryCount = 0) {
            const containers = document.querySelectorAll('.place-images-container[data-place-id="' + placeId + '"]');
            
            if (containers.length === 0) {
                if (retryCount < 3) {
                    setTimeout(() => loadPlaceImages(placeId, retryCount + 1), 200);
                }
                return;
            }
            
            // 로딩 상태 표시
            containers.forEach(container => {
                container.innerHTML = '<div style="position:relative; width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:#f8f9fa; color:#6c757d; font-size:13px;">' +
                    '<div style="text-align:center;">' +
                        '<div style="font-size:24px; margin-bottom:8px;">⏳</div>' +
                        '<div>이미지 로딩 중...</div>' +
                    '</div>' +
                '</div>';
            });
            
            // 타임아웃 설정 (15초)
            const imageTimeoutId = setTimeout(() => {
                containers.forEach(container => {
                    container.innerHTML = '<div class="no-images" style="position:relative; width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:#f8f9fa; color:#6c757d; font-size:13px;">' +
                        '<div style="text-align:center;">' +
                            '<div style="font-size:48px; margin-bottom:8px;">❌</div>' +
                            '<div>이미지 로드 실패</div>' +
                        '</div>' +
                    '</div>';
                });
            }, 15000);
            
            // Spring API 호출
            fetch(root + '/api/main/place-images?placeId=' + placeId)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('이미지 조회 실패: ' + response.status);
                    }
                    return response.json();
                })
                .then(data => {
                    clearTimeout(imageTimeoutId);
                    containers.forEach(container => {
                        if (data.success && data.images && data.images.length > 0) {
                            const images = data.images;
                            let imageHtml = '';
                            
                            if (images.length === 1) {
                                imageHtml = '<img src="' + root + images[0].imagePath + '" style="width:100%; height:100%; object-fit:cover; cursor:pointer;" alt="장소 이미지" onclick="openImageModal(\'' + root + images[0].imagePath + '\', ' + placeId + ', 0)">';
                            } else {
                                imageHtml = '<div class="place-image-slider" style="position:relative; width:100%; height:100%;">';
                                imageHtml += '<img src="' + root + images[0].imagePath + '" style="width:100%; height:100%; object-fit:cover; cursor:pointer;" alt="장소 이미지" onclick="openImageModal(\'' + root + images[0].imagePath + '\', ' + placeId + ', 0)">';
                                imageHtml += '<button class="image-nav-btn prev-btn" onclick="changeImage(' + placeId + ', ' + images.length + ', 0, -1)" style="position:absolute; left:10px; top:50%; transform:translateY(-50%); background:rgba(0,0,0,0.6); color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:16px;">‹</button>';
                                imageHtml += '<button class="image-nav-btn next-btn" onclick="changeImage(' + placeId + ', ' + images.length + ', 0, 1)" style="position:absolute; right:10px; top:50%; transform:translateY(-50%); background:rgba(0,0,0,0.6); color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:16px;">›</button>';
                                imageHtml += '<div style="position:absolute; bottom:10px; right:10px; background:rgba(0,0,0,0.7); color:white; padding:4px 8px; border-radius:4px; font-size:12px;">1 / ' + images.length + '</div>';
                                imageHtml += '</div>';
                            }
                            
                            container.innerHTML = imageHtml;
                        } else {
                            container.innerHTML = '<div class="no-images" style="position:relative; width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:#f8f9fa; color:#6c757d; font-size:13px;">' +
                                '<div style="text-align:center;">' +
                                    '<div style="font-size:48px; margin-bottom:8px;">📷</div>' +
                                    '<div>이미지 없음</div>' +
                                '</div>' +
                            '</div>';
                        }
                    });
                })
                .catch(error => {
                    clearTimeout(imageTimeoutId);
                    containers.forEach(container => {
                        container.innerHTML = '<div class="no-images" style="position:relative; width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:#f8f9fa; color:#6c757d; font-size:13px;">' +
                            '<div style="text-align:center;">' +
                                '<div style="font-size:48px; margin-bottom:8px;">❌</div>' +
                                '<div>이미지 로드 실패</div>' +
                            '</div>' +
                        '</div>';
                    });
                });
        }

        // 위시리스트 개수 로드 함수
        function loadWishCount(placeId) {
            const wishCountElements = document.querySelectorAll('.wish-count-' + placeId);
            if (wishCountElements.length === 0) {
                return;
            }
            
            // 모든 요소가 이미 숫자가 로드되어 있으면 중복 로딩 방지
            let allLoaded = true;
            for (let element of wishCountElements) {
                if (isNaN(element.textContent) || element.textContent === '') {
                    allLoaded = false;
                    break;
                }
            }
            if (allLoaded) {
                return;
            }
            
            fetch(root + '/api/main/wish-count', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'placeId=' + placeId
            })
            .then(response => response.json())
            .then(data => {
                const count = data.success ? data.count : '0';
                // 모든 해당 요소에 동시에 업데이트
                wishCountElements.forEach(element => {
                    element.textContent = count;
                });
            })
            .catch(error => {
                // 모든 해당 요소에 동시에 업데이트
                wishCountElements.forEach(element => {
                    element.textContent = '0';
                });
            });
        }

        // 찜 개수 실시간 업데이트 함수
        function updateWishCount(placeId) {
            const wishCountElements = document.querySelectorAll('.wish-count-' + placeId);
            if (wishCountElements.length === 0) return;
            
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
                    // 모든 해당 요소에 동시에 업데이트
                    wishCountElements.forEach(element => {
                        element.textContent = data.count;
                    });
                }
            })
            .catch(error => {
                // 위시 개수 업데이트 오류 무시
            });
        }

        // 투표 수 로드 함수
        // loadVoteCount 함수는 loadVoteTrends로 통합됨

        // 투표 트렌드 로드 함수
        function loadVoteTrends(placeId, voteCount) {
            const trendsElements = document.querySelectorAll('#voteTrends-' + placeId);
            const detailsElements = document.querySelectorAll('#voteDetails-' + placeId);
            if (trendsElements.length === 0) return;
            
            // 모든 요소가 이미 로드되어 있으면 중복 로딩 방지
            let allLoaded = true;
            for (let element of trendsElements) {
                if (!element.textContent.includes('회') || element.textContent.includes('로딩중')) {
                    allLoaded = false;
                    break;
                }
            }
            if (allLoaded) {
                return;
            }
            
            // 투표 수와 상세 정보를 동시에 로드
            Promise.all([
                fetch(root + '/api/main/vote-count', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'placeId=' + placeId
                }).then(response => response.json()),
                fetch(root + '/api/main/vote-trends', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'placeId=' + placeId
                }).then(response => response.json())
            ])
            .then(([voteData, trendsData]) => {
                // 역대 투표 수 표시
                const voteCountValue = voteCount || (voteData.success ? voteData.voteCount : 0) || 0;
                const trendsText = '📊 역대 투표: ' + voteCountValue + '회';
                
                // 모든 trends 요소에 동시에 업데이트
                trendsElements.forEach(element => {
                    element.textContent = trendsText;
                });
                
                // 상세 정보 표시
                let detailsText = '#혼잡도 #성비 #대기시간';
                if (trendsData.success && trendsData.trends) {
                    const trends = trendsData.trends;
                    const congestionText = trends.congestion || '데이터없음';
                    const genderRatioText = formatGenderRatio(trends.genderRatio || '데이터없음');
                    const waitTimeText = trends.waitTime || '데이터없음';
                    
                    detailsText = 
                        '#성비:' + genderRatioText + '<br>' +
                        '#혼잡도:' + congestionText + '<br>' +
                        '#대기시간:' + waitTimeText;
                }
                
                // 모든 details 요소에 동시에 업데이트
                detailsElements.forEach(element => {
                    element.innerHTML = detailsText;
                });
            })
            .catch(error => {
                const trendsText = '📊 역대 투표: 0회';
                const detailsText = '#성비<br>#혼잡도<br>#대기시간';
                
                // 모든 요소에 동시에 업데이트
                trendsElements.forEach(element => {
                    element.textContent = trendsText;
                });
                detailsElements.forEach(element => {
                    element.innerHTML = detailsText;
                });
            });
        }

        // 장르 정보 로드 함수
        function loadGenreInfo(placeId) {
            const genresElements = document.querySelectorAll('#genres-' + placeId);
            if (genresElements.length === 0) {
                return;
            }
            
            // 모든 요소가 이미 장르 정보가 로드되어 있으면 중복 로딩 방지
            let allLoaded = true;
            for (let element of genresElements) {
                if (!element.innerHTML.includes('장르:') || element.innerHTML.includes('로딩중')) {
                    allLoaded = false;
                    break;
                }
            }
            if (allLoaded) {
                return;
            }
            
            fetch(root + '/api/main/genre', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'action=getGenres&placeId=' + placeId
            })
            .then(response => response.json())
            .then(data => {
                let genreText = '🎵 장르: 미분류';
                if (data.success && data.genres) {
                    const selectedGenres = data.genres.filter(genre => genre.isSelected);
                    
                    if (selectedGenres.length > 0) {
                        const genreNames = selectedGenres.map(genre => genre.genreName).join(', ');
                        genreText = '🎵 장르: ' + genreNames;
                    }
                }
                
                // 모든 해당 요소에 동시에 업데이트
                genresElements.forEach(element => {
                    element.innerHTML = genreText;
                });
            })
            .catch(error => {
                // 모든 해당 요소에 동시에 업데이트
                genresElements.forEach(element => {
                    element.innerHTML = '🎵 장르: 로드 실패';
                });
            });
        }

        // 투표 섹션 표시 함수
        function showVoteSection(placeId, placeName, placeAddress, categoryId) {
            // 투표 모달 표시
            showVoteModal(placeId, placeName, placeAddress, categoryId);
        }

        // 장르 편집 모달 열기 함수
        function openGenreEditModal(placeId, placeName) {
            showToast('장르 편집 기능은 메인 페이지에서 이용하실 수 있습니다.', 'info');
        }

        // 이미지 업로드 모달 열기 함수
        function openImageUploadModal(placeId) {
            showToast('이미지 업로드 기능은 메인 페이지에서 이용하실 수 있습니다.', 'info');
        }

        // 이미지 관리 모달 열기 함수
        function openImageManageModal(placeId) {
            showToast('이미지 관리 기능은 메인 페이지에서 이용하실 수 있습니다.', 'info');
        }

        // 이미지 변경 함수 (슬라이더용)
        function changeImage(placeId, totalImages, currentIndex, direction) {
            // 현재 인덱스 계산
            let newIndex = currentIndex + direction;
            
            // 인덱스 범위 체크 (순환)
            if (newIndex < 0) {
                newIndex = totalImages - 1;
            } else if (newIndex >= totalImages) {
                newIndex = 0;
            }
            
            // 이미지 컨테이너 찾기
            const containers = document.querySelectorAll('.place-images-container[data-place-id="' + placeId + '"]');
            if (containers.length === 0) return;
            
            // 새로운 이미지 로드
            fetch(root + '/api/main/place-images?placeId=' + placeId)
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.images && data.images.length > newIndex) {
                        const newImage = data.images[newIndex];
                        const timestamp = Date.now();
                        
                        containers.forEach(container => {
                            const slider = container.querySelector('.place-image-slider');
                            if (slider) {
                                // 이미지 업데이트
                                const img = slider.querySelector('img');
                                if (img) {
                                    img.src = root + newImage.imagePath + '?t=' + timestamp;
                                    img.onclick = function() { openImageModal(root + newImage.imagePath, placeId, newIndex); };
                                }
                                
                                // 카운터 업데이트
                                const counter = slider.querySelector('div[style*="position:absolute; bottom:10px"]');
                                if (counter) {
                                    counter.textContent = (newIndex + 1) + ' / ' + totalImages;
                                }
                                
                                // 버튼 onclick 이벤트 업데이트
                                const prevBtn = slider.querySelector('.prev-btn');
                                const nextBtn = slider.querySelector('.next-btn');
                                if (prevBtn) {
                                    prevBtn.onclick = function() { changeImage(placeId, totalImages, newIndex, -1); };
                                }
                                if (nextBtn) {
                                    nextBtn.onclick = function() { changeImage(placeId, totalImages, newIndex, 1); };
                                }
                            }
                        });
                    }
                })
                .catch(error => {
                    // 이미지 변경 오류 무시
                });
        }

        // 이미지 모달 데이터
        let modalData = {
            placeId: 0,
            currentIndex: 0,
            totalImages: 0,
            images: []
        };

        // 이미지 모달 열기
        function openImageModal(imagePath, placeId, currentIndex) {
            // 해당 장소의 모든 이미지 정보 가져오기
            fetch(root + '/api/main/place-images?placeId=' + placeId)
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.images && data.images.length > 0) {
                        modalData = {
                            placeId: placeId,
                            currentIndex: currentIndex,
                            totalImages: data.images.length,
                            images: data.images
                        };
                        showImageModal(imagePath);
                    } else {
                        window.open(imagePath, '_blank');
                    }
                })
                .catch(error => {
                    window.open(imagePath, '_blank');
                });
        }

        // 이미지 모달 표시
        function showImageModal(imagePath) {
            // 기존 모달 제거
            const existingModal = document.getElementById('imageModal');
            if (existingModal) {
                existingModal.remove();
            }

            // 모달 생성
            const modal = document.createElement('div');
            modal.id = 'imageModal';
            modal.style.cssText = 'position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.9); z-index:10000; display:flex; align-items:center; justify-content:center;';

            // 이미지 컨테이너
            const imageContainer = document.createElement('div');
            imageContainer.style.cssText = 'position:relative; max-width:90%; max-height:90%; display:flex; align-items:center; justify-content:center;';
            imageContainer.onclick = function(e) { e.stopPropagation(); };

            // 이미지 생성
            const img = document.createElement('img');
            img.id = 'modalImage';
            img.src = imagePath;
            img.style.cssText = 'min-width: 500px; min-height: 400px; max-width: 100%; max-height: 100%; object-fit: contain; border-radius: 0; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);';
            img.alt = '이미지';

            // 이전 버튼 생성 (이미지가 2개 이상일 때만)
            if (modalData.totalImages > 1) {
                const prevBtn = document.createElement('button');
                prevBtn.innerHTML = '‹';
                prevBtn.style.cssText = 'position:absolute; left:-60px; top:50%; transform:translateY(-50%); background:rgba(255,255,255,0.8); border:none; border-radius:50%; width:50px; height:50px; font-size:24px; cursor:pointer; z-index:10001;';
                prevBtn.onclick = function() { changeModalImage(-1); };
                imageContainer.appendChild(prevBtn);
            }

            // 다음 버튼 생성 (이미지가 2개 이상일 때만)
            if (modalData.totalImages > 1) {
                const nextBtn = document.createElement('button');
                nextBtn.innerHTML = '›';
                nextBtn.style.cssText = 'position:absolute; right:-60px; top:50%; transform:translateY(-50%); background:rgba(255,255,255,0.8); border:none; border-radius:50%; width:50px; height:50px; font-size:24px; cursor:pointer; z-index:10001;';
                nextBtn.onclick = function() { changeModalImage(1); };
                imageContainer.appendChild(nextBtn);
            }

            // 닫기 버튼
            const closeBtn = document.createElement('button');
            closeBtn.innerHTML = '×';
            closeBtn.style.cssText = 'position:absolute; top:-50px; right:0; background:rgba(255,255,255,0.8); border:none; border-radius:50%; width:40px; height:40px; font-size:20px; cursor:pointer; z-index:10001;';
            closeBtn.onclick = closeImageModal;
            imageContainer.appendChild(closeBtn);

            // 카운터 (이미지가 2개 이상일 때만)
            if (modalData.totalImages > 1) {
                const counter = document.createElement('div');
                counter.textContent = (modalData.currentIndex + 1) + ' / ' + modalData.totalImages;
                counter.style.cssText = 'position:absolute; bottom:-40px; left:50%; transform:translateX(-50%); color:white; font-size:16px; background:rgba(0,0,0,0.7); padding:8px 16px; border-radius:20px;';
                imageContainer.appendChild(counter);
            }

            imageContainer.appendChild(img);
            modal.appendChild(imageContainer);
            document.body.appendChild(modal);

            // 모달 외부 클릭 시 닫기
            modal.onclick = closeImageModal;

            // ESC 키로 닫기
            const escapeHandler = function(e) {
                if (e.key === 'Escape') {
                    closeImageModal();
                    document.removeEventListener('keydown', escapeHandler);
                }
            };
            document.addEventListener('keydown', escapeHandler);
        }

        // 모달 이미지 변경
        function changeModalImage(direction) {
            let newIndex = modalData.currentIndex + direction;
            
            if (newIndex < 0) {
                newIndex = modalData.totalImages - 1;
            } else if (newIndex >= modalData.totalImages) {
                newIndex = 0;
            }
            
            const newImage = modalData.images[newIndex];
            const modalImage = document.getElementById('modalImage');
            const timestamp = Date.now();
            
            if (modalImage && newImage) {
                modalImage.src = root + newImage.imagePath + '?t=' + timestamp;
                
                // 카운터 업데이트
                const counter = document.querySelector('#imageModal div[style*="position: absolute; bottom: -40px"]');
                if (counter) {
                    counter.textContent = (newIndex + 1) + ' / ' + modalData.totalImages;
                }
                
                modalData.currentIndex = newIndex;
            }
        }

        // 이미지 모달 닫기
        function closeImageModal() {
            const modal = document.getElementById('imageModal');
            if (modal) {
                modal.remove();
            }
        }
        
        // 전역 함수들
        window.openRightPanelAndShowDongList = function(dong) {
            var panel = document.getElementById('rightPanel');
            var openBtn = document.getElementById('rightPanelToggleBtn');
            var closeBtn = document.getElementById('rightPanelCloseBtn');
            panel.style.transform = 'translateX(0)';
            if (openBtn) openBtn.style.display = 'none';
            if (closeBtn) closeBtn.style.display = 'flex';
            
            // dong이 없거나 빈 값이면 서울 전체 표시
            if (!dong || dong.trim() === '') {
                window.renderHotplaceListBySido('서울', null);
            } else {
                window.renderHotplaceListByDong(dong, null);
            }
        }
        
        window.selectedDong = null;
        
        // 전역 변수들
        window.itemsPerPage = 12;
        window.totalItems = 0;
        window.totalPages = 0;
        window.currentFilteredData = [];
        window.currentPage = 1;
        window.currentSortType = 'latest';

        window.renderHotplaceListBySido = function(sido, categoryId, page) {
            window.selectedDong = sido;
            window.selectedCategory = categoryId || null;
            
            var catBar = document.getElementById('categoryCountsBar');
            
            // catBar가 없으면 생성
            if (!catBar) {
                catBar = document.createElement('div');
                catBar.id = 'categoryCountsBar';
                catBar.style.cssText = 'position:sticky; top:72px; z-index:1; background:#fff; padding:20px; min-height:60px; display:flex; align-items:center; justify-content:center; gap:18px; border-radius:0 0 16px 16px; box-shadow:0 2px 8px rgba(0,0,0,0.04);';
                document.body.insertBefore(catBar, document.getElementById('searchResultBox'));
            }
            
            // 서울에 속하는 모든 regionId 찾기
            var seoulRegionIds = [];
            if (sido === '서울') {
                regionCenters.forEach(function(rc) {
                    if (rc.sido === '서울') {
                        seoulRegionIds.push(rc.id);
                    }
                });
            }
            
            var filtered = window.hotplaces.filter(function(h) {
                if (sido === '서울') {
                    if (seoulRegionIds.indexOf(h.regionId) === -1) return false;
                } else {
                    return false;
                }
                if (categoryId && String(h.categoryId) !== String(categoryId)) return false;
                return true;
            });
            
            window.currentFilteredData = filtered;
            window.totalItems = filtered.length;
            window.totalPages = Math.ceil(window.totalItems / window.itemsPerPage);
            
            if (page) {
                window.currentPage = page;
            } else {
                window.currentPage = 1;
            }
            
            // 현재 페이지에 해당하는 데이터만 추출
            var startIndex = (window.currentPage - 1) * window.itemsPerPage;
            var endIndex = startIndex + window.itemsPerPage;
            var currentPageData = filtered.slice(startIndex, endIndex);
            
            // 카테고리별 개수 계산 (서울 전체)
            var clubCount = filtered.filter(h => h.categoryId === 1).length;
            var huntingCount = filtered.filter(h => h.categoryId === 2).length;
            var loungeCount = filtered.filter(h => h.categoryId === 3).length;
            var pochaCount = filtered.filter(h => h.categoryId === 4).length;
            
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
                        window.renderHotplaceListBySido(sido, null, 1); // 전체, 1페이지로
                    } else {
                        window.renderHotplaceListBySido(sido, cat, 1); // 1페이지로
                    }
                };
            });
            
            var latestActive = window.currentSortType === 'latest' ? 'active' : '';
            var popularActive = window.currentSortType === 'popular' ? 'active' : '';
            var latestStyle = window.currentSortType === 'latest' ? 'background:#1275E0; color:white;' : 'background:white; color:#666;';
            var popularStyle = window.currentSortType === 'popular' ? 'background:#1275E0; color:white;' : 'background:white; color:#666;';
            
            var dongTitle = '<div style="font-size:1.13rem; font-weight:600; color:#1275E0; margin:14px 0 8px 0; display:flex; align-items:center;">지역: ' + sido + ' 전체</div>' +
                '<div style="display:flex; gap:8px; margin-bottom:16px;">' +
                '<button id="sortLatest" class="sort-btn ' + latestActive + '" onclick="sortHotplaces(\'latest\')" style="padding:6px 12px; border:1px solid #ddd; ' + latestStyle + ' border-radius:4px; font-size:0.9rem; cursor:pointer;">최신순</button>' +
                '<button id="sortPopular" class="sort-btn ' + popularActive + '" onclick="sortHotplaces(\'popular\')" style="padding:6px 12px; border:1px solid #ddd; ' + popularStyle + ' border-radius:4px; font-size:0.9rem; cursor:pointer;">인기순</button>' +
                '</div>';
            
            if (filtered.length === 0) {
                window.searchResultBox.innerHTML = dongTitle + '<div style="color:#bbb; text-align:center; padding:40px 0;">해당 지역의 핫플레이스가 없습니다.</div>';
                return;
            }
            
            var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차'};
            
            // 가게 목록 HTML 생성 (기존과 동일)
            var hotplaceListHtml = currentPageData.map(function(h) {
                var heartHtml = isLoggedIn ? '<i class="bi bi-heart wish-heart" data-place-id="'+h.id+'" style="font-size:1.25rem; color:#e74c3c; cursor:pointer;"></i>' : '<i class="bi bi-heart wish-heart" style="font-size:1.25rem; color:#bbb; cursor:pointer;"></i>';
                var voteButtonHtml = '<a href="#" onclick="showVoteSection(' + h.id + ', \'' + h.name + '\', \'' + h.address + '\', ' + h.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-weight:500; font-size:0.9rem; white-space:nowrap; padding:8px 14px; background:#f0f8ff; border-radius:8px; border:1px solid #e3f2fd;">🔥 투표하기</a>';
                
                return '<div class="hotplace-list-card" style="display:flex; flex-direction:column; padding:18px; margin-bottom:16px; background:white; border-radius:12px; box-shadow:0 2px 8px rgba(0,0,0,0.1);">'
                    + '<div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:12px;">'
                    +   '<div style="flex:1; min-width:0;">'
                    +     '<div class="place-name-wish-container" style="display:flex; align-items:center; margin-bottom:8px;">'
                    +       '<div style="flex:1; min-width:0;">'
                    +         '<div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">'
                    +           '<strong style="font-size:1.1rem; word-break:break-word; color:#1275E0; cursor:pointer; flex:1;" class="hotplace-name">' + h.name + '</strong>'
                    +           '<div style="position:relative;">' + heartHtml + '</div>'
                    +         '</div>'
                    +         '<div style="color:#888; font-size:0.8rem; margin-top:2px;">' + (categoryMap[h.categoryId]||'') + '</div>'
                    +         '<div style="color:#e91e63; font-size:0.8rem; margin-top:2px;">💖<span class="wish-count-' + h.id + '" style="color:#e91e63; font-weight:600;">로딩중...</span>명이 찜했어요</div>'
                    +       '</div>'
                    +     '</div>'
                    +     '<div style="margin-bottom:8px; color:#888; font-size:0.95rem; word-break:break-word;" id="voteTrends-' + h.id + '">📊 역대 투표: 로딩중...</div>'
                    +     '<div style="margin-bottom:8px; color:#888; font-size:0.95rem; word-break:break-word;" id="voteDetails-' + h.id + '">#성비<br>#혼잡도<br>#대기시간</div>'
                    +     '<div style="color:#666; font-size:0.95rem; line-height:1.4; margin-bottom:8px; display:flex; align-items:flex-start; gap:6px;">'
                    +       '<div style="flex:1; word-break:break-word;">' + h.address + '</div>'
                    +       '<span onclick="copyAddress(\'' + h.address + '\')" style="cursor:pointer; color:#1275E0; display:inline-flex; align-items:center; flex-shrink:0; margin-top:1px;" title="주소 복사"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></span>'
                    +     '</div>'
                    +     (h.categoryId === 1 ? '<div style="color:#9c27b0; font-weight:600; margin-bottom:8px; font-size:0.9rem; word-break:break-word;" id="genres-' + h.id + '">🎵 장르: 로딩중...</div>' : '')
                    +   '</div>'
                    + '</div>'
                    + '<div style="display:flex; justify-content:space-between; align-items:center;">'
                    +   '<div style="flex:1;"></div>'
                    +   '<div style="display:flex; align-items:center; gap:12px;">'
                    +     '<div>' + voteButtonHtml + '</div>'
                    +   '</div>'
                    + '</div>'
                    + '</div>';
            }).join('');
            
            // 페이징 HTML 생성
            var paginationHtml = '';
            if (window.totalPages > 1) {
                paginationHtml = '<div style="display:flex; justify-content:center; align-items:center; gap:8px; margin-top:20px;">';
                if (window.currentPage > 1) {
                    paginationHtml += '<button onclick="renderHotplaceListBySido(\'' + sido + '\', ' + (categoryId || 'null') + ', ' + (window.currentPage - 1) + ')" style="padding:8px 12px; border:1px solid #ddd; background:white; border-radius:4px; cursor:pointer;">이전</button>';
                }
                for (var i = Math.max(1, window.currentPage - 2); i <= Math.min(window.totalPages, window.currentPage + 2); i++) {
                    var activeStyle = i === window.currentPage ? 'background:#1275E0; color:white;' : 'background:white; color:#666;';
                    paginationHtml += '<button onclick="renderHotplaceListBySido(\'' + sido + '\', ' + (categoryId || 'null') + ', ' + i + ')" style="padding:8px 12px; border:1px solid #ddd; ' + activeStyle + ' border-radius:4px; cursor:pointer;">' + i + '</button>';
                }
                if (window.currentPage < window.totalPages) {
                    paginationHtml += '<button onclick="renderHotplaceListBySido(\'' + sido + '\', ' + (categoryId || 'null') + ', ' + (window.currentPage + 1) + ')" style="padding:8px 12px; border:1px solid #ddd; background:white; border-radius:4px; cursor:pointer;">다음</button>';
                }
                paginationHtml += '</div>';
            }
            
            window.searchResultBox.innerHTML = dongTitle + hotplaceListHtml + paginationHtml;
            
            // 위시리스트 하트 설정
            setTimeout(function() {
                Array.from(document.getElementsByClassName('hotplace-list-card')).forEach(function(card) {
                    var heart = card.querySelector('.wish-heart');
                    var placeName = card.querySelector('.hotplace-name').textContent;
                    var place = currentPageData.find(function(h) { return h.name === placeName; });
                    if (!heart || !place) return;
                    if (!isLoggedIn) {
                        heart.onclick = function() {
                            showToast('위시리스트는 로그인 후 사용할 수 있어요. 간편하게 로그인하고 저장해보세요!', 'error');
                        };
                    } else {
                        heart.setAttribute('data-place-id', place.id);
                        setupWishHeartByClass(place.id);
                    }
                    loadWishCount(place.id);
                    loadVoteTrends(place.id);
                    if (place.categoryId === 1) {
                        loadGenreInfo(place.id);
                    }
                });
            }, 100);
        }
        
        window.renderHotplaceListByDong = function(dong, categoryId, page) {
            window.selectedCategory = categoryId || null;
            window.selectedDong = dong;
            
            var catBar = document.getElementById('categoryCountsBar');
            
            // catBar가 없으면 생성
            if (!catBar) {
                catBar = document.createElement('div');
                catBar.id = 'categoryCountsBar';
                catBar.style.cssText = 'position:sticky; top:72px; z-index:1; background:#fff; padding:20px; min-height:60px; display:flex; align-items:center; justify-content:center; gap:18px; border-radius:0 0 16px 16px; box-shadow:0 2px 8px rgba(0,0,0,0.04);';
                document.body.insertBefore(catBar, document.getElementById('searchResultBox'));
            }
            
            var region = regionCenters.find(function(rc) { return rc.dong === dong; });
            if (!region) {
                window.searchResultBox.innerHTML = '<div style="color:#bbb; text-align:center; padding:40px 0;">해당 동을 찾을 수 없습니다.</div>';
                return;
            }
            
            var filtered = window.hotplaces.filter(function(h) {
                if (h.regionId !== region.id) return false;
                if (categoryId && String(h.categoryId) !== String(categoryId)) return false;
                return true;
            });
            
            window.currentFilteredData = filtered;
            window.totalItems = filtered.length;
            window.totalPages = Math.ceil(window.totalItems / window.itemsPerPage);
            
            if (page) {
                window.currentPage = page;
            } else {
                window.currentPage = 1;
            }
            
            // 현재 페이지에 해당하는 데이터만 추출
            var startIndex = (window.currentPage - 1) * window.itemsPerPage;
            var endIndex = startIndex + window.itemsPerPage;
            var currentPageData = filtered.slice(startIndex, endIndex);
            
            // 카테고리별 개수는 항상 표시 (0이어도)
            var count = (window.regionCategoryCounts || []).find(function(c) { return String(c.region_id) === String(region.id); }) || {};
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
                        window.renderHotplaceListByDong(dong, null, 1); // 전체, 1페이지로
                    } else {
                        window.renderHotplaceListByDong(dong, cat, 1); // 1페이지로
                    }
                };
            });
            
            var latestActive = window.currentSortType === 'latest' ? 'active' : '';
            var popularActive = window.currentSortType === 'popular' ? 'active' : '';
            var latestStyle = window.currentSortType === 'latest' ? 'background:#1275E0; color:white;' : 'background:white; color:#666;';
            var popularStyle = window.currentSortType === 'popular' ? 'background:#1275E0; color:white;' : 'background:white; color:#666;';
            
            var dongTitle = '<div style="font-size:1.13rem; font-weight:600; color:#1275E0; margin:14px 0 8px 0; display:flex; align-items:center;">지역: ' + dong + '</div>' +
                '<div style="display:flex; gap:8px; margin-bottom:16px;">' +
                '<button id="sortLatest" class="sort-btn ' + latestActive + '" onclick="sortHotplaces(\'latest\')" style="padding:6px 12px; border:1px solid #ddd; ' + latestStyle + ' border-radius:4px; font-size:0.9rem; cursor:pointer;">최신순</button>' +
                '<button id="sortPopular" class="sort-btn ' + popularActive + '" onclick="sortHotplaces(\'popular\')" style="padding:6px 12px; border:1px solid #ddd; ' + popularStyle + ' border-radius:4px; font-size:0.9rem; cursor:pointer;">인기순</button>' +
                '</div>';
            
            if (filtered.length === 0) {
                window.searchResultBox.innerHTML = dongTitle + '<div style="color:#bbb; text-align:center; padding:40px 0;">해당 지역의 핫플레이스가 없습니다.</div>';
                return;
            }
            
            var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차'};
            
            // 가게 목록 HTML 생성
            var hotplaceListHtml = currentPageData.map(function(h) {
                var heartHtml = isLoggedIn ? '<i class="bi bi-heart wish-heart" data-place-id="'+h.id+'" style="font-size:1.25rem; color:#e74c3c; cursor:pointer;"></i>' : '<i class="bi bi-heart wish-heart" style="font-size:1.25rem; color:#bbb; cursor:pointer;"></i>';
                var voteButtonHtml = '<a href="#" onclick="showVoteSection(' + h.id + ', \'' + h.name + '\', \'' + h.address + '\', ' + h.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-weight:500; font-size:0.9rem; white-space:nowrap; padding:8px 14px; background:#f0f8ff; border-radius:8px; border:1px solid #e3f2fd;">🔥 투표하기</a>';
                
                return '<div class="hotplace-list-card" style="display:flex; flex-direction:column; padding:18px; margin-bottom:16px; background:white; border-radius:12px; box-shadow:0 2px 8px rgba(0,0,0,0.1);">'
                    + '<div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:12px;">'
                    +   '<div style="flex:1; min-width:0;">'
                    +     '<div class="place-name-wish-container" style="display:flex; align-items:center; margin-bottom:8px;">'
                    +       '<div style="flex:1; min-width:0;">'
                    +         '<div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">'
                    +           '<strong style="font-size:1.1rem; word-break:break-word; color:#1275E0; cursor:pointer; flex:1;" class="hotplace-name">' + h.name + '</strong>'
                    +           '<div style="position:relative;">' + heartHtml + '</div>'
                    +         '</div>'
                    +         '<div style="color:#888; font-size:0.8rem; margin-top:2px;">' + (categoryMap[h.categoryId]||'') + '</div>'
                    +         '<div style="color:#e91e63; font-size:0.8rem; margin-top:2px;">💖<span class="wish-count-' + h.id + '" style="color:#e91e63; font-weight:600;">로딩중...</span>명이 찜했어요</div>'
                    +       '</div>'
                    +     '</div>'
                    +     '<div style="margin-bottom:8px; color:#888; font-size:0.95rem; word-break:break-word;" id="voteTrends-' + h.id + '">📊 역대 투표: 로딩중...</div>'
                    +     '<div style="margin-bottom:8px; color:#888; font-size:0.95rem; word-break:break-word;" id="voteDetails-' + h.id + '">#성비<br>#혼잡도<br>#대기시간</div>'
                    +     '<div style="color:#666; font-size:0.95rem; line-height:1.4; margin-bottom:8px; display:flex; align-items:flex-start; gap:6px;">'
                    +       '<div style="flex:1; word-break:break-word;">' + h.address + '</div>'
                    +       '<span onclick="copyAddress(\'' + h.address + '\')" style="cursor:pointer; color:#1275E0; display:inline-flex; align-items:center; flex-shrink:0; margin-top:1px;" title="주소 복사"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></span>'
                    +     '</div>'
                    +     (h.categoryId === 1 ? '<div style="color:#9c27b0; font-weight:600; margin-bottom:8px; font-size:0.9rem; word-break:break-word;" id="genres-' + h.id + '">🎵 장르: 로딩중...</div>' : '')
                    +   '</div>'
                    + '</div>'
                    + '<div style="display:flex; justify-content:space-between; align-items:center;">'
                    +   '<div style="flex:1;"></div>'
                    +   '<div style="display:flex; align-items:center; gap:12px;">'
                    +     '<div>' + voteButtonHtml + '</div>'
                    +   '</div>'
                    + '</div>'
                    + '</div>';
            }).join('');
            
            // 페이징 HTML 생성
            var paginationHtml = '';
            if (window.totalPages > 1) {
                paginationHtml = '<div style="display:flex; justify-content:center; align-items:center; gap:8px; margin-top:20px;">';
                if (window.currentPage > 1) {
                    paginationHtml += '<button onclick="renderHotplaceListByDong(\'' + dong + '\', ' + (categoryId || 'null') + ', ' + (window.currentPage - 1) + ')" style="padding:8px 12px; border:1px solid #ddd; background:white; border-radius:4px; cursor:pointer;">이전</button>';
                }
                for (var i = Math.max(1, window.currentPage - 2); i <= Math.min(window.totalPages, window.currentPage + 2); i++) {
                    var activeStyle = i === window.currentPage ? 'background:#1275E0; color:white;' : 'background:white; color:#666;';
                    paginationHtml += '<button onclick="renderHotplaceListByDong(\'' + dong + '\', ' + (categoryId || 'null') + ', ' + i + ')" style="padding:8px 12px; border:1px solid #ddd; ' + activeStyle + ' border-radius:4px; cursor:pointer;">' + i + '</button>';
                }
                if (window.currentPage < window.totalPages) {
                    paginationHtml += '<button onclick="renderHotplaceListByDong(\'' + dong + '\', ' + (categoryId || 'null') + ', ' + (window.currentPage + 1) + ')" style="padding:8px 12px; border:1px solid #ddd; background:white; border-radius:4px; cursor:pointer;">다음</button>';
                }
                paginationHtml += '</div>';
            }
            
            window.searchResultBox.innerHTML = dongTitle + hotplaceListHtml + paginationHtml;
            
            // 위시리스트 하트 설정
            setTimeout(function() {
                Array.from(document.getElementsByClassName('hotplace-list-card')).forEach(function(card) {
                    var heart = card.querySelector('.wish-heart');
                    var placeName = card.querySelector('.hotplace-name').textContent;
                    var place = currentPageData.find(function(h) { return h.name === placeName; });
                    if (!heart || !place) return;
                    if (!isLoggedIn) {
                        heart.onclick = function() {
                            showToast('위시리스트는 로그인 후 사용할 수 있어요. 간편하게 로그인하고 저장해보세요!', 'error');
                        };
                    } else {
                        heart.setAttribute('data-place-id', place.id);
                        setupWishHeartByClass(place.id);
                    }
                    loadWishCount(place.id);
                    loadVoteTrends(place.id);
                    if (place.categoryId === 1) {
                        loadGenreInfo(place.id);
                    }
                });
            }, 100);
        }
        
        // 정렬 함수
        window.sortHotplaces = function(sortType) {
            window.currentSortType = sortType;
            
            if (window.selectedDong) {
                if (window.selectedDong === '서울') {
                    window.renderHotplaceListBySido('서울', window.selectedCategory, 1);
                } else {
                    window.renderHotplaceListByDong(window.selectedDong, window.selectedCategory, 1);
                }
            }
        }
        
        // 주소 복사 함수
        function copyAddress(address) {
            navigator.clipboard.writeText(address).then(function() {
                showToast('주소가 복사되었습니다!', 'success');
            });
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
        
        // 전역 함수로 노출
        window.formatGenderRatio = formatGenderRatio;
        
        // 투표 모달 표시 함수
        function showVoteModal(hotplaceId, name, address, categoryId) {
            // 모달이 이미 있으면 제거
            const existingModal = document.getElementById('voteModal');
            if (existingModal) {
                existingModal.remove();
            }
            
            // 모달 HTML 생성
            const modalHtml = 
                '<div id="voteModal" class="modal fade" tabindex="-1" style="display: block !important; background: rgba(0,0,0,0.8) !important; position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 99999; visibility: visible !important; opacity: 1 !important;">' +
                    '<div class="modal-dialog modal-dialog-centered" style="z-index: 100000;">' +
                        '<div class="modal-content" style="border-radius: 20px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.3);">' +
                            '<div class="modal-header" style="border-bottom: none; padding: 25px 25px 10px 25px;">' +
                                '<h5 class="modal-title fw-bold" style="color: #333; font-size: 1.4rem;">' +
                                    '<i class="bi bi-fire" style="color: #ff6b35; margin-right: 8px;"></i>' +
                                    '오늘 핫 투표' +
                                '</h5>' +
                                '<button type="button" class="btn-close" onclick="closeVoteModal()" style="font-size: 1.2rem;"></button>' +
                            '</div>' +
                            '<div class="modal-body" style="padding: 10px 25px 25px 25px;">' +
                                '<!-- 가게 정보 -->' +
                                '<div class="hotplace-info mb-4 p-3 rounded" style="background: #f8f9fa; border-radius: 12px;">' +
                                    '<h6 class="fw-bold mb-1" style="color: #1275E0; font-size: 1.1rem;">' + name + '</h6>' +
                                    '<p class="mb-2 small text-muted">' + address + '</p>' +
                                    '<span class="badge bg-light text-dark">' + getCategoryName(categoryId) + '</span>' +
                                '</div>' +
                                '<!-- 투표 폼 -->' +
                                '<form id="voteForm">' +
                                    '<input type="hidden" id="voteHotplaceId" name="hotplaceId" value="' + hotplaceId + '">' +
                                    '<!-- 1번 질문 -->' +
                                    '<div class="mb-4">' +
                                        '<label class="form-label fw-bold" style="font-size: 1.2rem;">1. 지금 사람 많음?</label>' +
                                        '<div class="d-flex flex-column gap-2">' +
                                            '<div class="form-check">' +
                                                '<input class="form-check-input" type="radio" name="crowd" id="crowd1" value="1" style="transform: scale(1.3);">' +
                                                '<label class="form-check-label" for="crowd1" style="font-size: 1.1rem;">한산함</label>' +
                                            '</div>' +
                                            '<div class="form-check">' +
                                                '<input class="form-check-input" type="radio" name="crowd" id="crowd2" value="2" style="transform: scale(1.3);">' +
                                                '<label class="form-check-label" for="crowd2" style="font-size: 1.1rem;">적당함</label>' +
                                            '</div>' +
                                            '<div class="form-check">' +
                                                '<input class="form-check-input" type="radio" name="crowd" id="crowd3" value="3" style="transform: scale(1.3);">' +
                                                '<label class="form-check-label" for="crowd3" style="font-size: 1.1rem;">붐빔</label>' +
                                            '</div>' +
                                        '</div>' +
                                    '</div>' +
                                    '<!-- 2번 질문 -->' +
                                    '<div class="mb-4">' +
                                        '<label class="form-label fw-bold" style="font-size: 1.2rem;">2. 줄 서야 함?</label>' +
                                        '<div style="font-size: 1.2rem; color: #666; margin-bottom: 10px;">(대기 있음?)</div>' +
                                        '<div class="d-flex flex-column gap-2">' +
                                            '<div class="form-check">' +
                                                '<input class="form-check-input" type="radio" name="wait" id="wait1" value="1" style="transform: scale(1.3);">' +
                                                '<label class="form-check-label" for="wait1" style="font-size: 1.1rem;">바로입장</label>' +
                                            '</div>' +
                                            '<div class="form-check">' +
                                                '<input class="form-check-input" type="radio" name="wait" id="wait2" value="2" style="transform: scale(1.3);">' +
                                                '<label class="form-check-label" for="wait2" style="font-size: 1.1rem;">10분정도</label>' +
                                            '</div>' +
                                            '<div class="form-check">' +
                                                '<input class="form-check-input" type="radio" name="wait" id="wait3" value="3" style="transform: scale(1.3);">' +
                                                '<label class="form-check-label" for="wait3" style="font-size: 1.1rem;">30분</label>' +
                                            '</div>' +
                                            '<div class="form-check">' +
                                                '<input class="form-check-input" type="radio" name="wait" id="wait4" value="4" style="transform: scale(1.3);">' +
                                                '<label class="form-check-label" for="wait4" style="font-size: 1.1rem;">1시간 이상</label>' +
                                            '</div>' +
                                        '</div>' +
                                    '</div>' +
                                    '<!-- 3번 질문 -->' +
                                    '<div class="mb-4">' +
                                        '<label class="form-label fw-bold" style="font-size: 1.2rem;">3. 남녀 성비 어때?</label>' +
                                        '<div class="d-flex flex-column gap-2">' +
                                            '<div class="form-check">' +
                                                '<input class="form-check-input" type="radio" name="gender" id="gender1" value="1" style="transform: scale(1.3);">' +
                                                '<label class="form-check-label" for="gender1" style="font-size: 1.1rem;">여자↑</label>' +
                                            '</div>' +
                                            '<div class="form-check">' +
                                                '<input class="form-check-input" type="radio" name="gender" id="gender2" value="2" style="transform: scale(1.3);">' +
                                                '<label class="form-check-label" for="gender2" style="font-size: 1.1rem;">반반</label>' +
                                            '</div>' +
                                            '<div class="form-check">' +
                                                '<input class="form-check-input" type="radio" name="gender" id="gender3" value="3" style="transform: scale(1.3);">' +
                                                '<label class="form-check-label" for="gender3" style="font-size: 1.1rem;">남자↑</label>' +
                                            '</div>' +
                                        '</div>' +
                                    '</div>' +
                                    '<button type="submit" class="btn w-100" style="padding: 20px; font-size: 1.2rem; font-weight: 600; background: linear-gradient(135deg, rgba(255, 105, 180, 0.8) 0%, rgba(255, 20, 147, 0.7) 100%); border: 2px solid rgba(255,255,255,0.4); color: white; border-radius: 25px;">' +
                                        '<i class="bi bi-fire" style="font-size: 1.3rem;"></i> 투표하기' +
                                    '</button>' +
                                '</form>' +
                                '<!-- 상태 메시지 -->' +
                                '<div id="voteStatusMessage" class="mt-3"></div>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                '</div>';
            
            // 모달을 body에 추가
            document.body.insertAdjacentHTML('beforeend', modalHtml);
            // 폼 이벤트 리스너 추가
            setupVoteForm();
        }
        
        // 카테고리 이름 가져오기 함수
        function getCategoryName(categoryId) {
            const categoryNames = {1: '클럽', 2: '헌팅포차', 3: '라운지', 4: '포차'};
            return categoryNames[categoryId] || '기타';
        }
        
        // 투표 모달 닫기 함수
        function closeVoteModal() {
            const modal = document.getElementById('voteModal');
            if (modal) {
                modal.remove();
            }
        }
        
        // 투표 폼 설정 함수
        function setupVoteForm() {
            const form = document.getElementById('voteForm');
            const statusMessage = document.getElementById('voteStatusMessage');
            
            if (!form) return;
            
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                
                const formData = new FormData(form);
                const hotplaceId = formData.get('hotplaceId');
                const crowd = formData.get('crowd');
                const wait = formData.get('wait');
                const gender = formData.get('gender');
                
                // 검증
                if (!hotplaceId) {
                    showVoteMessage('먼저 지도에서 장소를 선택해주세요.', 'warning');
                    return;
                }
                
                if (!crowd || !wait || !gender) {
                    showVoteMessage('모든 질문에 답변해주세요.', 'warning');
                    return;
                }
                
                // JWT 토큰 가져오기
                const token = getToken();
                
                // Spring API 호출 (JWT 토큰 포함)
                const data = new URLSearchParams();
                data.append('hotplaceId', hotplaceId);
                data.append('crowd', crowd);
                data.append('gender', gender);
                data.append('wait', wait);
                
                const headers = {
                    'Content-Type': 'application/x-www-form-urlencoded'
                };
                
                // 토큰이 있으면 Authorization 헤더 추가
                if (token) {
                    headers['Authorization'] = 'Bearer ' + token;
                }
                
                fetch(root + '/api/vote/now-hot', {
                    method: 'POST',
                    headers: headers,
                    body: data
                })
                .then(response => response.json())
                .then(result => {
                    if (result.success) {
                        showVoteMessage('투표가 완료되었습니다! 감사합니다.', 'success');
                        // 투표 완료 후 모달 닫기
                        setTimeout(() => {
                            closeVoteModal();
                            // 투표 정보 업데이트
                            loadVoteTrends(hotplaceId);
                        }, 1500);
                    } else {
                        showVoteMessage(result.message || '투표 처리 중 오류가 발생했습니다.', 'error');
                    }
                })
                .catch(error => {
                    showVoteMessage('네트워크 오류가 발생했습니다.', 'error');
                });
            });
        }
        
        // 투표 상태 메시지 표시 함수
        function showVoteMessage(message, type) {
            const statusMessage = document.getElementById('voteStatusMessage');
            if (!statusMessage) return;
            
            let alertClass = 'alert-info';
            if (type === 'success') alertClass = 'alert-success';
            else if (type === 'error') alertClass = 'alert-danger';
            else if (type === 'warning') alertClass = 'alert-warning';
            
            statusMessage.innerHTML = 
                '<div class="alert ' + alertClass + ' alert-dismissible fade show" role="alert">' +
                    message +
                    '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
                '</div>';
        }
    </script>
</div>

