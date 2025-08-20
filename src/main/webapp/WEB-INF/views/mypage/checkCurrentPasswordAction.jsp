<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setContentType("application/json; charset=UTF-8");

String loginId = (String)session.getAttribute("loginid");
String password = request.getParameter("password");

// 로그인하지 않은 경우
if(loginId == null) {
    out.print("{\"success\":false,\"message\":\"로그인이 필요합니다.\"}");
    return;
}

// 비밀번호가 입력되지 않은 경우
if(password == null || password.trim().isEmpty()) {
    out.print("{\"success\":false,\"message\":\"비밀번호를 입력해주세요.\"}");
    return;
}

// Spring API 호출 안내
String contextPath = request.getContextPath();
String apiUrl = contextPath + "/api/member/check-password";

out.print("{\"success\":true,\"message\":\"비밀번호 확인은 POST " + apiUrl + " 를 호출하세요.\",\"apiUrl\":\"" + apiUrl + "\",\"method\":\"POST\",\"data\":{\"password\":\"" + password + "\"}}");
%>