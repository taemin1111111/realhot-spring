package com.wherehot.spring.security;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

/**
 * 커스텀 OAuth2 사용자 서비스
 */
@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {
    
    private static final Logger logger = LoggerFactory.getLogger(CustomOAuth2UserService.class);
    
    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        
        try {
            String registrationId = userRequest.getClientRegistration().getRegistrationId();
            logger.info("OAuth2 user loaded: registrationId={}", registrationId);
            
            return oAuth2User;
            
        } catch (Exception ex) {
            logger.error("Error occurred while loading OAuth2 user", ex);
            throw new OAuth2AuthenticationException("OAuth2 사용자 정보 로드 중 오류가 발생했습니다.");
        }
    }
}
