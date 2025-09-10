<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String root = request.getContextPath();
%>

<!-- 부트스트랩 아이콘용 링크 (index.jsp <head>에 이미 있을 수도 있음) -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">

<footer class="bg-black text-white mt-5 py-4 border-top border-secondary">
    <div class="container text-center small">
        <div class="mb-2">
            <strong>어디핫? (WhereHot)</strong> &middot; 당신이 찾는 오늘의 핫플레이스
        </div>
        <div class="mb-2 text-light">
            대표: 조태민 &nbsp;|&nbsp; 문의: <a href="mailto:hothot0001122@gmail.com" class="text-decoration-none text-white">hothot0001122@gmail.com</a>
        </div>
        <div class="mb-2">
            <a href="<%=root %>/privacy.jsp" class="text-decoration-none text-light">개인정보처리방침</a> &nbsp;|&nbsp;
            <a href="<%=root %>/terms.jsp" class="text-decoration-none text-light">이용약관</a> &nbsp;|&nbsp;
            <a href="<%=root %>/notice" class="text-decoration-none text-light">공지사항</a>
        </div>
        <div class="mt-3">
            <!-- ✅ 인스타그램 아이콘 링크 (네 계정으로 바꿔) -->
            <a href="https://www.instagram.com/where.hot/" target="_blank" class="text-decoration-none" style="color: #E4405F;">
                <i class="bi bi-instagram" style="font-size: 1.5rem; color: #E4405F;"></i>
                <span class="ms-1" style="color: #E4405F;">Instagram</span>
            </a>
        </div>
        <div class="text-light mt-2">
            ⓒ 2025 어디핫? All rights reserved.
        </div>
    </div>
</footer>
