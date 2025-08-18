<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WhereHot - 오류가 발생했습니다</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
    <style>
        .error-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .error-card {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 3rem;
            text-align: center;
            max-width: 500px;
            width: 100%;
            margin: 1rem;
        }
        .error-icon {
            font-size: 5rem;
            margin-bottom: 1rem;
            opacity: 0.8;
        }
        .btn-home {
            background: rgba(255, 255, 255, 0.2);
            border: 2px solid rgba(255, 255, 255, 0.3);
            color: white;
            padding: 12px 30px;
            border-radius: 50px;
            transition: all 0.3s ease;
        }
        .btn-home:hover {
            background: rgba(255, 255, 255, 0.3);
            color: white;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-card">
            <i class="bi bi-exclamation-triangle-fill error-icon"></i>
            <h1 class="mb-3">${errorTitle != null ? errorTitle : '오류가 발생했습니다'}</h1>
            <p class="mb-4">
                ${errorDescription != null ? errorDescription : '죄송합니다. 일시적인 오류가 발생했습니다.<br>잠시 후 다시 시도해주세요.'}
            </p>
            <% if (request.getAttribute("statusCode") != null) { %>
            <div class="mb-3">
                <small class="text-light">
                    오류 코드: ${statusCode} - ${errorMessage}
                </small>
            </div>
            <% } %>
            <div class="mb-3">
                <small class="text-light">
                    오류 시간: <%= new java.util.Date() %>
                </small>
            </div>
            <a href="${pageContext.request.contextPath}/" class="btn btn-home">
                <i class="bi bi-house-fill me-2"></i>홈으로 돌아가기
            </a>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
