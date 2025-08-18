<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 - 서버 오류</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container">
        <div class="row justify-content-center align-items-center min-vh-100">
            <div class="col-md-6 text-center">
                <h1 class="display-1 text-danger">500</h1>
                <h2 class="mb-4">서버 내부 오류</h2>
                <p class="lead mb-4">일시적인 서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.</p>
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary">홈으로 돌아가기</a>
            </div>
        </div>
    </div>
</body>
</html>
