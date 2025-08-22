package com.wherehot.spring.controller;

import com.wherehot.spring.dto.auth.LoginRequest;
import com.wherehot.spring.dto.auth.JwtResponse;
import com.wherehot.spring.service.AuthService;
import com.wherehot.spring.entity.Member;
import com.wherehot.spring.mapper.MemberMapper;
import com.wherehot.spring.security.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
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
    @ResponseBody
    public ResponseEntity<Map<String, Object>> login(@RequestBody LoginRequest loginRequest) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 입력값 검증
            if (loginRequest == null || loginRequest.getUserid() == null || loginRequest.getPassword() == null) {
                response.put("result", false);
                response.put("error", "아이디와 비밀번호를 모두 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 임시 테스트 계정 (실제 구현에서는 제거)
            if ("test".equals(loginRequest.getUserid()) && "test".equals(loginRequest.getPassword())) {
                response.put("result", true);
                response.put("token", "test_token_12345");
                response.put("userid", "test");
                response.put("nickname", "테스트사용자");
                response.put("provider", "local");
                response.put("email", "test@test.com");
                response.put("message", "로그인이 완료되었습니다.");
                return ResponseEntity.ok(response);
            }
            
            JwtResponse jwtResponse = authService.authenticateUser(loginRequest);
            
            if (jwtResponse != null && jwtResponse.getToken() != null) {
                response.put("result", true);
                response.put("token", jwtResponse.getToken());
                response.put("userid", jwtResponse.getUserid());
                response.put("nickname", jwtResponse.getNickname());
                response.put("provider", jwtResponse.getProvider());
                response.put("email", jwtResponse.getEmail());
                response.put("message", "로그인이 완료되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("result", false);
                response.put("error", "아이디 또는 비밀번호가 올바르지 않습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            // 로그 출력
            System.err.println("Login error: " + e.getMessage());
            e.printStackTrace();
            
            response.put("result", false);
            response.put("error", "로그인 처리 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    // 로그아웃 API 엔드포인트
    @PostMapping("/api/auth/logout")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> logout() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // JWT 토큰은 클라이언트에서 삭제하므로 서버에서는 별도 처리 불필요
            // 필요시 블랙리스트 처리 등 추가 가능
            response.put("result", true);
            response.put("message", "로그아웃이 완료되었습니다.");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("result", false);
            response.put("error", "로그아웃 처리 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
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
                return ResponseEntity.ok(response);
            }
            
            String token = authHeader.substring(7);
            String userid = jwtUtils.getUseridFromToken(token);
            
            if (userid != null) {
                Optional<Member> memberOpt = memberMapper.findByUserid(userid);
                if (memberOpt.isPresent()) {
                    Member member = memberOpt.get();
                    boolean isAdmin = "admin".equals(userid) || "admin".equals(member.getProvider());
                    response.put("result", true);
                    response.put("isAdmin", isAdmin);
                    response.put("userid", userid);
                    response.put("nickname", member.getNickname());
                    response.put("provider", member.getProvider());
                } else {
                    response.put("result", false);
                    response.put("isAdmin", false);
                }
            } else {
                response.put("result", false);
                response.put("isAdmin", false);
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("result", false);
            response.put("isAdmin", false);
            return ResponseEntity.ok(response);
        }
    }
}
