package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.Member;
import com.wherehot.spring.entity.Post;
import com.wherehot.spring.service.MemberService;
import com.wherehot.spring.service.PostService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;


import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 관리자 API 컨트롤러
 */
@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    @Autowired
    private MemberService memberService;

    @Autowired
    private PostService postService;

    /**
     * 회원 상태 변경
     */
    @PutMapping("/members/{userid}/status")
    public ResponseEntity<Map<String, Object>> changeMemberStatus(
            @PathVariable String userid,
            @RequestParam String status,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // admin 계정 상태 변경 방지
            if ("admin".equals(userid)) {
                response.put("success", false);
                response.put("message", "관리자 계정의 상태는 변경할 수 없습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 상태 값 유효성 검사
            if (!status.equals("A") && !status.equals("B") && !status.equals("C")) {
                response.put("success", false);
                response.put("message", "잘못된 상태 값입니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 회원 존재 확인
            Member member = memberService.findByUserid(userid);
            if (member == null) {
                response.put("success", false);
                response.put("message", "해당 회원이 존재하지 않습니다.");
                return ResponseEntity.notFound().build();
            }
            
            // 상태 변경 실행
            boolean success = memberService.updateMemberStatus(userid, status);
            
            if (success) {
                String statusText = "";
                switch (status) {
                    case "A": statusText = "활성"; break;
                    case "B": statusText = "경고"; break;
                    case "C": statusText = "정지"; break;
                }
                response.put("success", true);
                response.put("message", "회원 상태가 '" + statusText + "'으로 성공적으로 변경되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "회원 상태 변경에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 회원 삭제
     */
    @DeleteMapping("/members/{userid}")
    public ResponseEntity<Map<String, Object>> deleteMember(
            @PathVariable String userid,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // admin 계정 삭제 방지
            if ("admin".equals(userid)) {
                response.put("success", false);
                response.put("message", "관리자 계정은 삭제할 수 없습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 회원 존재 확인
            Member member = memberService.findByUserid(userid);
            if (member == null) {
                response.put("success", false);
                response.put("message", "해당 회원이 존재하지 않습니다.");
                return ResponseEntity.notFound().build();
            }
            
            // 회원 삭제 실행
            boolean success = memberService.deleteMember(userid);
            
            if (success) {
                response.put("success", true);
                response.put("message", "회원이 성공적으로 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "회원 삭제에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 게시글 삭제
     */
    @DeleteMapping("/posts/{postId}")
    public ResponseEntity<Map<String, Object>> deletePost(
            @PathVariable int postId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 게시글 존재 확인
            Post post = postService.findById(postId);
            if (post == null) {
                response.put("success", false);
                response.put("message", "해당 게시글이 존재하지 않습니다.");
                return ResponseEntity.notFound().build();
            }
            
            // 게시글 삭제 실행
            boolean success = postService.deletePost(postId);
            
            if (success) {
                // TODO: 신고 기록 처리 로직 추가 필요
                // reportService.deleteReportsByPostId(postId);
                
                response.put("success", true);
                response.put("message", "게시글이 성공적으로 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "게시글 삭제에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (NumberFormatException e) {
            response.put("success", false);
            response.put("message", "잘못된 게시글 ID입니다.");
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "게시글 삭제 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 회원 목록 조회 (관리자용)
     */
    @GetMapping("/members")
    public ResponseEntity<Map<String, Object>> getMembers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String provider,
            @RequestParam(required = false) String status) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            int offset = page * size;
            
            List<Member> members;
            int totalCount;
            
            if (keyword != null && !keyword.trim().isEmpty()) {
                // 검색 모드
                members = memberService.searchMembers(keyword, provider, status, offset, size);
                totalCount = memberService.countSearchMembers(keyword, provider, status);
            } else {
                // 전체 목록 모드
                members = memberService.findAllMembers(offset, size);
                totalCount = memberService.countMembers();
            }
            
            response.put("success", true);
            response.put("members", members);
            response.put("totalCount", totalCount);
            response.put("currentPage", page);
            response.put("size", size);
            response.put("totalPages", (int) Math.ceil((double) totalCount / size));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "회원 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 회원 통계 조회
     */
    @GetMapping("/members/stats")
    public ResponseEntity<Map<String, Object>> getMemberStats() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            int totalMembers = memberService.countMembers();
            int activeMembers = memberService.countActiveMembers();
            List<Map<String, Object>> statsByProvider = memberService.getMemberStatsByProvider();
            List<Map<String, Object>> statsByMonth = memberService.getMemberStatsByMonth();
            
            response.put("success", true);
            response.put("totalMembers", totalMembers);
            response.put("activeMembers", activeMembers);
            response.put("statsByProvider", statsByProvider);
            response.put("statsByMonth", statsByMonth);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "통계 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
}
