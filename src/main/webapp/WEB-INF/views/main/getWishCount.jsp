<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%-- WishList DAO import 제거 - Spring Controller 사용 --%>
<%
response.setContentType("application/json; charset=UTF-8");

try {
    // 파라미터 받기
    String placeIdStr = request.getParameter("placeId");
    
    if (placeIdStr == null || placeIdStr.trim().isEmpty()) {
        response.getWriter().write("{\"success\":false,\"message\":\"장소 ID가 필요합니다.\",\"count\":0}");
        return;
    }
    
    int placeId = Integer.parseInt(placeIdStr);
    
    // Spring API 호출 안내
    String contextPath = request.getContextPath();
    String apiUrl = contextPath + "/api/places/" + placeId + "/wish-count";
    
    response.getWriter().write("{\"success\":true,\"message\":\"찜 개수 조회는 GET " + apiUrl + " 를 호출하세요.\",\"apiUrl\":\"" + apiUrl + "\",\"method\":\"GET\",\"count\":0,\"todo\":\"PlaceService 구현 필요\"}");
    
} catch (NumberFormatException e) {
    response.getWriter().write("{\"success\":false,\"message\":\"잘못된 파라미터입니다.\",\"count\":0}");
} catch (Exception e) {
    e.printStackTrace();
    response.getWriter().write("{\"success\":false,\"message\":\"서버 오류가 발생했습니다.\",\"count\":0}");
}
%>

