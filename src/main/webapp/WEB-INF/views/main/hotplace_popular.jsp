<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String root = request.getContextPath();
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
        <div class="col-likes">좋아요</div>
        <div class="col-views">조회수</div>
    </div>
    <div class="posts-list">
        <c:choose>
            <c:when test="${not empty popularHotplacePosts}">
                <c:forEach var="post" items="${popularHotplacePosts}" varStatus="status">
                    <div class="posts-table-row" onclick="location.href='<%=root%>/hpost/${post.id}'">
                        <div class="col-rank" style="color: #ff6b6b; font-weight: bold;">${status.index + 1}위</div>
                        <div class="col-nickname">
                            <span style="display: inline-block; width: 24px; text-align: center;">
                                <c:if test="${not empty post.userid and post.userid ne 'null'}">
                                    <i class="bi bi-person-fill" style="color: #ff69b4; font-size: 18px;"></i>
                                </c:if>
                            </span>
                            <c:out value="${post.nickname}" />
                        </div>
                        <div class="col-title">
                            <a href="<%=root%>/hpost/${post.id}"><c:out value="${post.title}" /></a>
                        </div>
                        <div class="col-likes">👍 ${post.likes}</div>
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
}

.col-title a {
    color: #333;
    text-decoration: none;
    font-weight: 500;
    font-size: 1rem;
    line-height: 1.4;
    display: block;
    transition: color 0.3s ease;
}

.col-title a:hover {
    color: #555;
}

.col-likes, .col-views {
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

@media (max-width: 900px) {
    .col-rank { flex-basis: 40px; font-size: 0.85rem; }
    .col-nickname { flex-basis: 60px; font-size: 0.93rem; }
    .col-title { font-size: 0.99rem; }
    .col-likes, .col-views { flex-basis: 45px; font-size: 0.95rem; }
}

@media (max-width: 600px) {
    .posts-table-header, .posts-table-row {
        font-size: 0.93rem;
    }
    .col-rank { flex-basis: 35px; font-size: 0.8rem; }
    .col-nickname, .col-likes, .col-views {
        flex-basis: 38px;
        padding: 0 2px;
    }
    .col-title {
        padding: 0 4px;
    }
}

@media (max-width: 768px) {
    .hotplace-popular-section {
        margin-top: 15px;
        padding: 15px;
    }
    
    .section-title {
        font-size: 1.1rem;
    }
}
</style>
