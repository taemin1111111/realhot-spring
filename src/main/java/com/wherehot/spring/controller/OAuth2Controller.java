package com.wherehot.spring.controller;

import com.wherehot.spring.dto.auth.SignupRequest;
import com.wherehot.spring.entity.Member;
import com.wherehot.spring.security.JwtUtils;
import com.wherehot.spring.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * OAuth2 회원가입 처리 컨트롤러
 */
@Controller
@RequestMapping("/oauth2")
public class OAuth2Controller {
    
    private static final Logger logger = LoggerFactory.getLogger(OAuth2Controller.class);
    
    @Autowired
    private AuthService authService;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    /**
     * 네이버 OAuth2 회원가입 페이지
     */
    @GetMapping("/signup/naver")
    public String naverSignupPage(HttpServletRequest request, Model model) {
        HttpSession session = request.getSession();
        
        // 세션에서 네이버 사용자 정보 가져오기
        String naverId = (String) session.getAttribute("oAuth2_naverId");
        String name = (String) session.getAttribute("oAuth2_name");
        String email = (String) session.getAttribute("oAuth2_email");
        String gender = (String) session.getAttribute("oAuth2_gender");
        String profileImage = (String) session.getAttribute("oAuth2_profileImage");
        
        if (naverId == null) {
            logger.warn("OAuth2 session data not found, redirecting to main page");
            return "redirect:/";
        }
        
        // 모델에 데이터 전달
        model.addAttribute("naverId", naverId);
        model.addAttribute("name", name);
        model.addAttribute("email", email);
        model.addAttribute("gender", gender);
        model.addAttribute("profileImage", profileImage);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "login/naverJoin.jsp");
        return "index";
    }
    
    /**
     * 네이버 OAuth2 회원가입 처리
     */
    @PostMapping("/signup/naver")
    public String naverSignupProcess(
            @RequestParam String naverId,
            @RequestParam String nickname,
            @RequestParam(required = false) String birth,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        try {
            HttpSession session = request.getSession();
            
            // 세션에서 네이버 사용자 정보 가져오기
            String name = (String) session.getAttribute("oAuth2_name");
            String email = (String) session.getAttribute("oAuth2_email");
            String gender = (String) session.getAttribute("oAuth2_gender");
            
            // SignupRequest 객체 생성
            SignupRequest signupRequest = new SignupRequest();
            signupRequest.setName(name);
            signupRequest.setNickname(nickname);
            signupRequest.setEmail(email);
            
            // 생년월일 처리 (String -> LocalDate)
            if (birth != null && !birth.trim().isEmpty()) {
                try {
                    LocalDate birthDate = LocalDate.parse(birth, DateTimeFormatter.ISO_LOCAL_DATE);
                    signupRequest.setBirth(birthDate);
                } catch (Exception e) {
                    logger.warn("Invalid birth date format: {}", birth);
                }
            }
            
            signupRequest.setGender(gender);
            signupRequest.setProvider("naver");
            
            // 네이버 회원가입 처리
            Member member = authService.registerNaverUser(signupRequest, naverId);
            
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
            // session.invalidate();
            
            logger.info("Naver OAuth2 signup successful: {}", member.getUserid());
            
            // 메인 페이지로 리다이렉트 (토큰과 함께, URL 인코딩 적용)
            try {
                return "redirect:/?token=" + accessToken + "&userid=" + member.getUserid() + 
                       "&nickname=" + java.net.URLEncoder.encode(member.getNickname(), "UTF-8") + 
                       "&provider=" + member.getProvider() + 
                       "&email=" + java.net.URLEncoder.encode(member.getEmail(), "UTF-8");
            } catch (Exception e) {
                logger.error("URL encoding error: {}", e.getMessage());
                return "redirect:/?error=encoding_error";
            }
            
        } catch (Exception e) {
            logger.error("Naver OAuth2 signup failed: ", e);
            return "redirect:/oauth2/signup/naver?error=" + e.getMessage();
        }
    }
}
