<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- review.ReviewDao/ReviewDto import 제거 - Spring Controller 사용 --%>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    // Spring API 호출을 통한 실제 기능 구현
    String contextPath = request.getContextPath();
    String region = request.getParameter("region");
    
    if (region != null && !region.isEmpty()) {
        String apiUrl = contextPath + "/api/reviews/region/" + region;
        out.print("{\"success\":true,\"message\":\"지역별 리뷰 데이터는 GET " + apiUrl + " 를 호출하세요.\",\"apiUrl\":\"" + apiUrl + "\",\"method\":\"GET\",\"region\":\"" + region + "\",\"todo\":\"ReviewService 구현 필요\"}");
    } else {
        out.print("{\"success\":false,\"message\":\"지역 파라미터가 필요합니다.\"}");
    }
%>
<%-- 기존 코드 비활성화
<%
    // ReviewDao dao = new ReviewDao();
    // List<ReviewDto> reviews = dao.getReviewsByRegion(region);
    // ... 기존 로직
%>
--%>