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
// 토스트 메시지 표시 함수
function showMessage(message, type = 'info') {
    // 기존 토스트 메시지 제거
    const existingToast = document.querySelector('.toast-message');
    if (existingToast) {
        existingToast.remove();
    }
    
    // 토스트 메시지 생성
    const toast = document.createElement('div');
    toast.className = `toast-message toast-${type}`;
    toast.textContent = message;
    
    // 스타일 설정
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 20px;
        border-radius: 6px;
        color: white;
        font-weight: 600;
        font-size: 14px;
        z-index: 10000;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        animation: slideIn 0.3s ease-out;
    `;
    
    // 타입별 색상 설정
    if (type === 'error') {
        toast.style.backgroundColor = '#dc3545';
    } else if (type === 'warning') {
        toast.style.backgroundColor = '#ffc107';
        toast.style.color = '#212529';
    } else if (type === 'success') {
        toast.style.backgroundColor = '#28a745';
    } else {
        toast.style.backgroundColor = '#17a2b8';
    }
    
    // 애니메이션 CSS 추가
    if (!document.querySelector('#toast-animation')) {
        const style = document.createElement('style');
        style.id = 'toast-animation';
        style.textContent = `
            @keyframes slideIn {
                from {
                    transform: translateX(100%);
                    opacity: 0;
                }
                to {
                    transform: translateX(0);
                    opacity: 1;
                }
            }
            @keyframes slideOut {
                from {
                    transform: translateX(0);
                    opacity: 1;
                }
                to {
                    transform: translateX(100%);
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
        toast.style.animation = 'slideOut 0.3s ease-in';
        setTimeout(() => {
            if (toast.parentNode) {
                toast.remove();
            }
        }, 300);
    }, 3000);
}

// 좋아요/싫어요 토글
function toggleReaction(courseId, reactionType) {
    fetch('<%=root%>/course/' + courseId + '/reaction', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'reactionType=' + reactionType
    })
    .then(response => response.json())
    .then(data => {
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
        } else {
            // 로그인 필요 메시지 표시
            if (data.requireLogin) {
                showMessage(data.message, 'error');
            } else {
                showMessage(data.message, 'error');
            }
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showMessage('리액션 처리 중 오류가 발생했습니다.', 'error');
    });
}

// 페이지 로드 시 현재 리액션 상태 설정
document.addEventListener('DOMContentLoaded', function() {
    const currentReaction = '${currentReaction}';
    const likeBtn = document.getElementById('likeBtn');
    const dislikeBtn = document.getElementById('dislikeBtn');
    
    if (currentReaction === 'LIKE') {
        likeBtn.classList.add('active');
    } else if (currentReaction === 'DISLIKE') {
        dislikeBtn.classList.add('active');
    }
});

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
