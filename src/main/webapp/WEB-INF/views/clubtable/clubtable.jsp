<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
%>

<link rel="stylesheet" href="<%=root%>/css/clubtable.css">

<div class="clubtable-page">
    <!-- 우주 배경 -->
    <div class="space-background"></div>
    
    <!-- 별들 컨테이너 -->
    <div class="stars-container" id="starsContainer"></div>
    
    <!-- 메인 콘텐츠 래퍼 -->
    <div class="clubtable-content-wrapper">
        <div class="main-container">
            <div class="container">
                <div class="card-box">
                    <div class="section-title" style="text-align: center; padding: 10px;">
                        <i class="bi bi-calendar-check"></i>
                        클럽 테이블 예약서비스입니다
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- 클럽 테이블 이미지 (배경 밖에) -->
    <div style="margin-top: 30px; margin-bottom: 30px; text-align: center;">
        <img src="<%=root%>/logo/clubtable.png" alt="클럽 테이블" style="width: 600px; height: auto;">
    </div>
</div>

<script>
// 별 생성 함수
function createStars() {
    const starsContainer = document.getElementById('starsContainer');
    const starCount = 150; // 별 개수
    
    for (let i = 0; i < starCount; i++) {
        const star = document.createElement('div');
        star.className = 'star';
        
        // 랜덤 위치
        star.style.left = Math.random() * 100 + '%';
        star.style.top = Math.random() * 100 + '%';
        
        // 랜덤 크기
        const size = Math.random() * 3 + 1;
        star.style.width = size + 'px';
        star.style.height = size + 'px';
        
        starsContainer.appendChild(star);
    }
}

// 페이지 로드 시 별 생성
document.addEventListener('DOMContentLoaded', function() {
    createStars();
    
    // body에 클래스 추가
    document.body.classList.add('clubtable-page');
});
</script>