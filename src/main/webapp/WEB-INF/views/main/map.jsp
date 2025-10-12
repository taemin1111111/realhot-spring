<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String root = "";
    
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
        /* all.css와 index.jsp의 centered-content 스타일 오버라이드 */
        .centered-content {
            max-width: none !important;
            margin: 0 !important;
            padding: 0 !important;
            min-height: auto !important;
        }
        
        /* map.jsp에서만 푸터 숨기기 */
        footer {
            display: none !important;
        }
        
        .map-page-container {
            width: 100%;
            height: 100vh; /* 전체 화면 높이 사용 */
            margin: 0;
            padding: 0;
            position: relative;
            overflow: hidden;
        }
        
        /* 모바일에서 지도 전체 화면 */
        @media (max-width: 768px) {
            .map-page-container {
                height: 100vh !important;
                margin: 0 !important;
                padding: 0 !important;
            }
            
            .map-container {
                height: 100% !important;
            }
            
            #map {
                height: 100% !important;
            }
            
            /* 모바일에서 카테고리 버튼 위치 조정 */
            .map-controls {
                top: 10px !important;
                left: 10px !important;
                padding: 10px !important;
            }
            
            /* 모바일에서 내 위치 버튼과 메인 버튼 크기 동일하게 */
            .map-controls .btn-outline-primary,
            .map-controls .btn-primary,
            .map-controls button.btn-outline-primary,
            .map-controls a.btn-primary {
                font-size: 0.8rem !important;
                padding: 8px 12px !important;
                min-width: 80px !important;
                height: 35px !important;
            }
            
            /* 모바일에서 토글 버튼 위치 조정 */
            .toggle-button-area {
                right: 5px !important;
            }
            
            /* 모바일에서 오른쪽 패널 전체 화면으로 열리기 */
            #rightPanel {
                width: 100vw !important;
                max-width: 100vw !important;
                border-radius: 0 !important;
            }
            
            /* 모바일에서 검색창 패딩 증가 */
            #searchBar {
                padding: 32px 24px 20px 24px !important;
            }
            
            /* 모바일에서 토글 버튼이 패널 위에 계속 보이도록 */
            .toggle-button-area {
                z-index: 1002 !important;
            }
            
            /* 모바일에서 닫기 버튼도 패널 위에 보이도록 */
            #rightPanelCloseBtn {
                z-index: 1003 !important;
                display: flex !important;
                left: 20px !important;
                top: 50% !important;
                transform: translateY(-50%) !important;
                border-radius: 8px !important;
                border: 1.5px solid #ddd !important;
                width: 40px !important;
                height: 40px !important;
                font-size: 1.2rem !important;
                background: #fff !important;
                box-shadow: 0 2px 8px rgba(0,0,0,0.15) !important;
            }
            
            /* 모바일에서 정렬 버튼 영역에 닫기 버튼 배치 */
            .sort-btn {
                position: relative !important;
            }
            
            /* 최신등록 버튼 왼쪽에 닫기 버튼 배치 */
            #sortLatest {
                margin-left: 50px !important;
            }
            
            /* 모바일에서 검색창 내부 요소들 간격 조정 */
            #searchBar form {
                gap: 12px !important;
            }
            
            /* 모바일에서 지역 드롭다운 크기 조정 */
            .search-type-dropdown {
                flex: 0 0 70px !important;
                min-width: 60px !important;
                max-width: 80px !important;
            }
            
            .search-type-btn {
                height: 36px !important;
                font-size: 0.95rem !important;
                padding: 0 12px !important;
            }
            
            /* 모바일에서 검색 입력창 크기 조정 */
            #searchBar input[type="text"] {
                height: 36px !important;
                font-size: 0.95rem !important;
                padding: 0 12px !important;
            }
        }
        
        .map-container {
            width: 100%;
            height: 100%;
            position: relative;
            z-index: 0; /* 헤더와 푸터 뒤로 */
        }
        
        /* 토글 버튼 영역 - 오른쪽 끝 고정 */
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
            background: none !important;
            color: #000 !important;
            font-size: 13px !important;
            font-weight: 700 !important;
            text-shadow: 2px 2px 4px rgba(255,255,255,1), -1px -1px 2px rgba(255,255,255,1), 1px -1px 2px rgba(255,255,255,1), -1px 1px 2px rgba(255,255,255,1) !important;
            padding: 3px 8px !important;
            border-radius: 4px !important;
            border: none !important;
            white-space: nowrap !important;
            pointer-events: none;
        }
        
        .infoWindow {
            max-width: 280px;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
            z-index: 9999 !important;
            background: white !important;
            border: 1px solid #e0e0e0 !important;
        }
        
        .place-images-container {
            height: 140px;
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
        .map-category-btn.wishlist-filter-btn { background: linear-gradient(135deg, #e74c3c, #c0392b); color: #fff; }
        .map-category-btn.wishlist-filter-btn.active { background: linear-gradient(135deg, #c0392b, #a93226); color: #fff; border: 2.5px solid #000; }
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
        .region-count-marker.marker-guesthouse { background: #2196f3; color: white; }
        
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
        }
        
        /* 검색 결과 카테고리 바 스타일 */
        .search-category-counts-bar {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            justify-content: flex-start;
            gap: 8px;
            padding: 16px 0 4px 16px;
        }
        
        .search-category-row {
            display: flex;
            align-items: center;
            justify-content: flex-start;
            gap: 16px;
        }
        
        /* 모바일에서 검색 패널 카테고리 버튼 배치 */
        @media (max-width: 768px) {
            .search-category-counts-bar {
                gap: 8px !important;
                padding: 12px 0 4px 20px !important;
                flex-direction: row !important;
                flex-wrap: wrap !important;
                justify-content: center !important;
            }
            
            .search-category-row {
                gap: 8px !important;
                display: flex !important;
                flex-direction: row !important;
                flex-wrap: wrap !important;
            }
            
            /* 모든 카테고리 버튼을 한 줄로 배치 */
            .search-category-row:first-child,
            .search-category-row:last-child {
                gap: 8px !important;
                display: contents !important;
            }
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
                padding: 16px !important;
                margin-bottom: 16px !important;
            }
            
            .hotplace-list-card .hotplace-name {
                font-size: 1.1rem !important;
                font-weight: 700 !important;
            }
            
            .hotplace-list-card .hotplace-category {
                font-size: 0.9rem !important;
                margin-top: 3px !important;
            }
            
            .hotplace-list-card .wish-count {
                font-size: 0.9rem !important;
                margin-top: 3px !important;
            }
            
            .hotplace-list-card .vote-trends {
                font-size: 0.9rem !important;
                margin-top: 3px !important;
            }
            
            .hotplace-list-card .vote-details {
                font-size: 0.85rem !important;
                margin-top: 3px !important;
            }
            
            .hotplace-list-card .genre-info {
                font-size: 0.9rem !important;
                margin-top: 3px !important;
            }
            
            .hotplace-list-card .action-buttons-container a {
                font-size: 0.9rem !important;
                padding: 10px 16px !important;
            }
            
            .region-item {
                padding: 12px 16px !important;
                margin-bottom: 10px !important;
            }
            
            .region-item > div:first-child {
                font-size: 1rem !important;
                font-weight: 700 !important;
            }
            
            .region-item .category-counts {
                font-size: 0.9rem !important;
            }
            
            .autocomplete-item {
                padding: 12px 16px !important;
                font-size: 0.95rem !important;
            }
            
            #searchResultBox {
                font-size: 1rem !important;
            }
            
            #searchResultBox .hotplace-address {
                font-size: 0.9rem !important;
            }
            
        /* 모바일에서 화살표 버튼 크기 증가 */
        #rightPanelToggleBtn, #rightPanelCloseBtn {
            width: 50px !important;
            height: 60px !important;
            font-size: 1.8rem !important;
        }
        
        /* 모바일에서 내 위치 버튼과 메인 버튼 크기 */
        .map-controls .btn-outline-primary,
        .map-controls .btn-primary,
        .map-controls button.btn-outline-primary,
        .map-controls a.btn-primary {
            font-size: 0.8rem !important;
            padding: 8px 12px !important;
            min-width: 80px !important;
            height: 35px !important;
        }
        
        /* 모바일에서 카테고리 필터 버튼 크기 조정 */
        .map-category-btn {
            font-size: 0.8rem !important;
            padding: 6px 10px !important;
            min-width: 35px !important;
            height: 35px !important;
        }
        }
        
        /* 작은 모바일 기기 (480px 이하) */
        @media (max-width: 480px) {
            /* 화살표 버튼 크기 */
            #rightPanelToggleBtn, #rightPanelCloseBtn {
                width: 45px !important;
                height: 55px !important;
                font-size: 1.6rem !important;
            }
            
            /* 내 위치 버튼과 메인 버튼 크기 */
            .map-controls .btn-outline-primary,
            .map-controls .btn-primary,
            .map-controls button.btn-outline-primary,
            .map-controls a.btn-primary {
                font-size: 0.7rem !important;
                padding: 6px 10px !important;
                min-width: 70px !important;
                height: 30px !important;
            }
            
            /* 카테고리 필터 버튼 크기 */
            .map-category-btn {
                font-size: 0.7rem !important;
                padding: 5px 8px !important;
                min-width: 30px !important;
                height: 30px !important;
            }
        }
    </style>

<div class="map-page-container">
        
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
                <div style="display: flex; gap: 10px; align-items: center;">
                    <button class="btn btn-sm btn-outline-primary" onclick="getCurrentLocation()">
                        <i class="bi bi-geo-alt"></i> 내 위치
                    </button>
                    <a href="<%=root%>/" class="btn btn-sm btn-primary">
                        <i class="bi bi-house"></i> 메인
                    </a>
                </div>
                
                <!-- 카테고리 필터 -->
                <div class="category-filter">
                    <button class="map-category-btn active" data-category="all">전체</button>
                    <button class="map-category-btn marker-club" data-category="1">C</button>
                    <button class="map-category-btn marker-hunting" data-category="2">H</button>
                    <button class="map-category-btn marker-lounge" data-category="3">L</button>
                    <button class="map-category-btn marker-pocha" data-category="4">P</button>
                    <button class="map-category-btn marker-guesthouse" data-category="5">G</button>
                    <button class="map-category-btn wishlist-filter-btn" data-category="wishlist" id="wishlistFilterBtn" style="display: none;">
                        <i class="bi bi-heart-fill"></i>
                    </button>
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
                // 찜 버튼 표시/숨김 업데이트
                updateWishlistButtonVisibility();
                // 찜한 장소 목록 로드
                loadUserWishlist();
            } else {
                // 로그인되지 않은 상태에서도 찜 버튼 숨김
                updateWishlistButtonVisibility();
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
        var sigunguCategoryCounts = [<% for (int i = 0; i < sigunguCategoryCountList.size(); i++) { Map<String, Object> row = sigunguCategoryCountList.get(i); %>{sigungu:'<%=row.get("sigungu")%>', lat:<%=row.get("lat")%>, lng:<%=row.get("lng")%>, clubCount:<%=row.get("clubCount")%>, huntingCount:<%=row.get("huntingCount")%>, loungeCount:<%=row.get("loungeCount")%>, pochaCount:<%=row.get("pochaCount")%>, guesthouseCount:<%=row.get("guesthouseCount")%>}<% if (i < sigunguCategoryCountList.size() - 1) { %>,<% } %><% } %>];
        var regionCenters = [<% for (int i = 0; i < regionCenters.size(); i++) { Map<String, Object> row = regionCenters.get(i); %>{id:<%=row.get("id")%>, sido:'<%=row.get("sido")%>', sigungu:'<%=row.get("sigungu")%>', dong:'<%=row.get("dong")%>', lat:<%=row.get("lat")%>, lng:<%=row.get("lng")%>}<% if (i < regionCenters.size() - 1) { %>,<% } %><% } %>];
        var regionCategoryCounts = [<% for (int i = 0; i < regionCategoryCounts.size(); i++) { Map<String, Object> row = regionCategoryCounts.get(i); %>{region_id:<%=row.get("region_id")%>, clubCount:<%=row.get("clubCount")%>, huntingCount:<%=row.get("huntingCount")%>, loungeCount:<%=row.get("loungeCount")%>, pochaCount:<%=row.get("pochaCount")%>, guesthouseCount:<%=row.get("guesthouseCount")%>}<% if (i < regionCategoryCounts.size() - 1) { %>,<% } %><% } %>];
        
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
        
        // 찜한 장소 목록을 저장할 전역 변수
        var userWishlist = [];
        var isWishlistFilterActive = false; // 찜 필터 활성화 상태
        var singlePlaceMode = false; // 단일 장소 표시 모드
        var singlePlaceId = null; // 표시할 단일 장소 ID
        
        // 찜한 장소 목록을 가져오는 함수
        function loadUserWishlist() {
            if (!isLoggedIn) {
                userWishlist = [];
                return;
            }
            
            var token = localStorage.getItem('accessToken');
            fetch(root + '/api/main/wish', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Authorization': token ? 'Bearer ' + token : ''
                },
                body: 'action=list'
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('HTTP ' + response.status);
                }
                return response.json();
            })
            .then(data => {
                if (data.result && data.wishList) {
                    userWishlist = data.wishList.map(wish => wish.place_id);
                } else {
                    userWishlist = [];
                }
            })
            .catch(error => {
                console.error('찜한 장소 목록 로드 실패:', error);
                userWishlist = [];
                // 에러가 발생해도 계속 진행
            });
        }
        
        // 로그인 상태에 따라 하트 버튼 표시/숨김
        function updateWishlistButtonVisibility() {
            var wishlistBtn = document.getElementById('wishlistFilterBtn');
            if (wishlistBtn) {
                if (isLoggedIn) {
                    wishlistBtn.style.display = 'flex';
                } else {
                    wishlistBtn.style.display = 'none';
                }
            }
        }
        
        // 개별 장소 정보 표시 함수 (단일 장소 모드)
        window.showPlaceInfo = function(placeId) {
            var place = hotplaces.find(function(p) { return p.id === placeId; });
            if (!place) return;
            
            // 모바일에서 검색창이 열려있으면 닫기
            if (window.innerWidth <= 768) {
                var panel = document.getElementById('rightPanel');
                if (panel && panel.style.transform !== 'translateX(100%)') {
                    panel.style.transform = 'translateX(100%)';
                    var closeBtn = document.getElementById('rightPanelCloseBtn');
                    var openBtn = document.getElementById('rightPanelToggleBtn');
                    if (closeBtn) closeBtn.style.display = 'none';
                    if (openBtn) openBtn.style.display = 'flex';
                }
            }
            
            // 단일 장소 표시 모드 활성화
            singlePlaceMode = true;
            singlePlaceId = placeId;
            showHotplaceMarkers = true; // 가게 마커 표시 활성화
            
            // 모든 기존 마커와 오버레이 완전 제거
            hotplaceMarkers.forEach(function(marker) {
                if (marker) marker.setMap(null);
            });
            hotplaceLabels.forEach(function(label) {
                if (label) label.setMap(null);
            });
            clusterMarkers.forEach(function(marker) {
                if (marker) marker.setMap(null);
            });
            guOverlays.forEach(function(overlay) {
                if (overlay) overlay.setMap(null);
            });
            guCountOverlays.forEach(function(overlay) {
                if (overlay) overlay.setMap(null);
            });
            dongOverlays.forEach(function(overlay) {
                if (overlay) overlay.setMap(null);
            });
            
            // 카테고리 버튼 초기화 (전체 비활성화)
            document.querySelectorAll('.map-category-btn').forEach(b => b.classList.remove('active'));
            
            // 해당 장소의 마커만 강제로 표시
            var targetMarker = null;
            for (var i = 0; i < hotplaces.length; i++) {
                if (hotplaces[i].id === placeId) {
                    targetMarker = hotplaceMarkers[i];
                    if (targetMarker) {
                        targetMarker.setMap(map);
                        if (hotplaceLabels[i]) {
                            hotplaceLabels[i].setMap(map);
                        }
                    }
                    break;
                }
            }
            
            if (targetMarker) {
                // InfoWindow 열기
                var infoContent = generateInfoWindowContent(place);
                var infowindow = new kakao.maps.InfoWindow({ 
                    content: infoContent,
                    maxWidth: 300,
                    minWidth: 260
                });
                infowindow.open(map, targetMarker);
                openInfoWindow = infowindow;
                
                // InfoWindow 내용 로드
                setTimeout(function() {
                    loadInfoWindowContent(place);
                }, 100);
                
                // 지도 중심을 해당 위치로 이동 (마커 표시와 InfoWindow 생성 후에)
                map.setCenter(new kakao.maps.LatLng(place.lat, place.lng));
                map.setLevel(3);
            }
        };
        
        // 하트 상태 동기화 및 클릭 이벤트 (class 기반)
        function setupWishHeartByClass(placeId, retryCount = 0) {
            const hearts = document.querySelectorAll('.wish-heart[data-place-id="' + placeId + '"]');
            if (hearts.length === 0) {
                if (retryCount < 5) {
                    setTimeout(function() {
                        setupWishHeartByClass(placeId, retryCount + 1);
                    }, 100);
                }
                return;
            }
            
            hearts.forEach(heart => {
                // 기존 이벤트 리스너 제거
                heart.onclick = null;
                
                // JWT 토큰 가져오기
                var token = localStorage.getItem('accessToken');
                
                // 찜 여부 확인 (Spring API 호출)
                fetch(root + '/api/main/wish', {
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
                
                // 찜/찜 해제 이벤트
                heart.onclick = function() {
                    var isWished = heart.classList.contains('on');
                    var action = isWished ? 'remove' : 'add';
                    fetch(root + '/api/main/wish', {
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
                                heart.style.color = '#ccc';
                                showToast('위시리스트에서 제거되었습니다.', 'success');
                                
                                // 찜한 장소 목록에서 제거
                                var index = userWishlist.indexOf(placeId);
                                if (index > -1) {
                                    userWishlist.splice(index, 1);
                                }
                                
                                // 찜 필터가 활성화된 상태라면 지도 업데이트
                                if (isWishlistFilterActive && !singlePlaceMode) {
                                    // 마커들 다시 표시 (클러스터링 고려)
                                    showFilteredMarkers();
                                }
                            } else {
                                heart.classList.add('on');
                                heart.classList.remove('bi-heart');
                                heart.classList.add('bi-heart-fill');
                                heart.style.color = '#e91e63';
                                showToast('위시리스트에 추가되었습니다!', 'success');
                                
                                // 찜한 장소 목록에 추가
                                if (!userWishlist.includes(placeId)) {
                                    userWishlist.push(placeId);
                                }
                                
                                // 찜 필터가 활성화된 상태라면 지도 업데이트
                                if (isWishlistFilterActive && !singlePlaceMode) {
                                    // 마커들 다시 표시 (클러스터링 고려)
                                    showFilteredMarkers();
                                }
                            }
                            
                            // 찜 개수 실시간 업데이트
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
        
        // 위시리스트 개수 로드 함수 (Spring API 호출)
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
                    // 모든 해당 요소에 동시에 업데이트 (애니메이션 효과 포함)
                    wishCountElements.forEach(element => {
                        element.style.transform = 'scale(1.2)';
                        element.style.transition = 'transform 0.2s ease';
                        element.textContent = data.count;
                        
                        // 애니메이션 완료 후 원래 크기로 복원
                        setTimeout(() => {
                            element.style.transform = 'scale(1)';
                        }, 200);
                    });
                } else {
                    // 모든 해당 요소에 동시에 업데이트
                    wishCountElements.forEach(element => {
                        element.textContent = '0';
                    });
                }
            })
            .catch(error => {
                console.error('위시리스트 개수 업데이트 오류:', error);
                // 모든 해당 요소에 동시에 업데이트
                wishCountElements.forEach(element => {
                    element.textContent = '0';
                });
            });
        }
        
        // 토스트 메시지 함수
        function showToast(message, type = 'info') {
            // 기존 토스트 제거
            const existingToast = document.getElementById('toast');
            if (existingToast) {
                existingToast.remove();
            }
            
            // 토스트 컨테이너 생성
            const toast = document.createElement('div');
            toast.id = 'toast';
            toast.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: ` + (type === 'success' ? '#28a745' : type === 'error' ? '#dc3545' : '#17a2b8') + `;
                color: white;
                padding: 12px 20px;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                z-index: 10000;
                font-size: 14px;
                font-weight: 500;
                max-width: 300px;
                word-wrap: break-word;
                opacity: 0;
                transform: translateX(100%);
                transition: all 0.3s ease;
            `;
            toast.textContent = message;
            
            document.body.appendChild(toast);
            
            // 애니메이션으로 표시
            setTimeout(() => {
                toast.style.opacity = '1';
                toast.style.transform = 'translateX(0)';
            }, 100);
            
            // 3초 후 자동 제거
            setTimeout(() => {
                toast.style.opacity = '0';
                toast.style.transform = 'translateX(100%)';
                setTimeout(() => {
                    if (toast.parentNode) {
                        toast.parentNode.removeChild(toast);
                    }
                }, 300);
            }, 3000);
        }
        
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

        // 마커 클러스터링 함수
        function clusterMarkers(places, clusterDistance) {
            var clusters = [];
            var processed = new Array(places.length).fill(false);
            
            for (var i = 0; i < places.length; i++) {
                if (processed[i]) continue;
                
                var cluster = {
                    places: [places[i]],
                    centerLat: places[i].lat,
                    centerLng: places[i].lng,
                    indices: [i]
                };
                
                // 같은 위치 근처의 다른 장소들 찾기
                for (var j = i + 1; j < places.length; j++) {
                    if (processed[j]) continue;
                    
                    var distance = Math.sqrt(
                        Math.pow(places[i].lat - places[j].lat, 2) + 
                        Math.pow(places[i].lng - places[j].lng, 2)
                    );
                    
                    if (distance <= clusterDistance) {
                        cluster.places.push(places[j]);
                        cluster.indices.push(j);
                        processed[j] = true;
                    }
                }
                
                processed[i] = true;
                clusters.push(cluster);
            }
            
            return clusters;
        }
        
        // 클러스터 마커 생성 함수
        function createClusterMarker(cluster) {
            var count = cluster.places.length;
            var canvas = document.createElement('canvas');
            canvas.width = 40; canvas.height = 40;
            var ctx = canvas.getContext('2d');
            
            // 클러스터 마커 스타일 (빨간색 원형)
            var gradient = ctx.createRadialGradient(20,20,0,20,20,20);
            gradient.addColorStop(0,'#ff4444');
            gradient.addColorStop(1,'#cc0000');
            
            ctx.fillStyle = gradient;
            ctx.beginPath();
            ctx.arc(20, 20, 20, 0, 2 * Math.PI);
            ctx.fill();
            
            // 그림자 효과
            ctx.shadowColor = 'rgba(0,0,0,0.3)';
            ctx.shadowBlur = 6;
            ctx.shadowOffsetX = 2;
            ctx.shadowOffsetY = 2;
            
            // 흰색 테두리
            ctx.strokeStyle = 'white';
            ctx.lineWidth = 3;
            ctx.stroke();
            
            // 숫자 텍스트
            ctx.fillStyle = 'white';
            ctx.font = 'bold 16px Arial';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText(count.toString(), 20, 20);
            
            var markerImage = new kakao.maps.MarkerImage(canvas.toDataURL(), new kakao.maps.Size(40, 40));
            var marker = new kakao.maps.Marker({
                map: null,
                position: new kakao.maps.LatLng(cluster.centerLat, cluster.centerLng),
                image: markerImage
            });
            
            return marker;
        }
        
        // 클러스터 팝업 생성 함수
        function createClusterPopup(cluster) {
            var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차',5:'게스트하우스'};
            var categoryColors = {1:'#9c27b0',2:'#f44336',3:'#4caf50',4:'#8d6e63',5:'#2196f3'};
            
            var placesHtml = cluster.places.map(function(place) {
                var categoryColor = categoryColors[place.categoryId] || '#666';
                var categoryText = categoryMap[place.categoryId] || '';
                
                return '<div style="display:flex; align-items:center; padding:8px 12px; border-bottom:1px solid #eee; cursor:pointer;" onclick="showPlaceInfo(' + place.id + ')">' +
                    '<div style="width:12px; height:12px; border-radius:50%; background-color:' + categoryColor + '; margin-right:10px; flex-shrink:0;"></div>' +
                    '<div style="flex:1; font-size:14px; color:#333;">' + place.name + '</div>' +
                    '<div style="font-size:12px; color:#999; margin-left:8px;">' + categoryText + '</div>' +
                    '</div>';
            }).join('');
            
            var popupContent = '<div style="background:white; border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.15); min-width:200px; max-width:300px;">' +
                '<div style="padding:12px 16px; border-bottom:1px solid #eee; background:#f8f9fa; border-radius:8px 8px 0 0;">' +
                '<div style="font-weight:bold; color:#333; font-size:16px;">이 위치의 장소들 (' + cluster.places.length + '개)</div>' +
                '</div>' +
                '<div style="max-height:300px; overflow-y:auto;">' + placesHtml + '</div>' +
                '</div>';
            
            return popupContent;
        }
        
        // InfoWindow 내용 생성 함수
        function generateInfoWindowContent(place) {
            // 로그인 상태 다시 확인
            const payload = getTokenPayload();
            const currentIsLoggedIn = payload && payload.exp * 1000 > Date.now();
            
            var heartHtml = currentIsLoggedIn ? '<i class="bi bi-heart wish-heart" data-place-id="' + place.id + '" style="position:absolute;top:6px;right:6px;z-index:1000; color:#e74c3c; font-size:24px; cursor:pointer;"></i>' : '';
            var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차',5:'게스트하우스'};
            return '<div class="infoWindow" style="position:relative; padding:0; font-size:clamp(11px, 1.8vw, 14px); line-height:1.3; border-radius:0; overflow:visible; box-sizing:border-box; min-width:240px; max-width:260px; background:rgba(255,255,255,0.98) !important; backdrop-filter:blur(10px) !important;">'
                + heartHtml
                + '<div class="place-images-container" style="position:relative; width:100%; background:#f8f9fa; display:flex; align-items:center; justify-content:center; color:#6c757d; font-size:clamp(10px, 1.4vw, 12px);" data-place-id="' + place.id + '">이미지 로딩 중...</div>'
                + '<div style="padding:clamp(12px, 2.5vw, 16px);">'
                + '<div class="place-name-wish-container" style="display:flex; align-items:center; margin-bottom:6px;">'
                + '<div style="flex:1; min-width:0;">'
                + '<div style="display:flex; align-items:center; gap:6px; flex-wrap:wrap;">'
                + '<strong style="font-size:clamp(13px, 2.2vw, 16px); word-break:break-word; color:#1275E0; cursor:pointer; flex:1;">' + place.name + '</strong>'
                + '</div>'
                + '<div style="color:#888; font-size:clamp(9px, 1.4vw, 11px); margin-top:1px;">' + (categoryMap[place.categoryId]||'') + '</div>'
                + '<div style="color:#e91e63; font-size:clamp(9px, 1.4vw, 11px); margin-top:1px;">💖<span class="wish-count-' + place.id + '" style="color:#e91e63; font-weight:600;">로딩중...</span>명이 찜했어요</div>'
                + '</div>'
                + '</div>'
                + '<div style="margin-bottom:clamp(6px, 1.5vw, 10px); color:#ff6b35; font-size:clamp(11px, 1.8vw, 13px); font-weight:600;" id="todayHotRank-' + place.id + '">🔥 오늘핫: 로딩중...</div>'
                + '<div style="margin-bottom:clamp(6px, 1.5vw, 10px); color:#ff6b35; font-size:clamp(11px, 1.8vw, 13px); font-weight:600;" id="todayVoteStats-' + place.id + '">#성비 #혼잡도 #대기시간</div>'
                + '<div style="margin-bottom:clamp(6px, 1.5vw, 10px); color:#2196f3; font-size:clamp(11px, 1.8vw, 13px); font-weight:600; cursor:pointer;" id="courseCount-' + place.id + '" onclick="goToPlaceCourses(' + place.id + ')">📝 코스글: 로딩중...</div>'
                + '<div style="margin-bottom:clamp(6px, 1.5vw, 10px); color:#888; font-size:clamp(11px, 1.8vw, 13px); word-break:break-word; display:flex; align-items:center; gap:6px;">'
                +   '<span id="voteTrends-' + place.id + '">📊 역대 투표: 로딩중...</span>'
                +   '<span onclick="toggleVoteDetails(' + place.id + ')" style="color:#1275E0; cursor:pointer; font-size:clamp(11px, 1.8vw, 13px);" id="voteDetailsToggle-' + place.id + '">더보기▾</span>'
                + '</div>'
                + '<div style="margin-bottom:clamp(6px, 1.5vw, 10px); color:#888; font-size:clamp(11px, 1.8vw, 13px); word-break:break-word; display:none;" id="voteDetails-' + place.id + '">#성비<br>#혼잡도<br>#대기시간</div>'
                + '<div style="margin-bottom:clamp(6px, 1.5vw, 10px); color:#666; font-size:clamp(11px, 1.8vw, 13px); word-break:break-word; line-height:1.2; display:flex; align-items:center;">' + place.address + '<span onclick="copyAddress(\'' + place.address + '\')" style="cursor:pointer; color:#1275E0; margin-left:2px; display:inline-flex; align-items:center;" title="주소 복사"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></span></div>'
                + (place.categoryId === 1 ? '<div style="color:#9c27b0; font-weight:600; margin-bottom:clamp(6px, 1.5vw, 10px); font-size:clamp(10px, 1.6vw, 12px); word-break:break-word;" id="genres-' + place.id + '">🎵 장르: 로딩중...</div>' : '')
                + '<div style="margin-bottom:clamp(6px, 1.5vw, 10px); font-size:clamp(11px, 1.8vw, 13px);" id="naverPlaceLink-' + place.id + '">🔗 네이버 플레이스: 로딩중...</div>'
                + '<div class="action-buttons-container" style="padding-bottom: 16px !important;"><a href="#" onclick="showVoteSection(' + place.id + ', \'' + place.name + '\', \'' + place.address + '\', ' + place.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-weight:500; font-size:clamp(11px, 1.8vw, 13px); white-space:nowrap; padding:8px 14px; background:#f0f8ff; border-radius:6px; border:1px solid #e3f2fd;">🔥 투표하기</a>'
                + (isAdmin && place.categoryId === 1 ? '<a href="#" onclick="openGenreEditModal(' + place.id + ', \'' + place.name + '\'); return false;" style="color:#ff6b35; text-decoration:none; font-size:clamp(9px, 1.6vw, 11px); white-space:nowrap; padding:6px 12px; background:#fff3e0; border-radius:5px; border:1px solid #ffe0b2;">✏️ 장르 편집</a>' : '') + '</div>'
                + '</div>'
                + '</div>';
        }
        
        // InfoWindow 내용 로드 함수
        function loadInfoWindowContent(place) {
            var iwEls = document.getElementsByClassName('infoWindow');
            if (iwEls.length > 0) {
                var iw = iwEls[0];
                
                // 하트 태그 설정
                var heart = iw.querySelector('.wish-heart');
                if (heart) {
                    heart.setAttribute('data-place-id', place.id);
                    // 로그인 상태 다시 확인
                    const payload = getTokenPayload();
                    const currentIsLoggedIn = payload && payload.exp * 1000 > Date.now();
                    
                    if (!currentIsLoggedIn) {
                        heart.onclick = function() {
                            showToast('위시리스트는 로그인 후 사용할 수 있어요. 간편하게 로그인하고 저장해보세요!', 'error');
                        };
                    } else {
                        setupWishHeartByClass(place.id);
                    }
                }
                
                // 이미지 로드
                const imageContainer = iw.querySelector('.place-images-container');
                if (imageContainer) {
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
                
      // 오늘핫 순위 로드
      setTimeout(function() {
        loadTodayHotRank(place.id);
      }, 550);
      
      // 코스글 개수 로드
      setTimeout(function() {
        loadCourseCount(place.id);
      }, 600);
      
      // 오늘 투표 통계 로드
      setTimeout(function() {
        loadTodayVoteStats(place.id);
      }, 650);
                
                // 장르 정보 로드 (클럽에만 적용)
                if (place.categoryId === 1) {
                    setTimeout(function() {
                        loadGenreInfo(place.id);
                    }, 600);
                }
                
                // 네이버 플레이스 링크 로드
                setTimeout(function() {
                    loadNaverPlaceLink(place.id);
                }, 650);
                
                // 관리자용 버튼들 추가
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
        }

        // 클러스터링 거리 설정 (위도/경도 차이 기준)
        var CLUSTER_DISTANCE = 0.0001; // 약 10-15미터 정도
        
        // 핫플레이스 클러스터링 및 마커 생성
        var clusters = clusterMarkers(hotplaces, CLUSTER_DISTANCE);
        var clusterMarkers = [];
        var clusterInfoWindows = [];
        
        // 모든 핫플레이스에 대해 개별 마커 생성 (필터링 시 사용)
        hotplaces.forEach(function(place) {
            var markerClass = '', markerText = '';
            switch(place.categoryId) {
                case 1: markerClass = 'marker-club'; markerText = 'C'; break;
                case 2: markerClass = 'marker-hunting'; markerText = 'H'; break;
                case 3: markerClass = 'marker-lounge'; markerText = 'L'; break;
                case 4: markerClass = 'marker-pocha'; markerText = 'P'; break;
                case 5: markerClass = 'marker-guesthouse'; markerText = 'G'; break;
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
                case 5: gradient = ctx.createRadialGradient(16,16,0,16,16,16); gradient.addColorStop(0,'#2196f3'); gradient.addColorStop(1,'#42a5f5'); break;
            }
            ctx.fillStyle = gradient;
            ctx.beginPath(); ctx.arc(16,16,16,0,2*Math.PI); ctx.fill();
            ctx.shadowColor = 'rgba(0,0,0,0.3)'; ctx.shadowBlur = 4; ctx.shadowOffsetX = 2; ctx.shadowOffsetY = 2;
            ctx.fillStyle = 'white'; ctx.font = 'bold 14px Arial'; ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText(markerText, 16, 16);
            
            var markerImage = new kakao.maps.MarkerImage(canvas.toDataURL(), new kakao.maps.Size(32, 32));
            var marker = new kakao.maps.Marker({ map: null, position: new kakao.maps.LatLng(place.lat, place.lng), image: markerImage });
            var labelOverlay = new kakao.maps.CustomOverlay({ content: '<div class="marker-label">' + place.name + '</div>', position: new kakao.maps.LatLng(place.lat, place.lng), xAnchor: 0.5, yAnchor: 0, map: null });
            
            var infowindow = new kakao.maps.InfoWindow({ 
                content: generateInfoWindowContent(place),
                maxWidth: 400,
                minWidth: 300
            });
            
            kakao.maps.event.addListener(marker, 'click', function() {
                if (openInfoWindow) openInfoWindow.close();
                infowindow.open(map, marker);
                openInfoWindow = infowindow;
                setTimeout(function() {
                    loadInfoWindowContent(place);
                }, 100);
            });
            
            hotplaceMarkers.push(marker);
            hotplaceLabels.push(labelOverlay);
            hotplaceInfoWindows.push(infowindow);
            hotplaceCategoryIds.push(place.categoryId);
        });

        // 필터링된 마커들 표시 함수
        function showFilteredMarkers() {
            // 단일 장소 모드일 때는 해당 장소만 표시 (다른 모든 마커 숨김)
            if (singlePlaceMode && singlePlaceId) {
                // 모든 마커 완전히 숨기기
                hotplaceMarkers.forEach(function(marker, idx) {
                    if (marker) marker.setMap(null);
                    if (hotplaceLabels[idx]) hotplaceLabels[idx].setMap(null);
                });
                clusterMarkers.forEach(function(marker) {
                    if (marker) marker.setMap(null);
                });
                
                // 해당 장소만 표시
                for (var i = 0; i < hotplaces.length; i++) {
                    if (hotplaces[i].id === singlePlaceId) {
                        if (hotplaceMarkers[i]) {
                            hotplaceMarkers[i].setMap(map);
                            if (hotplaceLabels[i]) {
                                hotplaceLabels[i].setMap(map);
                            }
                        }
                        break;
                    }
                }
                return;
            }
            
            // 기존 클러스터 마커들 제거
            clusterMarkers.forEach(function(marker) {
                if (marker) marker.setMap(null);
            });
            clusterMarkers = [];
            clusterInfoWindows = [];
            
            // 클러스터 마커들 다시 생성하여 필터링 적용
            var filteredClusters = [];
            var processed = new Array(hotplaces.length).fill(false);
            
            for (var i = 0; i < hotplaces.length; i++) {
                if (processed[i]) continue;
                
                var place = hotplaces[i];
                var shouldShow = true;
                
                // 찜 필터가 활성화된 경우
                if (isWishlistFilterActive) {
                    shouldShow = userWishlist.includes(place.id);
                }
                
                // 카테고리 필터가 활성화된 경우
                var activeCategoryBtn = document.querySelector('.map-category-btn.active');
                if (activeCategoryBtn && activeCategoryBtn.getAttribute('data-category') !== 'all') {
                    var cat = activeCategoryBtn.getAttribute('data-category');
                    if (cat !== 'wishlist') {
                        shouldShow = shouldShow && (String(place.categoryId) === cat);
                    }
                }
                
                if (!shouldShow) {
                    processed[i] = true;
                    continue;
                }
                
                var cluster = {
                    places: [place],
                    centerLat: place.lat,
                    centerLng: place.lng,
                    indices: [i]
                };
                
                // 같은 위치 근처의 다른 장소들 찾기
                for (var j = i + 1; j < hotplaces.length; j++) {
                    if (processed[j]) continue;
                    
                    var otherPlace = hotplaces[j];
                    var otherShouldShow = true;
                    
                    // 찜 필터가 활성화된 경우
                    if (isWishlistFilterActive) {
                        otherShouldShow = userWishlist.includes(otherPlace.id);
                    }
                    
                    // 카테고리 필터가 활성화된 경우
                    if (activeCategoryBtn && activeCategoryBtn.getAttribute('data-category') !== 'all') {
                        var cat = activeCategoryBtn.getAttribute('data-category');
                        if (cat !== 'wishlist') {
                            otherShouldShow = otherShouldShow && (String(otherPlace.categoryId) === cat);
                        }
                    }
                    
                    if (!otherShouldShow) {
                        processed[j] = true;
                        continue;
                    }
                    
                    var distance = Math.sqrt(
                        Math.pow(place.lat - otherPlace.lat, 2) + 
                        Math.pow(place.lng - otherPlace.lng, 2)
                    );
                    
                    if (distance <= CLUSTER_DISTANCE) {
                        cluster.places.push(otherPlace);
                        cluster.indices.push(j);
                        processed[j] = true;
                    }
                }
                
                processed[i] = true;
                filteredClusters.push(cluster);
            }
            
            // 필터링된 클러스터들 표시
            filteredClusters.forEach(function(cluster) {
                if (cluster.places.length === 1) {
                    // 단일 장소인 경우
                    var place = cluster.places[0];
                    var markerIndex = hotplaces.findIndex(function(p) { return p.id === place.id; });
                    if (markerIndex !== -1 && hotplaceMarkers[markerIndex]) {
                        hotplaceMarkers[markerIndex].setMap(map);
                        if (hotplaceLabels[markerIndex]) {
                            hotplaceLabels[markerIndex].setMap(map);
                        }
                    }
                } else {
                    // 여러 장소가 클러스터링된 경우
                    var clusterMarker = createClusterMarker(cluster);
                    var clusterPopup = createClusterPopup(cluster);
                    var clusterInfoWindow = new kakao.maps.InfoWindow({ content: clusterPopup });
                    
                    kakao.maps.event.addListener(clusterMarker, 'click', function() {
                        if (openInfoWindow) openInfoWindow.close();
                        clusterInfoWindow.open(map, clusterMarker);
                        openInfoWindow = clusterInfoWindow;
                    });
                    
                    clusterMarker.setMap(map);
                    clusterMarkers.push(clusterMarker);
                    clusterInfoWindows.push(clusterInfoWindow);
                }
            });
        }

        // 카테고리 필터 기능
        function filterByCategory(category) {
            // 단일 장소 모드가 아닐 때만 가게 마크 표시 활성화
            if (!singlePlaceMode) {
                showHotplaceMarkers = true;
            }
            
            // 기존 마커들 먼저 숨기기
            hideAllMarkers();
            
            // 마커들 다시 표시 (클러스터링 고려)
            showFilteredMarkers();
        }
        
        // 모든 마커 숨기기 함수
        function hideAllMarkers() {
            hotplaceMarkers.forEach(function(marker) {
                if (marker) marker.setMap(null);
            });
            hotplaceLabels.forEach(function(label) {
                if (label) label.setMap(null);
            });
            // 클러스터 마커들도 숨기기
            clusterMarkers.forEach(function(marker) {
                if (marker) marker.setMap(null);
            });
        }
        
        // 모든 가게 마크 숨기기
        function hideAllHotplaceMarkers() {
            showHotplaceMarkers = false;
            hideAllMarkers();
        }

        // 카테고리 버튼 이벤트 (토글 기능)
        document.querySelectorAll('.map-category-btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                var category = this.dataset.category;
                var isActive = this.classList.contains('active');
                
                if (category === 'wishlist') {
                    // 찜 버튼 클릭 처리
                    if (!isLoggedIn) {
                        showToast('로그인 후 찜한 장소를 확인할 수 있어요!', 'error');
                        return;
                    }
                    
                    // 찜한 장소 목록이 비어있으면 다시 로드 시도
                    if (userWishlist.length === 0) {
                        loadUserWishlist();
                        setTimeout(function() {
                            if (userWishlist.length === 0) {
                                showToast('찜한 장소가 없습니다. 마음에 드는 장소를 찜해보세요!', 'error');
                                return;
                            }
                            toggleWishlistFilter();
                        }, 500);
                    } else {
                        toggleWishlistFilter();
                    }
                } else {
                    // 일반 카테고리 버튼 클릭 처리
                    
                    // 단일 장소 모드 해제
                    singlePlaceMode = false;
                    singlePlaceId = null;
                    
                    if (isWishlistFilterActive) {
                        // 찜 필터가 활성화된 상태에서는 찜 버튼의 active 상태를 유지
                        var wishlistBtn = document.getElementById('wishlistFilterBtn');
                        if (wishlistBtn) {
                            wishlistBtn.classList.add('active');
                        }
                    } else {
                        // 찜 필터가 비활성화된 상태에서는 모든 버튼 비활성화
                        document.querySelectorAll('.map-category-btn').forEach(b => b.classList.remove('active'));
                    }
                    
                    if (isActive && !isWishlistFilterActive) {
                        // 찜 필터가 비활성화된 상태에서 이미 활성화된 버튼을 다시 클릭하면 전체로 변경
                        document.querySelectorAll('.map-category-btn').forEach(b => b.classList.remove('active'));
                        var allButton = document.querySelector('.map-category-btn[data-category="all"]');
                        if (allButton) {
                            allButton.classList.add('active');
                        }
                        filterByCategory('all');
                    } else {
                        // 새로운 카테고리 선택
                        this.classList.add('active');
                        filterByCategory(category);
                    }
                }
            });
        });
        
        // 찜 필터 토글 함수
        function toggleWishlistFilter() {
            isWishlistFilterActive = !isWishlistFilterActive;
            var wishlistBtn = document.getElementById('wishlistFilterBtn');
            
            // 단일 장소 모드 해제
            singlePlaceMode = false;
            singlePlaceId = null;
            
            if (isWishlistFilterActive) {
                // 찜 필터 활성화
                wishlistBtn.classList.add('active');
                filterByCategory('wishlist');
            } else {
                // 찜 필터 비활성화
                wishlistBtn.classList.remove('active');
                // 전체 버튼 활성화
                document.querySelector('.map-category-btn[data-category="all"]').classList.add('active');
                filterByCategory('all');
            }
        }
        
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
                        var seoulGuesthouseCount = seoulHotplaces.filter(h => h.categoryId === 5).length;
                        
                        countHtml = '<span style="margin-left:10px; font-size:0.98rem; color:#888; display:inline-flex; gap:7px; align-items:center;">'
                            + (seoulClubCount > 0 ? '<span style="color:#9c27b0;">C:' + seoulClubCount + '</span>' : '')
                            + (seoulHuntingCount > 0 ? '<span style="color:#f44336;">H:' + seoulHuntingCount + '</span>' : '')
                            + (seoulLoungeCount > 0 ? '<span style="color:#4caf50;">L:' + seoulLoungeCount + '</span>' : '')
                            + (seoulPochaCount > 0 ? '<span style="color:#8d6e63;">P:' + seoulPochaCount + '</span>' : '')
                            + (seoulGuesthouseCount > 0 ? '<span style="color:#2196f3;">G:' + seoulGuesthouseCount + '</span>' : '')
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
                            var guesthouseCount = dongHotplaces.filter(h => h.categoryId === 5).length;
                            
                            countHtml = '<span style="margin-left:10px; font-size:0.98rem; color:#888; display:inline-flex; gap:7px; align-items:center;">'
                                + (clubCount > 0 ? '<span style="color:#9c27b0;">C:' + clubCount + '</span>' : '')
                                + (huntingCount > 0 ? '<span style="color:#f44336;">H:' + huntingCount + '</span>' : '')
                                + (loungeCount > 0 ? '<span style="color:#4caf50;">L:' + loungeCount + '</span>' : '')
                                + (pochaCount > 0 ? '<span style="color:#8d6e63;">P:' + pochaCount + '</span>' : '')
                                + (guesthouseCount > 0 ? '<span style="color:#2196f3;">G:' + guesthouseCount + '</span>' : '')
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
                var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차',5:'게스트하우스'};
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
                        +       '<div class="wish-count" style="color:#e91e63; font-size:0.95rem; margin-top:2px;">💖<span class="wish-count-' + h.id + '" style="color:#e91e63; font-weight:600;">로딩중...</span>명이 찜했어요</div>'
                        +       '<div style="color:#ff6b35; font-size:0.95rem; margin-top:2px; font-weight:600;" id="todayHotRank-' + h.id + '">🔥 오늘핫: 로딩중...</div>'
                        +       '<div style="color:#ff6b35; font-size:0.95rem; margin-top:2px; font-weight:600;" id="todayVoteStats-' + h.id + '">#성비 #혼잡도 #대기시간</div>'
                        +       '<div style="color:#2196f3; font-size:0.95rem; margin-top:2px; font-weight:600; cursor:pointer;" id="courseCount-' + h.id + '" onclick="goToPlaceCourses(' + h.id + ')">📝 코스글: 로딩중...</div>'
                        +     '</div>'
                        +   '</div>'
                        +   '<div style="margin-bottom:8px; color:#888; font-size:0.95rem; word-break:break-word; display:flex; align-items:center; gap:8px;">'
                        +     '<span id="voteTrends-' + h.id + '">📊 역대 투표: 로딩중...</span>'
                        +     '<span onclick="toggleVoteDetails(' + h.id + ')" style="color:#1275E0; cursor:pointer; font-size:0.95rem;" id="voteDetailsToggle-' + h.id + '">더보기▾</span>'
                        +   '</div>'
                        +   '<div style="margin-bottom:8px; color:#888; font-size:0.95rem; word-break:break-word; display:none;" id="voteDetails-' + h.id + '">#성비<br>#혼잡도<br>#대기시간</div>'
                        +   '<div class="hotplace-address" style="color:#666; margin-top:2px; display:flex; align-items:center; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">' + h.address + '<span onclick="copyAddress(\'' + h.address + '\')" style="cursor:pointer; color:#1275E0; margin-left:2px; display:inline-flex; align-items:center; flex-shrink:0;" title="주소 복사"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></span></div>'
                        +   (h.categoryId === 1 ? '<div style="color:#9c27b0; font-weight:600; margin-bottom:8px; font-size:0.9rem; word-break:break-word;" id="genres-' + h.id + '">🎵 장르: 로딩중...</div>' : '')
                        +   '<div style="margin-top:2px; font-size:0.95rem;" id="naverPlaceLink-' + h.id + '">🔗 네이버 플레이스: 로딩중...</div>'
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
                        loadTodayHotRank(place.id);
                        loadCourseCount(place.id);
                        loadTodayVoteStats(place.id);
                        if (place.categoryId === 1) {
                            loadGenreInfo(place.id);
                        }
                        loadNaverPlaceLink(place.id);
                        
                        // 가게명 클릭 시 해당 가게로 지도 이동
                        var placeNameEl = card.querySelector('.hotplace-name');
                        if (placeNameEl) {
                            placeNameEl.style.cursor = 'pointer';
                            placeNameEl.onclick = function(e) {
                                e.stopPropagation();
                                showPlaceInfo(place.id);
                            };
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
                + (count && count.guesthouseCount ? '<span class="region-count-marker marker-guesthouse">G <span class="count">' + count.guesthouseCount + '</span></span>' : '')
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
            
            // 기존 마커들 숨기기
            hotplaceMarkers.forEach(function(marker) {
                if (marker) marker.setMap(null);
            });
            hotplaceLabels.forEach(function(label) {
                if (label) label.setMap(null);
            });
            
            // 클러스터 마커들 숨기기
            clusterMarkers.forEach(function(marker) {
                if (marker) marker.setMap(null);
            });
            
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
                if (singlePlaceMode) {
                    // 단일 장소 모드일 때는 해당 장소만 표시
                    for (var i = 0; i < hotplaces.length; i++) {
                        if (hotplaces[i].id === singlePlaceId) {
                            if (hotplaceMarkers[i]) {
                                hotplaceMarkers[i].setMap(map);
                                if (hotplaceLabels[i]) {
                                    hotplaceLabels[i].setMap(map);
                                }
                            }
                            break;
                        }
                    }
                } else {
                    if (singlePlaceMode) {
                        // 단일 장소 모드일 때는 해당 장소만 표시
                        for (var i = 0; i < hotplaces.length; i++) {
                            if (hotplaces[i].id === singlePlaceId) {
                                if (hotplaceMarkers[i]) {
                                    hotplaceMarkers[i].setMap(map);
                                    if (hotplaceLabels[i]) {
                                        hotplaceLabels[i].setMap(map);
                                    }
                                }
                                break;
                            }
                        }
                    } else {
                        // 가게 마크 레벨에서는 기존 카테고리 필터 상태 유지
                        showHotplaceMarkers = true;
                        
                        // 현재 활성화된 카테고리 버튼이 있는지 확인
                        var activeButton = document.querySelector('.map-category-btn.active');
                        if (!activeButton) {
                            // 활성화된 버튼이 없으면 전체 버튼 활성화
                            var allButton = document.querySelector('.map-category-btn[data-category="all"]');
                            if (allButton) {
                                allButton.classList.add('active');
                            }
                        }
                        
                        // 마커들 다시 표시 (클러스터링 고려)
                        showFilteredMarkers();
                    }
                }
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

        // 특정 가게의 코스 목록으로 이동하는 함수
        function goToPlaceCourses(placeId) {
            // 모바일에서 검색창이 열려있으면 닫기
            if (window.innerWidth <= 768) {
                var panel = document.getElementById('rightPanel');
                if (panel && panel.style.transform !== 'translateX(100%)') {
                    panel.style.transform = 'translateX(100%)';
                    var closeBtn = document.getElementById('rightPanelCloseBtn');
                    var openBtn = document.getElementById('rightPanelToggleBtn');
                    if (closeBtn) closeBtn.style.display = 'none';
                    if (openBtn) openBtn.style.display = 'flex';
                }
            }
            
            window.location.href = root + '/course/place/' + placeId;
        }

        // 코스글 개수 로드 함수
        function loadCourseCount(placeId) {
            const courseElements = document.querySelectorAll('#courseCount-' + placeId);
            if (courseElements.length === 0) {
                return;
            }
            
            fetch(root + '/course/api/course-count', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'placeId=' + placeId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const courseText = '📝 코스글: ' + data.courseCount + '개';
                    courseElements.forEach(element => {
                        element.textContent = courseText;
                    });
                } else {
                    const courseText = '📝 코스글: 0개';
                    courseElements.forEach(element => {
                        element.textContent = courseText;
                    });
                }
            })
            .catch(error => {
                const courseText = '📝 코스글: 0개';
                courseElements.forEach(element => {
                    element.textContent = courseText;
                });
            });
        }

        // 역대 투표 상세 정보 토글 함수
        function toggleVoteDetails(placeId) {
            const detailsElement = document.getElementById('voteDetails-' + placeId);
            const toggleElement = document.getElementById('voteDetailsToggle-' + placeId);
            
            if (detailsElement && toggleElement) {
                if (detailsElement.style.display === 'none') {
                    detailsElement.style.display = 'block';
                    toggleElement.textContent = '접기△';
                } else {
                    detailsElement.style.display = 'none';
                    toggleElement.textContent = '더보기▾';
                }
            }
        }

        // 오늘 투표 통계 로드 함수
        function loadTodayVoteStats(placeId, retryCount = 0) {
            const statsElements = document.querySelectorAll('#todayVoteStats-' + placeId);
            if (statsElements.length === 0 && retryCount < 10) {
                setTimeout(function() {
                    loadTodayVoteStats(placeId, retryCount + 1);
                }, 200);
                return;
            }
            if (statsElements.length === 0) {
                return;
            }
            
            // 모든 요소가 이미 통계 정보가 로드되어 있으면 중복 로딩 방지
            let allLoaded = true;
            for (let element of statsElements) {
                if (element.textContent.includes('로딩중') || element.textContent.includes('#성비 #혼잡도 #대기시간')) {
                    allLoaded = false;
                    break;
                }
            }
            if (allLoaded) {
                return;
            }
            
            fetch(root + '/api/today-hot/today-stats', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'placeId=' + placeId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    let statsText = '';
                    
                    // 성비
                    if (data.genderRatio) {
                        let genderText = '';
                        switch(data.genderRatio) {
                            case '남초': genderText = '남자 ↑'; break;
                            case '여초': genderText = '여자 ↑'; break;
                            case '반반': genderText = '반반'; break;
                            default: genderText = data.genderRatio; break;
                        }
                        statsText += '#성비: ' + genderText + ' ';
                    }
                    
                    // 혼잡도
                    if (data.congestion) {
                        let congestionText = '';
                        switch(data.congestion) {
                            case '여유': congestionText = '여유'; break;
                            case '보통': congestionText = '보통'; break;
                            case '많음': congestionText = '많음'; break;
                            case '혼잡': congestionText = '혼잡'; break;
                            default: congestionText = data.congestion; break;
                        }
                        statsText += '#혼잡도: ' + congestionText + ' ';
                    }
                    
                    // 대기시간
                    if (data.waitTime) {
                        let waitTimeText = '';
                        switch(data.waitTime) {
                            case '없음': waitTimeText = '없음'; break;
                            case '10분': waitTimeText = '10분 ↑'; break;
                            case '30분': waitTimeText = '30분 ↑'; break;
                            case '1시간': waitTimeText = '1시간 ↑'; break;
                            default: waitTimeText = data.waitTime; break;
                        }
                        statsText += '#대기시간: ' + waitTimeText;
                    }
                    
                    if (statsText.trim()) {
                        statsElements.forEach(element => {
                            // 검색 결과인지 지도 상세 정보인지 구분
                            const isSearchResult = element.closest('.hotplace-list-card') !== null;
                            
                            if (isSearchResult) {
                                // 검색 결과: 각각 한 줄씩
                                let formattedText = '';
                                if (data.genderRatio) {
                                    let genderText = '';
                                    switch(data.genderRatio) {
                                        case '남초': genderText = '남자 ↑'; break;
                                        case '여초': genderText = '여자 ↑'; break;
                                        case '반반': genderText = '반반'; break;
                                        default: genderText = data.genderRatio; break;
                                    }
                                    formattedText += '#성비: ' + genderText + '<br>';
                                }
                                
                                if (data.congestion) {
                                    let congestionText = '';
                                    switch(data.congestion) {
                                        case '여유': congestionText = '여유'; break;
                                        case '보통': congestionText = '보통'; break;
                                        case '많음': congestionText = '많음'; break;
                                        case '혼잡': congestionText = '혼잡'; break;
                                        default: congestionText = data.congestion; break;
                                    }
                                    formattedText += '#혼잡도: ' + congestionText + '<br>';
                                }
                                
                                if (data.waitTime) {
                                    let waitTimeText = '';
                                    switch(data.waitTime) {
                                        case '없음': waitTimeText = '없음'; break;
                                        case '10분': waitTimeText = '10분 ↑'; break;
                                        case '30분': waitTimeText = '30분 ↑'; break;
                                        case '1시간': waitTimeText = '1시간 ↑'; break;
                                        default: waitTimeText = data.waitTime; break;
                                    }
                                    formattedText += '#대기시간: ' + waitTimeText;
                                }
                                
                                element.innerHTML = formattedText.trim();
                            } else {
                                // 지도 상세 정보: 한 줄로
                                element.textContent = statsText.trim();
                            }
                        });
                    } else {
                        statsElements.forEach(element => {
                            element.textContent = '#성비 #혼잡도 #대기시간';
                        });
                    }
                } else {
                    statsElements.forEach(element => {
                        element.textContent = '#성비 #혼잡도 #대기시간';
                    });
                }
            })
            .catch(error => {
                statsElements.forEach(element => {
                    element.textContent = '#성비 #혼잡도 #대기시간';
                });
            });
        }

        // 오늘핫 순위 로드 함수
        function loadTodayHotRank(placeId) {
            const rankElements = document.querySelectorAll('#todayHotRank-' + placeId);
            if (rankElements.length === 0) {
                return;
            }
            
            // 모든 요소가 이미 순위 정보가 로드되어 있으면 중복 로딩 방지
            let allLoaded = true;
            for (let element of rankElements) {
                if (element.textContent.includes('로딩중')) {
                    allLoaded = false;
                    break;
                }
            }
            if (allLoaded) {
                return;
            }
            
            fetch(root + '/api/today-hot/rank', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'placeId=' + placeId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success && data.ranking) {
                    const rankText = '🔥 오늘핫: ' + data.ranking + '위(' + data.voteCount + '표)';
                    rankElements.forEach(element => {
                        element.textContent = rankText;
                    });
                } else if (data.success && data.voteCount > 0) {
                    // 투표는 있지만 순위가 없는 경우 (상위 12위 밖)
                    const rankText = '🔥 오늘핫: 순위밖(' + data.voteCount + '표)';
                    rankElements.forEach(element => {
                        element.textContent = rankText;
                    });
                } else {
                    const rankText = '🔥 오늘핫: 투표없음';
                    rankElements.forEach(element => {
                        element.textContent = rankText;
                    });
                }
            })
            .catch(error => {
                const rankText = '🔥 오늘핫: 투표없음';
                rankElements.forEach(element => {
                    element.textContent = rankText;
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
        let mapModalData = {
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
                        mapModalData = {
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
            if (mapModalData.totalImages > 1) {
                const prevBtn = document.createElement('button');
                prevBtn.innerHTML = '‹';
                prevBtn.style.cssText = 'position:absolute; left:-60px; top:50%; transform:translateY(-50%); background:rgba(255,255,255,0.8); border:none; border-radius:50%; width:50px; height:50px; font-size:24px; cursor:pointer; z-index:10001;';
                prevBtn.onclick = function() { changeModalImage(-1); };
                imageContainer.appendChild(prevBtn);
            }

            // 다음 버튼 생성 (이미지가 2개 이상일 때만)
            if (mapModalData.totalImages > 1) {
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
            if (mapModalData.totalImages > 1) {
                const counter = document.createElement('div');
                counter.textContent = (mapModalData.currentIndex + 1) + ' / ' + mapModalData.totalImages;
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
            let newIndex = mapModalData.currentIndex + direction;
            
            if (newIndex < 0) {
                newIndex = mapModalData.totalImages - 1;
            } else if (newIndex >= mapModalData.totalImages) {
                newIndex = 0;
            }
            
            const newImage = mapModalData.images[newIndex];
            const modalImage = document.getElementById('modalImage');
            const timestamp = Date.now();
            
            if (modalImage && newImage) {
                modalImage.src = root + newImage.imagePath + '?t=' + timestamp;
                
                // 카운터 업데이트
                const counter = document.querySelector('#imageModal div[style*="position: absolute; bottom: -40px"]');
                if (counter) {
                    counter.textContent = (newIndex + 1) + ' / ' + mapModalData.totalImages;
                }
                
                mapModalData.currentIndex = newIndex;
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
            
            // 정렬 적용
            if (window.currentSortType === 'popular' || window.currentSortType === 'coursePopular') {
                // 인기순 또는 인기 코스 정렬의 경우 전체 데이터의 통계를 먼저 로드
                loadAllStatsForSorting(filtered, function(sortedFiltered) {
                    renderHotplaceListBySidoWithData(sido, categoryId, page, sortedFiltered);
                });
                return;
            } else {
                // 최신순 정렬의 경우 바로 정렬
                filtered = sortHotplaceData(filtered, window.currentSortType);
            }
            
            renderHotplaceListBySidoWithData(sido, categoryId, page, filtered);
        }
        
        // 실제 렌더링을 수행하는 함수
        function renderHotplaceListBySidoWithData(sido, categoryId, page, filtered) {
            var catBar = document.getElementById('categoryCountsBar');
            
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
            var guesthouseCount = filtered.filter(h => h.categoryId === 5).length;
            
            var catHtml = '<div class="search-category-counts-bar">'
                + '<div class="search-category-row">'
                + '<span class="search-category-ball marker-club' + (categoryId==1?' active':'') + '" data-category="1">C</span> <span class="search-cat-count-num" style="color:#9c27b0;">' + clubCount + '</span>'
                + '<span class="search-category-ball marker-hunting' + (categoryId==2?' active':'') + '" data-category="2">H</span> <span class="search-cat-count-num" style="color:#f44336;">' + huntingCount + '</span>'
                + '<span class="search-category-ball marker-lounge' + (categoryId==3?' active':'') + '" data-category="3">L</span> <span class="search-cat-count-num" style="color:#4caf50;">' + loungeCount + '</span>'
                + '</div>'
                + '<div class="search-category-row">'
                + '<span class="search-category-ball marker-pocha' + (categoryId==4?' active':'') + '" data-category="4">P</span> <span class="search-cat-count-num" style="color:#8d6e63;">' + pochaCount + '</span>'
                + '<span class="search-category-ball marker-guesthouse' + (categoryId==5?' active':'') + '" data-category="5">G</span> <span class="search-cat-count-num" style="color:#2196f3;">' + guesthouseCount + '</span>'
                + '</div>'
                + '</div>';
            catBar.innerHTML = catHtml;
            catBar.style.display = 'flex';
            
            // 카테고리 원 클릭 이벤트 바인딩
            Array.from(catBar.getElementsByClassName('search-category-ball')).forEach(function(ball) {
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
                '<div style="display:flex; gap:6px; margin:8px 0 16px 0; flex-wrap:wrap;">' +
                '<button id="sortLatest" class="sort-btn ' + latestActive + '" onclick="sortHotplaces(\'latest\')" style="padding:8px 12px; border:1px solid #ddd; ' + latestStyle + ' border-radius:6px; font-size:0.85rem; cursor:pointer; flex:1; min-width:0;">최신등록</button>' +
                '<button id="sortPopular" class="sort-btn ' + popularActive + '" onclick="sortHotplaces(\'popular\')" style="padding:8px 12px; border:1px solid #ddd; ' + popularStyle + ' border-radius:6px; font-size:0.85rem; cursor:pointer; flex:1; min-width:0;">인기순</button>' +
                '<button id="sortCoursePopular" class="sort-btn ' + (window.currentSortType === 'coursePopular' ? 'active' : '') + '" onclick="sortHotplaces(\'coursePopular\')" style="padding:8px 12px; border:1px solid #ddd; ' + (window.currentSortType === 'coursePopular' ? 'background:#1275E0; color:white;' : 'background:white; color:#333;') + ' border-radius:6px; font-size:0.85rem; cursor:pointer; flex:1; min-width:0;">인기 코스</button>' +
                '</div>';
            
            if (filtered.length === 0) {
                window.searchResultBox.innerHTML = dongTitle + '<div style="color:#bbb; text-align:center; padding:40px 0;">해당 지역의 핫플레이스가 없습니다.</div>';
                return;
            }
            
            var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차',5:'게스트하우스'};
            
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
                    +         '<div style="color:#e91e63; font-size:0.95rem; margin-top:2px;">💖<span class="wish-count-' + h.id + '" style="color:#e91e63; font-weight:600;">로딩중...</span>명이 찜했어요</div>'
                    +         '<div style="color:#ff6b35; font-size:0.95rem; margin-top:2px; font-weight:600;" id="todayHotRank-' + h.id + '">🔥 오늘핫: 로딩중...</div>'
                    +         '<div style="color:#ff6b35; font-size:0.95rem; margin-top:2px; font-weight:600;" id="todayVoteStats-' + h.id + '">#성비 #혼잡도 #대기시간</div>'
                    +         '<div style="color:#2196f3; font-size:0.95rem; margin-top:2px; font-weight:600; cursor:pointer;" id="courseCount-' + h.id + '" onclick="goToPlaceCourses(' + h.id + ')">📝 코스글: 로딩중...</div>'
                    +       '</div>'
                    +     '</div>'
                    +     '<div style="margin-bottom:8px; color:#888; font-size:0.95rem; word-break:break-word; display:flex; align-items:center; gap:8px;">'
                    +       '<span id="voteTrends-' + h.id + '">📊 역대 투표: 로딩중...</span>'
                    +       '<span onclick="toggleVoteDetails(' + h.id + ')" style="color:#1275E0; cursor:pointer; font-size:0.95rem;" id="voteDetailsToggle-' + h.id + '">더보기▾</span>'
                    +     '</div>'
                    +     '<div style="margin-bottom:8px; color:#888; font-size:0.95rem; word-break:break-word; display:none;" id="voteDetails-' + h.id + '">#성비<br>#혼잡도<br>#대기시간</div>'
                    +     '<div style="color:#666; font-size:0.95rem; line-height:1.4; margin-bottom:8px; display:flex; align-items:flex-start; gap:6px;">'
                    +       '<div style="flex:1; word-break:break-word;">' + h.address + '</div>'
                    +       '<span onclick="copyAddress(\'' + h.address + '\')" style="cursor:pointer; color:#1275E0; display:inline-flex; align-items:center; flex-shrink:0; margin-top:1px;" title="주소 복사"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></span>'
                    +     '</div>'
                    +     (h.categoryId === 1 ? '<div style="color:#9c27b0; font-weight:600; margin-bottom:8px; font-size:0.9rem; word-break:break-word;" id="genres-' + h.id + '">🎵 장르: 로딩중...</div>' : '')
                    +     '<div style="margin-bottom:8px; font-size:0.95rem;" id="naverPlaceLink-' + h.id + '">🔗 네이버 플레이스: 로딩중...</div>'
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
                    paginationHtml += '<button onclick="renderHotplaceListBySido(\'' + sido + '\', ' + (categoryId || 'null') + ', ' + (window.currentPage - 1) + ')" style="padding:6px 10px; border:1px solid #ddd; background:white; border-radius:4px; cursor:pointer; font-size:14px;">&lt;</button>';
                }
                for (var i = Math.max(1, window.currentPage - 2); i <= Math.min(window.totalPages, window.currentPage + 2); i++) {
                    var activeStyle = i === window.currentPage ? 'background:#1275E0; color:white;' : 'background:white; color:#666;';
                    paginationHtml += '<button onclick="renderHotplaceListBySido(\'' + sido + '\', ' + (categoryId || 'null') + ', ' + i + ')" style="padding:8px 12px; border:1px solid #ddd; ' + activeStyle + ' border-radius:4px; cursor:pointer;">' + i + '</button>';
                }
                if (window.currentPage < window.totalPages) {
                    paginationHtml += '<button onclick="renderHotplaceListBySido(\'' + sido + '\', ' + (categoryId || 'null') + ', ' + (window.currentPage + 1) + ')" style="padding:6px 10px; border:1px solid #ddd; background:white; border-radius:4px; cursor:pointer; font-size:14px;">&gt;</button>';
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
                    
                    // 장소 이름 클릭 이벤트 추가
                    var placeNameEl = card.querySelector('.hotplace-name');
                    if (placeNameEl) {
                        placeNameEl.style.cursor = 'pointer';
                        placeNameEl.onclick = function(e) {
                            e.stopPropagation();
                            showPlaceInfo(place.id);
                        };
                    }
                    
                    loadWishCount(place.id);
                    loadVoteTrends(place.id);
                    loadTodayHotRank(place.id);
                    loadCourseCount(place.id);
                    loadTodayVoteStats(place.id);
                    if (place.categoryId === 1) {
                        loadGenreInfo(place.id);
                    }
                    loadNaverPlaceLink(place.id);
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
            
            // 정렬 적용
            if (window.currentSortType === 'popular' || window.currentSortType === 'coursePopular') {
                // 인기순 또는 인기 코스 정렬의 경우 전체 데이터의 통계를 먼저 로드
                loadAllStatsForSorting(filtered, function(sortedFiltered) {
                    renderHotplaceListByDongWithData(dong, categoryId, page, sortedFiltered, region);
                });
                return;
            } else {
                // 최신순 정렬의 경우 바로 정렬
                filtered = sortHotplaceData(filtered, window.currentSortType);
            }
            
            renderHotplaceListByDongWithData(dong, categoryId, page, filtered, region);
        }
        
        // 실제 렌더링을 수행하는 함수
        function renderHotplaceListByDongWithData(dong, categoryId, page, filtered, region) {
            var catBar = document.getElementById('categoryCountsBar');
            
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
            var guesthouseCount = (typeof count.guesthouseCount === 'number') ? count.guesthouseCount : 0;
            var catHtml = '<div class="search-category-counts-bar">'
                + '<div class="search-category-row">'
                + '<span class="search-category-ball marker-club' + (categoryId==1?' active':'') + '" data-category="1">C</span> <span class="search-cat-count-num" style="color:#9c27b0;">' + clubCount + '</span>'
                + '<span class="search-category-ball marker-hunting' + (categoryId==2?' active':'') + '" data-category="2">H</span> <span class="search-cat-count-num" style="color:#f44336;">' + huntingCount + '</span>'
                + '<span class="search-category-ball marker-lounge' + (categoryId==3?' active':'') + '" data-category="3">L</span> <span class="search-cat-count-num" style="color:#4caf50;">' + loungeCount + '</span>'
                + '</div>'
                + '<div class="search-category-row">'
                + '<span class="search-category-ball marker-pocha' + (categoryId==4?' active':'') + '" data-category="4">P</span> <span class="search-cat-count-num" style="color:#8d6e63;">' + pochaCount + '</span>'
                + '<span class="search-category-ball marker-guesthouse' + (categoryId==5?' active':'') + '" data-category="5">G</span> <span class="search-cat-count-num" style="color:#2196f3;">' + guesthouseCount + '</span>'
                + '</div>'
                + '</div>';
            catBar.innerHTML = catHtml;
            catBar.style.display = 'flex';
            
            // 카테고리 원 클릭 이벤트 바인딩
            Array.from(catBar.getElementsByClassName('search-category-ball')).forEach(function(ball) {
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
                '<div style="display:flex; gap:6px; margin:8px 0 16px 0; flex-wrap:wrap;">' +
                '<button id="sortLatest" class="sort-btn ' + latestActive + '" onclick="sortHotplaces(\'latest\')" style="padding:8px 12px; border:1px solid #ddd; ' + latestStyle + ' border-radius:6px; font-size:0.85rem; cursor:pointer; flex:1; min-width:0;">최신등록</button>' +
                '<button id="sortPopular" class="sort-btn ' + popularActive + '" onclick="sortHotplaces(\'popular\')" style="padding:8px 12px; border:1px solid #ddd; ' + popularStyle + ' border-radius:6px; font-size:0.85rem; cursor:pointer; flex:1; min-width:0;">인기순</button>' +
                '<button id="sortCoursePopular" class="sort-btn ' + (window.currentSortType === 'coursePopular' ? 'active' : '') + '" onclick="sortHotplaces(\'coursePopular\')" style="padding:8px 12px; border:1px solid #ddd; ' + (window.currentSortType === 'coursePopular' ? 'background:#1275E0; color:white;' : 'background:white; color:#333;') + ' border-radius:6px; font-size:0.85rem; cursor:pointer; flex:1; min-width:0;">인기 코스</button>' +
                '</div>';
            
            if (filtered.length === 0) {
                window.searchResultBox.innerHTML = dongTitle + '<div style="color:#bbb; text-align:center; padding:40px 0;">해당 지역의 핫플레이스가 없습니다.</div>';
                return;
            }
            
            var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차',5:'게스트하우스'};
            
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
                    +         '<div style="color:#e91e63; font-size:0.95rem; margin-top:2px;">💖<span class="wish-count-' + h.id + '" style="color:#e91e63; font-weight:600;">로딩중...</span>명이 찜했어요</div>'
                    +         '<div style="color:#ff6b35; font-size:0.95rem; margin-top:2px; font-weight:600;" id="todayHotRank-' + h.id + '">🔥 오늘핫: 로딩중...</div>'
                    +         '<div style="color:#ff6b35; font-size:0.95rem; margin-top:2px; font-weight:600;" id="todayVoteStats-' + h.id + '">#성비 #혼잡도 #대기시간</div>'
                    +         '<div style="color:#2196f3; font-size:0.95rem; margin-top:2px; font-weight:600; cursor:pointer;" id="courseCount-' + h.id + '" onclick="goToPlaceCourses(' + h.id + ')">📝 코스글: 로딩중...</div>'
                    +       '</div>'
                    +     '</div>'
                    +     '<div style="margin-bottom:8px; color:#888; font-size:0.95rem; word-break:break-word; display:flex; align-items:center; gap:8px;">'
                    +       '<span id="voteTrends-' + h.id + '">📊 역대 투표: 로딩중...</span>'
                    +       '<span onclick="toggleVoteDetails(' + h.id + ')" style="color:#1275E0; cursor:pointer; font-size:0.95rem;" id="voteDetailsToggle-' + h.id + '">더보기▾</span>'
                    +     '</div>'
                    +     '<div style="margin-bottom:8px; color:#888; font-size:0.95rem; word-break:break-word; display:none;" id="voteDetails-' + h.id + '">#성비<br>#혼잡도<br>#대기시간</div>'
                    +     '<div style="color:#666; font-size:0.95rem; line-height:1.4; margin-bottom:8px; display:flex; align-items:flex-start; gap:6px;">'
                    +       '<div style="flex:1; word-break:break-word;">' + h.address + '</div>'
                    +       '<span onclick="copyAddress(\'' + h.address + '\')" style="cursor:pointer; color:#1275E0; display:inline-flex; align-items:center; flex-shrink:0; margin-top:1px;" title="주소 복사"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></span>'
                    +     '</div>'
                    +     (h.categoryId === 1 ? '<div style="color:#9c27b0; font-weight:600; margin-bottom:8px; font-size:0.9rem; word-break:break-word;" id="genres-' + h.id + '">🎵 장르: 로딩중...</div>' : '')
                    +     '<div style="margin-bottom:8px; font-size:0.95rem;" id="naverPlaceLink-' + h.id + '">🔗 네이버 플레이스: 로딩중...</div>'
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
                    paginationHtml += '<button onclick="renderHotplaceListByDong(\'' + dong + '\', ' + (categoryId || 'null') + ', ' + (window.currentPage - 1) + ')" style="padding:6px 10px; border:1px solid #ddd; background:white; border-radius:4px; cursor:pointer; font-size:14px;">&lt;</button>';
                }
                for (var i = Math.max(1, window.currentPage - 2); i <= Math.min(window.totalPages, window.currentPage + 2); i++) {
                    var activeStyle = i === window.currentPage ? 'background:#1275E0; color:white;' : 'background:white; color:#666;';
                    paginationHtml += '<button onclick="renderHotplaceListByDong(\'' + dong + '\', ' + (categoryId || 'null') + ', ' + i + ')" style="padding:8px 12px; border:1px solid #ddd; ' + activeStyle + ' border-radius:4px; cursor:pointer;">' + i + '</button>';
                }
                if (window.currentPage < window.totalPages) {
                    paginationHtml += '<button onclick="renderHotplaceListByDong(\'' + dong + '\', ' + (categoryId || 'null') + ', ' + (window.currentPage + 1) + ')" style="padding:6px 10px; border:1px solid #ddd; background:white; border-radius:4px; cursor:pointer; font-size:14px;">&gt;</button>';
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
                    
                    // 장소 이름 클릭 이벤트 추가
                    var placeNameEl = card.querySelector('.hotplace-name');
                    if (placeNameEl) {
                        placeNameEl.style.cursor = 'pointer';
                        placeNameEl.onclick = function(e) {
                            e.stopPropagation();
                            showPlaceInfo(place.id);
                        };
                    }
                    
                    loadWishCount(place.id);
                    loadVoteTrends(place.id);
                    loadTodayHotRank(place.id);
                    loadCourseCount(place.id);
                    loadTodayVoteStats(place.id);
                    if (place.categoryId === 1) {
                        loadGenreInfo(place.id);
                    }
                    loadNaverPlaceLink(place.id);
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
        
        // 가게 데이터 정렬 함수
        function sortHotplaceData(hotplaces, sortType) {
            if (sortType === 'latest') {
                // 최신등록순 (created_at 기준 내림차순)
                return hotplaces.sort(function(a, b) {
                    return new Date(b.created_at || b.createdAt || 0) - new Date(a.created_at || a.createdAt || 0);
                });
            } else if (sortType === 'popular') {
                // 인기순 (찜 65% + 투표 35%) - 기본값으로 정렬
                return hotplaces.sort(function(a, b) {
                    var aWishCount = parseInt(a.wish_count || a.wishCount || 0);
                    var bWishCount = parseInt(b.wish_count || b.wishCount || 0);
                    var aVoteCount = parseInt(a.vote_count || a.voteCount || 0);
                    var bVoteCount = parseInt(b.vote_count || b.voteCount || 0);
                    
                    var aPopularity = (aWishCount * 0.65) + (aVoteCount * 0.35);
                    var bPopularity = (bWishCount * 0.65) + (bVoteCount * 0.35);
                    
                    return bPopularity - aPopularity;
                });
            } else if (sortType === 'coursePopular') {
                // 인기 코스순 (가게별 코스 개수 기준 내림차순)
                return hotplaces.sort(function(a, b) {
                    var aCourseCount = parseInt(a.course_count || a.courseCount || 0);
                    var bCourseCount = parseInt(b.course_count || b.courseCount || 0);
                    
                    return bCourseCount - aCourseCount;
                });
            }
            return hotplaces;
        }
        
        // 전체 데이터의 찜 수와 투표 수를 로드하는 함수
        function loadAllStatsForSorting(hotplaces, callback) {
            var loadedCount = 0;
            var totalCount = hotplaces.length;
            
            if (totalCount === 0) {
                callback(hotplaces);
                return;
            }
            
            hotplaces.forEach(function(hotplace) {
                // 찜 수 가져오기
                fetch(root + '/api/main/wish-count', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'placeId=' + hotplace.id
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        hotplace.wish_count = data.count || 0;
                    } else {
                        hotplace.wish_count = 0;
                    }
                    
                    // 투표 수 가져오기
                    return fetch(root + '/api/main/vote-count', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'placeId=' + hotplace.id
                    });
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        hotplace.vote_count = data.voteCount || 0;
                    } else {
                        hotplace.vote_count = 0;
                    }
                    
                    // 코스 수 가져오기
                    return fetch(root + '/api/main/course-count', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'placeId=' + hotplace.id
                    });
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        hotplace.course_count = data.count || 0;
                    } else {
                        hotplace.course_count = 0;
                    }
                    
                    loadedCount++;
                    if (loadedCount === totalCount) {
                        // 모든 데이터 로드 완료 후 정렬
                        var sortedHotplaces = sortHotplaceData(hotplaces, window.currentSortType);
                        callback(sortedHotplaces);
                    }
                })
                .catch(error => {
                    hotplace.wish_count = 0;
                    hotplace.vote_count = 0;
                    hotplace.course_count = 0;
                    loadedCount++;
                    if (loadedCount === totalCount) {
                        var sortedHotplaces = sortHotplaceData(hotplaces, window.currentSortType);
                        callback(sortedHotplaces);
                    }
                });
            });
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
        
        // 투표 관련 함수들은 voteModal.jsp에서 처리됨
        
        // 네이버 플레이스 링크 로드 함수
        function loadNaverPlaceLink(placeId, retryCount = 0) {
            const linkElements = document.querySelectorAll('#naverPlaceLink-' + placeId);
            if (linkElements.length === 0 && retryCount < 10) {
                setTimeout(function() {
                    loadNaverPlaceLink(placeId, retryCount + 1);
                }, 200);
                return;
            }
            if (linkElements.length === 0) {
                return;
            }
            
            fetch(root + '/api/main/naver-place-link', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'placeId=' + placeId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    for (let element of linkElements) {
                        if (data.link && data.link.trim() !== '') {
                            element.innerHTML = '<a href="' + data.link + '" target="_blank" style="color:#00c73c; text-decoration:none;">🔗 네이버 플레이스</a>';
                        } else {
                            element.innerHTML = '<span style="color:#999;">🔗 네이버 플레이스: 없음</span>';
                        }
                    }
                } else {
                    for (let element of linkElements) {
                        element.innerHTML = '<span style="color:#999;">🔗 네이버 플레이스: 로드 실패</span>';
                    }
                }
            })
            .catch(error => {
                for (let element of linkElements) {
                    element.innerHTML = '<span style="color:#999;">🔗 네이버 플레이스: 로드 실패</span>';
                }
            });
        }
    </script>
</div>

<!-- 투표 모달 관련 함수들 (map.jsp 전용) -->
<jsp:include page="voteMapModal.jsp" />

