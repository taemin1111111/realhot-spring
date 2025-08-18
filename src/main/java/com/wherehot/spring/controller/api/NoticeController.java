package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.Notice;
import com.wherehot.spring.service.NoticeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 공지사항 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/notices")
public class NoticeController {
    
    @Autowired
    private NoticeService noticeService;
    
    /**
     * 모든 공지사항 조회 (페이징)
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllNotices(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Notice> notices = noticeService.findAllNotices(page, size);
        int totalCount = noticeService.getTotalNoticeCount();
        
        Map<String, Object> result = new HashMap<>();
        result.put("notices", notices);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 활성 공지사항 조회
     */
    @GetMapping("/active")
    public ResponseEntity<Map<String, Object>> getActiveNotices(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Notice> notices = noticeService.findActiveNotices(page, size);
        int totalCount = noticeService.getActiveNoticeCount();
        
        Map<String, Object> result = new HashMap<>();
        result.put("notices", notices);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 고정 공지사항 조회
     */
    @GetMapping("/pinned")
    public ResponseEntity<List<Notice>> getPinnedNotices() {
        List<Notice> notices = noticeService.findPinnedNotices();
        return ResponseEntity.ok(notices);
    }
    
    /**
     * ID로 공지사항 조회
     */
    @GetMapping("/{id}")
    public ResponseEntity<Notice> getNoticeById(@PathVariable int id) {
        Optional<Notice> notice = noticeService.findNoticeById(id);
        if (notice.isPresent()) {
            // 조회수 증가
            noticeService.incrementViewCount(id);
            return ResponseEntity.ok(notice.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    /**
     * 공지사항 검색
     */
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchNotices(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Notice> notices = noticeService.searchNotices(keyword, page, size);
        int totalCount = noticeService.getSearchResultCount(keyword);
        
        Map<String, Object> result = new HashMap<>();
        result.put("notices", notices);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("keyword", keyword);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 최신 공지사항 조회
     */
    @GetMapping("/recent")
    public ResponseEntity<List<Notice>> getRecentNotices(@RequestParam(defaultValue = "5") int limit) {
        List<Notice> notices = noticeService.findRecentNotices(limit);
        return ResponseEntity.ok(notices);
    }
    
    /**
     * 작성자별 공지사항 조회
     */
    @GetMapping("/author/{authorId}")
    public ResponseEntity<Map<String, Object>> getNoticesByAuthor(
            @PathVariable String authorId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Notice> notices = noticeService.findNoticesByAuthor(authorId, page, size);
        int totalCount = noticeService.getNoticeCountByAuthor(authorId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("notices", notices);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("authorId", authorId);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 공지사항 등록
     */
    @PostMapping
    public ResponseEntity<Notice> createNotice(@RequestBody Notice notice,
                                              @AuthenticationPrincipal UserDetails userDetails) {
        try {
            if (userDetails != null) {
                notice.setAuthorId(userDetails.getUsername());
            }
            
            Notice savedNotice = noticeService.saveNotice(notice);
            return ResponseEntity.ok(savedNotice);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 공지사항 수정
     */
    @PutMapping("/{id}")
    public ResponseEntity<Notice> updateNotice(@PathVariable int id,
                                              @RequestBody Notice notice,
                                              @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 기존 공지사항 조회
            Optional<Notice> existingNotice = noticeService.findNoticeById(id);
            if (existingNotice.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            // 작성자 권한 확인 (또는 관리자)
            if (userDetails == null || (!existingNotice.get().getAuthorId().equals(userDetails.getUsername()) 
                && !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN")))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            notice.setId(id);
            Notice updatedNotice = noticeService.updateNotice(notice);
            return ResponseEntity.ok(updatedNotice);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 공지사항 삭제
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteNotice(@PathVariable int id,
                                            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 기존 공지사항 조회
            Optional<Notice> existingNotice = noticeService.findNoticeById(id);
            if (existingNotice.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            // 작성자 권한 확인 (또는 관리자)
            if (userDetails == null || (!existingNotice.get().getAuthorId().equals(userDetails.getUsername()) 
                && !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN")))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            boolean deleted = noticeService.deleteNotice(id);
            return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 고정 설정/해제
     */
    @PatchMapping("/{id}/pin")
    public ResponseEntity<Void> togglePin(@PathVariable int id,
                                         @RequestParam boolean isPinned,
                                         @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 관리자 권한 확인
            if (userDetails == null || !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            boolean updated = noticeService.updatePinnedStatus(id, isPinned);
            return updated ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 활성/비활성 설정
     */
    @PatchMapping("/{id}/active")
    public ResponseEntity<Void> toggleActive(@PathVariable int id,
                                            @RequestParam boolean isActive,
                                            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 관리자 권한 확인
            if (userDetails == null || !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            boolean updated = noticeService.updateActiveStatus(id, isActive);
            return updated ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
