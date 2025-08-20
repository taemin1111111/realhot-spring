<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시글 작성 - WhereHot</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        .post-form-container { margin-top: 30px; }
        .form-floating textarea { min-height: 150px; }
    </style>
</head>
<body>
    <div class="container post-form-container">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0"><i class="bi bi-pencil-square"></i> 새 게시글 작성</h5>
                    </div>
                    <div class="card-body">
                        <form id="postForm" enctype="multipart/form-data">
                            <div class="mb-3">
                                <label class="form-label">카테고리</label>
                                <select class="form-select" id="categoryId" name="categoryId" required>
                                    <option value="">카테고리를 선택하세요</option>
                                </select>
                            </div>
                            
                            <div class="form-floating mb-3">
                                <input type="text" class="form-control" id="title" name="title" placeholder="제목을 입력하세요" required maxlength="200">
                                <label for="title">제목</label>
                            </div>
                            
                            <div class="form-floating mb-3">
                                <textarea class="form-control" id="content" name="content" placeholder="내용을 입력하세요" required></textarea>
                                <label for="content">내용</label>
                            </div>
                            
                            <!-- 3개 사진 업로드 (Model1 호환) -->
                            <div class="mb-3">
                                <label class="form-label">사진 첨부 (선택사항, 최대 3개)</label>
                                <div class="row">
                                    <div class="col-md-4">
                                        <label for="photo1" class="form-label">사진 1</label>
                                        <input type="file" class="form-control" id="photo1" name="photo1" accept="image/*">
                                    </div>
                                    <div class="col-md-4">
                                        <label for="photo2" class="form-label">사진 2</label>
                                        <input type="file" class="form-control" id="photo2" name="photo2" accept="image/*">
                                    </div>
                                    <div class="col-md-4">
                                        <label for="photo3" class="form-label">사진 3</label>
                                        <input type="file" class="form-control" id="photo3" name="photo3" accept="image/*">
                                    </div>
                                </div>
                            </div>
                            
                            <!-- 익명 작성 옵션 -->
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="isAnonymous">
                                        <label class="form-check-label" for="isAnonymous">
                                            익명으로 작성
                                        </label>
                                    </div>
                                </div>
                                <div class="col-md-6" id="anonymousFields" style="display: none;">
                                    <div class="row">
                                        <div class="col-6">
                                            <input type="text" class="form-control" id="nickname" name="nickname" placeholder="닉네임">
                                        </div>
                                        <div class="col-6">
                                            <input type="password" class="form-control" id="password" name="password" placeholder="비밀번호">
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <button type="button" class="btn btn-secondary" onclick="history.back()">
                                    <i class="bi bi-arrow-left"></i> 취소
                                </button>
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-check-lg"></i> 게시글 작성
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // 페이지 로드시 초기화
        $(document).ready(function() {
            loadCategories();
            
            // 익명 작성 체크박스 이벤트
            $('#isAnonymous').change(function() {
                if (this.checked) {
                    $('#anonymousFields').show();
                    $('#nickname, #password').prop('required', true);
                } else {
                    $('#anonymousFields').hide();
                    $('#nickname, #password').prop('required', false);
                }
            });
            
            // 폼 제출 이벤트
            $('#postForm').submit(function(e) {
                e.preventDefault();
                submitPost();
            });
        });

        // 카테고리 목록 로드
        function loadCategories() {
            $.ajax({
                url: '<%=root%>/api/community/categories',
                method: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.success && response.categories) {
                        let options = '<option value="">카테고리를 선택하세요</option>';
                        response.categories.forEach(function(category) {
                            options += '<option value="' + category.id + '">' + category.name + '</option>';
                        });
                        $('#categoryId').html(options);
                    } else {
                        // 기본 카테고리 (API 미구현시)
                        $('#categoryId').html(`
                            <option value="">카테고리를 선택하세요</option>
                            <option value="1">자유게시판</option>
                            <option value="2">질문/답변</option>
                            <option value="3">정보공유</option>
                        `);
                    }
                },
                error: function() {
                    // 기본 카테고리
                    $('#categoryId').html(`
                        <option value="">카테고리를 선택하세요</option>
                        <option value="1">자유게시판</option>
                        <option value="2">질문/답변</option>
                        <option value="3">정보공유</option>
                    `);
                }
            });
        }

        // 게시글 작성 제출
        function submitPost() {
            const formData = new FormData();
            
            // 기본 필드 추가
            formData.append('categoryId', $('#categoryId').val());
            formData.append('title', $('#title').val());
            formData.append('content', $('#content').val());
            
            // 익명 작성 처리
            if ($('#isAnonymous').is(':checked')) {
                formData.append('nickname', $('#nickname').val());
                formData.append('password', $('#password').val());
            }
            
            // 3개 사진 파일 추가 (Model1 호환)
            const photo1 = $('#photo1')[0].files[0];
            const photo2 = $('#photo2')[0].files[0];
            const photo3 = $('#photo3')[0].files[0];
            
            if (photo1) formData.append('photo1', photo1);
            if (photo2) formData.append('photo2', photo2);
            if (photo3) formData.append('photo3', photo3);
            
            // API 호출
            $.ajax({
                url: '<%=root%>/api/community/posts',
                method: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    if (response.success) {
                        alert('게시글이 성공적으로 작성되었습니다!');
                        window.location.href = '<%=root%>/WEB-INF/views/community/cumain.jsp';
                    } else {
                        alert('오류: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    console.error('게시글 작성 오류:', error);
                    alert('게시글 작성 중 오류가 발생했습니다: ' + error);
                }
            });
        }
    </script>
</body>
</html>