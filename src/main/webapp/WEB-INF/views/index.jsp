<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    String root = request.getContextPath();
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
<title>어디핫?</title>
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
