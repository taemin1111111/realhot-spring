package com.wherehot.spring.controller;

import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 전역 에러 처리 컨트롤러 - 프로덕션 레벨 에러 핸들링
 */
@Controller
public class GlobalErrorController implements ErrorController {

    private static final Logger logger = LoggerFactory.getLogger(GlobalErrorController.class);

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request, Model model) {
        // 에러 상태 코드 가져오기
        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        
        if (status != null) {
            Integer statusCode = Integer.valueOf(status.toString());
            
            // 에러 정보 로깅 (운영 환경에서 디버깅용)
            String requestUri = (String) request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI);
            String errorMessage = (String) request.getAttribute(RequestDispatcher.ERROR_MESSAGE);
            Exception exception = (Exception) request.getAttribute(RequestDispatcher.ERROR_EXCEPTION);
            
            logger.error("Error occurred - Status: {}, URI: {}, Message: {}", 
                        statusCode, requestUri, errorMessage, exception);
            
            // 클라이언트에는 안전한 정보만 전달
            model.addAttribute("statusCode", statusCode);
            model.addAttribute("errorMessage", getErrorMessage(statusCode));
            
            // 특정 에러 코드에 따른 처리
            if (statusCode == HttpStatus.NOT_FOUND.value()) {
                model.addAttribute("errorTitle", "페이지를 찾을 수 없습니다");
                model.addAttribute("errorDescription", "요청하신 페이지가 존재하지 않거나 이동되었습니다.");
            } else if (statusCode == HttpStatus.INTERNAL_SERVER_ERROR.value()) {
                model.addAttribute("errorTitle", "서버 오류가 발생했습니다");
                model.addAttribute("errorDescription", "일시적인 서버 오류입니다. 잠시 후 다시 시도해주세요.");
            } else if (statusCode == HttpStatus.FORBIDDEN.value()) {
                model.addAttribute("errorTitle", "접근이 거부되었습니다");
                model.addAttribute("errorDescription", "이 페이지에 접근할 권한이 없습니다.");
            } else {
                model.addAttribute("errorTitle", "오류가 발생했습니다");
                model.addAttribute("errorDescription", "예기치 않은 오류가 발생했습니다.");
            }
        } else {
            // 상태 코드가 없는 경우 기본 처리
            model.addAttribute("statusCode", 500);
            model.addAttribute("errorTitle", "오류가 발생했습니다");
            model.addAttribute("errorDescription", "일시적인 오류가 발생했습니다.");
            model.addAttribute("errorMessage", "알 수 없는 오류");
        }
        
        return "error";
    }
    
    private String getErrorMessage(int statusCode) {
        switch (statusCode) {
            case 400:
                return "잘못된 요청입니다";
            case 401:
                return "인증이 필요합니다";
            case 403:
                return "접근이 거부되었습니다";
            case 404:
                return "페이지를 찾을 수 없습니다";
            case 405:
                return "허용되지 않는 메서드입니다";
            case 500:
                return "서버 내부 오류가 발생했습니다";
            case 502:
                return "잘못된 게이트웨이입니다";
            case 503:
                return "서비스를 사용할 수 없습니다";
            default:
                return "오류가 발생했습니다";
        }
    }
}
