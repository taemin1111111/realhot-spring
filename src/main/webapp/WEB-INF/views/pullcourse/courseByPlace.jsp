<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String root = request.getContextPath();
%>

<!-- 코스 추천 전용 CSS -->
<link rel="stylesheet" href="<%=root%>/css/course.css">

<!-- 전체 코스 보기 버튼 스타일 -->
<style>
.course-hunting-all-courses-btn {
    background: linear-gradient(135deg, #ff69b4, #ff1493);
    color: white;
    border: none;
    padding: 12px 20px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 2px 8px rgba(255, 20, 147, 0.3);
}

.course-hunting-all-courses-btn:hover {
    background: linear-gradient(135deg, #ff1493, #ff69b4);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(255, 20, 147, 0.4);
}

.course-hunting-all-courses-btn:active {
    transform: translateY(0);
    box-shadow: 0 2px 8px rgba(255, 20, 147, 0.3);
}

.course-hunting-all-courses-btn i {
    margin-right: 6px;
}
</style>

<!-- 특정 가게의 코스 목록 페이지 -->
<div class="course-hunting-container">
    
    <!-- 상단 탭 및 공유하기 버튼 -->
    <div class="course-hunting-header">
        <div class="course-hunting-tabs">
            <button class="course-hunting-tab-btn ${sort == 'latest' ? 'active' : ''}" onclick="changeTab('latest')">
                <i class="fas fa-clock"></i> 최신글
            </button>
            <button class="course-hunting-tab-btn ${sort == 'popular' ? 'active' : ''}" onclick="changeTab('popular')">
                <img src="<%=root%>/logo/fire.png" alt="fire" style="width: 16px; height: 16px; margin-right: 4px; vertical-align: middle;"> 인기글
            </button>
        </div>
        
        <!-- 현재 선택된 가게 표시 -->
        <div class="course-hunting-current-region">
            <i class="fas fa-map-marker-alt"></i> 
            <span style="font-weight: bold; color: #1275E0;">${hotplace.name}</span>
            <span style="color: #666; margin-left: 8px;">(${totalCount}개 코스)</span>
        </div>
        
        <div class="course-hunting-share">
            <button class="course-hunting-all-courses-btn" onclick="goToAllCourses()">
                <i class="fas fa-list"></i> 전체 코스 보기
            </button>
        </div>
    </div>
    
    <!-- 코스 목록 -->
    <div class="course-hunting-list">
        <c:choose>
            <c:when test="${not empty courseList}">
                <div class="course-hunting-grid">
                    <c:forEach var="course" items="${courseList}" varStatus="status">
                        <div class="course-hunting-card" onclick="goToDetail('${course.id}')">
                            <!-- 제목 섹션 -->
                            <div class="course-hunting-card-title-section">
                                <h3 class="course-hunting-card-title">
                                    <c:if test="${param.sort == 'popular' && currentPage == 1}">
                                        <c:set var="rank" value="${status.index + 1}" />
                                        <span class="rank-number ${rank <= 3 ? 'top-rank' : ''}" style="font-weight: bold; color: #ff6b6b; margin-right: 8px; font-size: 20px;">${rank}위</span>
                                    </c:if>
                                    ${course.title}
                                </h3>
                            </div>
                            
                            <!-- 스텝 경로 -->
                            <div class="course-hunting-card-steps">
                                <c:choose>
                                    <c:when test="${not empty course.courseSteps}">
                                        <c:forEach var="step" items="${course.courseSteps}" varStatus="status">
                                            <div class="course-step-line">
                                                <span class="course-step-number">${step.stepNo}</span>
                                                <span class="course-step-place">${step.placeName}</span>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="course-step-info">스텝 정보 없음</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            
                            <!-- 구분선 -->
                            <div class="course-hunting-card-divider"></div>
                            
                            <!-- 요약 -->
                            <div class="course-hunting-card-summary-section">
                                <p class="course-hunting-card-summary">${course.summary}</p>
                            </div>
                            
                            <!-- 닉네임 -->
                            <div class="course-hunting-card-author-section">
                                <span class="course-hunting-card-nickname" data-author-userid="${course.authorUserid}">
                                    <i class="author-indicator bi bi-person-fill" style="display: none; color: #ff69b4; margin-right: 6px; font-size: 18px;"></i>${course.nickname}
                                </span>
                            </div>
                            
                            <!-- 하단 통계 -->
                            <div class="course-hunting-card-footer">
                                <div class="course-hunting-card-stats">
                                    <span class="course-hunting-stat-item">
                                        👁️ ${course.viewCount}
                                    </span>
                                    <span class="course-hunting-stat-item">
                                        👍 ${course.likeCount}
                                    </span>
                                    <span class="course-hunting-stat-item">
                                        👎 ${course.dislikeCount != null ? course.dislikeCount : 0}
                                    </span>
                                    <span class="course-hunting-stat-item">
                                        💬 ${course.commentCount}
                                    </span>
                                </div>

                                <div class="course-hunting-card-time">
                                    <c:choose>
                                        <c:when test="${not empty course.createdAt}">
                                            <%
                                                // 현재 시간과 생성 시간의 차이를 계산
                                                java.time.LocalDateTime now = java.time.LocalDateTime.now();
                                                com.wherehot.spring.entity.Course course = (com.wherehot.spring.entity.Course) pageContext.getAttribute("course");
                                                if (course != null && course.getCreatedAt() != null) {
                                                    long secondsDiff = java.time.Duration.between(course.getCreatedAt(), now).getSeconds();
                                                    
                                                    if (secondsDiff < 60) {
                                                        out.print("방금전");
                                                    } else if (secondsDiff < 3600) {
                                                        long minutes = secondsDiff / 60;
                                                        out.print(minutes + "분전");
                                                    } else if (secondsDiff < 86400) {
                                                        long hours = secondsDiff / 3600;
                                                        out.print(hours + "시간전");
                                                    } else {
                                                        long days = secondsDiff / 86400;
                                                        out.print(days + "일전");
                                                    }
                                                } else {
                                                    out.print("방금전");
                                                }
                                            %>
                                        </c:when>
                                        <c:otherwise>
                                            방금전
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="course-hunting-no-courses">
                    <i class="fas fa-glass-cheers"></i>
                    <h3>${hotplace.name}이 포함된 코스가 없습니다</h3>
                    <p>첫 번째 코스를 공유해보세요!</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    
    <!-- 페이징 -->
    <c:if test="${totalCount > 12}">
        <div class="course-hunting-pagination">
            <c:set var="totalPages" value="${(totalCount + 11) / 12}" />
            <c:set var="currentPage" value="${currentPage}" />
            
            <!-- 이전 페이지 -->
            <c:if test="${currentPage > 1}">
                <button class="course-hunting-page-btn" onclick="goToPage('${currentPage - 1}')">
                    <i class="fas fa-chevron-left"></i>
                </button>
            </c:if>
            
            <!-- 페이지 번호 -->
            <c:set var="startPage" value="${((currentPage - 1) / 10) * 10 + 1}" />
            <c:set var="endPage" value="${startPage + 9}" />
            <c:if test="${endPage > totalPages}">
                <c:set var="endPage" value="${totalPages}" />
            </c:if>
            
            <c:forEach var="pageNum" begin="${startPage}" end="${endPage}">
                <button class="course-hunting-page-btn ${pageNum == currentPage ? 'active' : ''}" 
                        onclick="goToPage('${pageNum}')">
                    ${pageNum}
                </button>
            </c:forEach>
            
            <!-- 다음 페이지 -->
            <c:if test="${currentPage < totalPages}">
                <button class="course-hunting-page-btn" onclick="goToPage('${currentPage + 1}')">
                    <i class="fas fa-chevron-right"></i>
                </button>
            </c:if>
        </div>
    </c:if>
</div>

<script>
// 탭 변경
function changeTab(sortType) {
    const url = new URL(window.location);
    url.searchParams.set('sort', sortType);
    url.searchParams.set('page', '1'); // 첫 페이지로 이동
    window.location.href = url.toString();
}

// 페이지 이동
function goToPage(page) {
    const url = new URL(window.location);
    url.searchParams.set('page', page);
    window.location.href = url.toString();
}

// 코스 상세 페이지로 이동
function goToDetail(courseId) {
    window.location.href = '<%=root%>/course/' + courseId;
}

// 코스 작성 페이지로 이동
function goToCourseCreate() {
    window.location.href = '<%=root%>/course/create';
}

// 전체 코스 보기
function goToAllCourses() {
    window.location.href = '<%=root%>/course';
}
</script>
