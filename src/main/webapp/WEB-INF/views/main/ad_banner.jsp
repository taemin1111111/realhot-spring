<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String root = request.getContextPath();
%>

<style>
.ad-banner-section {
    background: transparent;
    border-radius: 0;
    padding: 0;
    margin-top: 0;
    box-shadow: none;
    width: 100%;
    max-width: 500px;
    margin-left: 0;
    margin-right: auto;
    position: relative;
}

.ad-banner-container {
    position: relative;
    width: 100%;
    height: 400px;
    overflow: hidden;
}

.ad-banner-slide {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    opacity: 0;
    transition: opacity 0.5s ease-in-out;
}

.ad-banner-slide.active {
    opacity: 1;
}

.ad-banner-item {
    position: relative;
    border-radius: 0;
    overflow: hidden;
    box-shadow: none;
    transition: transform 0.2s ease;
    cursor: pointer;
}

.ad-banner-item:hover {
    transform: translateY(-2px);
}

.ad-banner-image {
    width: 100%;
    height: 400px;
    object-fit: cover;
    display: block;
}

/* 관리자용 버튼 스타일 */
.admin-ad-controls {
    position: absolute;
    top: 10px;
    right: 10px;
    display: flex;
    gap: 5px;
    z-index: 10;
}

.admin-ad-btn {
    background: rgba(0, 0, 0, 0.7);
    color: white;
    border: none;
    border-radius: 4px;
    padding: 4px 8px;
    font-size: 12px;
    cursor: pointer;
    transition: background 0.2s ease;
}

.admin-ad-btn:hover {
    background: rgba(0, 0, 0, 0.9);
}

.admin-ad-btn.edit {
    background: rgba(33, 150, 243, 0.8);
}

.admin-ad-btn.edit:hover {
    background: rgba(33, 150, 243, 1);
}

.admin-ad-btn.delete {
    background: rgba(244, 67, 54, 0.8);
}

.admin-ad-btn.delete:hover {
    background: rgba(244, 67, 54, 1);
}

/* 광고 추가 버튼 - 간소화 */
.add-ad-banner-btn {
    position: absolute;
    top: 10px;
    left: 10px;
    background: #007bff;
    color: white;
    border: none;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    font-size: 20px;
    font-weight: bold;
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 2px 8px rgba(0, 123, 255, 0.3);
    z-index: 10;
}

.add-ad-banner-btn:hover {
    background: #0056b3;
    transform: scale(1.1);
    box-shadow: 0 4px 12px rgba(0, 123, 255, 0.4);
}

/* 모바일 반응형 */
@media (max-width: 768px) {
    .ad-banner-container {
        height: 450px;
    }
    
    .ad-banner-image {
        height: 450px;
    }
    
    .admin-ad-controls {
        top: 8px;
        right: 8px;
    }
    
    .admin-ad-btn {
        padding: 3px 6px;
        font-size: 11px;
    }
    
    .add-ad-banner-btn {
        width: 35px;
        height: 35px;
        font-size: 18px;
        top: 10px;
        left: 10px;
    }
}

/* 섹션 헤더 스타일 */
.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.section-title {
    font-size: 1.4rem;
    color: #333;
    margin: 0;
    font-weight: 600;
}

/* 네비게이션 버튼 */
.ad-banner-nav {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    background: rgba(0, 0, 0, 0.5);
    color: white;
    border: none;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    cursor: pointer;
    font-size: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background 0.3s ease;
    z-index: 20;
}

.ad-banner-nav:hover {
    background: rgba(0, 0, 0, 0.7);
}

.ad-banner-nav.prev {
    left: 15px;
}

.ad-banner-nav.next {
    right: 15px;
}

/* 페이지 인디케이터 */
.ad-banner-indicators {
    position: absolute;
    bottom: 20px;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    gap: 8px;
    z-index: 20;
    background: rgba(0, 0, 0, 0.4);
    padding: 8px 12px;
    border-radius: 20px;
    backdrop-filter: blur(5px);
}

.ad-banner-indicator {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.6);
    cursor: pointer;
    transition: all 0.3s ease;
}

.ad-banner-indicator.active {
    background: white;
    transform: scale(1.2);
}

/* 광고가 없을 때 */
.no-ads-message {
    text-align: center;
    color: #666;
    font-style: italic;
    padding: 40px 20px;
    background: transparent;
    border-radius: 0;
    border: none;
}
</style>

<div class="ad-banner-section">
    <!-- 관리자용 광고 추가 버튼 (관리자만 보임) -->
    <button class="add-ad-banner-btn" id="addAdBannerBtn" onclick="showAddAdBannerModal()" title="광고 배너 추가" style="display: none;">
        +
    </button>


    <!-- 광고 배너 목록 -->
    <c:choose>
        <c:when test="${not empty activeAdBanners and fn:length(activeAdBanners) > 0}">
            <div class="ad-banner-container" id="adBannerContainer">
                <!-- 네비게이션 버튼 -->
                <button class="ad-banner-nav prev" onclick="changeSlide(-1)">‹</button>
                <button class="ad-banner-nav next" onclick="changeSlide(1)">›</button>
                
                <!-- 슬라이드들 -->
                <c:forEach var="banner" items="${activeAdBanners}" varStatus="status">
                    <div class="ad-banner-slide ${status.index == 0 ? 'active' : ''}" data-index="${status.index}">
                        <div class="ad-banner-item" 
                             <c:if test="${not empty banner.linkUrl}">onclick="window.open('${banner.linkUrl}', '_blank')"</c:if>>
                            
                            <!-- 관리자용 컨트롤 버튼 -->
                            <div class="admin-ad-controls" id="adminControls-${banner.adId}" style="display: none;">
                                <button class="admin-ad-btn edit" onclick="editAdBanner(${banner.adId}, event)">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button class="admin-ad-btn delete" onclick="deleteAdBanner(${banner.adId}, event)">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </div>
                            
                            <!-- 광고 이미지 -->
                            <img src="<%=root%>${banner.imagePath}" 
                                 alt="${banner.title}" 
                                 class="ad-banner-image"
                                 onerror="this.src='<%=root%>/logo/fire.png'">
                            
                            <!-- 페이지 인디케이터 (각 슬라이드 안에) -->
                            <div class="ad-banner-indicators">
                                <c:forEach var="bannerInner" items="${activeAdBanners}" varStatus="statusInner">
                                    <div class="ad-banner-indicator ${statusInner.index == 0 ? 'active' : ''}" 
                                         onclick="goToSlide(${statusInner.index})"></div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="no-ads-message">
                <i class="bi bi-image" style="font-size: 2rem; color: #ccc; margin-bottom: 10px;"></i>
                <p>등록된 광고가 없습니다.</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- 광고 배너 추가/수정 모달 -->
<div id="adBannerModal" class="modal" style="display: none;">
    <div class="modal-content" style="max-width: 500px;">
        <div class="modal-header">
            <h3 id="adBannerModalTitle">광고 배너 추가</h3>
            <span class="close" onclick="closeAdBannerModal()">&times;</span>
        </div>
        <div class="modal-body">
            <form id="adBannerForm" enctype="multipart/form-data">
                <input type="hidden" id="adBannerId" name="adId">
                
                <div class="form-group">
                    <label for="adBannerTitle">광고 제목 *</label>
                    <input type="text" id="adBannerTitle" name="title" required 
                           placeholder="광고 제목을 입력하세요">
                </div>
                
                <div class="form-group">
                    <label for="adBannerLinkUrl">링크 URL</label>
                    <input type="url" id="adBannerLinkUrl" name="linkUrl" 
                           placeholder="클릭 시 이동할 URL (선택사항)">
                </div>
                
                <div class="form-group">
                    <label for="adBannerDisplayOrder">표시 순서 *</label>
                    <input type="number" id="adBannerDisplayOrder" name="displayOrder" 
                           min="1" max="10" value="1" required>
                </div>
                
                <div class="form-group">
                    <label for="adBannerImageFile">광고 이미지 *</label>
                    <input type="file" id="adBannerImageFile" name="imageFile" 
                           accept="image/*" required>
                    <small class="form-text">권장 크기: 400x200px 이상</small>
                </div>
                
                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="closeAdBannerModal()">
                        취소
                    </button>
                    <button type="submit" class="btn btn-primary">
                        <span id="adBannerSubmitText">추가</span>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// 광고 배너 추가 모달 표시
function showAddAdBannerModal() {
    document.getElementById('adBannerModalTitle').textContent = '광고 배너 추가';
    document.getElementById('adBannerSubmitText').textContent = '추가';
    document.getElementById('adBannerForm').reset();
    document.getElementById('adBannerId').value = '';
    document.getElementById('adBannerImageFile').required = true;
    document.getElementById('adBannerModal').style.display = 'block';
}

// 광고 배너 수정 모달 표시
function editAdBanner(adId, event) {
    event.stopPropagation();
    
    // TODO: 서버에서 광고 배너 정보를 가져와서 폼에 채우기
    document.getElementById('adBannerModalTitle').textContent = '광고 배너 수정';
    document.getElementById('adBannerSubmitText').textContent = '수정';
    document.getElementById('adBannerId').value = adId;
    document.getElementById('adBannerImageFile').required = false;
    document.getElementById('adBannerModal').style.display = 'block';
}

// 광고 배너 삭제
function deleteAdBanner(adId, event) {
    event.stopPropagation();
    
    if (confirm('정말로 이 광고 배너를 삭제하시겠습니까?')) {
        const formData = new FormData();
        formData.append('adId', adId);
        
         fetch('<%=root%>/api/admin/ad-banner/delete', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
         .then(data => {
             if (data.success) {
                 alert(data.message);
                 location.reload();
             } else {
                 alert(data.error);
             }
         })
         .catch(error => {
             console.error('Error:', error);
             alert('광고 배너 삭제 중 오류가 발생했습니다.');
         });
    }
}

// 광고 배너 모달 닫기
function closeAdBannerModal() {
    document.getElementById('adBannerModal').style.display = 'none';
}

// 광고 배너 폼 제출
document.getElementById('adBannerForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(this);
    const adId = document.getElementById('adBannerId').value;
    const isEdit = adId && adId !== '';
    
     const url = isEdit ? '<%=root%>/api/admin/ad-banner/update' : '<%=root%>/api/admin/ad-banner/add';
    
    fetch(url, {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
     .then(data => {
         if (data.success) {
             alert(data.message);
             closeAdBannerModal();
             location.reload();
         } else {
             alert(data.error);
         }
     })
     .catch(error => {
         console.error('Error:', error);
         alert('광고 배너 처리 중 오류가 발생했습니다.');
     });
});

// 모달 외부 클릭 시 닫기
window.onclick = function(event) {
    const modal = document.getElementById('adBannerModal');
    if (event.target === modal) {
        closeAdBannerModal();
    }
}

// 슬라이드쇼 관련 변수
let currentSlide = 0;
let slideInterval;
const slides = document.querySelectorAll('.ad-banner-slide');
const indicators = document.querySelectorAll('.ad-banner-indicator');

// 슬라이드쇼 초기화
function initSlideshow() {
    if (slides.length === 0) return;
    
    // 첫 번째 슬라이드 활성화
    showSlide(0);
    
    // 4초마다 자동으로 다음 슬라이드로
    slideInterval = setInterval(() => {
        nextSlide();
    }, 4000);
    
    // 마우스 호버 시 자동 슬라이드 일시정지
    const container = document.getElementById('adBannerContainer');
    if (container) {
        container.addEventListener('mouseenter', pauseSlideshow);
        container.addEventListener('mouseleave', resumeSlideshow);
    }
}

// 다음 슬라이드로 이동
function nextSlide() {
    currentSlide = (currentSlide + 1) % slides.length;
    showSlide(currentSlide);
}

// 이전 슬라이드로 이동
function prevSlide() {
    currentSlide = (currentSlide - 1 + slides.length) % slides.length;
    showSlide(currentSlide);
}

// 특정 슬라이드로 이동
function goToSlide(index) {
    currentSlide = index;
    showSlide(currentSlide);
}

// 슬라이드 변경
function changeSlide(direction) {
    if (direction === 1) {
        nextSlide();
    } else {
        prevSlide();
    }
}

// 슬라이드 표시
function showSlide(index) {
    // 모든 슬라이드 비활성화
    slides.forEach(slide => slide.classList.remove('active'));
    indicators.forEach(indicator => indicator.classList.remove('active'));
    
    // 현재 슬라이드 활성화
    if (slides[index]) {
        slides[index].classList.add('active');
    }
    if (indicators[index]) {
        indicators[index].classList.add('active');
    }
    
    currentSlide = index;
}

// 슬라이드쇼 일시정지
function pauseSlideshow() {
    if (slideInterval) {
        clearInterval(slideInterval);
    }
}

// 슬라이드쇼 재시작
function resumeSlideshow() {
    slideInterval = setInterval(() => {
        nextSlide();
    }, 4000);
}

// 관리자 UI 업데이트 함수
function updateAdBannerAdminUI() {
    const addBtn = document.getElementById('addAdBannerBtn');
    const adminControls = document.querySelectorAll('[id^="adminControls-"]');
    
    if (window.isAdmin) {
        // 관리자일 때 버튼들 표시
        if (addBtn) addBtn.style.display = 'flex';
        adminControls.forEach(control => {
            control.style.display = 'flex';
        });
    } else {
        // 일반 사용자일 때 버튼들 숨김
        if (addBtn) addBtn.style.display = 'none';
        adminControls.forEach(control => {
            control.style.display = 'none';
        });
    }
}

// 페이지 로드 시 슬라이드쇼 초기화
document.addEventListener('DOMContentLoaded', function() {
    initSlideshow();
    
    // 관리자 UI 초기화
    updateAdBannerAdminUI();
    
    // isAdmin 변수 변경 감지를 위한 주기적 체크
    setInterval(function() {
        if (typeof window.isAdmin !== 'undefined') {
            updateAdBannerAdminUI();
        }
    }, 1000);
});
</script>
