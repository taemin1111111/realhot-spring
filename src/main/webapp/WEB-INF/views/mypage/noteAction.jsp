<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%-- WishListDao import 제거 - Spring Controller 사용 --%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    
    // 로그인하지 않은 경우 처리
    if(loginId == null) {
        response.getWriter().write("{\"result\": false, \"message\": \"로그인이 필요합니다.\"}");
        return;
    }
    
    // POST 요청만 처리
    if(!"POST".equals(request.getMethod())) {
        response.getWriter().write("{\"result\": false, \"message\": \"잘못된 요청입니다.\"}");
        return;
    }
    
    try {
        // 파라미터 받기
        String wishIdStr = request.getParameter("wishId");
        String noteContent = request.getParameter("noteContent");
        
        if(wishIdStr == null || noteContent == null) {
            response.getWriter().write("{\"result\": false, \"message\": \"필수 파라미터가 누락되었습니다.\"}");
            return;
        }
        
        int wishId = Integer.parseInt(wishIdStr);
        
        // Spring API 호출 안내
        String apiUrl = root + "/api/wishlist/" + wishId + "/note";
        response.getWriter().write("{\"result\": true, \"message\": \"메모 업데이트는 PUT " + apiUrl + " 를 호출하세요.\", \"apiUrl\": \"" + apiUrl + "\", \"method\": \"PUT\", \"data\": {\"noteContent\": \"" + noteContent + "\"}}");
        
    } catch(NumberFormatException e) {
        response.getWriter().write("{\"result\": false, \"message\": \"잘못된 위시리스트 ID입니다.\"}");
    } catch(Exception e) {
        e.printStackTrace();
        response.getWriter().write("{\"result\": false, \"message\": \"서버 오류가 발생했습니다.\"}");
    }
%>
