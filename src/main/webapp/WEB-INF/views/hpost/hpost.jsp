<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    String root = request.getContextPath();
%>

<div class="container hpost-container">
    <!-- 헤더 -->
    <div class="hpost-header">
        <h2 class="hpost-title">💬 썰게시판</h2>
        <p class="hpost-subtitle">다양한 이야기들을 나누어보세요</p>
    </div>

    <!-- 정렬 및 카테고리 필터 -->
    <div class="hpost-filters">
        <div class="filter-group">
            <select id="categoryFilter" class="form-select" onchange="filterByCategory()">
                <option value="0">전체 카테고리</option>
                <c:forEach var="category" items="${categories}">
                    <option value="${category.id}" ${categoryId == category.id ? 'selected' : ''}>
                        ${category.name}
                    </option>
                </c:forEach>
            </select>
        </div>
        
        <div class="filter-group">
            <select id="sortFilter" class="form-select" onchange="changeSort()">
                <option value="latest" ${sort == 'latest' ? 'selected' : ''}>최신순</option>
                <option value="popular" ${sort == 'popular' ? 'selected' : ''}>인기순</option>
            </select>
        </div>
        
        <div class="filter-group">
            <button class="btn btn-primary" onclick="goToWritePage()">글쓰기</button>
        </div>
    </div>

    <!-- 게시글 목록 -->
    <div class="hpost-list">
        <c:if test="${empty hpostList}">
            <div class="no-posts">
                <p>아직 게시글이 없습니다.</p>
                <button class="btn btn-primary" onclick="goToWritePage()">첫 게시글 작성하기</button>
            </div>
        </c:if>
        
        <c:forEach var="hpost" items="${hpostList}">
            <div class="hpost-item" onclick="goToHpostDetail(${hpost.id})">
                <div class="hpost-content">
                    <h5 class="hpost-title">${hpost.title}</h5>
                    <p class="hpost-summary">
                        <c:choose>
                            <c:when test="${fn:length(hpost.content) > 100}">
                                ${fn:substring(hpost.content, 0, 100)}...
                            </c:when>
                            <c:otherwise>
                                ${hpost.content}
                            </c:otherwise>
                        </c:choose>
                    </p>
                    
                    <c:if test="${not empty hpost.photo1 || not empty hpost.photo2 || not empty hpost.photo3}">
                        <div class="hpost-images">
                            <c:if test="${not empty hpost.photo1}">
                                <img src="<%=root%>/uploads/hpost/${hpost.photo1}" alt="이미지1" class="hpost-image">
                            </c:if>
                            <c:if test="${not empty hpost.photo2}">
                                <img src="<%=root%>/uploads/hpost/${hpost.photo2}" alt="이미지2" class="hpost-image">
                            </c:if>
                            <c:if test="${not empty hpost.photo3}">
                                <img src="<%=root%>/uploads/hpost/${hpost.photo3}" alt="이미지3" class="hpost-image">
                            </c:if>
                        </div>
                    </c:if>
                </div>
                
                <div class="hpost-meta">
                    <div class="hpost-author">
                        <span class="author-name">👤 ${hpost.nickname}</span>
                        <span class="post-date">📅 <fmt:formatDate value="${hpost.createdAt}" pattern="MM/dd"/></span>
                    </div>
                    
                    <div class="hpost-stats">
                        <span class="view-count">👁️ ${hpost.views}</span>
                        <span class="like-count">👍 ${hpost.likes}</span>
                        <span class="dislike-count">👎 ${hpost.dislikes}</span>
                        <span class="comment-count">💬 ${hpost.comments.size()}</span>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- 페이징 -->
    <c:if test="${totalCount > 0}">
        <div class="pagination-container">
            <nav aria-label="게시글 페이지네이션">
                <ul class="pagination justify-content-center">
                    <c:set var="totalPages" value="${(totalCount + 11) / 12}" />
                    <c:set var="startPage" value="${Math.max(1, currentPage - 2)}" />
                    <c:set var="endPage" value="${Math.min(totalPages, currentPage + 2)}" />
                    
                    <!-- 이전 페이지 -->
                    <c:if test="${currentPage > 1}">
                        <li class="page-item">
                            <a class="page-link" href="javascript:void(0)" onclick="goToPage(${currentPage - 1})">이전</a>
                        </li>
                    </c:if>
                    
                    <!-- 페이지 번호 -->
                    <c:forEach var="pageNum" begin="${startPage}" end="${endPage}">
                        <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                            <a class="page-link" href="javascript:void(0)" onclick="goToPage(${pageNum})">${pageNum}</a>
                        </li>
                    </c:forEach>
                    
                    <!-- 다음 페이지 -->
                    <c:if test="${currentPage < totalPages}">
                        <li class="page-item">
                            <a class="page-link" href="javascript:void(0)" onclick="goToPage(${currentPage + 1})">다음</a>
                        </li>
                    </c:if>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

<script>
    // 카테고리 필터링
    function filterByCategory() {
        const categoryId = document.getElementById('categoryFilter').value;
        const sort = document.getElementById('sortFilter').value;
        window.location.href = '<%=root%>/hpost?categoryId=' + categoryId + '&sort=' + sort;
    }
    
    // 정렬 변경
    function changeSort() {
        const categoryId = document.getElementById('categoryFilter').value;
        const sort = document.getElementById('sortFilter').value;
        window.location.href = '<%=root%>/hpost?categoryId=' + categoryId + '&sort=' + sort;
    }
    
    // 페이지 이동
    function goToPage(page) {
        const categoryId = document.getElementById('categoryFilter').value;
        const sort = document.getElementById('sortFilter').value;
        window.location.href = '<%=root%>/hpost?page=' + page + '&categoryId=' + categoryId + '&sort=' + sort;
    }
    
    // 게시글 상세 페이지로 이동
    function goToHpostDetail(hpostId) {
        window.location.href = '<%=root%>/hpost/' + hpostId;
    }
    
    // 글쓰기 페이지로 이동
    function goToWritePage() {
        window.location.href = '<%=root%>/hpost/write';
    }
</script>

<style>
.hpost-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

.hpost-header {
    text-align: center;
    margin-bottom: 30px;
}

.hpost-title {
    font-size: 2.5rem;
    font-weight: bold;
    color: #333;
    margin-bottom: 10px;
}

.hpost-subtitle {
    font-size: 1.1rem;
    color: #666;
}

.hpost-filters {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
    padding: 20px;
    background-color: #f8f9fa;
    border-radius: 10px;
}

.filter-group {
    display: flex;
    align-items: center;
    gap: 10px;
}

.form-select {
    padding: 8px 12px;
    border: 1px solid #ddd;
    border-radius: 5px;
    background-color: white;
}

.hpost-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.hpost-item {
    background-color: white;
    border: 1px solid #e0e0e0;
    border-radius: 10px;
    padding: 20px;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.hpost-item:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.15);
}

.hpost-content {
    margin-bottom: 15px;
}

.hpost-content .hpost-title {
    font-size: 1.3rem;
    font-weight: bold;
    color: #333;
    margin-bottom: 10px;
}

.hpost-summary {
    color: #666;
    line-height: 1.6;
    margin-bottom: 15px;
}

.hpost-images {
    display: flex;
    gap: 10px;
    margin-top: 15px;
}

.hpost-image {
    width: 80px;
    height: 80px;
    object-fit: cover;
    border-radius: 5px;
    border: 1px solid #ddd;
}

.hpost-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 15px;
    border-top: 1px solid #eee;
}

.hpost-author {
    display: flex;
    gap: 15px;
    color: #666;
    font-size: 0.9rem;
}

.hpost-stats {
    display: flex;
    gap: 15px;
    color: #666;
    font-size: 0.9rem;
}

.no-posts {
    text-align: center;
    padding: 60px 20px;
    color: #666;
}

.no-posts p {
    font-size: 1.2rem;
    margin-bottom: 20px;
}

.pagination-container {
    margin-top: 40px;
}

.pagination .page-link {
    color: #007bff;
    border: 1px solid #dee2e6;
}

.pagination .page-item.active .page-link {
    background-color: #007bff;
    border-color: #007bff;
}

@media (max-width: 768px) {
    .hpost-filters {
        flex-direction: column;
        gap: 15px;
    }
    
    .hpost-meta {
        flex-direction: column;
        gap: 10px;
        align-items: flex-start;
    }
    
    .hpost-stats {
        flex-wrap: wrap;
        gap: 10px;
    }
}
</style>
