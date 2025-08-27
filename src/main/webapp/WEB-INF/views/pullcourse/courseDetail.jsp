<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    String root = request.getContextPath();
%>

<!-- 코스 상세 페이지 CSS -->
<link rel="stylesheet" href="<%=root%>/css/coursedetail.css">

<script>
// body에 클래스 추가
document.body.classList.add('course-detail-page');

// fetchWithAuth 함수가 없으면 정의
if (typeof window.fetchWithAuth === 'undefined') {
    window.fetchWithAuth = async function(url, options = {}) {
        const token = localStorage.getItem('accessToken');
        
        // 기본 헤더 설정
        if (!options.headers) {
            options.headers = {};
        }
        
        // Authorization 헤더 추가
        if (token) {
            options.headers['Authorization'] = 'Bearer ' + token;
        }
        
        try {
            let response = await fetch(url, options);
            
            // 401 에러 시 토큰 갱신 시도
            if (response.status === 401) {
                const refreshToken = localStorage.getItem('refreshToken');
                if (refreshToken) {
                    try {
                        const refreshResponse = await fetch('<%=root%>/api/auth/refresh', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify({ refreshToken: refreshToken })
                        });
                        
                        if (refreshResponse.ok) {
                            const refreshData = await refreshResponse.json();
                            if (refreshData.token) {
                                localStorage.setItem('accessToken', refreshData.token);
                                
                                // 새로운 토큰으로 원래 요청 재시도
                                options.headers['Authorization'] = 'Bearer ' + refreshData.token;
                                response = await fetch(url, options);
                            }
                        }
                    } catch (refreshError) {
                        console.error('토큰 갱신 실패:', refreshError);
                        // 토큰 갱신 실패 시 로그아웃 처리
                        localStorage.removeItem('accessToken');
                        localStorage.removeItem('refreshToken');
                        localStorage.removeItem('userInfo');
                        location.reload();
                        return;
                    }
                } else {
                    // 리프레시 토큰이 없으면 로그아웃 처리
                    localStorage.removeItem('accessToken');
                    localStorage.removeItem('refreshToken');
                    localStorage.removeItem('userInfo');
                    location.reload();
                    return;
                }
            }
            
            return response;
        } catch (error) {
            console.error('fetchWithAuth 오류:', error);
            throw error;
        }
    };
}
</script>

<div class="course-detail-container">
    <div class="course-detail-content">
        <!-- 제목 -->
        <h1 class="course-detail-title">${course.title}</h1>
        
        <!-- 작성자 정보 -->
        <div class="course-detail-author-info">
            <span class="course-detail-nickname">${course.nickname}</span>
            <div style="display: flex; align-items: center;">
                <span class="course-detail-time">
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
                <span class="course-detail-view-count">👁️ ${course.viewCount}</span>
            </div>
        </div>
        
        <!-- 구분선 -->
        <div class="course-detail-divider"></div>
        
        <!-- 코스 스텝들 -->
        <div class="course-detail-steps">
            <c:forEach var="step" items="${courseSteps}" varStatus="status">
                <div class="course-detail-step">
                    <!-- 스텝 번호와 장소명 -->
                    <div class="course-detail-step-header">
                        <span class="course-detail-step-number">${step.stepNo}</span>
                        <span class="course-detail-step-place">
                            ${step.placeName}
                            <c:if test="${not empty step.placeAddress}">
                                <span class="course-detail-step-address">(${step.placeAddress})</span>
                            </c:if>
                        </span>
                    </div>
                    
                    <!-- 스텝 사진 -->
                    <c:if test="${not empty step.photoUrl}">
                        <div class="course-detail-step-photo">
                            <img src="<%=root%>${step.photoUrl}" alt="스텝 ${step.stepNo} 사진" />
                        </div>
                    </c:if>
                    
                                                              <!-- 스텝 설명 -->
                     <c:if test="${not empty step.description}">
                         <div class="course-detail-step-description">
                             ${step.description}
                         </div>
                     </c:if>
                 </div>
                 
                 <!-- 화살표 (마지막 스텝이 아닌 경우) -->
                 <c:if test="${!status.last}">
                     <div class="course-detail-step-arrow">
                         ↓
                     </div>
                 </c:if>
            </c:forEach>
        </div>
        
        <!-- 구분선 -->
        <div class="course-detail-divider"></div>
        
        <!-- 코스 요약 -->
        <div class="course-detail-summary">
            <h3>코스 요약</h3>
            <p>${course.summary}</p>
        </div>
        
        <!-- 좋아요/싫어요 버튼 -->
        <div class="course-detail-reactions">
            <button class="course-detail-like-btn" id="likeBtn" onclick="toggleReaction(${course.id}, 'LIKE')">
                👍 <span class="like-count">${likeCount}</span>
            </button>
            <button class="course-detail-dislike-btn" id="dislikeBtn" onclick="toggleReaction(${course.id}, 'DISLIKE')">
                👎 <span class="dislike-count">${dislikeCount}</span>
            </button>
        </div>
        
        <!-- 댓글 갯수 -->
        <div class="course-detail-comment-count">💬 ${course.commentCount}</div>
        
        <!-- 구분선 -->
        <div class="course-detail-divider"></div>
        
        <!-- 댓글 입력 -->
        <div class="course-detail-comment-form">
            <div class="comment-input-row">
                <div class="comment-left-column">
                    <input type="text" class="comment-nickname" placeholder="닉네임" maxlength="5" />
                    <input type="password" class="comment-password" placeholder="비밀번호 (숫자 4자리)" maxlength="4" pattern="[0-9]{4}" />
                </div>
                <div class="comment-right-section">
                    <textarea class="comment-content" placeholder="댓글을 입력하세요..."></textarea>
                    <button class="comment-submit-btn" onclick="submitComment(${course.id})">댓글 작성</button>
                </div>
            </div>
        </div>
        
        <!-- 구분선 -->
        <div class="course-detail-divider"></div>
        
        <!-- 댓글 목록 -->
        <div class="course-detail-comments">
            <h3>댓글</h3>
            <p>댓글 기능은 추후 구현 예정입니다.</p>
        </div>
    </div>
</div>

<script>
// 로그인 상태 확인 함수
function isLoggedIn() {
    const token = localStorage.getItem('accessToken');
    if (!token) {
        console.log('토큰이 없습니다');
        return false;
    }
    
    try {
        // Base64 디코딩 시 한글 인코딩 문제 해결
        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        
        const payload = JSON.parse(jsonPayload);
        const currentTime = Date.now() / 1000;
        const isValid = payload.exp > currentTime;
        console.log('토큰 유효성 확인:', { exp: payload.exp, current: currentTime, isValid });
        return isValid;
    } catch (error) {
        console.error('토큰 파싱 오류:', error);
        return false;
    }
}

// 코스 상세 전용 토스트 메시지 표시 함수
function showCourseMessage(message, type = 'info') {
    // 기존 코스 상세 토스트 메시지 제거
    const existingToast = document.querySelector('.course-toast-message');
    if (existingToast) {
        existingToast.remove();
    }
    
    // 토스트 메시지 생성
    const toast = document.createElement('div');
    toast.className = `course-toast-message course-toast-${type}`;
    toast.textContent = message;
    
    // 스타일 설정
    toast.style.cssText = `
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        padding: 15px 25px;
        border-radius: 8px;
        color: white;
        font-weight: 600;
        font-size: 16px;
        z-index: 10000;
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
        animation: slideIn 0.3s ease-out;
        text-align: center;
        min-width: 300px;
    `;
    
    // 타입별 색상 설정
    if (type === 'error') {
        toast.style.backgroundColor = '#dc3545';
    } else if (type === 'warning') {
        toast.style.backgroundColor = '#dc3545';
        toast.style.color = 'white';
    } else if (type === 'success') {
        toast.style.backgroundColor = '#28a745';
    } else {
        toast.style.backgroundColor = '#17a2b8';
    }
    
    // 코스 상세 전용 애니메이션 CSS 추가
    if (!document.querySelector('#course-toast-animation')) {
        const style = document.createElement('style');
        style.id = 'course-toast-animation';
        style.textContent = `
            @keyframes courseSlideIn {
                from {
                    transform: translate(-50%, -50%) scale(0.8);
                    opacity: 0;
                }
                to {
                    transform: translate(-50%, -50%) scale(1);
                    opacity: 1;
                }
            }
            @keyframes courseSlideOut {
                from {
                    transform: translate(-50%, -50%) scale(1);
                    opacity: 1;
                }
                to {
                    transform: translate(-50%, -50%) scale(0.8);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);
    }
    
    // DOM에 추가
    document.body.appendChild(toast);
    
    // 3초 후 자동 제거
    setTimeout(() => {
        toast.style.animation = 'courseSlideOut 0.3s ease-in';
        setTimeout(() => {
            if (toast.parentNode) {
                toast.remove();
            }
        }, 300);
    }, 3000);
}

// 좋아요/싫어요 토글
async function toggleReaction(courseId, reactionType) {
    console.log('toggleReaction 호출:', { courseId, reactionType });
    
    // 로그인 상태 확인
    const loggedIn = isLoggedIn();
    console.log('로그인 상태:', loggedIn);
    
    if (!loggedIn) {
        showCourseMessage('로그인 후 좋아요/싫어요를 사용할 수 있습니다.', 'warning');
        return;
    }
    
    try {
        // JWT 토큰 가져오기
        const token = localStorage.getItem('accessToken');
        if (!token) {
            showCourseMessage('로그인 후 좋아요/싫어요를 사용할 수 있습니다.', 'warning');
            return;
        }
        
        // fetchWithAuth 사용 (자동 토큰 갱신 포함)
        let response;
        if (typeof window.fetchWithAuth === 'function') {
            response = await window.fetchWithAuth('<%=root%>/course/' + courseId + '/reaction', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Authorization': 'Bearer ' + token
                },
                body: 'reactionType=' + reactionType
            });
        } else {
            // fallback: 일반 fetch 사용
            response = await fetch('<%=root%>/course/' + courseId + '/reaction', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Authorization': 'Bearer ' + token
                },
                body: 'reactionType=' + reactionType
            });
        }
        
        const data = await response.json();
        
        if (data.success) {
            // 개수 업데이트
            document.querySelector('.like-count').textContent = data.likeCount;
            document.querySelector('.dislike-count').textContent = data.dislikeCount;
            
            // 버튼 상태 업데이트
            const likeBtn = document.getElementById('likeBtn');
            const dislikeBtn = document.getElementById('dislikeBtn');
            
            // 모든 버튼에서 active 클래스 제거
            likeBtn.classList.remove('active');
            dislikeBtn.classList.remove('active');
            
            // 현재 리액션에 따라 active 클래스 추가
            if (data.currentReaction === 'LIKE') {
                likeBtn.classList.add('active');
            } else if (data.currentReaction === 'DISLIKE') {
                dislikeBtn.classList.add('active');
            }
            
            // 성공 시에는 토스트 메시지 표시하지 않음 (조용히 처리)
            console.log('리액션 처리 성공:', data.action);
            
        } else {
            // 에러 메시지 표시
            if (data.requireLogin) {
                showCourseMessage('로그인 후 좋아요/싫어요를 사용할 수 있습니다.', 'warning');
            } else {
                showCourseMessage(data.message || '리액션 처리 중 오류가 발생했습니다.', 'error');
            }
        }
    } catch (error) {
        console.error('Error:', error);
        showCourseMessage('리액션 처리 중 오류가 발생했습니다.', 'error');
    }
}

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    // 현재 리액션 상태 설정
    const currentReaction = '${currentReaction}';
    const likeBtn = document.getElementById('likeBtn');
    const dislikeBtn = document.getElementById('dislikeBtn');
    
    if (currentReaction === 'LIKE') {
        likeBtn.classList.add('active');
    } else if (currentReaction === 'DISLIKE') {
        dislikeBtn.classList.add('active');
    }
    
    // 로그인 상태에 따른 버튼 스타일 조정
    updateReactionButtonsStyle();
    
    // 주기적으로 로그인 상태 확인 (5초마다)
    setInterval(updateReactionButtonsStyle, 5000);
});

// 로그인 상태에 따른 버튼 스타일 업데이트
function updateReactionButtonsStyle() {
    const likeBtn = document.getElementById('likeBtn');
    const dislikeBtn = document.getElementById('dislikeBtn');
    
    if (!isLoggedIn()) {
        // 비로그인 상태: 버튼 비활성화
        likeBtn.disabled = true;
        dislikeBtn.disabled = true;
        
        // 툴팁 추가
        likeBtn.title = '로그인 후 사용 가능합니다';
        dislikeBtn.title = '로그인 후 사용 가능합니다';
    } else {
        // 로그인 상태: 버튼 활성화
        likeBtn.disabled = false;
        dislikeBtn.disabled = false;
        
        // 툴팁 제거
        likeBtn.title = '';
        dislikeBtn.title = '';
    }
}

// 댓글 작성
function submitComment(courseId) {
    const nickname = document.querySelector('.comment-nickname').value;
    const password = document.querySelector('.comment-password').value;
    const content = document.querySelector('.comment-content').value;
    
    if (!nickname || !password || !content) {
        alert('모든 필드를 입력해주세요.');
        return;
    }
    
    if (password.length !== 4 || !/^\d{4}$/.test(password)) {
        alert('비밀번호는 숫자 4자리로 입력해주세요.');
        return;
    }
    
    // 댓글 작성 로직 (추후 구현)
    alert('댓글 기능은 추후 구현 예정입니다.');
}
</script>
