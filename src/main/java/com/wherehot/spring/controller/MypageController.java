package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Member;
import com.wherehot.spring.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 마이페이지 관련 REST API 컨트롤러
 * - JWT 토큰 기반 인증으로 완전 전환
 * - 세션 의존성 제거
 */
@RestController
@RequestMapping("/api/mypage")
@CrossOrigin(origins = "*", maxAge = 3600)
public class MypageController {
    
    private static final Logger logger = LoggerFactory.getLogger(MypageController.class);
    
    @Autowired
    private AuthService authService;
    
    /**
     * 현재 로그인한 사용자 정보 조회
     */
    @GetMapping("/user-info")
    public ResponseEntity<?> getUserInfo(HttpServletRequest request) {
        try {
            String token = extractTokenFromRequest(request);
            if (token == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "인증 토큰이 필요합니다."));
            }
            
            Member member = authService.getUserFromToken(token);
            if (member == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "유효하지 않은 토큰입니다."));
            }
            
            // 비밀번호 제외하고 반환
            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("userid", member.getUserid());
            userInfo.put("nickname", member.getNickname());
            userInfo.put("email", member.getEmail());
            userInfo.put("provider", member.getProvider());
            userInfo.put("joindate", member.getRegdate());
            userInfo.put("isAdmin", "admin".equals(member.getProvider()));
            
            return ResponseEntity.ok(userInfo);
            
        } catch (Exception e) {
            logger.error("Error getting user info: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "사용자 정보 조회 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 사용자 위시리스트 조회
     */
    @GetMapping("/wishlist")
    public ResponseEntity<?> getUserWishlist(HttpServletRequest request,
                                           @RequestParam(defaultValue = "1") int page,
                                           @RequestParam(defaultValue = "10") int size) {
        try {
            String token = extractTokenFromRequest(request);
            if (token == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "인증 토큰이 필요합니다."));
            }
            
            Member member = authService.getUserFromToken(token);
            if (member == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "유효하지 않은 토큰입니다."));
            }
            
            // TODO: WishListService를 통해 위시리스트 조회 로직 구현
            Map<String, Object> response = new HashMap<>();
            response.put("wishlist", new java.util.ArrayList<>());
            response.put("totalCount", 0);
            response.put("currentPage", page);
            response.put("totalPages", 0);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Error getting wishlist: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "위시리스트 조회 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 사용자가 작성한 게시글 조회
     */
    @GetMapping("/posts")
    public ResponseEntity<?> getUserPosts(HttpServletRequest request,
                                        @RequestParam(defaultValue = "1") int page,
                                        @RequestParam(defaultValue = "10") int size) {
        try {
            String token = extractTokenFromRequest(request);
            if (token == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "인증 토큰이 필요합니다."));
            }
            
            Member member = authService.getUserFromToken(token);
            if (member == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "유효하지 않은 토큰입니다."));
            }
            
            // TODO: PostService를 통해 사용자 게시글 조회 로직 구현
            Map<String, Object> response = new HashMap<>();
            response.put("posts", new java.util.ArrayList<>());
            response.put("totalCount", 0);
            response.put("currentPage", page);
            response.put("totalPages", 0);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Error getting user posts: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "게시글 조회 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 사용자가 작성한 댓글 조회
     */
    @GetMapping("/comments")
    public ResponseEntity<?> getUserComments(HttpServletRequest request,
                                           @RequestParam(defaultValue = "1") int page,
                                           @RequestParam(defaultValue = "10") int size) {
        try {
            String token = extractTokenFromRequest(request);
            if (token == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "인증 토큰이 필요합니다."));
            }
            
            Member member = authService.getUserFromToken(token);
            if (member == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "유효하지 않은 토큰입니다."));
            }
            
            // TODO: CommentService를 통해 사용자 댓글 조회 로직 구현
            Map<String, Object> response = new HashMap<>();
            response.put("comments", new java.util.ArrayList<>());
            response.put("totalCount", 0);
            response.put("currentPage", page);
            response.put("totalPages", 0);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Error getting user comments: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "댓글 조회 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 프로필 정보 업데이트
     */
    @PostMapping("/update-profile")
    public ResponseEntity<?> updateProfile(HttpServletRequest request,
                                         @RequestBody Map<String, String> updateData) {
        try {
            String token = extractTokenFromRequest(request);
            if (token == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "인증 토큰이 필요합니다."));
            }
            
            Member member = authService.getUserFromToken(token);
            if (member == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "유효하지 않은 토큰입니다."));
            }
            
            // TODO: 프로필 업데이트 로직 구현
            return ResponseEntity.ok(Map.of("message", "프로필이 성공적으로 업데이트되었습니다."));
            
        } catch (Exception e) {
            logger.error("Error updating profile: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "프로필 업데이트 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 비밀번호 변경
     */
    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(HttpServletRequest request,
                                          @RequestBody Map<String, String> passwordData) {
        try {
            String token = extractTokenFromRequest(request);
            if (token == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "인증 토큰이 필요합니다."));
            }
            
            Member member = authService.getUserFromToken(token);
            if (member == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "유효하지 않은 토큰입니다."));
            }
            
            String currentPassword = passwordData.get("currentPassword");
            String newPassword = passwordData.get("newPassword");
            
            if (currentPassword == null || newPassword == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "현재 비밀번호와 새 비밀번호가 필요합니다."));
            }
            
            // TODO: 비밀번호 변경 로직 구현
            return ResponseEntity.ok(Map.of("message", "비밀번호가 성공적으로 변경되었습니다."));
            
        } catch (Exception e) {
            logger.error("Error changing password: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "비밀번호 변경 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 회원 탈퇴
     */
    @PostMapping("/withdraw")
    public ResponseEntity<?> withdrawMember(HttpServletRequest request,
                                          @RequestBody Map<String, String> withdrawData) {
        try {
            String token = extractTokenFromRequest(request);
            if (token == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "인증 토큰이 필요합니다."));
            }
            
            Member member = authService.getUserFromToken(token);
            if (member == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "유효하지 않은 토큰입니다."));
            }
            
            String password = withdrawData.get("password");
            if (password == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "비밀번호 확인이 필요합니다."));
            }
            
            // TODO: 회원 탈퇴 로직 구현
            return ResponseEntity.ok(Map.of("message", "회원 탈퇴가 완료되었습니다."));
            
        } catch (Exception e) {
            logger.error("Error withdrawing member: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "회원 탈퇴 중 오류가 발생했습니다."));
        }
    }
    
    // 유틸리티 메서드
    private String extractTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
