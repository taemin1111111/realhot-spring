<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Spring REST API 방식으로 변환: Model1 DAO/DTO 제거 --%>

<%
    String root = request.getContextPath();
%>

<div class="mymdlist-container" id="mymdlist-container">
    <!-- MD 컬렉션은 REST API를 통해 동적으로 로드됩니다 -->
    <div class="loading">내 MD 컬렉션을 불러오는 중...</div>
</div>

<script>
// 페이지 로드 시 MD 위시리스트 로드
document.addEventListener('DOMContentLoaded', function() {
    loadMyMdWishlist();
});

// REST API를 통한 MD 위시리스트 로드
function loadMyMdWishlist() {
    const url = '<%=root%>/api/md/user/wishlist?limit=1000';
    
    fetch(url, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            renderMyMdWishlist(data.wishList || [], data.totalCount || 0);
        } else {
            if (data.message && data.message.includes('로그인')) {
                // 로그인이 필요한 경우
                window.location.href = '<%=root%>/index.jsp';
            } else {
                document.getElementById('mymdlist-container').innerHTML = 
                    '<div class="error">MD 컬렉션을 불러올 수 없습니다: ' + (data.message || '') + '</div>';
            }
        }
    })
    .catch(error => {
        console.error('MD 위시리스트 로드 오류:', error);
        document.getElementById('mymdlist-container').innerHTML = 
            '<div class="error">MD 컬렉션을 불러오는 중 오류가 발생했습니다.</div>';
    });
}

// MD 위시리스트 렌더링
function renderMyMdWishlist(wishList, totalCount) {
    let html = `
        <!-- 헤더 섹션 -->
        <div class="mymdlist-header">
            <div class="header-content">
                <h1 class="mymdlist-title">
                    <i class="bi bi-collection-heart-fill text-danger me-3"></i>
                    내가 소장한 MD
                </h1>
                <p class="mymdlist-subtitle">소중한 MD 컬렉션을 관리해보세요</p>
                <div class="mymdlist-stats">
                    <span class="stat-item">
                        <i class="bi bi-heart-fill text-danger"></i>
                        총 <strong>${totalCount}</strong>개의 MD
                    </span>
                </div>
            </div>
        </div>

        <!-- MD 컬렉션 섹션 -->
        <div class="md-collection-section">`;
    
    if (!wishList || wishList.length === 0) {
        html += `
            <div class="empty-collection">
                <div class="empty-icon">
                    <i class="bi bi-collection-heart"></i>
                </div>
                <h3 class="empty-title">아직 소장한 MD가 없어요</h3>
                <p class="empty-description">첫 번째 MD를 소장해보세요!</p>
                <a href="<%=root%>/index.jsp?main=clubmd/clubmd.jsp" class="btn btn-primary btn-lg">
                    <i class="bi bi-search me-2"></i>MD 둘러보기
                </a>
            </div>`;
    } else {
        html += '<div class="md-collection-grid">';
        
        wishList.forEach(mdWish => {
            const formattedDate = formatDate(mdWish.wishDate || mdWish.createdAt);
            
            html += `
                <div class="md-collection-item" data-md-id="${mdWish.mdId}">
                    <div class="md-collection-card">
                        <div class="md-card-header">
                            <div class="md-status-badge">
                                <i class="bi bi-heart-fill text-danger"></i>
                                소장중
                            </div>
                            <button class="md-remove-btn" onclick="removeMdFromWishlist(${mdWish.mdId})" title="소장 해제">
                                <i class="bi bi-x-lg"></i>
                            </button>
                        </div>
                        
                        <div class="md-card-body">
                            <div class="md-info">
                                <h4 class="md-title">${mdWish.mdTitle || mdWish.title || 'MD 제목'}</h4>
                                <p class="md-description">${mdWish.mdDescription || mdWish.description || '설명이 없습니다.'}</p>
                                
                                <div class="md-details">
                                    <div class="md-detail-item">
                                        <i class="bi bi-calendar-check text-primary"></i>
                                        <span class="detail-label">소장일:</span>
                                        <span class="detail-value">${formattedDate}</span>
                                    </div>
                                    
                                    <div class="md-detail-item">
                                        <i class="bi bi-tag text-success"></i>
                                        <span class="detail-label">카테고리:</span>
                                        <span class="detail-value">${mdWish.categoryName || '일반'}</span>
                                    </div>
                                    
                                    <div class="md-detail-item">
                                        <i class="bi bi-geo-alt text-warning"></i>
                                        <span class="detail-label">지역:</span>
                                        <span class="detail-value">${mdWish.regionName || '전체'}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="md-card-footer">
                            <button class="btn btn-outline-primary btn-sm" onclick="viewMdDetail(${mdWish.mdId})">
                                <i class="bi bi-eye me-1"></i>상세보기
                            </button>
                            <button class="btn btn-outline-secondary btn-sm" onclick="shareMd(${mdWish.mdId})">
                                <i class="bi bi-share me-1"></i>공유하기
                            </button>
                        </div>
                    </div>
                </div>`;
        });
        
        html += '</div>';
    }
    
    html += `
        </div>
        
        <!-- 하단 액션 버튼 -->
        <div class="mymdlist-actions">
            <div class="action-buttons">
                <a href="<%=root%>/index.jsp?main=clubmd/clubmd.jsp" class="btn btn-primary">
                    <i class="bi bi-plus-circle me-2"></i>새 MD 찾기
                </a>
                <button onclick="refreshMdList()" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-clockwise me-2"></i>새로고침
                </button>
            </div>
        </div>`;
    
    document.getElementById('mymdlist-container').innerHTML = html;
}

// MD 위시리스트에서 제거
function removeMdFromWishlist(mdId) {
    if (!confirm('이 MD를 소장 목록에서 제거하시겠습니까?')) {
        return;
    }
    
    const url = '<%=root%>/api/md/' + mdId + '/wish';
    
    fetch(url, {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('MD가 소장 목록에서 제거되었습니다.');
            loadMyMdWishlist(); // 목록 새로고침
        } else {
            alert(data.message || 'MD 제거 중 오류가 발생했습니다.');
        }
    })
    .catch(error => {
        console.error('MD 제거 오류:', error);
        alert('MD 제거 중 오류가 발생했습니다.');
    });
}

// MD 상세보기
function viewMdDetail(mdId) {
    window.location.href = '<%=root%>/index.jsp?main=clubmd/clubmd.jsp&mdId=' + mdId;
}

// MD 공유하기
function shareMd(mdId) {
    const shareUrl = window.location.origin + '<%=root%>/index.jsp?main=clubmd/clubmd.jsp&mdId=' + mdId;
    
    if (navigator.share) {
        navigator.share({
            title: 'MD 공유',
            text: '이 MD를 확인해보세요!',
            url: shareUrl
        });
    } else {
        // 클립보드에 복사
        navigator.clipboard.writeText(shareUrl).then(() => {
            alert('MD 링크가 클립보드에 복사되었습니다.');
        }).catch(() => {
            alert('링크: ' + shareUrl);
        });
    }
}

// 목록 새로고침
function refreshMdList() {
    loadMyMdWishlist();
}

// 날짜 포맷팅
function formatDate(dateString) {
    if (!dateString) return '';
    
    const date = new Date(dateString);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    
    return `${year}-${month}-${day}`;
}

// CSS 추가
const style = document.createElement('style');
style.textContent = `
    .mymdlist-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
    }
    
    .mymdlist-header {
        text-align: center;
        margin-bottom: 40px;
        padding: 40px 20px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 15px;
        color: white;
    }
    
    .mymdlist-title {
        font-size: 2.5rem;
        font-weight: bold;
        margin-bottom: 10px;
    }
    
    .mymdlist-subtitle {
        font-size: 1.2rem;
        opacity: 0.9;
        margin-bottom: 20px;
    }
    
    .mymdlist-stats .stat-item {
        font-size: 1.1rem;
        padding: 10px 20px;
        background: rgba(255,255,255,0.2);
        border-radius: 25px;
        display: inline-block;
    }
    
    .md-collection-section {
        margin-bottom: 40px;
    }
    
    .empty-collection {
        text-align: center;
        padding: 60px 20px;
        background: #f8f9fa;
        border-radius: 15px;
    }
    
    .empty-icon {
        font-size: 4rem;
        color: #dee2e6;
        margin-bottom: 20px;
    }
    
    .empty-title {
        font-size: 1.5rem;
        color: #6c757d;
        margin-bottom: 10px;
    }
    
    .empty-description {
        color: #adb5bd;
        margin-bottom: 30px;
    }
    
    .md-collection-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
        gap: 20px;
    }
    
    .md-collection-item {
        border-radius: 15px;
        overflow: hidden;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        transition: transform 0.3s ease;
    }
    
    .md-collection-item:hover {
        transform: translateY(-5px);
    }
    
    .md-collection-card {
        background: white;
        height: 100%;
        display: flex;
        flex-direction: column;
    }
    
    .md-card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 15px;
        background: #f8f9fa;
    }
    
    .md-status-badge {
        background: #e3f2fd;
        color: #1976d2;
        padding: 5px 12px;
        border-radius: 20px;
        font-size: 0.9rem;
        font-weight: 500;
    }
    
    .md-remove-btn {
        background: #ffebee;
        color: #d32f2f;
        border: none;
        width: 30px;
        height: 30px;
        border-radius: 50%;
        cursor: pointer;
    }
    
    .md-card-body {
        padding: 20px;
        flex: 1;
    }
    
    .md-title {
        font-size: 1.2rem;
        font-weight: bold;
        margin-bottom: 10px;
        color: #2c3e50;
    }
    
    .md-description {
        color: #6c757d;
        margin-bottom: 15px;
        font-size: 0.9rem;
        line-height: 1.5;
    }
    
    .md-details {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }
    
    .md-detail-item {
        display: flex;
        align-items: center;
        font-size: 0.9rem;
    }
    
    .md-detail-item i {
        margin-right: 8px;
        width: 16px;
    }
    
    .detail-label {
        font-weight: 500;
        margin-right: 5px;
        color: #495057;
    }
    
    .detail-value {
        color: #6c757d;
    }
    
    .md-card-footer {
        padding: 15px;
        background: #f8f9fa;
        display: flex;
        gap: 10px;
    }
    
    .md-card-footer .btn {
        flex: 1;
    }
    
    .mymdlist-actions {
        text-align: center;
        padding: 30px 0;
    }
    
    .action-buttons {
        display: flex;
        justify-content: center;
        gap: 15px;
        flex-wrap: wrap;
    }
    
    .loading, .error {
        text-align: center;
        padding: 60px 20px;
        color: #6c757d;
    }
    
    .error {
        color: #dc3545;
        background: #f8d7da;
        border: 1px solid #f5c6cb;
        border-radius: 10px;
    }
    
    @media (max-width: 768px) {
        .md-collection-grid {
            grid-template-columns: 1fr;
        }
        
        .mymdlist-title {
            font-size: 2rem;
        }
        
        .action-buttons {
            flex-direction: column;
            align-items: center;
        }
        
        .action-buttons .btn {
            min-width: 200px;
        }
    }
`;
document.head.appendChild(style);
</script>