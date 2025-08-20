package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.Md;
import com.wherehot.spring.service.MdService;
import com.wherehot.spring.service.MdWishService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/md")
public class MdController {

    private static final Logger log = LoggerFactory.getLogger(MdController.class);
    
    @Autowired
    private MdService mdService;
    
    @Autowired
    private MdWishService mdWishService;

    /**
     * MD 목록 조회 (페이징)
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getMdList(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "latest") String sort,
            @RequestParam(defaultValue = "all") String searchType) {
        
        try {
            Pageable pageable = PageRequest.of(page, size);
            Page<Map<String, Object>> mdPage = mdService.getMdListWithPlace(pageable, keyword, sort, searchType);
            
            // JWT 토큰에서 로그인 정보 가져와서 찜 상태 확인 (안전하게 처리)
            String loginId = null;
            try {
                loginId = getCurrentUserFromJWT();
                log.info("JWT 인증 처리 완료: loginId={}", loginId);
            } catch (Exception e) {
                log.warn("JWT 인증 처리 중 오류: {}", e.getMessage());
                loginId = null;
            }
            
            // 찜 상태 설정
            for (Map<String, Object> md : mdPage.getContent()) {
                try {
                    if (loginId != null) {
                        Integer mdId = (Integer) md.get("mdId");
                        boolean isWished = mdWishService.isMdWished(mdId, loginId);
                        md.put("isWished", isWished);
                    } else {
                        md.put("isWished", false);
                    }
                } catch (Exception e) {
                    log.warn("찜 상태 확인 중 오류: {}", e.getMessage());
                    md.put("isWished", false);
                }
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("mds", mdPage.getContent());
            response.put("currentPage", mdPage.getNumber());
            response.put("totalPages", mdPage.getTotalPages());
            response.put("totalElements", mdPage.getTotalElements());
            response.put("hasNext", mdPage.hasNext());
            response.put("hasPrevious", mdPage.hasPrevious());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting MD list", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "MD 목록 조회 중 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * MD 등록
     */
    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> registerMd(
            @RequestParam String mdName,
            @RequestParam Integer placeId,
            @RequestParam(required = false) String contact,
            @RequestParam(required = false) String description,
            @RequestParam(required = false) MultipartFile photo) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            Md md = new Md();
            md.setMdName(mdName);
            md.setPlaceId(placeId);
            md.setContact(contact);
            md.setDescription(description);
            
            mdService.registerMd(md, photo);
            
            response.put("success", true);
            response.put("message", "MD가 성공적으로 등록되었습니다.");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error registering MD", e);
            response.put("success", false);
            response.put("message", "MD 등록 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * MD 찜하기
     */
    @PostMapping("/{mdId}/wish")
    public ResponseEntity<Map<String, Object>> addMdWish(
            @PathVariable Integer mdId) {
        
        Map<String, Object> response = new HashMap<>();
        String loginId = getCurrentUserFromJWT();
        
        if (loginId == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }
        
        try {
            mdWishService.addMdWish(mdId, loginId);
            log.info("MD 찜 추가 성공: mdId={}, loginId={}", mdId, loginId);
            response.put("success", true);
            response.put("message", "찜 목록에 추가되었습니다.");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("MD 찜 추가 실패: mdId={}, loginId={}", mdId, loginId, e);
            response.put("success", false);
            response.put("message", "찜하기 처리 중 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * MD 찜 취소
     */
    @DeleteMapping("/{mdId}/wish")
    public ResponseEntity<Map<String, Object>> removeMdWish(
            @PathVariable Integer mdId) {
        
        Map<String, Object> response = new HashMap<>();
        String loginId = getCurrentUserFromJWT();
        
        if (loginId == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }
        
        try {
            mdWishService.removeMdWish(mdId, loginId);
            log.info("MD 찜 취소 성공: mdId={}, loginId={}", mdId, loginId);
            response.put("success", true);
            response.put("message", "찜 목록에서 제거되었습니다.");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("MD 찜 취소 실패: mdId={}, loginId={}", mdId, loginId, e);
            response.put("success", false);
            response.put("message", "찜 취소 처리 중 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 검색 자동완성 제안
     */
    @GetMapping("/suggestions")
    public ResponseEntity<Map<String, Object>> getSearchSuggestions(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "all") String searchType,
            @RequestParam(defaultValue = "5") int limit) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Map<String, Object>> suggestions = mdService.getSearchSuggestions(keyword, searchType, limit);
            
            response.put("success", true);
            response.put("suggestions", suggestions);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error getting search suggestions", e);
            response.put("success", false);
            response.put("message", "검색 제안을 가져오는 중 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * MD 상세 조회
     */
    @GetMapping("/{mdId}")
    public ResponseEntity<Map<String, Object>> getMdDetail(@PathVariable Integer mdId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Map<String, Object> mdDetail = mdService.getMdDetail(mdId);
            response.put("success", true);
            response.put("md", mdDetail);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error getting MD detail", e);
            response.put("success", false);
            response.put("message", "MD 상세 정보 조회 중 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * JWT 토큰에서 현재 사용자 정보 가져오기 (안전한 처리)
     */
    private String getCurrentUserFromJWT() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && 
                authentication.isAuthenticated() && 
                authentication.getName() != null &&
                !authentication.getName().equals("anonymousUser") &&
                !authentication.getName().equals("null")) {
                String username = authentication.getName();
                log.debug("JWT에서 사용자 인증 성공: {}", username);
                return username;
            } else {
                log.debug("JWT 인증 상태: anonymous 또는 미인증");
                return null;
            }
        } catch (Exception e) {
            log.warn("JWT 인증 정보 처리 중 예외 발생: {}", e.getMessage(), e);
            return null;
        }
    }
}