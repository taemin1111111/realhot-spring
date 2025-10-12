<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    String root = "";
%>

<div class="course-popular-section">
    <div class="section-header">
        <h3 class="section-title">📝 코스 인기글</h3>
        <a href="<%=root%>/course?sort=popular" class="view-all-link">전체보기 →</a>
    </div>
    
    <div class="course-popular-grid">
        <c:choose>
            <c:when test="${not empty popularCourses and fn:length(popularCourses) > 0}">
                <c:forEach var="course" items="${popularCourses}" varStatus="status" end="1">
                    <div class="course-popular-card" onclick="location.href='<%=root%>/course/${course.id}'">
                        <!-- 순위 표시 -->
                        <div class="course-rank">
                            <span class="rank-number ${status.index + 1 <= 3 ? 'top-rank' : ''}">${status.index + 1}위</span>
                        </div>
                        
                        <!-- 제목과 닉네임 -->
                        <div class="course-header">
                            <h4 class="course-title">${course.title}</h4>
                            <div class="course-author">
                                <c:if test="${not empty course.userId and course.userId ne 'null' and not empty course.level}">
                                    <c:choose>
                                        <c:when test="${course.level == 1}">
                                            <span style="display: inline-block; background: #FFD700; color: #333; padding: 2px 6px; border-radius: 8px; font-size: 10px; font-weight: 600; margin-right: 6px; box-shadow: 0 1px 3px rgba(255, 215, 0, 0.3);">Lv.${course.level}</span>
                                        </c:when>
                                        <c:when test="${course.level == 2}">
                                            <span style="display: inline-block; background: #C0C0C0; color: #333; padding: 2px 6px; border-radius: 8px; font-size: 10px; font-weight: 600; margin-right: 6px; box-shadow: 0 1px 3px rgba(192, 192, 192, 0.3);">Lv.${course.level}</span>
                                        </c:when>
                                        <c:when test="${course.level == 3}">
                                            <span style="display: inline-block; background: #32CD32; color: white; padding: 2px 6px; border-radius: 8px; font-size: 10px; font-weight: 600; margin-right: 6px; box-shadow: 0 1px 3px rgba(50, 205, 50, 0.3);">Lv.${course.level}</span>
                                        </c:when>
                                        <c:when test="${course.level == 4}">
                                            <span style="display: inline-block; background: #FF69B4; color: white; padding: 2px 6px; border-radius: 8px; font-size: 10px; font-weight: 600; margin-right: 6px; box-shadow: 0 1px 3px rgba(255, 105, 180, 0.3);">Lv.${course.level}</span>
                                        </c:when>
                                        <c:when test="${course.level == 5}">
                                            <span style="display: inline-block; background: #FF0000; color: white; padding: 2px 6px; border-radius: 8px; font-size: 10px; font-weight: 600; margin-right: 6px; box-shadow: 0 1px 3px rgba(255, 0, 0, 0.3);">Lv.${course.level}</span>
                                        </c:when>
                                        <c:when test="${course.level == 6}">
                                            <span style="display: inline-block; background: linear-gradient(135deg, #B9F2FF 0%, #00BFFF 100%); color: #333; padding: 2px 6px; border-radius: 8px; font-size: 10px; font-weight: 600; margin-right: 6px; box-shadow: 0 1px 3px rgba(0, 191, 255, 0.3);">Lv.${course.level}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 2px 6px; border-radius: 8px; font-size: 10px; font-weight: 600; margin-right: 6px;">Lv.${course.level}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                                <span class="author-nickname">${course.nickname}</span>
                            </div>
                        </div>
                        
                        <!-- 시간과 조회수 -->
                        <div class="course-meta">
                            <span class="course-time">
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
                                    <c:otherwise>방금전</c:otherwise>
                                </c:choose>
                            </span>
                            <span class="course-views">👁️ ${course.viewCount}</span>
                        </div>
                        
                        <!-- 코스 스텝 -->
                        <div class="course-steps">
                            <c:choose>
                                <c:when test="${not empty course.courseSteps}">
                                    <div class="step-navigation">
                                        <button class="step-nav-btn prev-btn" onclick="event.stopPropagation(); changeStep(${course.id}, -1, this)" style="display: none;">&lt;</button>
                                        <div class="current-step" id="step-${course.id}">
                                            <div class="step-number">1</div>
                                            <div class="step-info">
                                                <div class="step-place">${course.courseSteps[0].placeName}</div>
                                                <div class="step-address">${course.courseSteps[0].placeAddress}</div>
                                            </div>
                                        </div>
                                        <button class="step-nav-btn next-btn" onclick="event.stopPropagation(); changeStep(${course.id}, 1, this)" 
                                                style="${fn:length(course.courseSteps) > 1 ? 'display: block;' : 'display: none;'}">&gt;</button>
                                    </div>
                                    
                                    <!-- 스텝 이미지 -->
                                    <div class="step-image-container">
                                        <c:choose>
                                            <c:when test="${not empty course.courseSteps[0].photoUrl}">
                                                <img src="<%=root%>${course.courseSteps[0].photoUrl}" 
                                                     alt="코스 이미지" class="step-image" 
                                                     onerror="this.src='<%=root%>/logo/fire.png'">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="no-image">
                                                    <i class="bi bi-image"></i>
                                                    <span>이미지 없음</span>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    
                                    <!-- 스텝 설명 -->
                                    <div class="step-description" id="description-${course.id}">
                                        <c:choose>
                                            <c:when test="${not empty course.courseSteps[0].description}">
                                                ${course.courseSteps[0].description}
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #999; font-style: italic;">설명이 없습니다.</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="no-steps">
                                        <span>스텝 정보 없음</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <!-- 구분선 -->
                        <div class="course-divider"></div>
                        
                        <!-- 코스 요약 -->
                        <div class="course-summary">
                            <p>${course.summary}</p>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="no-courses">
                    <i class="bi bi-glass-cheers"></i>
                    <p>아직 인기 코스가 없습니다.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<style>
.course-popular-section {
    background: white;
    border-radius: 15px;
    padding: 25px;
    margin-top: 0;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
    width: 100%;
    max-width: 100%;
    margin-left: 0;
    margin-right: auto;
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 25px;
}

.section-title {
    font-size: 1.4rem;
    color: #333;
    margin: 0;
    font-weight: 600;
}

.view-all-link {
    color: #1275E0;
    text-decoration: none;
    font-size: 0.9rem;
    font-weight: 500;
}

.view-all-link:hover {
    text-decoration: underline;
}

.course-popular-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 20px;
    width: 100%;
}

.course-popular-card {
    background: #fff;
    border: 1px solid #e0e0e0;
    border-radius: 12px;
    padding: 20px;
    cursor: pointer;
    transition: all 0.3s ease;
    position: relative;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.course-popular-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
    border-color: #1275E0;
}

.course-rank {
    position: absolute;
    top: 15px;
    right: 15px;
    z-index: 2;
}

.rank-number {
    background: #f8f9fa;
    color: #666;
    padding: 4px 8px;
    border-radius: 6px;
    font-size: 0.8rem;
    font-weight: 600;
}

.rank-number.top-rank {
    background: linear-gradient(135deg, #ff6b6b, #ff8e8e);
    color: white;
    font-weight: 700;
}

.course-header {
    margin-bottom: 12px;
    padding-right: 60px;
}

.course-title {
    font-size: 1.1rem;
    font-weight: 600;
    color: #333;
    margin: 0 0 8px 0;
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.course-author {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 0.9rem;
    color: #666;
}


.author-nickname {
    font-weight: 500;
}

.course-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    font-size: 0.85rem;
    color: #888;
}

.course-time {
    font-weight: 500;
}

.course-views {
    font-weight: 500;
}

.course-steps {
    margin-bottom: 15px;
}

.step-navigation {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 10px;
}

.step-nav-btn {
    background: #f8f9fa;
    border: 1px solid #e0e0e0;
    border-radius: 6px;
    width: 28px;
    height: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    font-size: 14px;
    color: #666;
    transition: all 0.2s ease;
}

.step-nav-btn:hover {
    background: #1275E0;
    color: white;
    border-color: #1275E0;
}

.current-step {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 10px;
    background: #f8f9fa;
    padding: 8px 12px;
    border-radius: 8px;
}

.step-number {
    background: #1275E0;
    color: white;
    width: 24px;
    height: 24px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.8rem;
    font-weight: 600;
    flex-shrink: 0;
}

.step-info {
    flex: 1;
    min-width: 0;
}

.step-place {
    font-weight: 600;
    color: #333;
    font-size: 0.9rem;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.step-address {
    font-size: 0.8rem;
    color: #666;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.step-image-container {
    width: 100%;
    height: 280px;
    border-radius: 8px;
    overflow: hidden;
    background: #f8f9fa;
    display: flex;
    align-items: center;
    justify-content: center;
}

.step-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.no-image {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    color: #999;
    font-size: 0.9rem;
}

.no-image i {
    font-size: 2rem;
}

.step-description {
    margin-top: 12px;
    padding: 8px 12px;
    background-color: #f8f9fa;
    border-radius: 6px;
    font-size: 15px;
    line-height: 1.4;
    color: #000;
    min-height: 40px;
    display: flex;
    align-items: center;
}

.no-steps {
    text-align: center;
    color: #999;
    font-style: italic;
    padding: 20px;
    background: #f8f9fa;
    border-radius: 8px;
}

.course-divider {
    height: 1px;
    background: #e0e0e0;
    margin: 15px 0;
}

.course-summary {
    color: #000;
    font-size: 1rem;
    line-height: 1.5;
}

.course-summary p {
    margin: 0;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.no-courses {
    grid-column: 1 / -1;
    text-align: center;
    padding: 40px 20px;
    color: #999;
}

.no-courses i {
    font-size: 3rem;
    margin-bottom: 15px;
    display: block;
}

.no-courses p {
    margin: 0;
    font-size: 1.1rem;
    font-style: italic;
}

/* 반응형 디자인 */
@media (max-width: 768px) {
    .course-popular-section {
        padding: 20px;
    }
    
    .section-title {
        font-size: 1.2rem;
    }
    
    .course-popular-grid {
        grid-template-columns: 1fr;
        gap: 15px;
    }
    
    .course-popular-card {
        padding: 15px;
    }
    
    .course-title {
        font-size: 1rem;
    }
    
    .step-image-container {
        height: 150px;
    }
}

@media (max-width: 480px) {
    .course-popular-section {
        padding: 15px;
    }
    
    .section-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 10px;
    }
    
    .course-popular-card {
        padding: 12px;
    }
    
    .course-header {
        padding-right: 50px;
    }
    
    .step-navigation {
        gap: 8px;
    }
    
    .step-nav-btn {
        width: 24px;
        height: 24px;
        font-size: 12px;
    }
}
</style>

<script>
// 코스 데이터를 JavaScript에서 사용할 수 있도록 설정
window.courseData = {
    <c:forEach var="course" items="${popularCourses}" varStatus="status" end="1">
    ${course.id}: {
        id: ${course.id},
        title: "${course.title}",
        courseSteps: [
            <c:forEach var="step" items="${course.courseSteps}" varStatus="stepStatus">
            {
                stepNo: ${step.stepNo},
                placeName: "${step.placeName}",
                placeAddress: "${step.placeAddress}",
                photoUrl: "${step.photoUrl}",
                description: "${step.description}"
            }<c:if test="${!stepStatus.last}">,</c:if>
            </c:forEach>
        ]
    }<c:if test="${!status.last}">,</c:if>
    </c:forEach>
};

// 코스 스텝 네비게이션 함수
function changeStep(courseId, direction, button) {
    // 코스 데이터에서 스텝 정보 가져오기
    const courseData = window.courseData || {};
    const course = courseData[courseId];
    
    if (!course || !course.courseSteps) {
        return;
    }
    
    // 현재 스텝 번호 가져오기
    const stepContainer = document.getElementById('step-' + courseId);
    if (!stepContainer) {
        return;
    }
    
    const currentStepNumber = parseInt(stepContainer.querySelector('.step-number').textContent);
    const newStepNumber = currentStepNumber + direction;
    
    if (newStepNumber < 1 || newStepNumber > course.courseSteps.length) {
        return;
    }
    
    const newStep = course.courseSteps[newStepNumber - 1];
    
    // 스텝 정보 업데이트
    stepContainer.querySelector('.step-number').textContent = newStepNumber;
    stepContainer.querySelector('.step-place').textContent = newStep.placeName || '';
    stepContainer.querySelector('.step-address').textContent = newStep.placeAddress || '';
    
    // 이미지 컨테이너 찾기
    const courseCard = stepContainer.closest('.course-popular-card');
    const imageContainer = courseCard.querySelector('.step-image-container');
    
    if (imageContainer) {
        const img = imageContainer.querySelector('img');
        const noImageDiv = imageContainer.querySelector('.no-image');
        
        if (newStep.photoUrl && newStep.photoUrl.trim() !== '') {
            if (img) {
                img.src = '<%=root%>' + newStep.photoUrl;
                img.style.display = 'block';
            }
            if (noImageDiv) {
                noImageDiv.style.display = 'none';
            }
        } else {
            if (img) {
                img.style.display = 'none';
            }
            if (noImageDiv) {
                noImageDiv.style.display = 'flex';
            }
        }
    }
    
    // 설명 업데이트
    const descriptionElement = document.getElementById('description-' + courseId);
    if (descriptionElement) {
        if (newStep.description && newStep.description.trim() !== '') {
            descriptionElement.innerHTML = newStep.description;
        } else {
            descriptionElement.innerHTML = '<span style="color: #999; font-style: italic;">설명이 없습니다.</span>';
        }
    }
    
    // 버튼 상태 업데이트
    const prevBtn = courseCard.querySelector('.prev-btn');
    const nextBtn = courseCard.querySelector('.next-btn');
    
    if (prevBtn) {
        if (newStepNumber <= 1) {
            prevBtn.style.display = 'none';
        } else {
            prevBtn.style.display = 'block';
        }
    }
    
    if (nextBtn) {
        if (newStepNumber >= course.courseSteps.length) {
            nextBtn.style.display = 'none';
        } else {
            nextBtn.style.display = 'block';
        }
    }
}
</script>
