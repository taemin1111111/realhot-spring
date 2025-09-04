package com.wherehot.spring.controller;

import com.wherehot.spring.dto.auth.LoginRequest;
import com.wherehot.spring.dto.auth.JwtResponse;
import com.wherehot.spring.service.AuthService;
import com.wherehot.spring.entity.Member;
import com.wherehot.spring.mapper.MemberMapper;
import com.wherehot.spring.security.JwtUtils;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Controller
public class AuthController {
    
    @Autowired
    private AuthService authService;
    
    @Autowired
    private MemberMapper memberMapper;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    // 로그인 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/login")
    public String loginForm(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "login/loginModal.jsp");
        return "index";
    }
    
    // 회원가입 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/signup")
    public String signupForm(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "login/join.jsp");
        return "index";
    }
    
    // 네이버 회원가입 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/signup/naver")
    public String naverSignupForm(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "login/naverJoin.jsp");
        return "index";
    }
    
    // 로그인 API 엔드포인트
    @PostMapping("/api/auth/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest, HttpServletResponse response) {
        try {
            JwtResponse jwtResponse = authService.authenticateUser(loginRequest);

            // ✅ 서버에서 직접 쿠키 설정 (가장 안정적인 방식)
            // HttpOnly: JavaScript에서 접근 불가 (XSS 방어)
            // Secure: HTTPS에서만 전송 (운영 환경에서는 true로 설정)
            // Path: 쿠키가 유효한 경로
            ResponseCookie accessTokenCookie = ResponseCookie.from("accessToken", jwtResponse.getToken())
                    .httpOnly(true)
                    .secure(false) // 개발 환경에서는 false
                    .path("/")
                    .maxAge(24 * 60 * 60) // 1일
                    .build();

            ResponseCookie refreshTokenCookie = ResponseCookie.from("refreshToken", jwtResponse.getRefreshToken())
                    .httpOnly(true)
                    .secure(false) // 개발 환경에서는 false
                    .path("/")
                    .maxAge(7 * 24 * 60 * 60) // 7일
                    .build();
            
            // 응답 헤더에 쿠키 추가
            response.addHeader(HttpHeaders.SET_COOKIE, accessTokenCookie.toString());
            response.addHeader(HttpHeaders.SET_COOKIE, refreshTokenCookie.toString());
            
            // 기존과 같이 JSON 응답도 전달 (클라이언트 UI 즉시 업데이트용)
            return ResponseEntity.ok(jwtResponse);

        } catch (Exception e) {
            return ResponseEntity
                    .status(401)
                    .body(Map.of("error", e.getMessage()));
        }
    }
    
    /**
     * 토큰 갱신
     */
    @PostMapping("/api/auth/refresh")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> refreshToken(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String refreshToken = request.get("refreshToken");
            
            if (refreshToken == null || refreshToken.trim().isEmpty()) {
                response.put("result", false);
                response.put("error", "리프레시 토큰이 필요합니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            String newAccessToken = authService.refreshAccessToken(refreshToken);
            
            if (newAccessToken != null) {
                response.put("result", true);
                response.put("token", newAccessToken);
                response.put("message", "토큰이 갱신되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("result", false);
                response.put("error", "토큰 갱신에 실패했습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            System.err.println("Token refresh error: " + e.getMessage());
            e.printStackTrace();
            
            response.put("result", false);
            response.put("error", "토큰 갱신 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 로그아웃
     */
    @PostMapping("/api/auth/logout")
    public ResponseEntity<?> logout(HttpServletResponse response) {
        
        // ✅ 서버에서 쿠키 삭제
        ResponseCookie accessTokenCookie = ResponseCookie.from("accessToken", "")
                .httpOnly(true)
                .secure(false)
                .path("/")
                .maxAge(0) // 즉시 만료
                .build();

        ResponseCookie refreshTokenCookie = ResponseCookie.from("refreshToken", "")
                .httpOnly(true)
                .secure(false)
                .path("/")
                .maxAge(0) // 즉시 만료
                .build();
        
        response.addHeader(HttpHeaders.SET_COOKIE, accessTokenCookie.toString());
        response.addHeader(HttpHeaders.SET_COOKIE, refreshTokenCookie.toString());

        return ResponseEntity.ok(Map.of("message", "로그아웃 되었습니다."));
    }
    
    // 관리자 체크 API 엔드포인트
    @GetMapping("/api/auth/check-admin")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkAdmin(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                System.out.println("check-admin: Authorization 헤더 없음");
                response.put("result", false);
                response.put("isAdmin", false);
                response.put("error", "Authorization 헤더 없음");
                return ResponseEntity.ok(response);
            }
            
            String token = authHeader.substring(7);
            String userid = jwtUtils.getUseridFromToken(token);
            System.out.println("check-admin: userid from token = " + userid);
            
            if (userid != null) {
                Optional<Member> memberOpt = memberMapper.findByUserid(userid);
                if (memberOpt.isPresent()) {
                    Member member = memberOpt.get();
                    String provider = member.getProvider();
                    String status = member.getStatus();
                    
                    System.out.println("check-admin: member found - userid=" + userid + 
                                    ", provider=" + provider + ", status=" + status);
                    
                    // 관리자 권한 확인: provider가 admin인 경우만 (JWT Filter와 일관성 유지)
                    boolean isAdmin = "admin".equals(provider);
                    
                    System.out.println("check-admin: isAdmin = " + isAdmin);
                    
                    response.put("result", true);
                    response.put("isAdmin", isAdmin);
                    response.put("userid", userid);
                    response.put("nickname", member.getNickname());
                    response.put("provider", provider);
                    response.put("status", status);
                    response.put("debug", "userid=" + userid + ", provider=" + provider + ", status=" + status);
                } else {
                    System.out.println("check-admin: member not found for userid = " + userid);
                    response.put("result", false);
                    response.put("isAdmin", false);
                    response.put("error", "사용자를 찾을 수 없음");
                }
            } else {
                System.out.println("check-admin: userid is null from token");
                response.put("result", false);
                response.put("isAdmin", false);
                response.put("error", "토큰에서 userid 추출 실패");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("check-admin error: " + e.getMessage());
            e.printStackTrace();
            response.put("result", false);
            response.put("isAdmin", false);
            response.put("error", "오류 발생: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }
}
