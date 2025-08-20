package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.Notice;
import com.wherehot.spring.service.NoticeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * 공지사항 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/notices")
public class NoticeController {
    
    @Autowired
    private NoticeService noticeService;
    
    @Value("${file.upload.notice-path:${user.home}/uploads/notices}")
    private String noticeUploadPath;
    
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
     * 공지사항 등록 (파일 업로드 포함)
     */
    @PostMapping(consumes = {"multipart/form-data"})
    public ResponseEntity<Map<String, Object>> createNotice(
            @RequestParam("title") String title,
            @RequestParam("content") String content,
            @RequestParam(value = "pinned", defaultValue = "false") boolean pinned,
            @RequestParam(value = "photo", required = false) MultipartFile photo,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 확인
            if (userDetails == null || !userDetails.getAuthorities().stream()
                    .anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"))) {
                response.put("success", false);
                response.put("message", "관리자만 공지사항을 등록할 수 있습니다.");
                return ResponseEntity.status(403).body(response);
            }
            
            Notice notice = new Notice();
            notice.setTitle(title);
            notice.setContent(content);
            notice.setPinned(pinned);
            notice.setWriter(userDetails.getUsername());
            
            // 파일 업로드 처리
            if (photo != null && !photo.isEmpty()) {
                String fileName = saveUploadedFile(photo, "notices");
                notice.setPhoto(fileName);
            }
            
            Notice savedNotice = noticeService.saveNotice(notice);
            
            response.put("success", true);
            response.put("message", "공지사항이 성공적으로 등록되었습니다.");
            response.put("notice", savedNotice);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "공지사항 등록 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 파일 업로드 처리 메서드
     */
    private String saveUploadedFile(MultipartFile file, String subDir) throws IOException {
        // 업로드 디렉토리 생성
        Path uploadDir = Paths.get(noticeUploadPath, subDir);
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }
        
        // 파일명 생성 (중복 방지)
        String originalFileName = file.getOriginalFilename();
        String fileExtension = "";
        if (originalFileName != null && originalFileName.contains(".")) {
            fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
        }
        String fileName = UUID.randomUUID().toString() + "_" + System.currentTimeMillis() + fileExtension;
        
        // 파일 저장
        Path filePath = uploadDir.resolve(fileName);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        
        return fileName;
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
            if (userDetails == null || (!existingNotice.get().getWriter().equals(userDetails.getUsername()) 
                && !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN")))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            notice.setNoticeId(id);
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
            if (userDetails == null || (!existingNotice.get().getWriter().equals(userDetails.getUsername()) 
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
