package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.Member;
import com.wherehot.spring.service.MemberService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 회원 관리 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/member")
public class MemberApiController {

    @Autowired
    private MemberService memberService;

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
     * 닉네임 중복 확인
     */
    @GetMapping("/check-nickname")
    public ResponseEntity<Map<String, Object>> checkNickname(@RequestParam String nickname) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (nickname == null || nickname.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "닉네임을 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // TODO: MemberService에 닉네임 중복 확인 메서드 구현 필요
            // boolean exists = memberService.existsByNickname(nickname);
            boolean exists = false; // 임시
            
            response.put("success", true);
            response.put("available", !exists);
            response.put("message", exists ? "이미 사용중인 닉네임입니다." : "사용 가능한 닉네임입니다.");
            response.put("todo", "MemberService.existsByNickname 구현 필요");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "닉네임 확인 중 오류가 발생했습니다: " + e.getMessage());
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
