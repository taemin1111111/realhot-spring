<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setContentType("application/json; charset=UTF-8");

String nickname = request.getParameter("nickname");

// 닉네임이 입력되지 않은 경우
if(nickname == null || nickname.trim().isEmpty()) {
    out.print("{\"success\":false,\"message\":\"닉네임을 입력해주세요.\"}");
    return;
}

// Spring API 호출 안내
String contextPath = request.getContextPath();
String apiUrl = contextPath + "/api/member/check-nickname";

out.print("{\"success\":true,\"message\":\"닉네임 중복 확인은 GET " + apiUrl + "?nickname=" + nickname + " 를 호출하세요.\",\"apiUrl\":\"" + apiUrl + "\",\"method\":\"GET\",\"nickname\":\"" + nickname + "\"}");
%>