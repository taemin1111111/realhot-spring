<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = "";
%>
<!-- 마이페이지 전용 CSS -->
<link rel="stylesheet" href="<%=root%>/css/mypage.css">

<div class="wishlist-container">
    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2>나의 장소</h2>
                    <a href="<%=root%>/mypage" class="btn btn-outline-primary">
                        ← 마이페이지로
                    </a>
                </div>
                
                <!-- 카테고리 필터 -->
                <div class="category-filter mb-4">
                    <div class="d-flex flex-wrap gap-2">
                        <button class="category-filter-btn active" data-category="all">전체</button>
                        <button class="category-filter-btn marker-club" data-category="1">C</button>
                        <button class="category-filter-btn marker-hunting" data-category="2">H</button>
                        <button class="category-filter-btn marker-lounge" data-category="3">L</button>
                        <button class="category-filter-btn marker-pocha" data-category="4">P</button>
                    </div>
                </div>
                
                <!-- 찜 목록 -->
                <div id="wishlist-container">
                    <div class="text-center p-5">
                        <div class="card border-0 shadow-sm">
                            <div class="card-body p-5">
                                <div class="spinner-border text-primary mb-3" style="width: 3rem; height: 3rem;" role="status">
                                    <span class="visually-hidden">로딩 중...</span>
                                </div>
                                <h5 class="text-muted">찜 목록을 불러오는 중입니다...</h5>
                                <p class="text-muted mb-0">잠시만 기다려주세요</p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- 페이지네이션 -->
                <nav id="pagination" class="mt-4" style="display: none;">
                    <ul class="pagination justify-content-center">
                    </ul>
                </nav>
            </div>
        </div>
    </div>

    <script>
        let currentPage = 1;
        const pageSize = 10;
        let wishlistData = null; // 찜 목록 데이터를 저장할 전역 변수
        let currentCategory = 'all'; // 현재 선택된 카테고리
        
        $(document).ready(function() {
            // JWT 토큰 확인
            const token = getJwtToken();
            if (!token) {
                alert('로그인이 필요합니다.');
                window.location.href = '<%=root%>/';
                return;
            }
            
            loadWishlist();
            
            // 카테고리 필터 버튼 클릭 이벤트
            $('.category-filter-btn').on('click', function() {
                const category = $(this).data('category');
                filterByCategory(category);
            });
        });
        
        // JWT 토큰 가져오기
        function getJwtToken() {
            return localStorage.getItem('accessToken');
        }
        
        // API 요청 헤더 설정
        function getRequestHeaders() {
            const token = getJwtToken();
            return {
                'Authorization': 'Bearer ' + token,
                'Content-Type': 'application/json'
            };
        }
        
        // 카테고리별 필터링
        function filterByCategory(category) {
            currentCategory = category;
            currentPage = 1; // 카테고리 변경 시 첫 페이지로
            
            // 버튼 활성화 상태 변경
            $('.category-filter-btn').removeClass('active');
            $(`.category-filter-btn[data-category="${category}"]`).addClass('active');
            
            // 찜 목록 다시 로드
            loadWishlist();
        }
        
        // 찜 목록 로드
        function loadWishlist(page = 1) {
            currentPage = page;
            
            $.ajax({
                url: '<%=root%>/mypage/api/wishlist',
                method: 'GET',
                headers: getRequestHeaders(),
                data: {
                    page: page,
                    size: pageSize
                },
                success: function(response) {
                    displayWishlist(response);
                    displayPagination(response);
                },
                error: function(xhr, status, error) {
                    console.error('찜 목록 로드 오류:', error);
                    if (xhr.status === 401) {
                        alert('인증이 만료되었습니다. 다시 로그인해주세요.');
                        localStorage.removeItem('accessToken');
                        window.location.href = '<%=root%>/';
                    } else {
                        $('#wishlist-container').html(`
                            <div class="alert alert-danger">
                                <i class="bi bi-exclamation-triangle"></i>
                                찜 목록을 불러올 수 없습니다.
                            </div>
                        `);
                    }
                }
            });
        }
        
        // 찜 목록 표시
        function displayWishlist(data) {
            const container = $('#wishlist-container');
            
            // 전역 변수에 데이터 저장
            wishlistData = data;
            


            
                         // 데이터가 배열인지 객체인지 확인
                         
             let wishlistArray = data;
             if (data.wishlist && Array.isArray(data.wishlist)) {
                 wishlistArray = data.wishlist;
             } else if (Array.isArray(data)) {
                 wishlistArray = data;
             } else {
                 console.error('예상치 못한 데이터 구조:', data);
                 return;
             }
            
            // 카테고리별 필터링 적용
            
            if (currentCategory !== 'all') {
                // hotplace_category_id로 필터링 (1, 2, 3, 4)
                wishlistArray = wishlistArray.filter(item => {
                    return item.hotplace_category_id == currentCategory;
                });
            }
            
            if (!wishlistArray || wishlistArray.length === 0) {
                let message = '';
                if (currentCategory === 'all') {
                    message = '<span class="text-muted" style="font-size: 4rem;">💔</span>' +
                        '<h4 class="mt-3 text-muted">아직 찜한 장소가 없어요</h4>' +
                        '<p class="text-muted mb-4">마음에 드는 핫플레이스를 찜해보세요!</p>';
                } else {
                    // 카테고리별 메시지
                    let categoryDisplayName = '';
                    
                    if (currentCategory == 1) {
                        categoryDisplayName = '클럽';
                    } else if (currentCategory == 2) {
                        categoryDisplayName = '헌팅포차';
                    } else if (currentCategory == 3) {
                        categoryDisplayName = '라운지';
                    } else if (currentCategory == 4) {
                        categoryDisplayName = '포차거리';
                    } else {
                        categoryDisplayName = '선택된 카테고리';
                    }
                    
                    message = '<span class="text-muted" style="font-size: 4rem;">🔍</span>' +
                        '<h4 class="mt-3 text-muted">' + categoryDisplayName + ' 카테고리에 찜한 장소가 없습니다</h4>' +
                        '<p class="text-muted mb-4">다른 카테고리를 선택하거나 새로운 장소를 찜해보세요!</p>';
                }
                
                if (currentCategory === 'all') {
                    // 전체 카테고리일 때만 버튼들 표시
                    const allCategoryHtml = '<div class="text-center p-5">' +
                        '<div class="card border-0 shadow-sm">' +
                        '<div class="card-body p-5">' +
                        message +
                        '<div class="d-grid gap-2 d-md-flex justify-content-md-center">' +
                        '<a href="<%=root%>/" class="btn btn-primary btn-lg">' +
                        '🗺️ 핫플레이스 둘러보기' +
                        '</a>' +
                        '<a href="<%=root%>/mypage" class="btn btn-outline-secondary btn-lg">' +
                        '← 마이페이지로 돌아가기' +
                        '</a>' +
                        '</div>' +
                        '</div>' +
                        '</div>' +
                        '</div>';
                    container.html(allCategoryHtml);
                } else {
                    // 특정 카테고리일 때는 메시지만 표시
                    const categoryHtml = '<div class="text-center p-5">' +
                        '<div class="card border-0 shadow-sm">' +
                        '<div class="card-body p-5">' +
                        message +
                        '</div>' +
                        '</div>' +
                        '</div>';
                    container.html(categoryHtml);
                }
                
                return;
            }
            
            let html = '<div class="row g-3">';
            
                         wishlistArray.forEach(function(item, index) {
                
                // 카테고리별 헤더 클래스 결정
                let headerClass = 'card-header text-white text-center py-2';
                if (item.hotplace_category_id == 1) {
                    headerClass += ' category-club';
                } else if (item.hotplace_category_id == 2) {
                    headerClass += ' category-hunting';
                } else if (item.hotplace_category_id == 3) {
                    headerClass += ' category-lounge';
                } else if (item.hotplace_category_id == 4) {
                    headerClass += ' category-pocha';
                } else {
                    headerClass += ' bg-primary';
                }
                
                const itemHtml = '<div class="col-md-6 col-lg-4">' +
                    '<div class="card h-100 shadow-sm">' +
                    '<div class="' + headerClass + '">' +
                    '<h6 class="card-title mb-0">' + (item.hotplace_name || '장소명 없음') + '</h6>' +
                    '</div>' +
                    '<div class="card-body d-flex flex-column">' +
                    '<div class="mb-3">' +
                    '<div class="d-flex align-items-start mb-2">' +
                    '<small class="text-muted">' + (item.hotplace_address || '주소 정보 없음') + '</small>' +
                    '</div>' +
                    '<div class="d-flex align-items-center mb-2">' +
                    '<i class="bi bi-calendar3 text-muted me-2"></i>' +
                    '<small class="text-muted">찜한 날짜: <span class="wish-date" data-date="' + (item.wish_date || '') + '"></span></small>' +
                    '</div>' +
                    '<div class="d-flex align-items-center mb-3">' +
                    '<small class="text-muted">카테고리: ' + (item.category_name || '카테고리 정보 없음') + '</small>' +
                    '</div>' +
                    '</div>' +
                    
                                         // 개인 메모 섹션
                     '<div class="personal-note-section mb-3">' +
                     '<div class="d-flex align-items-start justify-content-between">' +
                     '<div class="flex-grow-1">' +
                     '<small class="text-muted d-block mb-1">나만의 메모</small>' +
                     '<div class="note-content" id="note-content-' + item.id + '">' +
                     (item.personal_note ? '<span class="note-text">' + item.personal_note + '</span>' : '<span class="note-placeholder">메모를 추가해보세요...</span>') +
                     '</div>' +
                     '</div>' +
                     (item.id && item.id > 0 && !isNaN(item.id) ? '<button class="btn btn-sm btn-outline-secondary ms-2" onclick="openNoteModal(' + item.id + ', \'' + (item.personal_note || '') + '\', \'' + (item.hotplace_name || '') + '\')" style="min-width: 32px; height: 32px; padding: 0;"><i class="bi bi-pencil"></i></button>' : '') +
                     '</div>' +
                     '</div>' +
                    
                    '<div class="mt-auto">' +
                    '<div class="d-grid gap-2">' +
                    '<button class="btn btn-primary btn-sm ' + headerClass.replace('card-header text-white text-center py-2', '').trim() + '" onclick="goToMainMap(' + (item.place_id || 0) + ')">' +
                    '<img src="<%=root%>/logo/gps.png" alt="GPS" style="width: 16px; height: 16px; margin-right: 5px;"> 지도에서 보기' +
                    '</button>' +
                    '<button class="btn btn-outline-danger btn-sm" onclick="removeWish(' + (item.id || 0) + ')">' +
                    '<i class="bi bi-heart-fill text-danger"></i> 찜 해제' +
                    '</button>' +
                    '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>';
                
                html += itemHtml;
            });
            
            html += '</div>';
            container.html(html);
            

            // 날짜 포맷팅 적용
            formatDates();
        }
        
        // 날짜 포맷팅 함수
        function formatDates() {
            $('.wish-date').each(function() {
                const dateStr = $(this).data('date');
                if (dateStr) {
                    try {
                        const date = new Date(dateStr);
                        if (!isNaN(date.getTime())) {
                            $(this).text(date.toLocaleDateString('ko-KR'));
                        } else {
                            $(this).text('날짜 정보 없음');
                        }
                    } catch (e) {
                        $(this).text('날짜 정보 없음');
                    }
                }
            });
        }
        
        // 페이지네이션 표시
        function displayPagination(data) {
            if (data.totalPages <= 1) {
                $('#pagination').hide();
                return;
            }
            
            const pagination = $('#pagination ul');
            let html = '';
            
            // 이전 페이지
            if (data.currentPage > 1) {
                html += `
                    <li class="page-item">
                        <a class="page-link" href="#" onclick="loadWishlist(${data.currentPage - 1})">
                            ←
                        </a>
                    </li>
                `;
            }
            
            // 페이지 번호들
            for (let i = 1; i <= data.totalPages; i++) {
                if (i === data.currentPage) {
                    html += `<li class="page-item active"><span class="page-link">${i}</span></li>`;
                } else {
                    html += `<li class="page-item"><a class="page-link" href="#" onclick="loadWishlist(${i})">${i}</a></li>`;
                }
            }
            
            // 다음 페이지
            if (data.currentPage < data.totalPages) {
                html += `
                    <li class="page-item">
                        <a class="page-link" href="#" onclick="loadWishlist(${data.currentPage + 1})">
                            →
                        </a>
                    </li>
                `;
            }
            
            pagination.html(html);
            $('#pagination').show();
        }
        
        // 찜 해제
        function removeWish(wishId) {
            if (!confirm('정말로 찜을 해제하시겠습니까?')) {
                return;
            }
            
            $.ajax({
                url: '<%=root%>/mypage/api/wishlist/' + wishId,
                method: 'DELETE',
                headers: getRequestHeaders(),
                success: function(response) {
                    alert(response.message);
                    // 찜 목록 다시 로드
                    loadWishlist(currentPage);
                },
                error: function(xhr, status, error) {
                    console.error('찜 해제 오류:', error);
                    if (xhr.responseJSON && xhr.responseJSON.error) {
                        alert('오류: ' + xhr.responseJSON.error);
                    } else {
                        alert('찜 해제 중 오류가 발생했습니다.');
                    }
                }
            });
        }
        
        // 장소로 이동
        function goToPlace(placeId) {
            // 해당 장소의 상세 정보를 모달로 표시
            showPlaceDetail(placeId);
        }
        
        // 장소 상세 정보 표시
        function showPlaceDetail(placeId) {
            // 찜 목록에서 해당 장소의 정보 찾기
            if (!wishlistData) {
                alert('찜 목록 데이터를 찾을 수 없습니다.');
                return;
            }
            
            // 데이터가 배열인지 객체인지 확인
            let wishlistArray = wishlistData;
            if (wishlistData.wishlist && Array.isArray(wishlistData.wishlist)) {
                wishlistArray = wishlistData.wishlist;
            } else if (!Array.isArray(wishlistData)) {
                alert('찜 목록 데이터 구조가 올바르지 않습니다.');
                return;
            }
            
            const wishItem = wishlistArray.find(item => item.place_id == placeId);
            if (!wishItem) {
                alert('찜 목록에서 해당 장소를 찾을 수 없습니다.');
                return;
            }
            
            $.ajax({
                url: '<%=root%>/api/hotplaces/' + placeId,
                method: 'GET',
                success: function(response) {
                    // 찜한 날짜 정보 추가
                    response.wish_date = wishItem.wish_date;
                    displayPlaceModal(response);
                },
                error: function(xhr, status, error) {
                    console.error('장소 정보 로드 오류:', error);
                    alert('장소 정보를 불러올 수 없습니다.');
                }
            });
        }
        
        // 장소 상세 모달 표시
        function displayPlaceModal(place) {
            const modalHtml = `
                <div class="modal fade" id="placeDetailModal" tabindex="-1" aria-labelledby="placeDetailModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="placeDetailModalLabel">\${place.name || '장소명 없음'}</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <h6>📍 주소</h6>
                                        <p>\${place.address || '주소 정보 없음'}</p>
                                        
                                        <h6>📅 찜한 날짜</h6>
                                        <p>\${place.wish_date ? formatDateForModal(place.wish_date) : '날짜 정보 없음'}</p>
                                    </div>
                                    <div class="col-md-6">
                                        <h6>🏷️ 카테고리</h6>
                                        <p>\${place.categoryName || '카테고리 정보 없음'}</p>
                                        
                                        <h6>⭐ 평점</h6>
                                        <p>\${place.rating || '평점 정보 없음'}</p>
                                    </div>
                                </div>
                                
                                <div class="mt-3">
                                    <h6>📝 설명</h6>
                                    <p>\${place.description || '설명 정보가 없습니다.'}</p>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
                                <button type="button" class="btn btn-primary" onclick="goToMainMap(\${place.id})">
                                    🗺️ 지도에서 보기
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            
            // 기존 모달 제거
            $('#placeDetailModal').remove();
            
            // 새 모달 추가
            $('body').append(modalHtml);
            
            // 모달 표시
            const modal = new bootstrap.Modal(document.getElementById('placeDetailModal'));
            modal.show();
        }
        
        // 메인 지도로 이동
        function goToMainMap(placeId) {
            if (!placeId || placeId === 0) {
                alert('장소 ID가 유효하지 않습니다.');
                return;
            }
            window.location.href = '<%=root%>/?placeId=' + placeId;
        }
        
        // 날짜 포맷팅 함수 (모달용)
        function formatDateForModal(dateStr) {
            if (!dateStr) return '날짜 정보 없음';
            try {
                const date = new Date(dateStr);
                if (!isNaN(date.getTime())) {
                    return date.toLocaleDateString('ko-KR');
                } else {
                    return '날짜 정보 없음';
                }
            } catch (e) {
                return '날짜 정보 없음';
            }
        }
        
                 // 메모 편집 모달 열기
         function openNoteModal(wishId, currentNote, placeName) {
             // wishId 검증
             if (!wishId || wishId === 'undefined' || wishId === 0 || isNaN(wishId)) {
                 console.error('유효하지 않은 위시리스트 ID:', wishId);
                 alert('유효하지 않은 위시리스트 ID입니다.');
                 return;
             }
             
             // 전역 변수에 wishId 저장
             window.currentWishId = wishId;
             
             const modalHtml = `
                 <div class="modal fade" id="noteEditModal" tabindex="-1" aria-labelledby="noteEditModalLabel" aria-hidden="true">
                     <div class="modal-dialog">
                         <div class="modal-content">
                             <div class="modal-header">
                                 <h5 class="modal-title" id="noteEditModalLabel">
                                     💭 ${placeName} - 나만의 메모
                                 </h5>
                                 <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                             </div>
                             <div class="modal-body">
                                 <div class="mb-3">
                                     <label for="noteText" class="form-label">메모 내용 (20자 이내)</label>
                                     <textarea class="form-control" id="noteText" rows="3" maxlength="20" placeholder="이 장소에 대한 나만의 메모를 작성해보세요..." style="resize: none; white-space: pre-wrap; word-wrap: break-word; overflow-wrap: break-word;"></textarea>
                                     <div class="form-text">
                                         <span id="charCount">0</span>/20
                                     </div>
                                 </div>
                             </div>
                             <div class="modal-footer">
                                 <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                                 <button type="button" class="btn btn-primary" onclick="saveNote()">저장</button>
                             </div>
                         </div>
                     </div>
                 </div>
             `;
            
            // 기존 모달 제거
            $('#noteEditModal').remove();
            
            // 새 모달 추가
            $('body').append(modalHtml);
            
            // 모달 표시
            const modal = new bootstrap.Modal(document.getElementById('noteEditModal'));
            modal.show();
            
            // 글자 수 카운터
            $('#noteText').on('input', function() {
                const length = $(this).val().length;
                $('#charCount').text(length);
                
                if (length > 20) {
                    $('#charCount').addClass('text-danger');
                } else {
                    $('#charCount').removeClass('text-danger');
                }
            });
            
            // 모달이 열릴 때 기존 메모가 있으면 글자 수 표시
            if (currentNote && currentNote.trim() !== '') {
                $('#noteText').val(currentNote);
                $('#charCount').text(currentNote.length);
                if (currentNote.length > 20) {
                    $('#charCount').addClass('text-danger');
                }
            }
            
            // 모달이 닫힐 때 전역 변수 정리
            $('#noteEditModal').on('hidden.bs.modal', function() {
                window.currentWishId = null;
            });
        }
        
                 // 메모 저장
         function saveNote() {
            // wishId 검증
            if (!window.currentWishId || window.currentWishId === 'undefined' || window.currentWishId === 0 || isNaN(window.currentWishId)) {
                console.error('유효하지 않은 위시리스트 ID:', window.currentWishId);
                alert('유효하지 않은 위시리스트 ID입니다.');
                return;
            }
            
            const noteText = $('#noteText').val().trim();
            
            if (noteText.length > 20) {
                alert('메모는 20자 이내로 작성해주세요.');
                return;
            }
            
            $.ajax({
                url: '<%=root%>/mypage/api/wishlist/' + window.currentWishId + '/note',
                method: 'PUT',
                headers: getRequestHeaders(),
                contentType: 'application/json',
                data: JSON.stringify({
                    personal_note: noteText
                }),
                success: function(response) {
                    // 모달 닫기
                    $('#noteEditModal').modal('hide');
                    
                    // 성공 메시지
                    if (noteText) {
                        alert('메모가 저장되었습니다!');
                    } else {
                        alert('메모가 삭제되었습니다.');
                    }
                    
                    // 찜 목록 다시 로드하여 업데이트된 메모 표시
                    loadWishlist(currentPage);
                },
                error: function(xhr, status, error) {
                    console.error('메모 저장 오류:', error);
                    if (xhr.responseJSON && xhr.responseJSON.error) {
                        alert('오류: ' + xhr.responseJSON.error);
                    } else {
                        alert('메모 저장 중 오류가 발생했습니다.');
                    }
                }
            });
        }
    </script>
</div>
