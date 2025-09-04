package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Member;
import com.wherehot.spring.service.AuthService;
import com.wherehot.spring.service.MypageService;
import com.wherehot.spring.service.WishListService;
import com.wherehot.spring.security.JwtUtils;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 마이페이지 관련 컨트롤러
 * - 화면 접근과 API를 모두 처리
 * - JWT 토큰 기반 인증
 */
@Controller
@RequestMapping("/mypage")
public class MypageController {
    
    private static final Logger logger = LoggerFactory.getLogger(MypageController.class);
    
    @Autowired
    private AuthService authService;
    
    @Autowired
    private MypageService mypageService;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    @Autowired
    private WishListService wishListService;
    
    /**
     * 마이페이지 메인 화면
     */
    @GetMapping("")
    public String mypageMain(Model model) {
        model.addAttribute("mainPage", "mypage/mypageMain.jsp");
        return "index";
    }
    

    
    /**
     * 마이페이지 찜 목록 화면
     */
    @GetMapping("/wishlist")
    public String wishlist(Model model) {
        model.addAttribute("mainPage", "mypage/wishlist.jsp");
        return "index";
    }
    
    /**
     * 마이페이지 내 게시글 화면
     */
    @GetMapping("/posts")
    public String posts(Model model) {
        model.addAttribute("mainPage", "mypage/posts.jsp");
        return "index";
    }
    
    /**
     * 마이페이지 MD 찜 목록 화면
     */
    @GetMapping("/mdwish")
    public String mdWish(Model model) {
        model.addAttribute("mainPage", "mypage/mymdlist.jsp");
        return "index";
    }
    
    // ===== API 엔드포인트들 =====
    
    /**
     * 현재 로그인한 사용자 정보 조회
     */
    @GetMapping("/api/user-info")
    @ResponseBody
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
            
            // mypageService를 통해 사용자 정보 조회
            Member userInfoFromDB = mypageService.getUserInfo(member.getUserid());
            if (userInfoFromDB == null) {
                logger.error("getUserInfo returned null for userid: {}", member.getUserid());
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "사용자 정보를 조회할 수 없습니다."));
            }
            
            // 디버깅 로그 추가
            logger.info("Retrieved user info - userid: {}, nickname: {}, email: {}, regdate: {}", 
                userInfoFromDB.getUserid(), 
                userInfoFromDB.getNickname(), 
                userInfoFromDB.getEmail(), 
                userInfoFromDB.getRegdate());
            
            // 비밀번호 제외하고 반환
            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("userid", userInfoFromDB.getUserid());
            userInfo.put("nickname", userInfoFromDB.getNickname());
            userInfo.put("email", userInfoFromDB.getEmail());
            userInfo.put("provider", userInfoFromDB.getProvider());
            
            // 가입일 포맷팅
            if (userInfoFromDB.getRegdate() != null) {
                String formattedDate = userInfoFromDB.getRegdate().format(java.time.format.DateTimeFormatter.ofPattern("yyyy년 MM월 dd일"));
                userInfo.put("joindate", formattedDate);
                logger.info("Formatted join date: {}", formattedDate);
            } else {
                userInfo.put("joindate", "정보 없음");
                logger.warn("Regdate is null for userid: {}", userInfoFromDB.getUserid());
            }
            
            userInfo.put("isAdmin", "admin".equals(userInfoFromDB.getProvider()));
            
            logger.info("Final userInfo map: {}", userInfo);
            return ResponseEntity.ok(userInfo);
            
        } catch (Exception e) {
            logger.error("Error getting user info: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "사용자 정보 조회 중 오류가 발생했습니다."));
        }
    }

    /**
     * 현재 비밀번호 확인
     */
    @PostMapping("/api/verify-password")
    @ResponseBody
    public ResponseEntity<?> verifyPassword(HttpServletRequest request, @RequestBody Map<String, String> requestBody) {
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
            
            String password = requestBody.get("password");
            if (password == null || password.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "비밀번호를 입력해주세요."));
            }
            
            boolean verified = mypageService.verifyPassword(member.getUserid(), password);
            
            if (verified) {
                return ResponseEntity.ok(Map.of("verified", true, "message", "비밀번호가 확인되었습니다."));
            } else {
                return ResponseEntity.ok(Map.of("verified", false, "message", "비밀번호가 일치하지 않습니다."));
            }
            
        } catch (Exception e) {
            logger.error("Error verifying password: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "비밀번호 확인 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 사용자 위시리스트 조회
     */
    @GetMapping("/api/wishlist")
    @ResponseBody
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
            
            Map<String, Object> wishlist = mypageService.getUserWishlist(member.getUserid(), page, size);
            return ResponseEntity.ok(wishlist);
            
        } catch (Exception e) {
            logger.error("Error getting user wishlist: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "위시리스트 조회 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 사용자가 작성한 게시글 조회 (전체)
     */
    @GetMapping("/api/posts")
    @ResponseBody
    public ResponseEntity<?> getUserPosts(HttpServletRequest request,
                                        @RequestParam(defaultValue = "1") int page,
                                        @RequestParam(defaultValue = "10") int size,
                                        @RequestParam(defaultValue = "all") String type) {
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
            
            Map<String, Object> posts;
            if ("course".equals(type)) {
                posts = mypageService.getUserCoursePosts(member.getUserid(), page, size);
            } else if ("hottalk".equals(type)) {
                posts = mypageService.getUserHottalkPosts(member.getUserid(), page, size);
            } else {
                posts = mypageService.getUserPosts(member.getUserid(), page, size);
            }
            
            return ResponseEntity.ok(posts);
            
        } catch (Exception e) {
            logger.error("Error getting user posts: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "게시글 조회 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 사용자가 작성한 댓글 조회
     */
    @GetMapping("/api/comments")
    @ResponseBody
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
            
            Map<String, Object> comments = mypageService.getUserComments(member.getUserid(), page, size);
            return ResponseEntity.ok(comments);
            
        } catch (Exception e) {
            logger.error("Error getting user comments: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "댓글 조회 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 사용자 통계 정보 조회
     */
    @GetMapping("/api/stats")
    @ResponseBody
    public ResponseEntity<?> getUserStats(HttpServletRequest request) {
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
            
            Map<String, Object> stats = mypageService.getUserStats(member.getUserid());
            return ResponseEntity.ok(stats);
            
        } catch (Exception e) {
            logger.error("Error getting user stats: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "통계 정보 조회 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 사용자 정보 수정
     */
    @PostMapping("/api/update-profile")
    @ResponseBody
    public ResponseEntity<?> updateProfile(HttpServletRequest request,
                                         @RequestBody Map<String, String> profileData) {
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
            
            String nickname = profileData.get("nickname");
            
            if (nickname == null || nickname.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "닉네임은 필수입니다."));
            }
            
            boolean updated = mypageService.updateProfile(member.getUserid(), nickname, null);
            if (updated) {
                // 기존 토큰을 업데이트된 닉네임으로 갱신
                member.setNickname(nickname); // 현재 객체의 닉네임 업데이트
                String newToken = jwtUtils.generateAccessToken(member);
                
                return ResponseEntity.ok(Map.of(
                    "message", "프로필이 수정되었습니다.",
                    "newToken", newToken,
                    "nickname", nickname
                ));
            } else {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "프로필 수정에 실패했습니다."));
            }
            
        } catch (Exception e) {
            logger.error("Error updating profile: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "프로필 수정 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 비밀번호 변경
     */
    @PostMapping("/api/change-password")
    @ResponseBody
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
            
            boolean changed = mypageService.changePassword(member.getUserid(), currentPassword, newPassword);
            if (changed) {
                return ResponseEntity.ok(Map.of("message", "비밀번호가 변경되었습니다."));
            } else {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "현재 비밀번호가 일치하지 않습니다."));
            }
            
        } catch (Exception e) {
            logger.error("Error changing password: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "비밀번호 변경 중 오류가 발생했습니다."));
        }
    }
    

    
    /**
     * 찜 해제
     */
    @DeleteMapping("/api/wishlist/{wishId}")
    @ResponseBody
    public ResponseEntity<?> removeWish(HttpServletRequest request, @PathVariable Long wishId) {
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
            
            boolean removed = mypageService.removeWish(member.getUserid(), wishId);
            if (removed) {
                return ResponseEntity.ok(Map.of("message", "찜이 해제되었습니다."));
            } else {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "찜 해제에 실패했습니다."));
            }
            
        } catch (Exception e) {
            logger.error("Error removing wish: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "찜 해제 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 개인 메모 업데이트
     */
    @PutMapping("/api/wishlist/{wishId}/note")
    @ResponseBody
    public ResponseEntity<?> updatePersonalNote(HttpServletRequest request, 
                                              @PathVariable Long wishId,
                                              @RequestBody Map<String, String> noteData) {
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
            
            String personalNote = noteData.get("personal_note");
            if (personalNote == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "메모 내용이 필요합니다."));
            }
            
            // 20글자 제한 검증
            if (personalNote.length() > 20) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "메모는 20글자 이내로 작성해주세요."));
            }
            
            boolean updated = wishListService.updatePersonalNote(wishId.intValue(), personalNote);
            if (updated) {
                return ResponseEntity.ok(Map.of("message", "메모가 업데이트되었습니다."));
            } else {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "메모 업데이트에 실패했습니다."));
            }
            
        } catch (Exception e) {
            logger.error("Error updating personal note: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "메모 업데이트 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * MD 찜 목록 조회
     */
    @GetMapping("/api/mdwish")
    @ResponseBody
    public ResponseEntity<?> getMdWishList(HttpServletRequest request,
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
            
            Map<String, Object> result = mypageService.getMdWishList(member.getUserid(), page, size);
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            logger.error("Error getting MD wish list: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "MD 찜 목록 조회 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * MD 찜 해제
     */
    @DeleteMapping("/api/mdwish/{wishId}")
    @ResponseBody
    public ResponseEntity<?> removeMdWish(HttpServletRequest request, @PathVariable int wishId) {
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
            
            boolean success = mypageService.removeMdWish(member.getUserid(), wishId);
            if (success) {
                return ResponseEntity.ok(Map.of("success", true, "message", "MD 찜이 해제되었습니다."));
            } else {
                return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", "MD 찜 해제에 실패했습니다."));
            }
            
        } catch (Exception e) {
            logger.error("Error removing MD wish: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("success", false, "error", "MD 찜 해제 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 회원 탈퇴
     */
    @PostMapping("/api/withdraw")
    @ResponseBody
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
            
            boolean withdrawn = mypageService.withdrawMember(member.getUserid(), password);
            if (withdrawn) {
                return ResponseEntity.ok(Map.of("message", "회원 탈퇴가 완료되었습니다."));
            } else {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "비밀번호가 일치하지 않습니다."));
            }
            
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
