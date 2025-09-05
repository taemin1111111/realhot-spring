package com.wherehot.spring.security;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.oauth2.client.web.AuthorizationRequestRepository;
import org.springframework.security.oauth2.core.endpoint.OAuth2AuthorizationRequest;
import org.springframework.stereotype.Component;
import java.io.*;
import java.util.Base64;

/**
 * OAuth2 인증 요청을 세션에 저장하는 커스텀 리포지토리
 */
@Component
public class CustomAuthorizationRequestRepository implements AuthorizationRequestRepository<OAuth2AuthorizationRequest> {
    
    private static final Logger logger = LoggerFactory.getLogger(CustomAuthorizationRequestRepository.class);
    
    private static final String DEFAULT_AUTHORIZATION_REQUEST_ATTR_NAME = 
            CustomAuthorizationRequestRepository.class.getName() + ".AUTHORIZATION_REQUEST";
    
    private final String sessionAttributeName = DEFAULT_AUTHORIZATION_REQUEST_ATTR_NAME;
    
    @Override
    public OAuth2AuthorizationRequest loadAuthorizationRequest(HttpServletRequest request) {
        logger.info("Loading authorization request from cookie");
        
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("OAUTH2_AUTH_REQUEST".equals(cookie.getName())) {
                    try {
                        byte[] data = Base64.getDecoder().decode(cookie.getValue());
                        ByteArrayInputStream bais = new ByteArrayInputStream(data);
                        ObjectInputStream ois = new ObjectInputStream(bais);
                        OAuth2AuthorizationRequest authRequest = (OAuth2AuthorizationRequest) ois.readObject();
                        ois.close();
                        logger.info("Found authorization request in cookie: {}", authRequest.getState());
                        return authRequest;
                    } catch (Exception e) {
                        logger.error("Failed to deserialize authorization request: {}", e.getMessage());
                    }
                }
            }
        }
        
        logger.warn("No authorization request found in cookie");
        return null;
    }
    
    @Override
    public void saveAuthorizationRequest(OAuth2AuthorizationRequest authorizationRequest, 
                                       HttpServletRequest request, HttpServletResponse response) {
        logger.info("Saving authorization request to cookie: {}", 
                   authorizationRequest != null ? authorizationRequest.getState() : "null");
        
        if (authorizationRequest == null) {
            // 쿠키 삭제
            Cookie cookie = new Cookie("OAUTH2_AUTH_REQUEST", "");
            cookie.setMaxAge(0);
            cookie.setPath("/");
            cookie.setHttpOnly(true);
            response.addCookie(cookie);
            logger.info("Removed authorization request cookie");
        } else {
            // 쿠키에 저장
            try {
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                ObjectOutputStream oos = new ObjectOutputStream(baos);
                oos.writeObject(authorizationRequest);
                oos.close();
                
                String serializedRequest = Base64.getEncoder().encodeToString(baos.toByteArray());
                Cookie cookie = new Cookie("OAUTH2_AUTH_REQUEST", serializedRequest);
                cookie.setMaxAge(300); // 5분
                cookie.setPath("/");
                cookie.setHttpOnly(true);
                response.addCookie(cookie);
                logger.info("Stored authorization request in cookie");
            } catch (Exception e) {
                logger.error("Failed to serialize authorization request: {}", e.getMessage());
            }
        }
    }
    
    @Override
    public OAuth2AuthorizationRequest removeAuthorizationRequest(HttpServletRequest request, 
                                                               HttpServletResponse response) {
        logger.debug("Removing authorization request from cookie");
        
        OAuth2AuthorizationRequest authRequest = this.loadAuthorizationRequest(request);
        if (authRequest != null) {
            // 쿠키 삭제
            Cookie cookie = new Cookie("OAUTH2_AUTH_REQUEST", "");
            cookie.setMaxAge(0);
            cookie.setPath("/");
            cookie.setHttpOnly(true);
            response.addCookie(cookie);
        }
        
        return authRequest;
    }
}
