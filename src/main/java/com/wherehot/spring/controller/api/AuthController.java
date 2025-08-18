package com.wherehot.spring.controller.api;

import com.wherehot.spring.dto.auth.JwtResponse;
import com.wherehot.spring.dto.auth.LoginRequest;
import com.wherehot.spring.dto.auth.SignupRequest;
import com.wherehot.spring.entity.Member;
import com.wherehot.spring.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 인증 관련 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {
    
    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);
    
    @Autowired
    private AuthService authService;
    
    /**
     * 로그인
     */
    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest, 
                                            HttpServletRequest request) {
        try {
            JwtResponse jwtResponse = authService.authenticateUser(loginRequest);
            
            logger.info("Login successful for user: {} from IP: {}", 
                       loginRequest.getUserid(), getClientIpAddress(request));
            
            return ResponseEntity.ok(jwtResponse);
            
        } catch (Exception e) {
            logger.error("Login failed for user: {} from IP: {}, Error: {}", 
                        loginRequest.getUserid(), getClientIpAddress(request), e.getMessage());
            
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
    }
    
    /**
     * 회원가입
     */
    @PostMapping("/signup")
    public ResponseEntity<?> registerUser(@Valid @RequestBody SignupRequest signupRequest,
                                        HttpServletRequest request) {
        try {
            Member member = authService.registerUser(signupRequest);
            
            logger.info("Signup successful for user: {} from IP: {}", 
                       member.getUserid(), getClientIpAddress(request));
            
            Map<String, String> response = new HashMap<>();
            response.put("message", "회원가입이 완료되었습니다.");
            response.put("userid", member.getUserid());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Signup failed for user: {} from IP: {}, Error: {}", 
                        signupRequest.getUserid(), getClientIpAddress(request), e.getMessage());
            
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 네이버 회원가입
     */
    @PostMapping("/signup/naver")
    public ResponseEntity<?> registerNaverUser(@Valid @RequestBody SignupRequest signupRequest,
                                             @RequestParam String naverId,
                                             HttpServletRequest request) {
        try {
            Member member = authService.registerNaverUser(signupRequest, naverId);
            
            logger.info("Naver signup successful for user: {} from IP: {}", 
                       member.getUserid(), getClientIpAddress(request));
            
            Map<String, String> response = new HashMap<>();
            response.put("message", "네이버 회원가입이 완료되었습니다.");
            response.put("userid", member.getUserid());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Naver signup failed for naverId: {} from IP: {}, Error: {}", 
                        naverId, getClientIpAddress(request), e.getMessage());
            
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 로그아웃
     */
    @PostMapping("/logout")
    public ResponseEntity<?> logoutUser(HttpServletRequest request) {
        try {
            String token = extractTokenFromRequest(request);
            if (token != null) {
                authService.logout(token);
            }
            
            SecurityContextHolder.clearContext();
            
            Map<String, String> response = new HashMap<>();
            response.put("message", "로그아웃이 완료되었습니다.");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Logout error: {}", e.getMessage());
            
            Map<String, String> error = new HashMap<>();
            error.put("error", "로그아웃 처리 중 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 토큰 갱신
     */
    @PostMapping("/refresh")
    public ResponseEntity<?> refreshToken(@RequestParam String refreshToken) {
        try {
            String newAccessToken = authService.refreshAccessToken(refreshToken);
            
            Map<String, String> response = new HashMap<>();
            response.put("accessToken", newAccessToken);
            response.put("tokenType", "Bearer");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Token refresh error: {}", e.getMessage());
            
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
    }
    
    /**
     * 아이디 중복 체크
     */
    @GetMapping("/check/userid")
    public ResponseEntity<?> checkUserid(@RequestParam String userid) {
        try {
            boolean exists = authService.isUseridExists(userid);
            
            Map<String, Object> response = new HashMap<>();
            response.put("exists", exists);
            response.put("message", exists ? "이미 사용 중인 아이디입니다." : "사용 가능한 아이디입니다.");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "아이디 중복 체크 중 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 이메일 중복 체크
     */
    @GetMapping("/check/email")
    public ResponseEntity<?> checkEmail(@RequestParam String email) {
        try {
            boolean exists = authService.isEmailExists(email);
            
            Map<String, Object> response = new HashMap<>();
            response.put("exists", exists);
            response.put("message", exists ? "이미 사용 중인 이메일입니다." : "사용 가능한 이메일입니다.");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "이메일 중복 체크 중 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 닉네임 중복 체크
     */
    @GetMapping("/check/nickname")
    public ResponseEntity<?> checkNickname(@RequestParam String nickname) {
        try {
            boolean exists = authService.isNicknameExists(nickname);
            
            Map<String, Object> response = new HashMap<>();
            response.put("exists", exists);
            response.put("message", exists ? "이미 사용 중인 닉네임입니다." : "사용 가능한 닉네임입니다.");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "닉네임 중복 체크 중 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 이메일 인증코드 발송
     */
    @PostMapping("/email/send-verification")
    public ResponseEntity<?> sendEmailVerification(@RequestParam String email) {
        try {
            logger.info("Attempting to send verification email to: {}", email);
            
            // 이메일 유효성 검사
            if (email == null || email.trim().isEmpty()) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "이메일 주소가 필요합니다.");
                return ResponseEntity.badRequest().body(error);
            }
            
            boolean sent = authService.sendEmailVerificationCode(email.trim());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", sent);
            response.put("message", sent ? "인증코드가 발송되었습니다." : "인증코드 발송에 실패했습니다.");
            
            logger.info("Email verification send result for {}: {}", email, sent);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Error sending verification email to: {}", email, e);
            Map<String, String> error = new HashMap<>();
            error.put("error", "인증코드 발송 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 이메일 인증코드 확인
     */
    @PostMapping("/email/verify")
    public ResponseEntity<?> verifyEmailCode(@RequestParam String email, @RequestParam String code) {
        try {
            boolean verified = authService.verifyEmailCode(email, code);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", verified);
            response.put("message", verified ? "이메일 인증이 완료되었습니다." : "인증코드가 올바르지 않습니다.");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 현재 사용자 정보 조회
     */
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(HttpServletRequest request) {
        try {
            String token = extractTokenFromRequest(request);
            if (token == null) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "인증 토큰이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
            }
            
            Member member = authService.getUserFromToken(token);
            if (member == null) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "유효하지 않은 토큰입니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
            }
            
            // 비밀번호 제외하고 반환
            member.setPasswd(null);
            return ResponseEntity.ok(member);
            
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "사용자 정보 조회 중 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    /**
     * 관리자 권한 확인 API (서버 사이드 검증)
     */
    @GetMapping("/check-admin")
    public ResponseEntity<?> checkAdminRole(HttpServletRequest request) {
        try {
            String token = extractTokenFromRequest(request);
            if (token == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "토큰이 필요합니다."));
            }
            
            Member member = authService.getUserFromToken(token);
            if (member == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "유효하지 않은 토큰입니다."));
            }
            
            // model1과 동일한 방식: provider가 "admin"이면 관리자
            boolean isAdmin = "admin".equals(member.getProvider());
            
            Map<String, Object> response = new HashMap<>();
            response.put("isAdmin", isAdmin);
            response.put("userid", member.getUserid());
            response.put("nickname", member.getNickname());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Admin check failed: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", "서버 오류가 발생했습니다."));
        }
    }
    
    // 유틸리티 메서드들
    
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null) {
            return xForwardedFor.split(",")[0];
        }
        return request.getRemoteAddr();
    }
    
    private String extractTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
