package com.wherehot.spring.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.Collections;
import jakarta.servlet.http.Cookie;

/**
 * JWT 인증 필터
 */
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    
    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);
    
    @Autowired
    private JwtUtils jwtUtils;
    
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, 
                                  FilterChain filterChain) throws ServletException, IOException {
        
        // OAuth2 관련 요청은 JWT 필터를 건너뛰기
        String requestURI = request.getRequestURI();
        if (requestURI.startsWith("/oauth2/") || requestURI.startsWith("/login/oauth2/")) {
            logger.info("OAuth2 요청으로 JWT 필터 건너뛰기: {}", requestURI);
            filterChain.doFilter(request, response);
            return;
        }
        
        try {
            String jwt = parseJwt(request);
            logger.info("JWT 인증 필터 - 요청 경로: {}, JWT 토큰: {}", request.getRequestURI(), jwt != null ? "있음" : "없음");
            
            if (jwt != null && jwtUtils.validateToken(jwt)) {
                // 블랙리스트 확인
                if (isTokenBlacklisted(jwt)) {
                    logger.warn("Blacklisted token attempted: {}", jwt.substring(0, 20) + "...");
                    filterChain.doFilter(request, response);
                    return;
                }
                
                String userid = jwtUtils.getUseridFromToken(jwt);
                String provider = jwtUtils.getClaimsFromToken(jwt).get("provider", String.class);
                
                logger.info("JWT 인증 성공 - 사용자 ID: {}, 제공자: {}", userid, provider);
                
                // 권한 설정
                SimpleGrantedAuthority authority;
                if ("admin".equals(provider)) {
                    authority = new SimpleGrantedAuthority("ADMIN");
                } else {
                    authority = new SimpleGrantedAuthority("USER");
                }
                
                UsernamePasswordAuthenticationToken authentication = 
                    new UsernamePasswordAuthenticationToken(userid, null, Collections.singletonList(authority));
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                
                SecurityContextHolder.getContext().setAuthentication(authentication);
                logger.info("SecurityContext에 인증 정보 설정 완료: {}", userid);
                
                // 사용자 정보를 request attribute에 추가
                request.setAttribute("userid", userid);
                request.setAttribute("provider", provider);
            } else {
                logger.info("JWT 토큰이 없거나 유효하지 않음");
            }
        } catch (Exception e) {
            logger.error("Cannot set user authentication: {}", e.getMessage());
        }
        
        filterChain.doFilter(request, response);
    }
    
    /**
     * 요청에서 JWT 토큰 추출
     */
    private String parseJwt(HttpServletRequest request) {
        // 1. HTTP 헤더에서 Authorization Bearer 토큰 확인
        String headerAuth = request.getHeader("Authorization");
        
        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            logger.info("HTTP 헤더에서 JWT 토큰 발견");
            return headerAuth.substring(7);
        }
        
        // 2. 쿠키에서 accessToken 확인 (브라우저 직접 접근 시)
        jakarta.servlet.http.Cookie[] cookies = request.getCookies();
        logger.info("쿠키 개수: {}", cookies != null ? cookies.length : 0);
        
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                logger.info("쿠키 이름: {}, 값: {}", cookie.getName(), 
                    (cookie.getValue() != null && cookie.getValue().length() > 20) ? 
                    cookie.getValue().substring(0, 20) + "..." : 
                    cookie.getValue());
                
                if ("accessToken".equals(cookie.getName())) {
                    String token = cookie.getValue();
                    if (StringUtils.hasText(token)) {
                        try {
                            // 서버에서 설정한 쿠키는 URL 인코딩되지 않았으므로 디코딩 불필요
                            logger.info("쿠키에서 JWT 토큰 발견 - 길이: {}", token.length());
                            return token;
                        } catch (IllegalArgumentException e) {
                            logger.error("쿠키 토큰 처리 실패 (IllegalArgumentException): {}", e.getMessage());
                        }
                    } else {
                        logger.warn("accessToken 쿠키 값이 비어있음");
                    }
                }
            }
        } else {
            logger.info("쿠키가 없음");
        }
        
        logger.info("JWT 토큰을 찾을 수 없음");
        return null;
    }
    
    /**
     * 토큰이 블랙리스트에 있는지 확인
     */
    private boolean isTokenBlacklisted(String token) {
        try {
            String blacklistKey = "blacklist_token:" + token;
            return redisTemplate.hasKey(blacklistKey);
        } catch (Exception e) {
            logger.warn("Error checking token blacklist: {}", e.getMessage());
            // Redis 연결 실패 시 블랙리스트 체크를 건너뛰고 false 반환
            // 이렇게 하면 Redis가 없어도 JWT 토큰 검증이 가능
            return false;
        }
    }
}
