<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    
    // 로그인하지 않은 경우 처리
    if(loginId == null) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 찜 목록 - WhereHot</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        .wishlist-container { margin-top: 30px; }
        .wish-card { transition: all 0.3s; }
        .wish-card:hover { transform: translateY(-5px); box-shadow: 0 4px 15px rgba(0,0,0,0.2); }
    </style>
</head>
<body>
    <div class="container wishlist-container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="bi bi-heart-fill text-danger"></i> 내 찜 목록</h2>
            <a href="<%=root%>/WEB-INF/views/mypage/mypageMain.jsp" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> 마이페이지
            </a>
        </div>

        <!-- 탭 메뉴 -->
        <ul class="nav nav-tabs" id="wishTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="places-tab" data-bs-toggle="tab" data-bs-target="#places" type="button" role="tab">
                    <i class="bi bi-geo-alt"></i> 핫플레이스 (<span id="placesCount">0</span>)
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="meetings-tab" data-bs-toggle="tab" data-bs-target="#meetings" type="button" role="tab">
                    <i class="bi bi-people"></i> 미팅/데이트 (<span id="meetingsCount">0</span>)
                </button>
            </li>
        </ul>

        <!-- 탭 컨텐츠 -->
        <div class="tab-content" id="wishTabContent">
            <!-- 핫플레이스 찜 목록 -->
            <div class="tab-pane fade show active" id="places" role="tabpanel">
                <div class="mt-4" id="placesWishList">
                    <div class="text-center py-5">
                        <div class="spinner-border" role="status">
                            <span class="visually-hidden">로딩중...</span>
                        </div>
                        <p class="mt-2">핫플레이스 찜 목록을 불러오는 중...</p>
                    </div>
                </div>
            </div>

            <!-- 미팅/데이트 찜 목록 -->
            <div class="tab-pane fade" id="meetings" role="tabpanel">
                <div class="mt-4" id="meetingsWishList">
                    <div class="text-center py-5">
                        <div class="spinner-border" role="status">
                            <span class="visually-hidden">로딩중...</span>
                        </div>
                        <p class="mt-2">미팅/데이트 찜 목록을 불러오는 중...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // 페이지 로드시 초기화
        $(document).ready(function() {
            loadPlacesWishList();
            
            // 탭 변경시 해당 목록 로드
            $('#meetings-tab').on('shown.bs.tab', function() {
                loadMeetingsWishList();
            });
        });

        // 핫플레이스 찜 목록 로드
        function loadPlacesWishList() {
            $('#placesWishList').html(`
                <div class="alert alert-info">
                    <h5><i class="bi bi-info-circle"></i> 핫플레이스 찜 목록 API 구현 필요</h5>
                    <p>핫플레이스 찜 목록을 위해 다음 API가 구현되어야 합니다:</p>
                    <ul>
                        <li><code>GET /api/wishlist/places</code> - 핫플레이스 찜 목록 조회</li>
                        <li><code>DELETE /api/wishlist/places/{id}</code> - 핫플레이스 찜 삭제</li>
                    </ul>
                    <p class="mb-0">기존 WishListDao → WishListService + WishListMapper로 변경 필요</p>
                </div>
            `);
            $('#placesCount').text('N/A');
        }

        // 미팅/데이트 찜 목록 로드
        function loadMeetingsWishList() {
            $('#meetingsWishList').html(`
                <div class="alert alert-info">
                    <h5><i class="bi bi-info-circle"></i> 미팅/데이트 찜 목록 API 구현 필요</h5>
                    <p>미팅/데이트 찜 목록을 위해 다음 API가 구현되어야 합니다:</p>
                    <ul>
                        <li><code>GET /api/meeting-dates/my-wishes</code> - 미팅/데이트 찜 목록 조회</li>
                        <li><code>DELETE /api/meeting-dates/{id}/wish</code> - 미팅/데이트 찜 삭제</li>
                    </ul>
                    <p class="mb-0">기존 MdWishDao → MeetingDateWishService + MeetingDateWishMapper로 변경 필요</p>
                </div>
            `);
            $('#meetingsCount').text('N/A');
        }

        // 찜 삭제 함수들 (구현 예정)
        function removePlaceWish(wishId) {
            if (!confirm('이 핫플레이스를 찜 목록에서 삭제하시겠습니까?')) {
                return;
            }
            alert('핫플레이스 찜 삭제 API 구현 필요:\nDELETE /api/wishlist/places/' + wishId);
        }

        function removeMeetingWish(mdId) {
            if (!confirm('이 미팅/데이트를 찜 목록에서 삭제하시겠습니까?')) {
                return;
            }
            alert('미팅/데이트 찜 삭제 API 구현 필요:\nDELETE /api/meeting-dates/' + mdId + '/wish');
        }
    </script>
</body>
</html>