 package com.wherehot.spring.security;

import com.wherehot.spring.entity.Member;
import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.util.StringUtils;

/**
 * JWT 토큰 유틸리티 클래스
 */
@Component
public class JwtUtils {
    
    private static final Logger logger = LoggerFactory.getLogger(JwtUtils.class);
    
    @Value("${app.jwt.secret:mySecretKey}")
    private String jwtSecret;
    
    @Value("${app.jwt.expiration:86400}")  // 24시간
    private int jwtExpirationMs;
    
    @Value("${app.jwt.refresh-expiration:604800}")  // 7일
    private int refreshExpirationMs;
    
    /**
     * JWT 서명 키 생성
     */
    private Key getSigningKey() {
        logger.info("JWT Secret length: {} characters", jwtSecret.length());
        byte[] keyBytes = jwtSecret.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        logger.info("Key bytes length: {} bytes ({} bits)", keyBytes.length, keyBytes.length * 8);
        return Keys.hmacShaKeyFor(keyBytes);
    }
    
    /**
     * 액세스 토큰 생성
     */
    public String generateAccessToken(Member member) {
        return generateToken(member, jwtExpirationMs);
    }
    
    /**
     * 리프레시 토큰 생성
     */
    public String generateRefreshToken(Member member) {
        return generateToken(member, refreshExpirationMs);
    }
    
    /**
     * JWT 토큰 생성
     */
    private String generateToken(Member member, int expiration) {
        Date expiryDate = new Date(System.currentTimeMillis() + expiration * 1000L);
        
        return Jwts.builder()
                .setSubject(member.getUserid())
                .claim("nickname", member.getNickname())
                .claim("email", member.getEmail())
                .claim("provider", member.getProvider())
                .claim("status", member.getStatus())
                .setIssuedAt(new Date())
                .setExpiration(expiryDate)
                .signWith(getSigningKey(), SignatureAlgorithm.HS512)
                .compact();
    }
    
    /**
     * JWT 토큰에서 사용자 ID 추출
     */
    public String getUseridFromToken(String token) {
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
        
        return claims.getSubject();
    }
    
    /**
     * JWT 토큰에서 provider 추출
     */
    public String getProviderFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        return claims.get("provider", String.class);
    }
    
    /**
     * JWT 토큰에서 status 추출
     */
    public String getStatusFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        return claims.get("status", String.class);
    }
    
    /**
     * JWT 토큰에서 클레임 추출
     */
    public Claims getClaimsFromToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
    
    /**
     * JWT 토큰 유효성 검증
     */
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token);
            return true;
        } catch (SecurityException e) {
            logger.error("Invalid JWT signature: {}", e.getMessage());
        } catch (MalformedJwtException e) {
            logger.error("Invalid JWT token: {}", e.getMessage());
        } catch (ExpiredJwtException e) {
            logger.error("JWT token is expired: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            logger.error("JWT token is unsupported: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            logger.error("JWT claims string is empty: {}", e.getMessage());
        }
        return false;
    }
    
    /**
     * JWT 토큰 만료 시간 조회
     */
    public Date getExpirationFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        return claims.getExpiration();
    }
    
    /**
     * JWT 토큰이 만료되었는지 확인
     */
    public boolean isTokenExpired(String token) {
        Date expiration = getExpirationFromToken(token);
        return expiration.before(new Date());
    }
    
    /**
     * 토큰에서 Member 객체 생성
     */
    public Member getMemberFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        
        Member member = new Member();
        member.setUserid(claims.getSubject());
        member.setNickname(claims.get("nickname", String.class));
        member.setEmail(claims.get("email", String.class));
        member.setProvider(claims.get("provider", String.class));
        member.setStatus(claims.get("status", String.class));
        
        return member;
    }
    
    /**
     * HttpServletRequest에서 JWT 토큰 추출
     */
    public String getTokenFromRequest(HttpServletRequest request) {
        return parseJwt(request);
    }
    
    /**
     * JWT 토큰 파싱 (Authorization 헤더에서 Bearer 토큰 추출)
     */
    private String parseJwt(HttpServletRequest request) {
        String headerAuth = request.getHeader("Authorization");
        
        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }
        
        return null;
    }
    
    /**
     * JWT 토큰에서 사용자 ID 추출 (getUseridFromToken과 동일하지만 이름 통일)
     */
    public String getUserIdFromToken(String token) {
        return getUseridFromToken(token);
    }
}
