<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String root = "";
%>
<div class="hotplace-popular-section">
    <div class="section-header">
        <h3 class="section-title">🔥 핫플썰 인기글</h3>
        <a href="<%=root%>/hpost?sort=popular" class="view-all-link">전체보기 →</a>
    </div>
    <div class="posts-table-header">
        <div class="col-rank">순위</div>
        <div class="col-nickname">닉네임</div>
        <div class="col-title">제목</div>
        <div class="col-views">조회수</div>
    </div>
    <div class="posts-list">
        <c:choose>
            <c:when test="${not empty popularHotplacePosts}">
                <c:forEach var="post" items="${popularHotplacePosts}" varStatus="status">
                    <div class="posts-table-row" onclick="location.href='<%=root%>/hpost/${post.id}'">
                        <div class="col-rank" style="color: #ff6b6b; font-weight: bold;">${status.index + 1}위</div>
                        <div class="col-nickname">
                            <c:out value="${post.nickname}" />
                        </div>
                        <div class="col-title">
                            <a href="<%=root%>/hpost/${post.id}"><c:out value="${post.title}" /></a>
                        </div>
                        <div class="col-views">👁️ ${post.views}</div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="no-posts-row">
                    <p>아직 인기글이 없습니다.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<style>
.hotplace-popular-section {
    background: white;
    border-radius: 15px;
    padding: 25px;
    margin-top: 0;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
    width: 100%;
    max-width: 500px;
    margin-left: 0;
    margin-right: auto;
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.section-title {
    font-size: 1.4rem;
    color: #333;
    margin: 0;
    font-weight: 600;
}

.view-all-link {
    color: #1275E0;
    text-decoration: none;
    font-size: 0.9rem;
    font-weight: 500;
}

.view-all-link:hover {
    text-decoration: underline;
}

/* Community 스타일과 동일한 테이블 스타일 */
.posts-table-header {
    display: flex;
    align-items: center;
    background: #f7f8fa;
    border-radius: 8px 8px 0 0;
    font-weight: 600;
    color: #34495e;
    font-size: 1.01rem;
    padding: 10px 0 10px 0;
    border-bottom: 1.5px solid #e3e6ec;
    margin-bottom: 0;
}

.posts-table-row {
    display: flex;
    align-items: center;
    padding: 15px 0;
    border-bottom: 1px solid #f0f0f0;
    transition: background-color 0.3s ease;
    color: #333;
    cursor: pointer;
}

.posts-table-row:hover {
    background-color: #f8f9fa;
}

.col-rank {
    flex-basis: 50px;
    text-align: center;
    font-size: 0.9rem;
    color: #333;
    font-weight: 600;
}

.col-nickname {
    flex-basis: 80px;
    font-size: 0.95rem;
    color: #333;
    font-weight: 500;
}

.col-title {
    flex: 1;
    padding: 0 15px;
    color: #333;
    text-align: center;
}

.col-title a {
    color: #333;
    text-decoration: none;
    font-weight: 500;
    font-size: 1rem;
    line-height: 1.4;
    display: block;
    transition: color 0.3s ease;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.col-title a:hover {
    color: #555;
}

.col-views {
    flex-basis: 60px;
    text-align: center;
    font-size: 0.9rem;
    color: #333;
}

.no-posts-row {
    background: #fff;
    color: #aaa;
    text-align: center;
    font-style: italic;
    border-bottom: none;
    padding: 20px;
}

/* ===== 모바일 반응형 스타일 ===== */

/* 태블릿 스타일 (768px 이하) */
@media (max-width: 768px) {
    .hotplace-popular-section {
        margin-top: 15px;
        padding: 15px;
        max-width: 100%;
    }
    
    .section-title {
        font-size: 1.2rem;
    }
    
    .posts-table-header {
        font-size: 0.9rem;
        padding: 8px 0;
    }
    
    .posts-table-row {
        padding: 12px 0;
        font-size: 0.9rem;
    }
    
    .col-rank { 
        flex-basis: 45px; 
        font-size: 0.85rem; 
    }
    
    .col-nickname { 
        flex-basis: 70px; 
        font-size: 0.85rem; 
    }
    
    .col-title { 
        font-size: 0.9rem; 
        padding: 0 8px;
        line-height: 1.3;
    }
    
    .col-views { 
        flex-basis: 50px; 
        font-size: 0.8rem; 
    }
}

/* 모바일 스타일 (480px 이하) */
@media (max-width: 480px) {
    .hotplace-popular-section {
        padding: 15px;
        margin-top: 10px;
        border-radius: 12px;
    }
    
    .section-title {
        font-size: 1.2rem;
    }
    
    .view-all-link {
        font-size: 0.85rem;
    }
    
    .posts-table {
        font-size: 0.75rem !important;
    }
    
    .posts-table th {
        padding: 4px 2px !important;
        font-size: 0.65rem !important;
        text-align: center !important;
    }
    
    .posts-table td {
        padding: 4px 2px !important;
        font-size: 0.7rem !important;
        text-align: center !important;
        vertical-align: middle !important;
    }
    
    .col-rank {
        font-size: 0.6rem !important;
        padding: 1px 3px !important;
    }
    
    .col-title {
        font-size: 0.65rem !important;
        max-width: 70px !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        white-space: nowrap !important;
    }
    
    .col-title a {
        font-size: 0.65rem !important;
    }
    
    .col-nickname {
        font-size: 0.6rem !important;
        max-width: 40px !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        white-space: nowrap !important;
    }
    
    .col-views {
        font-size: 0.6rem !important;
    }
}

/* 소형 모바일 (360px 이하) */
@media (max-width: 360px) {
    .hotplace-popular-section {
        padding: 12px;
        margin-top: 8px;
        border-radius: 10px;
    }
    
    .section-title {
        font-size: 1.1rem;
    }
    
    .view-all-link {
        font-size: 0.8rem;
    }
    
    .posts-table {
        font-size: 0.7rem !important;
    }
    
    .posts-table th {
        padding: 3px 1px !important;
        font-size: 0.6rem !important;
        text-align: center !important;
    }
    
    .posts-table td {
        padding: 3px 1px !important;
        font-size: 0.65rem !important;
        text-align: center !important;
        vertical-align: middle !important;
    }
    
    .col-rank {
        font-size: 0.55rem !important;
        padding: 1px 2px !important;
    }
    
    .col-title {
        font-size: 0.6rem !important;
        max-width: 60px !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        white-space: nowrap !important;
    }
    
    .col-title a {
        font-size: 0.6rem !important;
    }
    
    .col-nickname {
        font-size: 0.55rem !important;
        max-width: 35px !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        white-space: nowrap !important;
    }
    
    .col-views {
        font-size: 0.55rem !important;
    }
}
</style>
