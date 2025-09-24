package com.wherehot.spring.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.web.header.writers.ReferrerPolicyHeaderWriter;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * 보안 헤더 설정
 * 배포 환경에서 보안을 강화하기 위한 HTTP 헤더 추가
 */
@Configuration
public class SecurityHeadersConfig {

    @Bean
    public OncePerRequestFilter securityHeadersFilter() {
        return new OncePerRequestFilter() {
            @Override
            protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, 
                                          FilterChain filterChain) throws ServletException, IOException {
                
                // X-Content-Type-Options: MIME 타입 스니핑 방지
                response.setHeader("X-Content-Type-Options", "nosniff");
                
                // X-Frame-Options: 클릭재킹 방지
                response.setHeader("X-Frame-Options", "DENY");
                
                // X-XSS-Protection: XSS 공격 방지
                response.setHeader("X-XSS-Protection", "1; mode=block");
                
                // Strict-Transport-Security: HTTPS 강제 (HTTPS 환경에서만)
                if (request.isSecure()) {
                    response.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
                }
                
                // Content-Security-Policy: XSS 및 코드 인젝션 방지 (카카오맵 API 허용)
                response.setHeader("Content-Security-Policy", 
                    "default-src 'self' *; " +
                    "script-src 'self' 'unsafe-inline' 'unsafe-eval' *; " +
                    "style-src 'self' 'unsafe-inline' *; " +
                    "img-src 'self' data: *; " +
                    "font-src 'self' *; " +
                    "connect-src 'self' *; " +
                    "frame-ancestors 'none'; " +
                    "base-uri 'self'; " +
                    "form-action 'self'");
                
                // Referrer-Policy: 리퍼러 정보 제한
                response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
                
                // Permissions-Policy: 브라우저 기능 제한
                response.setHeader("Permissions-Policy", 
                    "geolocation=(), " +
                    "microphone=(), " +
                    "camera=(), " +
                    "payment=(), " +
                    "usb=(), " +
                    "magnetometer=(), " +
                    "gyroscope=(), " +
                    "speaker=(), " +
                    "vibrate=(), " +
                    "fullscreen=(self), " +
                    "sync-xhr=()");
                
                // Cache-Control: 민감한 정보 캐싱 방지
                if (request.getRequestURI().contains("/api/") || 
                    request.getRequestURI().contains("/mypage/") ||
                    request.getRequestURI().contains("/admin/")) {
                    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, private");
                    response.setHeader("Pragma", "no-cache");
                    response.setHeader("Expires", "0");
                }
                
                filterChain.doFilter(request, response);
            }
        };
    }
}
