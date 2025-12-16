<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    String root = "";
    String mainPage = (String) request.getAttribute("mainPage");
    if (mainPage == null) {
        mainPage = "main.jsp";
    }
    // 디버깅: mainPage 값 확인
    System.out.println("DEBUG: index.jsp - mainPage = " + mainPage);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
<title>어디핫? - 서울 클럽, 강남 클럽, 홍대 클럽, 핫플레이스 추천</title>
<meta name="description" content="실시간 핫플 추천! 강남 클럽, 홍대 클럽, 이태원 라운지, 헌팅포차까지. 클럽 순위, 클럽 후기, 라운지 후기를 한눈에! 서울 밤문화와 주말 데이트 코스 추천.">
<meta name="keywords" content="어디핫, WhereHotNow, 오늘 핫플, 오늘 핫한 곳, 홍대 클럽, 강남 라운지, 헌팅포차, 서울 핫플, 강남 클럽, 홍대 술집, 이태원 라운지, 서울 클럽 추천, 강남 핫플, 홍대 라운지, 헌팅 잘되는 곳, 홍대 헌팅포차, 서울 라운지 추천, 서울 나이트, 20대 놀거리, 클럽 후기, 라운지 후기, 강남 술집, 서울 주말 데이트, 서울 밤문화, 실시간 핫플, 클럽순위, 서울클럽순위, 한국클럽순위">
<meta name="author" content="어디핫?">
<meta name="robots" content="index, follow">
<link rel="canonical" href="https://wherehotnow.com/">

<!-- Naver Site Verification -->
<meta name="naver-site-verification" content="bee38fe45fc9daf8221030c34a1474c04d962d34" />

<!-- Open Graph (Facebook, KakaoTalk) -->
<meta property="og:type" content="website">
<meta property="og:title" content="어디핫? - 서울 클럽, 강남 클럽, 홍대 클럽 추천">
<meta property="og:description" content="실시간 핫플 추천! 강남 클럽, 홍대 클럽, 이태원 라운지, 헌팅포차까지. 클럽 순위, 클럽 후기를 한눈에!">
<meta property="og:url" content="https://wherehotnow.com/">
<meta property="og:site_name" content="어디핫?">
<meta property="og:image" content="https://wherehotnow.com/logo/mainlogo.png">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="어디핫? - 서울 클럽, 강남 클럽, 홍대 클럽 추천">
<meta name="twitter:description" content="실시간 핫플 추천! 강남 클럽, 홍대 클럽, 이태원 라운지, 헌팅포차까지. 클럽 순위, 클럽 후기를 한눈에!">
<meta name="twitter:image" content="https://wherehotnow.com/logo/mainlogo.png">

<link rel="icon" type="image/x-icon" href="<%=root%>/favicon.ico">


<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Bootstrap 5.3.3 -->
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<script
	src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- Bootstrap Icons -->
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">



<!-- 외부 스타일시트 연결 -->
<link rel="stylesheet" href="<%=root%>/css/all.css">
<!-- 후기작성 -->
<link rel="stylesheet" href="<%=root%>/css/LoginModal.css">
<!-- 후기작성 -->
<link rel="stylesheet" href="<%=root%>/css/join.css">
<!-- 네이버 가입 -->
<link rel="stylesheet" href="<%=root%>/css/naverJoin.css">
<!-- 오늘 핫 랭킹 -->
<link rel="stylesheet" href="<%=root%>/css/todayhot.css">


<style>
.main-welcome {
	text-align: center;
	padding: 40px 20px;
}

.main-welcome h1 {
	font-size: 3rem;
	font-weight: bold;
	color: #333;
	margin-bottom: 20px;
}

.main-welcome .lead {
	font-size: 1.2rem;
	color: #666;
	margin-bottom: 30px;
}

.main-welcome .card {
	transition: transform 0.2s, box-shadow 0.2s;
	border: none;
	box-shadow: 0 2px 10px rgba(0,0,0,0.1);
	margin-bottom: 20px;
}

.main-welcome .card:hover {
	transform: translateY(-5px);
	box-shadow: 0 5px 20px rgba(0,0,0,0.15);
}

.error-fallback {
	padding: 60px 20px;
	text-align: center;
}

.error-fallback h2 {
	font-size: 4rem;
	margin-bottom: 20px;
}

.error-fallback h3 {
	color: #666;
	margin-bottom: 15px;
}

.centered-content {
	min-height: calc(100vh - 200px);
	padding: 20px 0;
}
</style>

</head>
<body>

	<!-- 상단 타이틀 영역 -->
	<jsp:include page="main/title.jsp" />

	<!-- 중앙 콘텐츠 영역 -->
	<div class="centered-content">
		<%
		try {
			if (mainPage != null && !mainPage.equals("main.jsp")) {
				// 메뉴에서 온 JSP 처리
				System.out.println("DEBUG: including page - " + mainPage);
				try {
		%>
					<jsp:include page="<%= mainPage %>" />
		<%
				} catch (Exception e) {
					// 파일이 없으면 main.jsp로 fallback
					System.out.println("DEBUG: Exception occurred while including " + mainPage + ": " + e.getMessage());
					e.printStackTrace();
		%>
					<jsp:include page="main/main.jsp" />
					<div class="alert alert-warning mt-3">
						<i class="bi bi-exclamation-triangle"></i>
						요청하신 페이지를 찾을 수 없어 메인 페이지를 표시합니다. (오류: <%= e.getMessage() %>)
					</div>
		<%
				}
			} else {
				// 기본 메인 페이지 표시
		%>
				<jsp:include page="main/main.jsp" />
		<%
			}
		} catch (Exception e) {
			// 최종 fallback - 에러 메시지만 표시 (main.jsp include 하지 않음)
		%>
			<div class="error-fallback text-center">
				<h2><i class="bi bi-exclamation-triangle text-warning"></i></h2>
				<h3>서비스 일시 중단</h3>
				<p class="text-muted">시스템 점검 중입니다. 잠시 후 다시 시도해주세요.</p>
				<button class="btn btn-primary" onclick="location.reload()">
					<i class="bi bi-arrow-clockwise"></i> 새로고침
				</button>
			</div>
		<%
		}
		%>
	</div>

	<!-- 하단 푸터 영역 -->
	<jsp:include page="main/footer.jsp" />

	<!-- ✅ 인증 관련 스크립트 분리 -->
	<script>
		// JSP에서 JavaScript로 contextPath 전달
		window.ROOT_CONTEXT = "<%=root%>";
	</script>
	<script src="<%=root%>/js/auth-utils.js"></script>

</body>
</html>
