package com.wherehot.spring.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * OAuth2 로그인 실패 처리
 */
@Component
public class OAuth2AuthenticationFailureHandler extends SimpleUrlAuthenticationFailureHandler {
    
    private static final Logger logger = LoggerFactory.getLogger(OAuth2AuthenticationFailureHandler.class);
    
    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
                                      AuthenticationException exception) throws IOException, ServletException {
        
        logger.error("OAuth2 authentication failed: {}", exception.getMessage());
        
        String errorMessage = "OAuth2 로그인에 실패했습니다.";
        
        if (exception.getMessage().contains("access_denied")) {
            errorMessage = "OAuth2 인증이 취소되었습니다.";
        } else if (exception.getMessage().contains("invalid_request")) {
            errorMessage = "잘못된 OAuth2 요청입니다.";
        }
        
        response.sendRedirect("/?error=" + errorMessage);
    }
}
