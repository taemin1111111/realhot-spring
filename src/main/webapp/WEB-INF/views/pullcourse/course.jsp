<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String root = request.getContextPath();
%>

<!-- 코스 추천 전용 CSS -->
<link rel="stylesheet" href="<%=root%>/css/course.css">

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
                                                <div class="course-hunting-sigungu-name" onclick="filterByRegion('${sido}', '${tempEntry.key}', '')">${sigungu}</div>
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
                                                        <div class="course-hunting-dong-item" onclick="filterByRegion('${sido}', '${tempEntry.key}', '${region.dong}')">
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
        
        <!-- 현재 선택된 지역 표시 -->
        <div class="course-hunting-current-region">
            <c:choose>
                <c:when test="${not empty param.dong and param.dong ne ''}">
                    <span class="region-badge">
                        <i class="fas fa-map-marker-alt"></i> ${param.dong} 코스
                    </span>
                </c:when>
                <c:when test="${not empty param.sigungu and param.sigungu ne ''}">
                    <span class="region-badge">
                        <i class="fas fa-map-marker-alt"></i> ${param.sigungu} 전체 코스
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="region-badge">
                        <i class="fas fa-map-marker-alt"></i> 전체 코스
                    </span>
                </c:otherwise>
            </c:choose>
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
                             <!-- 제목 섹션 -->
                             <div class="course-hunting-card-title-section">
                                 <h3 class="course-hunting-card-title">${course.title}</h3>
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
                                 <span class="course-hunting-card-nickname">${course.nickname}</span>
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
                                          <c:otherwise>방금전</c:otherwise>
                                      </c:choose>
                                  </div>
                             </div>
                         </div>
                     </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    
         <!-- 페이징 -->
     <c:if test="${totalCount > 12}">
         <div class="course-hunting-pagination">
             <c:set var="pageSize" value="12" />
             <c:set var="totalPages" value="${(totalCount + pageSize - 1) / pageSize}" />
             <c:set var="startPage" value="${((currentPage - 1) / 5) * 5 + 1}" />
             <c:set var="endPage" value="${startPage + 4}" />
             <c:if test="${endPage > totalPages}">
                 <c:set var="endPage" value="${totalPages}" />
             </c:if>
             
             <!-- 이전 페이지 버튼 -->
             <c:if test="${currentPage > 1}">
                 <a href="javascript:void(0)" onclick="changePage(${currentPage - 1})" class="course-hunting-page-btn">
                     <i class="fas fa-chevron-left"></i>
                 </a>
             </c:if>
             
             <!-- 첫 페이지로 이동 (현재 페이지가 6 이상일 때) -->
             <c:if test="${startPage > 1}">
                 <a href="javascript:void(0)" onclick="changePage(1)" class="course-hunting-page-btn">1</a>
                 <c:if test="${startPage > 2}">
                     <span class="course-hunting-page-dots">...</span>
                 </c:if>
             </c:if>
             
             <!-- 페이지 번호들 -->
             <c:forEach begin="${startPage}" end="${endPage}" var="pageNum">
                 <c:choose>
                     <c:when test="${pageNum == currentPage}">
                         <span class="course-hunting-page-btn active">${pageNum}</span>
                     </c:when>
                     <c:otherwise>
                         <a href="javascript:void(0)" onclick="changePage(${pageNum})" class="course-hunting-page-btn">${pageNum}</a>
                     </c:otherwise>
                 </c:choose>
             </c:forEach>
             
             <!-- 마지막 페이지로 이동 (현재 페이지가 마지막 5페이지 이전일 때) -->
             <c:if test="${endPage < totalPages}">
                 <c:if test="${endPage < totalPages - 1}">
                     <span class="course-hunting-page-dots">...</span>
                 </c:if>
                 <a href="javascript:void(0)" onclick="changePage(${totalPages})" class="course-hunting-page-btn">${totalPages}</a>
             </c:if>
             
             <!-- 다음 페이지 버튼 -->
             <c:if test="${currentPage < totalPages}">
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
                    <input type="text" id="courseNickname" name="nickname" required 
                           maxlength="5" placeholder="닉네임 (5자 이하)">
                </div>
                <div class="course-hunting-form-group">
                    <label>비밀번호</label>
                    <input type="password" id="coursePassword" name="passwd_hash" 
                           maxlength="4" pattern="[0-9]{4}" placeholder="숫자 4자리" 
                           title="숫자 4자리를 입력해주세요"
                           oninput="validatePassword(this)" onkeypress="return onlyNumbers(event)">
                </div>
                <!-- 사용자 ID 히든 필드 (로그인 상태에 따라 자동 설정) -->
                <input type="hidden" id="courseUserId" name="userId" value="">
                
                <div class="course-hunting-steps-container">
                    <h3>코스 스텝</h3>
                    <div id="stepsList">
                        <div class="course-hunting-step-item" data-step="1">
                            <div class="course-hunting-step-header">
                                <span class="course-hunting-step-number">1</span>
                                <button type="button" class="course-hunting-remove-step" style="display:none;">삭제</button>
                            </div>
                            <div class="course-hunting-step-content">
                                <div class="hotplace-search-container">
                                    <div class="search-input-wrapper">
                                        <input type="text" placeholder="핫플레이스 검색..." class="course-hunting-step-place" required>
                                        <button type="button" class="search-refresh-btn" onclick="clearSearch(this)" title="검색 초기화">
                                            <span class="refresh-icon">↻</span>
                                        </button>
                                    </div>
                                    <input type="hidden" class="course-hunting-step-place-id" value="">
                                    <div class="hotplace-autocomplete" style="display: none;"></div>
                                </div>
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
let currentSort = '${sort}' || '';
let currentPage = ${currentPage} || 1;
let currentSido = '${param.sido}' || '';
let currentSigungu = '${param.sigungu}' || '';
let currentDong = '${param.dong}' || '';
let stepCount = 1;



// 시간 계산 함수
function calculateTimeAgo(createdAt) {
    if (!createdAt) return '방금전';
    
    const createdDate = new Date(createdAt);
    const now = new Date();
    const diffMs = now - createdDate;
    
    if (diffMs < 60000) { // 1분 미만
        return '방금전';
    } else if (diffMs < 3600000) { // 1시간 미만
        const minutes = Math.floor(diffMs / 60000);
        return minutes + '분전';
    } else if (diffMs < 86400000) { // 24시간 미만
        const hours = Math.floor(diffMs / 3600000);
        return hours + '시간전';
    } else {
        const days = Math.floor(diffMs / 86400000);
        return days + '일전';
    }
}

// 페이지 로드 시 시간 계산 실행
document.addEventListener('DOMContentLoaded', function() {
    // 시간 계산
    const timeElements = document.querySelectorAll('.course-hunting-card-time');
    timeElements.forEach(function(element) {
        const createdAt = element.getAttribute('data-created-at');
        const timeTextElement = element.querySelector('.time-text');
        if (timeTextElement) {
            timeTextElement.textContent = calculateTimeAgo(createdAt);
        }
    });
    
    // 기존 초기화 코드들...
    const initialRemoveButton = document.querySelector('.course-hunting-remove-step');
    if (initialRemoveButton) {
        initialRemoveButton.addEventListener('click', function() {
            const stepNum = parseInt(this.closest('.course-hunting-step-item').getAttribute('data-step'));
            removeStep(stepNum);
        });
    }
    
    // 핫플레이스 검색 자동완성 이벤트 리스너 추가
    setupHotplaceAutocomplete();
});

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
    if (currentSido) {
        var encodedSido = window.encodeURIComponent(currentSido);
        url += '&sido=' + encodedSido;
    }
    if (currentSigungu) {
        var encodedSigungu = window.encodeURIComponent(currentSigungu);
        url += '&sigungu=' + encodedSigungu;
    }
    if (currentDong) {
        var encodedDong = window.encodeURIComponent(currentDong);
        url += '&dong=' + encodedDong;
    }
    

    
    window.location.href = url;
}

// 상세 페이지로 이동
function goToDetail(courseId) {
    window.location.href = '<%=root%>/course/' + courseId;
}

// JWT 토큰 관리 함수들
function getToken() {
    return localStorage.getItem('accessToken');
}

function getUserInfo() {
    // JWT 토큰에서 직접 사용자 정보 추출 (localStorage보다 신뢰할 수 있음)
    const token = localStorage.getItem('accessToken');
    if (!token) {
        return null;
    }
    
    try {
        // Base64 디코딩 시 한글 인코딩 문제 해결
        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        
        const payload = JSON.parse(jsonPayload);
        
        return {
            userid: payload.sub,
            nickname: payload.nickname,
            provider: payload.provider || 'site'
        };
    } catch (error) {
        // localStorage에서 백업 정보 확인
        const backupInfo = localStorage.getItem('userInfo');
        if (backupInfo) {
            try {
                const parsed = JSON.parse(backupInfo);
                return parsed;
            } catch (e) {
                console.error('백업 정보 파싱 오류:', e);
            }
        }
        return null;
    }
}

// 비밀번호 입력 검증 함수들
function onlyNumbers(event) {
    const charCode = (event.which) ? event.which : event.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false;
    }
    return true;
}

function validatePassword(input) {
    // 숫자가 아닌 문자 제거
    input.value = input.value.replace(/[^0-9]/g, '');
    
    // 4자리로 제한
    if (input.value.length > 4) {
        input.value = input.value.slice(0, 4);
    }
    
    // 4자리가 아니면 경고 표시
    if (input.value.length > 0 && input.value.length !== 4) {
        input.style.borderColor = '#ff6b6b';
        input.title = '숫자 4자리를 입력해주세요';
    } else {
        input.style.borderColor = '#ddd';
        input.title = '숫자 4자리를 입력해주세요';
    }
}

// 코스 공유하기 모달 표시
function showCreateForm() {
    document.getElementById('createModal').style.display = 'block';
    
    // 로그인 상태 확인 및 작성자 필드 설정
    const userInfo = getUserInfo();
    const nicknameInput = document.getElementById('courseNickname');
    const passwordInput = document.getElementById('coursePassword');
    
    if (userInfo && userInfo.nickname) {
        // 로그인된 사용자: 닉네임 자동 설정
        nicknameInput.value = userInfo.nickname;
        nicknameInput.readOnly = true;
        nicknameInput.style.backgroundColor = '#f8f9fa';
        
        // 비밀번호 필드는 항상 표시 (숫자 4자리 입력)
        passwordInput.style.display = 'block';
        passwordInput.parentElement.style.display = 'block';
        passwordInput.required = true;
        
        // 히든 필드에 사용자 ID 설정
        const userIdInput = document.getElementById('courseUserId');
        if (userIdInput) {
            userIdInput.value = userInfo.userid || '';
        }
    } else {
        // 비로그인 사용자: 닉네임 입력 가능, 비밀번호 필드 표시
        nicknameInput.value = '';
        nicknameInput.readOnly = false;
        nicknameInput.style.backgroundColor = '#ffffff';
        passwordInput.style.display = 'block';
        passwordInput.parentElement.style.display = 'block';
        passwordInput.required = true;
        
        // 히든 필드 초기화 (서버에서 IP 주소로 설정됨)
        const userIdInput = document.getElementById('courseUserId');
        if (userIdInput) {
            userIdInput.value = '';
        }
    }
}

// 코스 공유하기 모달 닫기
function closeCreateModal() {
    document.getElementById('createModal').style.display = 'none';
    // 모달 닫을 때 폼 초기화
    resetForm();
}

// 폼 초기화
function resetForm() {
    document.getElementById('courseForm').reset();
    
    // 비밀번호 필드 초기화
    const passwordInput = document.getElementById('coursePassword');
    if (passwordInput) {
        passwordInput.value = '';
        passwordInput.required = false;
    }
    
    // 스텝을 1개로 초기화
    const stepsList = document.getElementById('stepsList');
    stepsList.innerHTML = `
        <div class="course-hunting-step-item" data-step="1">
            <div class="course-hunting-step-header">
                <span class="course-hunting-step-number">1</span>
                <button type="button" class="course-hunting-remove-step" onclick="removeStep(1)" style="display:none;">삭제</button>
            </div>
            <div class="course-hunting-step-content">
                <div class="hotplace-search-container">
                    <div class="search-input-wrapper">
                        <input type="text" placeholder="핫플레이스 검색..." class="course-hunting-step-place" required>
                        <button type="button" class="search-refresh-btn" onclick="clearSearch(this)" title="검색 초기화">
                            <span class="refresh-icon">↻</span>
                        </button>
                    </div>
                    <input type="hidden" class="course-hunting-step-place-id" value="">
                    <div class="hotplace-autocomplete" style="display: none;"></div>
                </div>
                <input type="file" class="course-hunting-step-photo" accept="image/*">
                <textarea placeholder="스텝 설명" class="course-hunting-step-description" rows="2"></textarea>
            </div>
        </div>
    `;
    
    stepCount = 1;
    updateRemoveButtons();
    
    // 새로 생성된 입력 필드에 자동완성 설정
    const newInput = document.querySelector('.course-hunting-step-place');
    if (newInput) {
        setupInputAutocomplete(newInput);
    }
}

// 스텝 추가
function addStep() {
    const currentSteps = document.querySelectorAll('.course-hunting-step-item').length;
    if (currentSteps >= 5) {
        alert('최대 5개까지 추가 가능합니다.');
        return;
    }
    
    const newStepNumber = currentSteps + 1;
    const stepsList = document.getElementById('stepsList');
    const newStep = document.createElement('div');
    newStep.className = 'course-hunting-step-item';
    newStep.setAttribute('data-step', newStepNumber);
    
    newStep.innerHTML = `
        <div class="course-hunting-step-header">
            <span class="course-hunting-step-number">${newStepNumber}</span>
            <button type="button" class="course-hunting-remove-step">삭제</button>
        </div>
                    <div class="course-hunting-step-content">
                <div class="hotplace-search-container">
                    <div class="search-input-wrapper">
                        <input type="text" placeholder="핫플레이스 검색..." class="course-hunting-step-place" required>
                        <button type="button" class="search-refresh-btn" onclick="clearSearch(this)" title="검색 초기화">
                            <span class="refresh-icon">↻</span>
                        </button>
                    </div>
                    <input type="hidden" class="course-hunting-step-place-id" value="">
                    <div class="hotplace-autocomplete" style="display: none;"></div>
                </div>
                <input type="file" class="course-hunting-step-photo" accept="image/*">
                <textarea placeholder="스텝 설명" class="course-hunting-step-description" rows="2"></textarea>
            </div>
    `;
    
    stepsList.appendChild(newStep);
    
    // 삭제 버튼에 이벤트 리스너 직접 추가
    const removeButton = newStep.querySelector('.course-hunting-remove-step');
    if (removeButton) {
        removeButton.addEventListener('click', function() {
            const stepNum = parseInt(this.closest('.course-hunting-step-item').getAttribute('data-step'));
            removeStep(stepNum);
        });
    }
    
    // stepCount 업데이트
    stepCount = newStepNumber;
    
    // 삭제 버튼 표시/숨김 처리
    updateRemoveButtons();
    
    // 강제로 번호 다시 설정
    setTimeout(() => {
        const numberElements = document.querySelectorAll('.course-hunting-step-number');
        numberElements.forEach((el, index) => {
            const stepNum = index + 1;
            el.textContent = stepNum.toString();
            el.closest('.course-hunting-step-item').setAttribute('data-step', stepNum);
        });
    }, 10);
    
    // 디버깅용 로그
    console.log('스텝 추가됨:', newStepNumber);
    console.log('현재 스텝들:', document.querySelectorAll('.course-hunting-step-item').length);
    console.log('스텝 번호들:', Array.from(document.querySelectorAll('.course-hunting-step-number')).map(el => el.textContent));
    console.log('data-step 속성들:', Array.from(document.querySelectorAll('.course-hunting-step-item')).map(el => el.getAttribute('data-step')));
    
    // 새로 추가된 스텝의 핫플레이스 입력 필드에 자동완성 설정
    const newInput = newStep.querySelector('.course-hunting-step-place');
    if (newInput) {
        setupInputAutocomplete(newInput);
    }
}

// 스텝 삭제
function removeStep(stepNum) {
    console.log('삭제 시도:', stepNum);
    console.log('현재 stepCount:', stepCount);
    
    if (stepCount <= 1) {
        alert('최소 1개의 스텝은 필요합니다.');
        return;
    }
    
    // 모든 스텝 요소를 가져와서 인덱스로 삭제
    const stepElements = document.querySelectorAll('.course-hunting-step-item');
    const stepToRemove = stepElements[stepNum - 1]; // 0-based index
    
    console.log('삭제할 스텝 요소:', stepToRemove);
    console.log('총 스텝 수:', stepElements.length);
    console.log('삭제할 인덱스:', stepNum - 1);
    
    if (stepToRemove) {
        stepToRemove.remove();
        stepCount--;
        
        console.log('스텝 삭제 후 stepCount:', stepCount);
        
        // 스텝 번호 재정렬
        reorderSteps();
        updateRemoveButtons();
        
        console.log('삭제 완료, 남은 스텝들:', document.querySelectorAll('.course-hunting-step-item').length);
    } else {
        console.log('삭제할 스텝을 찾을 수 없음:', stepNum);
    }
}

// 스텝 번호 재정렬
function reorderSteps() {
    const steps = document.querySelectorAll('.course-hunting-step-item');
    console.log('재정렬 시작, 총 스텝 수:', steps.length);
    
    steps.forEach((step, index) => {
        const stepNum = index + 1;
        step.setAttribute('data-step', stepNum);
        
        const numberElement = step.querySelector('.course-hunting-step-number');
        if (numberElement) {
            numberElement.textContent = stepNum;
            console.log(`스텝 ${stepNum} 번호 설정:`, stepNum);
        }
        
        // 삭제 버튼의 이벤트 리스너 업데이트
        const removeButton = step.querySelector('.course-hunting-remove-step');
        if (removeButton) {
            // 기존 이벤트 리스너 제거
            removeButton.replaceWith(removeButton.cloneNode(true));
            const newRemoveButton = step.querySelector('.course-hunting-remove-step');
            
            // 새로운 이벤트 리스너 추가
            newRemoveButton.addEventListener('click', function() {
                const currentStepNum = parseInt(this.closest('.course-hunting-step-item').getAttribute('data-step'));
                removeStep(currentStepNum);
            });
        }
    });
    
    console.log('재정렬 완료');
    console.log('재정렬 후 data-step 속성들:', Array.from(document.querySelectorAll('.course-hunting-step-item')).map(el => el.getAttribute('data-step')));
}

// 삭제 버튼 표시/숨김 처리
function updateRemoveButtons() {
    const removeButtons = document.querySelectorAll('.course-hunting-remove-step');
    removeButtons.forEach(btn => {
        btn.style.display = stepCount > 1 ? 'block' : 'none';
    });
    
    // stepCount 업데이트 (실제 스텝 개수와 동기화)
    const actualStepCount = document.querySelectorAll('.course-hunting-step-item').length;
    stepCount = actualStepCount;
}

// 모달 외부 클릭 시 닫기
window.onclick = function(event) {
    const modal = document.getElementById('createModal');
    if (event.target == modal) {
        closeCreateModal();
    }
}

// 시간 계산 함수
function calculateTimeAgo(createdAt) {
    if (!createdAt) return '방금전';
    
    const createdDate = new Date(createdAt);
    const now = new Date();
    const diffMs = now - createdDate;
    
    if (diffMs < 60000) { // 1분 미만
        return '방금전';
    } else if (diffMs < 3600000) { // 1시간 미만
        const minutes = Math.floor(diffMs / 60000);
        return minutes + '분전';
    } else if (diffMs < 86400000) { // 24시간 미만
        const hours = Math.floor(diffMs / 3600000);
        return hours + '시간전';
    } else {
        const days = Math.floor(diffMs / 86400000);
        return days + '일전';
    }
}

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    // 시간 계산
    const timeElements = document.querySelectorAll('.course-hunting-card-time');
    timeElements.forEach(function(element) {
        const createdAt = element.getAttribute('data-created-at');
        const timeTextElement = element.querySelector('.time-text');
        if (timeTextElement) {
            timeTextElement.textContent = calculateTimeAgo(createdAt);
        }
    });
    
    // 초기 스텝의 삭제 버튼에 이벤트 리스너 추가
    const initialRemoveButton = document.querySelector('.course-hunting-remove-step');
    if (initialRemoveButton) {
        initialRemoveButton.addEventListener('click', function() {
            const stepNum = parseInt(this.closest('.course-hunting-step-item').getAttribute('data-step'));
            removeStep(stepNum);
        });
    }
    
    // 핫플레이스 검색 자동완성 이벤트 리스너 추가
    setupHotplaceAutocomplete();
});

// 핫플레이스 검색 자동완성 설정
function setupHotplaceAutocomplete() {
    // 기존 핫플레이스 입력 필드에 이벤트 리스너 추가
    const existingInputs = document.querySelectorAll('.course-hunting-step-place');
    console.log('찾은 입력 필드 개수:', existingInputs.length);
    existingInputs.forEach((input, index) => {
        console.log(`입력 필드 ${index + 1}에 자동완성 설정`);
        setupInputAutocomplete(input);
    });
}

// 개별 입력 필드에 자동완성 설정
function setupInputAutocomplete(input) {
    let searchTimeout;
    let isSelectingFromAutocomplete = false; // 자동완성에서 선택 중인지 확인하는 플래그
    
    input.addEventListener('input', function() {
        // 자동완성에서 선택 중이면 검색하지 않음
        if (isSelectingFromAutocomplete) {
            return;
        }
        
        const keyword = this.value.trim();
        const searchContainer = this.closest('.hotplace-search-container');
        const autocompleteDiv = searchContainer.querySelector('.hotplace-autocomplete');
        
        console.log('입력 이벤트 발생:', keyword);
        console.log('검색 컨테이너:', searchContainer);
        console.log('자동완성 div:', autocompleteDiv);
        
        // 이전 검색 타이머 클리어
        clearTimeout(searchTimeout);
        
        if (keyword.length < 2) {
            if (autocompleteDiv) {
                autocompleteDiv.style.display = 'none';
            }
            return;
        }
        
        // 숨겨진 필드에 ID가 이미 설정되어 있으면 검색하지 않음 (자동완성에서 선택된 경우)
        const placeIdInput = searchContainer.querySelector('.course-hunting-step-place-id');
        if (placeIdInput && placeIdInput.value) {
            // ID가 설정되어 있으면 자동완성 숨기기
            if (autocompleteDiv) {
                autocompleteDiv.style.display = 'none';
            }
            return;
        }
        
        // 300ms 후에 검색 실행 (타이핑 중단 시)
        searchTimeout = setTimeout(() => {
            searchHotplaces(keyword, autocompleteDiv, this);
        }, 300);
    });
    
    // 포커스 아웃 시 자동완성 숨기기
    input.addEventListener('blur', function() {
        setTimeout(() => {
            const autocompleteDiv = this.closest('.hotplace-search-container').querySelector('.hotplace-autocomplete');
            if (autocompleteDiv) {
                autocompleteDiv.style.display = 'none';
                autocompleteDiv.innerHTML = '';
            }
        }, 200);
    });
}

// 핫플레이스 검색
function searchHotplaces(keyword, autocompleteDiv, input) {
    var encodedKeyword = window.encodeURIComponent(keyword);
    fetch('<%=root%>/course/hotplace/search?keyword=' + encodedKeyword)
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            console.log('검색 결과:', data); // 디버깅용 로그
            if (data && data.length > 0) {
                displayAutocompleteResults(data, autocompleteDiv, input);
            } else {
                autocompleteDiv.style.display = 'none';
                autocompleteDiv.innerHTML = '';
            }
        })
        .catch(error => {
            console.error('핫플레이스 검색 오류:', error);
            autocompleteDiv.style.display = 'none';
        });
}

// 자동완성 결과 표시
function displayAutocompleteResults(results, autocompleteDiv, input) {
    console.log('자동완성 결과 표시 시작');
    console.log('autocompleteDiv:', autocompleteDiv);
    console.log('results:', results);
    
    if (!autocompleteDiv) {
        console.error('자동완성 div를 찾을 수 없습니다!');
        return;
    }
    
    autocompleteDiv.innerHTML = '';
    
    results.forEach(item => {
        const resultItem = document.createElement('div');
        resultItem.className = 'autocomplete-item';
        
        const nameDiv = document.createElement('div');
        nameDiv.className = 'autocomplete-name';
        nameDiv.textContent = item.name;
        
        const addressDiv = document.createElement('div');
        addressDiv.className = 'autocomplete-address';
        addressDiv.textContent = item.address;
        
        resultItem.appendChild(nameDiv);
        resultItem.appendChild(addressDiv);
        
        resultItem.addEventListener('click', function(e) {
            // 이벤트 전파 중단
            e.preventDefault();
            e.stopPropagation();
            
            // 자동완성에서 선택 중임을 표시
            isSelectingFromAutocomplete = true;
            
            // 입력 필드에 가게 이름 설정
            input.value = item.name;
            
            // 숨겨진 필드에 핫플레이스 ID 설정
            const placeIdInput = input.closest('.hotplace-search-container').querySelector('.course-hunting-step-place-id');
            placeIdInput.value = item.id;
            
            // 자동완성 숨기기
            autocompleteDiv.style.display = 'none';
            autocompleteDiv.innerHTML = '';
            
            // 입력 필드에서 포커스 제거 (자동완성이 다시 뜨지 않도록)
            input.blur();
            
            // 잠시 후 플래그 리셋 (다음 입력을 위해)
            setTimeout(() => {
                isSelectingFromAutocomplete = false;
            }, 100);
            
            // 이벤트 완전 중단
            return false;
        });
        
        autocompleteDiv.appendChild(resultItem);
    });
    
    autocompleteDiv.style.display = 'block';
    

    
    console.log('자동완성 표시 완료, display:', autocompleteDiv.style.display);
    console.log('자동완성 요소 개수:', autocompleteDiv.children.length);
    console.log('자동완성 스타일:', autocompleteDiv.style.cssText);
    console.log('자동완성 위치:', autocompleteDiv.getBoundingClientRect());
    console.log('자동완성 z-index:', autocompleteDiv.style.zIndex);
}

// 폼 제출
console.log('폼 제출 이벤트 리스너 등록 시작');
document.getElementById('courseForm').addEventListener('submit', function(e) {
    console.log('폼 제출 이벤트 발생!');
    e.preventDefault();
    
    console.log('폼 제출 처리 시작');
    
    // 비밀번호 검증
    const passwordInput = document.getElementById('coursePassword');
    if (passwordInput && passwordInput.style.display !== 'none') {
        const password = passwordInput.value;
        if (password.length !== 4 || !/^\d{4}$/.test(password)) {
            alert('비밀번호는 숫자 4자리로 입력해주세요.');
            passwordInput.focus();
            return;
        }
    }
    
    // 폼 데이터 수집
    const formData = {
        title: document.getElementById('courseTitle').value,
        summary: document.getElementById('courseSummary').value,
        nickname: document.getElementById('courseNickname').value,
        passwd_hash: document.getElementById('coursePassword').value,
        steps: []
    };
    
    // 스텝 데이터 수집
    const stepElements = document.querySelectorAll('.course-hunting-step-item');
    console.log('찾은 스텝 요소 개수:', stepElements.length);
    console.log('스텝 요소들:', stepElements);
    
    // 유효한 스텝만 수집 (placeId가 있는 스텝만)
    const validSteps = [];
    
    stepElements.forEach((stepElement, index) => {
        const placeInput = stepElement.querySelector('.course-hunting-step-place');
        const placeIdInput = stepElement.querySelector('.course-hunting-step-place-id');
        const descriptionInput = stepElement.querySelector('.course-hunting-step-description');
        
        console.log(`스텝 ${index + 1} 요소:`, stepElement);
        console.log(`스텝 ${index + 1} placeInput:`, placeInput);
        console.log(`스텝 ${index + 1} placeIdInput:`, placeIdInput);
        console.log(`스텝 ${index + 1} descriptionInput:`, descriptionInput);
        
        const placeName = placeInput ? placeInput.value : '';
        const placeId = placeIdInput ? placeIdInput.value : '';
        const description = descriptionInput ? descriptionInput.value : '';
        
        console.log(`스텝 ${index + 1}:`, {
            placeName: placeName,
            placeId: placeId,
            description: description
        });
        
        // placeId가 있는 스텝만 유효한 스텝으로 간주
        
        if (placeId && placeId.trim() !== '') {
            validSteps.push({
                stepNo: validSteps.length + 1, // 유효한 스텝만 번호 재할당
                placeName: placeName,
                placeId: placeId,
                description: description,
                originalIndex: index // 원본 인덱스 저장
            });
        } else if (placeName && placeName.trim() !== '') {
            // placeId가 없지만 placeName이 있는 경우 경고
            alert(`스텝 ${index + 1}: 핫플레이스를 자동완성에서 선택해주세요.`);
            return;
        }
    });
    
    console.log('유효한 스텝 개수:', validSteps.length);
    console.log('유효한 스텝들:', validSteps);
    
    // 유효한 스텝이 없으면 등록 중단
    if (validSteps.length === 0) {
        alert('최소 하나의 핫플레이스를 선택해주세요.');
        return;
    }
    
    // FormData를 사용해서 파일과 텍스트 데이터를 함께 전송
    const formDataToSend = new FormData();
    formDataToSend.append('title', formData.title);
    formDataToSend.append('summary', formData.summary);
    formDataToSend.append('nickname', formData.nickname);
    formDataToSend.append('passwd_hash', formData.passwd_hash);
    
         // 스텝 데이터와 파일을 FormData에 추가 (유효한 스텝만)
     console.log('FormData에 스텝 추가 시작');
     for (let i = 0; i < validSteps.length; i++) {
         const step = validSteps[i];
         const validIndex = i;
         
         // 해당 스텝의 파일 찾기
         const stepElement = stepElements[step.originalIndex];
         const fileInput = stepElement.querySelector('.course-hunting-step-photo');
         
         console.log(`FormData 유효 스텝 ${validIndex + 1} 추가:`, {
             stepNo: step.stepNo,
             placeName: step.placeName,
             placeId: step.placeId,
             description: step.description,
             originalIndex: step.originalIndex
         });
         
         // 서버가 기대하는 형태로 FormData 추가 (steps[인덱스].필드명 형태)
         formDataToSend.append(`steps[${validIndex}].stepNo`, step.stepNo);
         formDataToSend.append(`steps[${validIndex}].placeName`, step.placeName);
         formDataToSend.append(`steps[${validIndex}].placeId`, step.placeId);
         formDataToSend.append(`steps[${validIndex}].description`, step.description);
         
         // 파일이 선택된 경우에만 추가 - 각 스텝별로 고유한 키 사용
         if (fileInput && fileInput.files.length > 0) {
             var photoKey = 'stepPhoto_' + validIndex;
             console.log('스텝 ' + (validIndex + 1) + ' 파일 추가:', fileInput.files[0].name, '크기:', fileInput.files[0].size, '키:', photoKey);
             formDataToSend.append(photoKey, fileInput.files[0]);
         } else {
             console.log('스텝 ' + (validIndex + 1) + ' 파일 없음');
             // 파일이 없는 경우는 추가하지 않음
         }
         
         // 디버깅: FormData에 추가된 내용 확인
         console.log(`스텝 ${validIndex + 1} FormData 추가 완료`);
     }
    console.log('FormData에 스텝 추가 완료');
    
    // FormData 내용 로깅
    console.log('=== FormData 내용 ===');
    formDataToSend.forEach((value, key) => {
        console.log(key + ': ' + value);
    });
    console.log('=== FormData 내용 완료 ===');
    
    // JWT 토큰 가져오기
    const token = getToken();
    
    // AJAX로 코스 등록 (파일 포함)
    const fetchOptions = {
        method: 'POST',
        body: formDataToSend // Content-Type은 브라우저가 자동으로 설정
    };
    
    // JWT 토큰이 있으면 헤더에 추가
    if (token) {
        fetchOptions.headers = {
            'Authorization': `Bearer ${token}`
        };
    }
    
    fetch('<%=root%>/course/create', fetchOptions)
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

// 검색 초기화 함수
function clearSearch(button) {
    const searchContainer = button.closest('.hotplace-search-container');
    const input = searchContainer.querySelector('.course-hunting-step-place');
    const placeIdInput = searchContainer.querySelector('.course-hunting-step-place-id');
    const autocompleteDiv = searchContainer.querySelector('.hotplace-autocomplete');
    
    // 입력 필드 초기화
    input.value = '';
    placeIdInput.value = '';
    
    // 자동완성 숨기기
    if (autocompleteDiv) {
        autocompleteDiv.style.display = 'none';
    }
    
    // 입력 필드에 포커스
    input.focus();
    
    // 새로고침 버튼 애니메이션
    const icon = button.querySelector('.refresh-icon');
    if (icon) {
        icon.style.transform = 'rotate(360deg)';
        icon.style.transition = 'transform 0.5s ease';
        
        setTimeout(() => {
            icon.style.transform = 'rotate(0deg)';
        }, 500);
    }
}
</script>