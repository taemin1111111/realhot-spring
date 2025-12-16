package com.wherehot.spring.security;

import com.wherehot.spring.entity.Member;
import com.wherehot.spring.mapper.MemberMapper;
import com.wherehot.spring.security.JwtUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

import java.util.Map;
import java.util.Optional;

/**
 * OAuth2 로그인 성공 처리
 */
@Component
public class OAuth2AuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {
    
    private static final Logger logger = LoggerFactory.getLogger(OAuth2AuthenticationSuccessHandler.class);
    
    @Autowired
    private MemberMapper memberMapper;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                      Authentication authentication) throws IOException, ServletException {
        
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
        
        try {
            // 네이버 사용자 정보 추출
            Map<String, Object> attributes = oAuth2User.getAttributes();
            logger.info("OAuth2 attributes: {}", attributes);
            
            // 네이버 응답 구조: {response: {id, name, email, ...}}
            @SuppressWarnings("unchecked")
            Map<String, Object> responseMap = (Map<String, Object>) attributes.get("response");
            
            if (responseMap == null) {
                logger.error("No response data in OAuth2 attributes");
                response.sendRedirect("/error?msg=oauth2_no_response");
                return;
            }
            
            String naverId = (String) responseMap.get("id");
            String name = (String) responseMap.get("name");
            String email = (String) responseMap.get("email");
            String gender = (String) responseMap.get("gender");
            String profileImage = (String) responseMap.get("profile_image");
            
            logger.info("Naver user info - ID: {}, Name: {}, Email: {}", naverId, name, email);
            
            // 기존 회원 확인
            Optional<Member> memberOpt = memberMapper.findByUserid(naverId);
            
            if (memberOpt.isPresent()) {
                // 기존 회원 - 로그인 처리
                Member member = memberOpt.get();
                
                if (!member.isActive()) {
                    logger.warn("Suspended account attempted OAuth2 login: {}", naverId);
                    response.sendRedirect("/error?msg=suspended");
                    return;
                }
                
                // 로그인 정보 업데이트
                member.updateLoginInfo();
                memberMapper.updateLoginInfo(member);
                
                // JWT 토큰 생성
                String accessToken = jwtUtils.generateAccessToken(member);
                String refreshToken = jwtUtils.generateRefreshToken(member);
                
                // 쿠키 설정 (일반 로그인과 동일한 방식)
                ResponseCookie accessTokenCookie = ResponseCookie.from("accessToken", accessToken)
                        .httpOnly(true)
                        .secure(false) // 개발 환경에서는 false
                        .path("/")
                        .maxAge(24 * 60 * 60) // 1일
                        .build();

                ResponseCookie refreshTokenCookie = ResponseCookie.from("refreshToken", refreshToken)
                        .httpOnly(true)
                        .secure(false) // 개발 환경에서는 false
                        .path("/")
                        .maxAge(7 * 24 * 60 * 60) // 7일
                        .build();
                
                // 응답 헤더에 쿠키 추가
                response.addHeader(HttpHeaders.SET_COOKIE, accessTokenCookie.toString());
                response.addHeader(HttpHeaders.SET_COOKIE, refreshTokenCookie.toString());
                
                // 세션 정리 (쿠키 기반으로 변경되어 불필요)
                // request.getSession().invalidate();
                
                // 프론트엔드로 토큰과 함께 리다이렉트 (URL 인코딩 적용)
                String redirectUrl = String.format("/?token=%s&userid=%s&nickname=%s&provider=%s&email=%s", 
                                                  accessToken, member.getUserid(), 
                                                  java.net.URLEncoder.encode(member.getNickname(), "UTF-8"),
                                                  member.getProvider(), 
                                                  java.net.URLEncoder.encode(member.getEmail(), "UTF-8"));
                response.sendRedirect(redirectUrl);
                
                logger.info("OAuth2 login successful for existing user: {}", naverId);
                
            } else {
                // 신규 회원 - 추가 정보 입력 페이지로 이동
                request.getSession().setAttribute("oAuth2_naverId", naverId);
                request.getSession().setAttribute("oAuth2_name", name);
                request.getSession().setAttribute("oAuth2_email", email);
                request.getSession().setAttribute("oAuth2_gender", gender);
                request.getSession().setAttribute("oAuth2_profileImage", profileImage);
                
                response.sendRedirect("/oauth2/signup/naver");
                
                logger.info("OAuth2 new user redirected to signup: {}", naverId);
            }
            
        } catch (Exception e) {
            logger.error("OAuth2 authentication success handler error: ", e);
            response.sendRedirect("/error?msg=oauth2_error");
        }
    }
}
