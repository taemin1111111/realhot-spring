<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String root = request.getContextPath();
%>

<!-- 코스 추천 메인 페이지 -->
<div class="course-hunting-container">
    
    <!-- 지역 필터 -->
    <div class="course-hunting-region-filter">
        <div class="course-hunting-region-tree">
            <c:forEach var="sidoEntry" items="${regionsBySido}">
                <c:set var="sido" value="${sidoEntry.key}" />
                <c:set var="regions" value="${sidoEntry.value}" />
                
                <div class="course-hunting-sido-section">
                    <div class="course-hunting-sido-header" onclick="toggleSido('${sido}')">
                        <i class="fas fa-map-marker-alt"></i> ${sido}
                        <i class="fas fa-chevron-down course-hunting-sido-arrow" id="arrow-${sido}"></i>
                    </div>
                    
                    <div class="course-hunting-sigungu-container" id="sigungu-${sido}" style="display: none;">
                        <!-- 시군구를 5개씩 그룹으로 나누어 표시 -->
                        <c:set var="sigunguEntries" value="${regionsBySigungu[sido]}" />
                        <c:set var="sigunguList" value="${sigunguEntries.entrySet()}" />
                        <c:forEach var="sigunguEntry" items="${sigunguList}" varStatus="status" step="5">
                            <!-- 시군구 제목 행 -->
                            <div class="course-hunting-sigungu-titles">
                                <c:forEach var="i" begin="0" end="4">
                                    <c:set var="currentIndex" value="${status.index + i}" />
                                    <c:if test="${currentIndex < fn:length(sigunguList)}">
                                        <c:forEach var="tempEntry" items="${sigunguList}" varStatus="tempStatus">
                                            <c:if test="${tempStatus.index == currentIndex}">
                                                <c:set var="sigungu" value="${tempEntry.key}" />
                                                <div class="course-hunting-sigungu-name">${sigungu}</div>
                                            </c:if>
                                        </c:forEach>
                                    </c:if>
                                </c:forEach>
                            </div>
                            
                            <!-- 동 목록 행 -->
                            <div class="course-hunting-dong-list">
                                <c:forEach var="i" begin="0" end="4">
                                    <c:set var="currentIndex" value="${status.index + i}" />
                                    <c:if test="${currentIndex < fn:length(sigunguList)}">
                                        <c:forEach var="tempEntry" items="${sigunguList}" varStatus="tempStatus">
                                            <c:if test="${tempStatus.index == currentIndex}">
                                                <c:set var="sigungu" value="${tempEntry.key}" />
                                                <c:set var="dongList" value="${tempEntry.value}" />
                                                
                                                <div class="course-hunting-dong-grid">
                                                    <c:forEach var="region" items="${dongList}">
                                                        <div class="course-hunting-dong-item" onclick="filterByRegion('${sido}', '${sigungu}', '${region.dong}')">
                                                            ${region.dong}
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
    
    <!-- 상단 탭 및 공유하기 버튼 -->
    <div class="course-hunting-header">
        <div class="course-hunting-tabs">
            <button class="course-hunting-tab-btn ${sort == 'latest' ? 'active' : ''}" onclick="changeTab('latest')">
                <i class="fas fa-clock"></i> 최신글
            </button>
            <button class="course-hunting-tab-btn ${sort == 'popular' ? 'active' : ''}" onclick="changeTab('popular')">
                <i class="fas fa-fire"></i> 인기글
            </button>
        </div>
        <div class="course-hunting-share-btn">
            <button class="course-hunting-share-btn" onclick="showCreateForm()">
                <i class="fas fa-plus"></i> 코스 공유하기
            </button>
        </div>
    </div>
    
    <!-- 코스 목록 -->
    <div class="course-hunting-list">
        <c:choose>
            <c:when test="${empty courseList}">
                <div class="course-hunting-no-courses">
                    <i class="fas fa-glass-cheers"></i>
                    <h3>아직 등록된 코스가 없습니다</h3>
                    <p>첫 번째 코스를 공유해보세요!</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="course-hunting-grid">
                    <c:forEach var="course" items="${courseList}">
                        <div class="course-hunting-card" onclick="goToDetail(${course.id})">
                            <div class="course-hunting-card-header">
                                <h3 class="course-hunting-card-title">${course.title}</h3>
                                <div class="course-hunting-card-stats">
                                    <span class="course-hunting-stat-item">
                                        <i class="fas fa-eye"></i> ${course.viewCount}
                                    </span>
                                    <span class="course-hunting-stat-item">
                                        <i class="fas fa-heart"></i> ${course.likeCount}
                                    </span>
                                    <span class="course-hunting-stat-item">
                                        <i class="fas fa-comment"></i> ${course.commentCount}
                                    </span>
                                </div>
                            </div>
                            <div class="course-hunting-card-content">
                                <p class="course-hunting-card-summary">${course.summary}</p>
                            </div>
                            <div class="course-hunting-card-footer">
                                <div class="course-hunting-card-author">
                                    <i class="fas fa-user"></i> ${course.nickname}
                                </div>
                                <div class="course-hunting-card-date">
                                    <fmt:formatDate value="${course.createdAt}" pattern="MM.dd"/>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    
    <!-- 페이징 -->
    <c:if test="${totalCount > 0}">
        <div class="course-hunting-pagination">
            <c:if test="${currentPage > 1}">
                <a href="javascript:void(0)" onclick="changePage(${currentPage - 1})" class="course-hunting-page-btn">
                    <i class="fas fa-chevron-left"></i>
                </a>
            </c:if>
            
            <c:forEach begin="1" end="${(totalCount + 11) / 12}" var="pageNum">
                <c:choose>
                    <c:when test="${pageNum == currentPage}">
                        <span class="course-hunting-page-btn active">${pageNum}</span>
                    </c:when>
                    <c:otherwise>
                        <a href="javascript:void(0)" onclick="changePage(${pageNum})" class="course-hunting-page-btn">${pageNum}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
            
            <c:if test="${currentPage < (totalCount + 11) / 12}">
                <a href="javascript:void(0)" onclick="changePage(${currentPage + 1})" class="course-hunting-page-btn">
                    <i class="fas fa-chevron-right"></i>
                </a>
            </c:if>
        </div>
    </c:if>
</div>

<!-- 코스 공유하기 모달 -->
<div id="createModal" class="course-hunting-modal">
    <div class="course-hunting-modal-content">
        <div class="course-hunting-modal-header">
            <h2><i class="fas fa-plus"></i> 코스 공유하기</h2>
            <span class="course-hunting-close" onclick="closeCreateModal()">&times;</span>
        </div>
        <div class="course-hunting-modal-body">
            <form id="courseForm">
                <div class="course-hunting-form-group">
                    <label>코스 제목</label>
                    <input type="text" id="courseTitle" name="title" required>
                </div>
                <div class="course-hunting-form-group">
                    <label>코스 설명</label>
                    <textarea id="courseSummary" name="summary" rows="3" required></textarea>
                </div>
                <div class="course-hunting-form-group">
                    <label>작성자</label>
                    <input type="text" id="courseNickname" name="nickname" required>
                </div>
                
                <div class="course-hunting-steps-container">
                    <h3>코스 스텝</h3>
                    <div id="stepsList">
                        <div class="course-hunting-step-item" data-step="1">
                            <div class="course-hunting-step-header">
                                <span class="course-hunting-step-number">1</span>
                                <button type="button" class="course-hunting-remove-step" onclick="removeStep(1)" style="display:none;">삭제</button>
                            </div>
                            <div class="course-hunting-step-content">
                                <input type="text" placeholder="핫플레이스 선택" class="course-hunting-step-place" required>
                                <input type="file" class="course-hunting-step-photo" accept="image/*">
                                <textarea placeholder="스텝 설명" class="course-hunting-step-description" rows="2"></textarea>
                            </div>
                        </div>
                    </div>
                    <button type="button" class="course-hunting-add-step-btn" onclick="addStep()">
                        <i class="fas fa-plus"></i> 스텝 추가
                    </button>
                </div>
                
                <div class="course-hunting-form-actions">
                    <button type="submit" class="course-hunting-submit-btn">코스 등록</button>
                    <button type="button" class="course-hunting-cancel-btn" onclick="closeCreateModal()">취소</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
let currentSort = '${sort}';
let currentPage = ${currentPage};
let currentSido = '${sido}';
let currentSigungu = '${sigungu}';
let currentDong = '${dong}';
let stepCount = 1;

// 탭 변경
function changeTab(sort) {
    currentSort = sort;
    currentPage = 1;
    loadCourses();
}

// 시도 토글 (펼치기/접기)
function toggleSido(sido) {
    const sigunguContainer = document.getElementById('sigungu-' + sido);
    const arrow = document.getElementById('arrow-' + sido);
    
    if (sigunguContainer.style.display === 'none') {
        sigunguContainer.style.display = 'block';
        arrow.classList.remove('fa-chevron-down');
        arrow.classList.add('fa-chevron-up');
    } else {
        sigunguContainer.style.display = 'none';
        arrow.classList.remove('fa-chevron-up');
        arrow.classList.add('fa-chevron-down');
    }
}

// 지역 필터링
function filterByRegion(sido, sigungu, dong) {
    currentSido = sido;
    currentSigungu = sigungu;
    currentDong = dong;
    currentPage = 1;
    loadCourses();
}

// 페이지 변경
function changePage(page) {
    currentPage = page;
    loadCourses();
}

// 코스 목록 로드
function loadCourses() {
    let url = '<%=root%>/course?page=' + currentPage + '&sort=' + currentSort;
    if (currentSido) url += '&sido=' + encodeURIComponent(currentSido);
    if (currentSigungu) url += '&sigungu=' + encodeURIComponent(currentSigungu);
    if (currentDong) url += '&dong=' + encodeURIComponent(currentDong);
    
    window.location.href = url;
}

// 상세 페이지로 이동
function goToDetail(courseId) {
    window.location.href = '<%=root%>/course/' + courseId;
}

// 코스 공유하기 모달 표시
function showCreateForm() {
    document.getElementById('createModal').style.display = 'block';
}

// 코스 공유하기 모달 닫기
function closeCreateModal() {
    document.getElementById('createModal').style.display = 'none';
}

// 스텝 추가
function addStep() {
    if (stepCount >= 5) {
        alert('최대 5개까지 추가 가능합니다.');
        return;
    }
    
    stepCount++;
    const stepsList = document.getElementById('stepsList');
    const newStep = document.createElement('div');
    newStep.className = 'step-item';
    newStep.setAttribute('data-step', stepCount);
    
    newStep.innerHTML = `
        <div class="course-hunting-step-header">
            <span class="course-hunting-step-number">${stepCount}</span>
            <button type="button" class="course-hunting-remove-step" onclick="removeStep(${stepCount})">삭제</button>
        </div>
        <div class="course-hunting-step-content">
            <input type="text" placeholder="핫플레이스 선택" class="course-hunting-step-place" required>
            <input type="file" class="course-hunting-step-photo" accept="image/*">
            <textarea placeholder="스텝 설명" class="course-hunting-step-description" rows="2"></textarea>
        </div>
    `;
    
    stepsList.appendChild(newStep);
    
    // 삭제 버튼 표시/숨김 처리
    updateRemoveButtons();
}

// 스텝 삭제
function removeStep(stepNum) {
    if (stepCount <= 1) {
        alert('최소 1개의 스텝은 필요합니다.');
        return;
    }
    
    const stepElement = document.querySelector(`[data-step="${stepNum}"]`);
    stepElement.remove();
    stepCount--;
    
    // 스텝 번호 재정렬
    reorderSteps();
    updateRemoveButtons();
}

// 스텝 번호 재정렬
function reorderSteps() {
    const steps = document.querySelectorAll('.course-hunting-step-item');
    steps.forEach((step, index) => {
        const stepNum = index + 1;
        step.setAttribute('data-step', stepNum);
        step.querySelector('.course-hunting-step-number').textContent = stepNum;
    });
}

// 삭제 버튼 표시/숨김 처리
function updateRemoveButtons() {
    const removeButtons = document.querySelectorAll('.course-hunting-remove-step');
    removeButtons.forEach(btn => {
        btn.style.display = stepCount > 1 ? 'block' : 'none';
    });
}

// 모달 외부 클릭 시 닫기
window.onclick = function(event) {
    const modal = document.getElementById('createModal');
    if (event.target == modal) {
        closeCreateModal();
    }
}

// 폼 제출
document.getElementById('courseForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    // 폼 데이터 수집
    const formData = {
        title: document.getElementById('courseTitle').value,
        summary: document.getElementById('courseSummary').value,
        nickname: document.getElementById('courseNickname').value
    };
    
    // AJAX로 코스 등록
    fetch('<%=root%>/course/create', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData)
    })
    .then(response => response.text())
    .then(result => {
        if (result === 'success') {
            alert('코스가 등록되었습니다!');
            closeCreateModal();
            loadCourses(); // 목록 새로고침
        } else {
            alert('등록에 실패했습니다.');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('등록에 실패했습니다.');
    });
});
</script>