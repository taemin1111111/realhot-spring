<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setContentType("application/json; charset=UTF-8");

String loginId = (String)session.getAttribute("loginid");

// 로그인하지 않은 경우
if(loginId == null) {
    out.print("{\"success\":false,\"message\":\"로그인이 필요합니다.\"}");
    return;
}

// 파라미터 받기
String name = request.getParameter("name");
String nickname = request.getParameter("nickname");
String email = request.getParameter("email");
String phone = request.getParameter("phone");

// Spring API 호출 안내
String contextPath = request.getContextPath();
String apiUrl = contextPath + "/api/member/profile";

// 데이터 구성
StringBuilder dataBuilder = new StringBuilder("{");
if (name != null && !name.trim().isEmpty()) {
    dataBuilder.append("\"name\":\"").append(name).append("\",");
}
if (nickname != null && !nickname.trim().isEmpty()) {
    dataBuilder.append("\"nickname\":\"").append(nickname).append("\",");
}
if (email != null && !email.trim().isEmpty()) {
    dataBuilder.append("\"email\":\"").append(email).append("\",");
}
if (phone != null && !phone.trim().isEmpty()) {
    dataBuilder.append("\"phone\":\"").append(phone).append("\",");
}
String data = dataBuilder.toString();
if (data.endsWith(",")) {
    data = data.substring(0, data.length() - 1);
}
data += "}";

out.print("{\"success\":true,\"message\":\"프로필 업데이트는 PUT " + apiUrl + " 를 호출하세요.\",\"apiUrl\":\"" + apiUrl + "\",\"method\":\"PUT\",\"data\":" + data + "}");
%>

