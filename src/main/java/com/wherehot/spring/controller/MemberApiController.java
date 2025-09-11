package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Member;
import com.wherehot.spring.service.MemberService;
import com.wherehot.spring.service.AuthService;
import com.wherehot.spring.dto.auth.SignupRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

/**
 * 회원 관리 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/auth")
public class MemberApiController {

    @Autowired
    private MemberService memberService;

    @Autowired
    private AuthService authService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * 회원 탈퇴
     */
    @DeleteMapping("/withdraw")
    public ResponseEntity<Map<String, Object>> withdrawMember(
            @RequestParam String password,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (userDetails == null) {
                response.put("result", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(401).body(response);
            }
            
            String userid = userDetails.getUsername();
            
            // 비밀번호가 입력되지 않은 경우
            if (password == null || password.trim().isEmpty()) {
                response.put("result", false);
                response.put("message", "비밀번호를 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 회원 정보 조회
            Member member = memberService.findByUserid(userid);
            if (member == null) {
                response.put("result", false);
                response.put("message", "회원 정보를 찾을 수 없습니다.");
                return ResponseEntity.notFound().build();
            }
            
            // 네이버 로그인 사용자는 탈퇴 불가
            if ("naver".equals(member.getProvider())) {
                response.put("result", false);
                response.put("message", "네이버 로그인 사용자는 회원 탈퇴가 불가능합니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 비밀번호 확인
            if (!passwordEncoder.matches(password, member.getPassword())) {
                response.put("result", false);
                response.put("message", "비밀번호가 일치하지 않습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 관리자 계정 탈퇴 방지
            if ("admin".equals(userid)) {
                response.put("result", false);
                response.put("message", "관리자 계정은 탈퇴할 수 없습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 회원 탈퇴 처리
            boolean success = memberService.deleteMember(userid);
            
            if (success) {
                response.put("result", true);
                response.put("message", "회원 탈퇴가 완료되었습니다. 이용해 주셔서 감사합니다.");
                
                // TODO: 추가 탈퇴 처리
                // - 관련 데이터 삭제/익명화 처리
                // - 세션 무효화
                // - 로그 기록
                
            } else {
                response.put("result", false);
                response.put("message", "회원 탈퇴 처리 중 오류가 발생했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("result", false);
            response.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 현재 비밀번호 확인
     */
    @PostMapping("/check-password")
    public ResponseEntity<Map<String, Object>> checkCurrentPassword(
            @RequestParam String password,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (userDetails == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(401).body(response);
            }
            
            String userid = userDetails.getUsername();
            Member member = memberService.findByUserid(userid);
            
            if (member == null) {
                response.put("success", false);
                response.put("message", "회원 정보를 찾을 수 없습니다.");
                return ResponseEntity.notFound().build();
            }
            
            boolean isValid = passwordEncoder.matches(password, member.getPassword());
            
            response.put("success", true);
            response.put("valid", isValid);
            response.put("message", isValid ? "비밀번호가 일치합니다." : "비밀번호가 일치하지 않습니다.");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "비밀번호 확인 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 아이디 중복 확인
     */
    @GetMapping("/check/userid")
    public ResponseEntity<Map<String, Object>> checkUserid(@RequestParam String userid) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (userid == null || userid.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "아이디를 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            boolean exists = authService.isUseridExists(userid);
            
            response.put("success", true);
            response.put("exists", exists);
            response.put("message", exists ? "이미 사용중인 아이디입니다." : "사용 가능한 아이디입니다.");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "아이디 확인 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 닉네임 중복 확인
     */
    @GetMapping("/check/nickname")
    public ResponseEntity<Map<String, Object>> checkNickname(@RequestParam String nickname) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (nickname == null || nickname.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "닉네임을 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            boolean exists = authService.isNicknameExists(nickname);
            
            response.put("success", true);
            response.put("exists", exists);
            response.put("message", exists ? "이미 사용중인 닉네임입니다." : "사용 가능한 닉네임입니다.");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "닉네임 확인 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 이메일 중복 확인
     */
    @GetMapping("/check/email")
    public ResponseEntity<Map<String, Object>> checkEmail(@RequestParam String email) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (email == null || email.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "이메일을 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            boolean exists = authService.isEmailExists(email);
            
            response.put("success", true);
            response.put("exists", exists);
            response.put("message", exists ? "이미 사용중인 이메일입니다." : "사용 가능한 이메일입니다.");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "이메일 확인 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 회원가입
     */
    @PostMapping("/signup")
    public ResponseEntity<Map<String, Object>> signup(@RequestBody Map<String, String> signupData) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 필수 필드 검증
            String userid = signupData.get("userid");
            String password = signupData.get("password");
            String passwordConfirm = signupData.get("passwordConfirm");
            String name = signupData.get("name");
            String nickname = signupData.get("nickname");
            String email = signupData.get("email");
            String emailVerificationCode = signupData.get("emailVerificationCode");
            
            // 디버깅을 위한 로그 (개발 환경에서만)
            System.out.println("Received signup data: " + signupData);
            
            if (userid == null || userid.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                name == null || name.trim().isEmpty() ||
                nickname == null || nickname.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                emailVerificationCode == null || emailVerificationCode.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "모든 필수 항목을 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 비밀번호 확인
            if (!password.equals(passwordConfirm)) {
                response.put("success", false);
                response.put("message", "비밀번호가 일치하지 않습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 이메일 인증 확인 (이미 인증된 이메일인지 확인)
            if (!authService.isEmailVerified(email)) {
                response.put("success", false);
                response.put("message", "이메일 인증을 완료해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // SignupRequest 객체 생성
            SignupRequest signupRequest = new SignupRequest();
            signupRequest.setUserid(userid);
            signupRequest.setPassword(password);
            signupRequest.setPasswordConfirm(passwordConfirm);
            signupRequest.setName(name);
            signupRequest.setNickname(nickname);
            signupRequest.setEmail(email);
            signupRequest.setPhone(signupData.get("phone"));
            
            // birth String을 LocalDate로 변환
            String birthStr = signupData.get("birth");
            if (birthStr != null && !birthStr.trim().isEmpty()) {
                try {
                    LocalDate birth = LocalDate.parse(birthStr, DateTimeFormatter.ISO_LOCAL_DATE);
                    signupRequest.setBirth(birth);
                } catch (Exception e) {
                    response.put("success", false);
                    response.put("message", "생년월일 형식이 올바르지 않습니다.");
                    return ResponseEntity.badRequest().body(response);
                }
            }
            
            signupRequest.setGender(signupData.get("gender"));
            signupRequest.setProvider(signupData.getOrDefault("provider", "site"));
            
            // 회원가입 처리
            Member member = authService.registerUser(signupRequest);
            
            response.put("success", true);
            response.put("message", "회원가입이 완료되었습니다.");
            response.put("member", member);
            
            return ResponseEntity.ok(response);
            
        } catch (IllegalArgumentException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "회원가입 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 이메일 인증코드 발송
     */
    @PostMapping("/email/send-verification")
    public ResponseEntity<Map<String, Object>> sendEmailVerification(@RequestParam String email) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (email == null || email.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "이메일을 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            boolean sent = authService.sendEmailVerificationCode(email);
            
            if (sent) {
                response.put("success", true);
                response.put("message", "인증코드가 발송되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "인증코드 발송에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "인증코드 발송 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 이메일 인증코드 확인
     */
    @PostMapping("/email/verify")
    public ResponseEntity<Map<String, Object>> verifyEmailCode(
            @RequestParam String email, 
            @RequestParam String code) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (email == null || email.trim().isEmpty() || code == null || code.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "이메일과 인증코드를 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            boolean verified = authService.verifyEmailCode(email, code);
            
            if (verified) {
                response.put("success", true);
                response.put("message", "이메일 인증이 완료되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "인증코드가 올바르지 않습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "이메일 인증 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 프로필 업데이트
     */
    @PutMapping("/profile")
    public ResponseEntity<Map<String, Object>> updateProfile(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String nickname,
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String phone,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (userDetails == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(401).body(response);
            }
            
            String userid = userDetails.getUsername();
            Member member = memberService.findByUserid(userid);
            
            if (member == null) {
                response.put("success", false);
                response.put("message", "회원 정보를 찾을 수 없습니다.");
                return ResponseEntity.notFound().build();
            }
            
            // 프로필 정보 업데이트
            boolean updated = false;
            
            if (name != null && !name.trim().isEmpty()) {
                member.setName(name.trim());
                updated = true;
            }
            
            if (nickname != null && !nickname.trim().isEmpty()) {
                member.setNickname(nickname.trim());
                updated = true;
            }
            
            if (email != null && !email.trim().isEmpty()) {
                member.setEmail(email.trim());
                updated = true;
            }
            
            if (phone != null && !phone.trim().isEmpty()) {
                member.setPhone(phone.trim());
                updated = true;
            }
            
            if (updated) {
                Member updatedMember = memberService.updateMember(member);
                if (updatedMember != null) {
                    response.put("success", true);
                    response.put("message", "프로필이 업데이트되었습니다.");
                    response.put("member", updatedMember);
                } else {
                    response.put("success", false);
                    response.put("message", "프로필 업데이트에 실패했습니다.");
                }
            } else {
                response.put("success", false);
                response.put("message", "업데이트할 정보를 입력해주세요.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "프로필 업데이트 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
}
