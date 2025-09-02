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
import java.util.Collections;

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
                    authority = new SimpleGrantedAuthority("ROLE_ADMIN");
                } else {
                    authority = new SimpleGrantedAuthority("ROLE_USER");
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
        String headerAuth = request.getHeader("Authorization");
        
        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }
        
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
