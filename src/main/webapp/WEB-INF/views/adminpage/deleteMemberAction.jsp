<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
    
    // 관리자 권한 확인
    String provider = (String)session.getAttribute("provider");
    if(provider == null || !"admin".equals(provider)) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
    
    // 새로운 관리자 페이지로 리다이렉트
    response.sendRedirect(root + "/WEB-INF/views/adminpage/admin.jsp");
%>
