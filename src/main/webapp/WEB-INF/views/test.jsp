<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>테스트 페이지</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background-color: #f0f0f0;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .success {
            color: #28a745;
            font-size: 18px;
            text-align: center;
            margin: 20px 0;
        }
        .info {
            background: #e7f3ff;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 테스트 페이지</h1>
        <div class="success">
            Spring Boot 애플리케이션이 정상적으로 작동하고 있습니다!
        </div>
        <div class="info">
            <strong>메시지:</strong> ${message}
        </div>
        <div class="info">
            <strong>현재 시간:</strong> <%= new java.util.Date() %>
        </div>
        <div class="info">
            <strong>서버 정보:</strong> Spring Boot 3.5.4
        </div>
        <p style="text-align: center; margin-top: 30px;">
            <a href="/" style="color: #007bff; text-decoration: none;">← 메인 페이지로 돌아가기</a>
        </p>
    </div>
</body>
</html>
