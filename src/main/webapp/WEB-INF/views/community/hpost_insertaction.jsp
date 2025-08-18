<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
    
    // Controller에서 설정한 속성 가져오기
    Boolean success = (Boolean) request.getAttribute("success");
    String message = (String) request.getAttribute("message");
    Integer targetPage = (Integer) request.getAttribute("targetPage");
    Integer categoryId = (Integer) request.getAttribute("categoryId");
    
    if (success != null && success) {
        // 성공한 경우
        %>
        <script>
            alert('<%= message %>');
            // 해당 글이 있는 페이지로 이동 (헌팅썰 목록)
            parent.location.href = '<%= root %>/?main=community/cumain.jsp&category=<%= categoryId %>&page=<%= targetPage %>';
        </script>
        <%
    } else {
        // 실패한 경우
        %>
        <script>
            alert('<%= message != null ? message : "글 작성에 실패했습니다." %>');
            history.back();
        </script>
        <%
    }
%>