package com.wherehot.spring.controller;

import com.wherehot.spring.dto.auth.LoginRequest;
import com.wherehot.spring.dto.auth.JwtResponse;
import com.wherehot.spring.service.AuthService;
import com.wherehot.spring.service.EmailService;
import com.wherehot.spring.service.MemberService;
import com.wherehot.spring.entity.Member;
import com.wherehot.spring.entity.EmailVerification;
import com.wherehot.spring.mapper.MemberMapper;
import com.wherehot.spring.mapper.EmailVerificationMapper;
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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
public class AuthController {
    
    @Autowired
    private AuthService authService;
    
    @Autowired
    private MemberMapper memberMapper;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    @Autowired
    private EmailService emailService;
    
    @Autowired
    private EmailVerificationMapper emailVerificationMapper;
    
    @Autowired
    private MemberService memberService;
    
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
    
    // 아이디 찾기 페이지
    @GetMapping("/idsearch")
    public String idSearchForm(Model model) {
        model.addAttribute("mainPage", "login/idsearch.jsp");
        return "index";
    }
    
    // 비밀번호 찾기 페이지
    @GetMapping("/passsearch")
    public String passSearchForm(Model model) {
        model.addAttribute("mainPage", "login/passsearch.jsp");
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
               
                response.put("result", false);
                response.put("isAdmin", false);
                response.put("error", "Authorization 헤더 없음");
                return ResponseEntity.ok(response);
            }
            
            String token = authHeader.substring(7);
            String userid = jwtUtils.getUseridFromToken(token);
          
            
            if (userid != null) {
                Optional<Member> memberOpt = memberMapper.findByUserid(userid);
                if (memberOpt.isPresent()) {
                    Member member = memberOpt.get();
                    String provider = member.getProvider();
                    String status = member.getStatus();
                    
                   
                    
                    // 관리자 권한 확인: provider가 admin인 경우만 (JWT Filter와 일관성 유지)
                    boolean isAdmin = "admin".equals(provider);
                    
                   
                    
                    response.put("result", true);
                    response.put("isAdmin", isAdmin);
                    response.put("userid", userid);
                    response.put("nickname", member.getNickname());
                    response.put("provider", provider);
                    response.put("status", status);
                    response.put("debug", "userid=" + userid + ", provider=" + provider + ", status=" + status);
                } else {
                   
                    response.put("result", false);
                    response.put("isAdmin", false);
                    response.put("error", "사용자를 찾을 수 없음");
                }
            } else {
               
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
    
    // ===== 아이디 찾기 관련 API =====
    
    /**
     * 아이디 찾기 - 인증번호 발송
     */
    @PostMapping("/api/auth/send-id-search-code")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> sendIdSearchCode(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String email = request.get("email");
            
            if (email == null || email.trim().isEmpty()) {
                response.put("success", false);
                response.put("error", "이메일을 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 이메일로 회원 조회
            Optional<Member> memberOpt = memberMapper.findByEmail(email);
            if (!memberOpt.isPresent()) {
                response.put("success", false);
                response.put("error", "EMAIL_NOT_FOUND");
                return ResponseEntity.badRequest().body(response);
            }
            
            Member member = memberOpt.get();
            
            // 네이버 계정인지 확인
            if ("naver".equals(member.getProvider())) {
                response.put("success", false);
                response.put("error", "NAVER_ACCOUNT");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 하루 1회 제한 확인 (오늘 이미 아이디 찾기를 했는지 확인)
            if (emailVerificationMapper.hasIdSearchToday(email)) {
                response.put("success", false);
                response.put("error", "DAILY_LIMIT_EXCEEDED");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 인증번호 발송
            boolean sent = emailService.sendIdSearchCode(email);
            
            if (sent) {
                response.put("success", true);
                response.put("message", "인증번호가 발송되었습니다.");
            } else {
                response.put("success", false);
                response.put("error", "인증번호 발송에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
           
            e.printStackTrace();
            response.put("success", false);
            response.put("error", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 아이디 찾기 - 인증번호 확인
     */
    @PostMapping("/api/auth/verify-id-search-code")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> verifyIdSearchCode(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String email = request.get("email");
            String code = request.get("code");
            
            if (email == null || email.trim().isEmpty() || code == null || code.trim().isEmpty()) {
                response.put("success", false);
                response.put("error", "이메일과 인증번호를 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 인증번호 확인
            boolean verified = emailService.verifyIdSearchCode(email, code);
            
            if (verified) {
                // 회원 정보 조회
                Optional<Member> memberOpt = memberMapper.findByEmail(email);
                if (memberOpt.isPresent()) {
                    Member member = memberOpt.get();
                    
                    response.put("success", true);
                    response.put("userid", member.getUserid());
                    response.put("regdate", member.getRegdate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
                    response.put("message", "아이디 찾기가 완료되었습니다.");
                    return ResponseEntity.ok(response);
                } else {
                    response.put("success", false);
                    response.put("error", "회원 정보를 찾을 수 없습니다.");
                    return ResponseEntity.badRequest().body(response);
                }
            } else {
                response.put("success", false);
                response.put("error", "INVALID_CODE");
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
         
            e.printStackTrace();
            response.put("success", false);
            response.put("error", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 아이디 찾기 - 인증번호 재발송
     */
    @PostMapping("/api/auth/resend-id-search-code")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> resendIdSearchCode(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String email = request.get("email");
            
            if (email == null || email.trim().isEmpty()) {
                response.put("success", false);
                response.put("error", "이메일을 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 인증번호 재발송
            boolean sent = emailService.sendIdSearchCode(email);
            
            if (sent) {
                response.put("success", true);
                response.put("message", "인증번호가 재발송되었습니다.");
            } else {
                response.put("success", false);
                response.put("error", "인증번호 재발송에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("resend-id-search-code error: " + e.getMessage());
            e.printStackTrace();
            response.put("success", false);
            response.put("error", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    // ===== 비밀번호 찾기 관련 API =====
    
    /**
     * 비밀번호 찾기 - 인증번호 발송
     */
    @PostMapping("/api/auth/send-password-reset-code")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> sendPasswordResetCode(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String email = request.get("email");
            
            if (email == null || email.trim().isEmpty()) {
                response.put("success", false);
                response.put("error", "이메일을 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 이메일로 회원 조회
            Optional<Member> memberOpt = memberMapper.findByEmail(email);
            if (!memberOpt.isPresent()) {
                response.put("success", false);
                response.put("error", "EMAIL_NOT_FOUND");
                return ResponseEntity.badRequest().body(response);
            }
            
            Member member = memberOpt.get();
            
            // 네이버 계정인지 확인
            if ("naver".equals(member.getProvider())) {
                response.put("success", false);
                response.put("error", "NAVER_ACCOUNT");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 하루 1회 제한 확인 (오늘 이미 비밀번호 찾기를 했는지 확인)
            if (emailVerificationMapper.hasPasswordResetToday(email)) {
                response.put("success", false);
                response.put("error", "DAILY_LIMIT_EXCEEDED");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 인증번호 발송
            boolean sent = emailService.sendPasswordResetCode(email);
            
            if (sent) {
                response.put("success", true);
                response.put("message", "인증번호가 발송되었습니다.");
            } else {
                response.put("success", false);
                response.put("error", "인증번호 발송에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("send-password-reset-code error: " + e.getMessage());
            e.printStackTrace();
            response.put("success", false);
            response.put("error", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 비밀번호 찾기 - 인증번호 확인
     */
    @PostMapping("/api/auth/verify-password-reset-code")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> verifyPasswordResetCode(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String email = request.get("email");
            String code = request.get("code");
            
            if (email == null || email.trim().isEmpty() || code == null || code.trim().isEmpty()) {
                response.put("success", false);
                response.put("error", "이메일과 인증번호를 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 인증번호 확인
            boolean verified = emailService.verifyPasswordResetCode(email, code);
            
            if (verified) {
                response.put("success", true);
                response.put("message", "인증이 완료되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("error", "INVALID_CODE");
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            System.err.println("verify-password-reset-code error: " + e.getMessage());
            e.printStackTrace();
            response.put("success", false);
            response.put("error", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 비밀번호 찾기 - 인증번호 재발송
     */
    @PostMapping("/api/auth/resend-password-reset-code")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> resendPasswordResetCode(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String email = request.get("email");
            
            if (email == null || email.trim().isEmpty()) {
                response.put("success", false);
                response.put("error", "이메일을 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 인증번호 재발송
            boolean sent = emailService.sendPasswordResetCode(email);
            
            if (sent) {
                response.put("success", true);
                response.put("message", "인증번호가 재발송되었습니다.");
            } else {
                response.put("success", false);
                response.put("error", "인증번호 재발송에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("resend-password-reset-code error: " + e.getMessage());
            e.printStackTrace();
            response.put("success", false);
            response.put("error", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 비밀번호 재설정
     */
    @PostMapping("/api/auth/reset-password")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> resetPassword(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String email = request.get("email");
            String newPassword = request.get("newPassword");
            
            if (email == null || email.trim().isEmpty() || newPassword == null || newPassword.trim().isEmpty()) {
                response.put("success", false);
                response.put("error", "이메일과 새 비밀번호를 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // ✅ 이메일 인증 확인 (최근 10분 이내에 인증되었는지 확인)
            boolean isVerified = emailService.isPasswordResetVerified(email, 10);
            
            if (!isVerified) {
                response.put("success", false);
                response.put("error", "이메일 인증을 먼저 완료해주세요. 인증 시간이 만료된 경우 다시 인증해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 비밀번호 규칙 검증
            if (!isValidPassword(newPassword)) {
                response.put("success", false);
                response.put("error", "비밀번호는 8자 이상, 영문, 숫자, 특수문자를 포함해야 합니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 회원 조회
            Optional<Member> memberOpt = memberMapper.findByEmail(email);
            if (!memberOpt.isPresent()) {
                response.put("success", false);
                response.put("error", "회원 정보를 찾을 수 없습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            Member member = memberOpt.get();
            
            // 비밀번호 업데이트 (MemberService의 resetPassword 메서드 사용)
            boolean updated = memberService.resetPassword(member.getUserid(), newPassword);
            
            if (updated) {
                response.put("success", true);
                response.put("message", "비밀번호가 성공적으로 변경되었습니다.");
            } else {
                response.put("success", false);
                response.put("error", "비밀번호 변경에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("reset-password error: " + e.getMessage());
            e.printStackTrace();
            response.put("success", false);
            response.put("error", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 비밀번호 규칙 검증
     */
    private boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        
        boolean hasLetter = password.matches(".*[a-zA-Z].*");
        boolean hasNumber = password.matches(".*\\d.*");
        boolean hasSpecial = password.matches(".*[!@#$%^&*(),.?\":{}|<>].*");
        
        return hasLetter && hasNumber && hasSpecial;
    }
}
