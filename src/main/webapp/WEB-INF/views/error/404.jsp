<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - 페이지를 찾을 수 없습니다</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container">
        <div class="row justify-content-center align-items-center min-vh-100">
            <div class="col-md-6 text-center">
                <h1 class="display-1 text-primary">404</h1>
                <h2 class="mb-4">페이지를 찾을 수 없습니다</h2>
                <p class="lead mb-4">요청하신 페이지가 존재하지 않거나 이동되었을 수 있습니다.</p>
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary">홈으로 돌아가기</a>
            </div>
        </div>
    </div>
</body>
</html>
