package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Notice;
import com.wherehot.spring.service.NoticeService;
import com.wherehot.spring.security.JwtUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/notice")
public class NoticeController {
    
    private static final Logger logger = LoggerFactory.getLogger(NoticeController.class);
    
    @Autowired
    private NoticeService noticeService;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    @Value("${file.upload.notice-path:src/main/webapp/uploads/noticesave}")
    private String noticeUploadPath;
    
    // 공지사항 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("")
    public String noticeMain(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "notice/noticemain.jsp");
        return "index";
    }
    
    // 공지사항 목록 API
    @GetMapping("/api/list")
    @ResponseBody
    public Map<String, Object> getNoticeList() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 실제 데이터베이스에서 공지사항 목록 조회
            List<Notice> noticeList = noticeService.getPublicNotices();
            
            if (noticeList != null && !noticeList.isEmpty()) {
                // Notice 엔티티를 Map으로 변환
                List<Map<String, Object>> notices = new ArrayList<>();
                for (Notice notice : noticeList) {
                    Map<String, Object> noticeMap = new HashMap<>();
                    noticeMap.put("noticeId", notice.getNoticeId());
                    noticeMap.put("title", notice.getTitle());
                    noticeMap.put("content", notice.getContent());
                    noticeMap.put("photoUrl", notice.getPhotoUrl());
                    noticeMap.put("writerUserid", notice.getWriterUserid());
                    noticeMap.put("viewCount", notice.getViewCount());
                    noticeMap.put("isPinned", notice.getIsPinned());
                    noticeMap.put("status", notice.getStatus());
                    noticeMap.put("createdAt", notice.getCreatedAt());
                    noticeMap.put("updatedAt", notice.getUpdatedAt());
                    notices.add(noticeMap);
                }
                
                response.put("success", true);
                response.put("notices", notices);
                response.put("totalCount", notices.size());
            } else {
                // 공지사항이 없는 경우
                response.put("success", true);
                response.put("notices", new ArrayList<>());
                response.put("totalCount", 0);
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "공지사항 조회 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        
        return response;
    }
    
    // 공지사항 상세 페이지
    @GetMapping("/detail/{noticeId}")
    public String noticeDetail(@PathVariable Long noticeId, Model model) {
        model.addAttribute("mainPage", "notice/noticedetail.jsp");
        model.addAttribute("noticeId", noticeId);
        return "index";
    }
    
    // 공지사항 상세 정보 API
    @GetMapping("/api/detail/{noticeId}")
    @ResponseBody
    public Map<String, Object> getNoticeDetail(@PathVariable Long noticeId) {
        Map<String, Object> response = new HashMap<>();
        try {
            Notice notice = noticeService.getNoticeById(noticeId);
            if (notice != null) {
                // 조회수 증가
                noticeService.incrementViewCount(noticeId);
                
                Map<String, Object> noticeMap = new HashMap<>();
                noticeMap.put("noticeId", notice.getNoticeId());
                noticeMap.put("title", notice.getTitle());
                noticeMap.put("content", notice.getContent());
                noticeMap.put("photoUrl", notice.getPhotoUrl());
                noticeMap.put("writerUserid", notice.getWriterUserid());
                noticeMap.put("viewCount", notice.getViewCount() + 1); // 증가된 조회수
                noticeMap.put("isPinned", notice.getIsPinned());
                noticeMap.put("createdAt", notice.getCreatedAt());
                
                response.put("success", true);
                response.put("notice", noticeMap);
            } else {
                response.put("success", false);
                response.put("message", "공지사항을 찾을 수 없습니다.");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "공지사항을 불러오는 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        
        return response;
    }
    
    // 공지사항 작성 API
    @PostMapping("/api/create")
    @ResponseBody
    public Map<String, Object> createNotice(
            @RequestParam String title,
            @RequestParam String content,
            @RequestParam(required = false) MultipartFile photo,
            @RequestParam(required = false) String isPinned,
            @RequestHeader("Authorization") String authHeader) {
        
        logger.info("공지사항 작성 요청 - 제목: {}, 내용 길이: {}, 사진: {}, isPinned: {}", 
                   title, content.length(), photo != null ? photo.getOriginalFilename() : "없음", isPinned);
        logger.info("파라미터 상세 - title: '{}', content: '{}', isPinned: '{}'", title, content, isPinned);
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 확인
            logger.info("Authorization 헤더: {}", authHeader);
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                logger.warn("인증 헤더가 없거나 Bearer 토큰이 아닙니다: {}", authHeader);
                response.put("success", false);
                response.put("message", "인증이 필요합니다.");
                return response;
            }
            
            String token = authHeader.substring(7);
            logger.info("토큰 유효성 검사 시작");
            if (!jwtUtils.validateToken(token)) {
                logger.warn("토큰이 유효하지 않습니다");
                response.put("success", false);
                response.put("message", "유효하지 않은 토큰입니다.");
                return response;
            }
            
            // 토큰에서 사용자 정보 추출
            String username = jwtUtils.getUseridFromToken(token);
            logger.info("토큰에서 추출한 사용자 ID: {}", username);
            if (!"admin".equals(username)) {
                logger.warn("관리자가 아닌 사용자가 공지사항 작성을 시도했습니다: {}", username);
                response.put("success", false);
                response.put("message", "관리자만 공지사항을 작성할 수 있습니다.");
                return response;
            }
            
            // 공지사항 객체 생성
            Notice notice = new Notice();
            notice.setTitle(title);
            notice.setContent(content);
            notice.setWriterUserid(username);
            notice.setIsPinned("true".equals(isPinned) || "on".equals(isPinned));
            notice.setStatus("PUBLIC");
            
            // 사진 업로드 처리
            if (photo != null && !photo.isEmpty()) {
                String photoUrl = saveNoticePhoto(photo);
                if (photoUrl != null) {
                    notice.setPhotoUrl(photoUrl);
                }
            }
            
            // 공지사항 저장
            logger.info("공지사항 저장 시도 - 제목: {}, 작성자: {}", notice.getTitle(), notice.getWriterUserid());
            boolean result = noticeService.createNotice(notice);
            logger.info("공지사항 저장 결과: {}", result);
            
            if (result) {
                response.put("success", true);
                response.put("message", "공지사항이 성공적으로 작성되었습니다.");
                response.put("noticeId", notice.getNoticeId());
                logger.info("공지사항 작성 성공 - ID: {}", notice.getNoticeId());
            } else {
                response.put("success", false);
                response.put("message", "공지사항 작성에 실패했습니다.");
                logger.error("공지사항 작성 실패");
            }
            
        } catch (Exception e) {
            logger.error("공지사항 작성 중 오류 발생", e);
            logger.error("오류 상세 정보: {}", e.getClass().getSimpleName());
            logger.error("오류 메시지: {}", e.getMessage());
            if (e.getCause() != null) {
                logger.error("원인: {}", e.getCause().getMessage());
            }
            response.put("success", false);
            response.put("message", "공지사항 작성 중 오류가 발생했습니다: " + e.getMessage());
            response.put("errorType", e.getClass().getSimpleName());
        }
        
        return response;
    }
    
    // 공지사항 사진 저장 메서드
    private String saveNoticePhoto(MultipartFile photo) {
        try {
            // 프로젝트 루트 디렉토리 찾기
            File projectRoot = new File(System.getProperty("user.dir"));
            
            // target/classes에서 실행되는 경우 프로젝트 루트로 이동
            if (projectRoot.getAbsolutePath().contains("target")) {
                projectRoot = projectRoot.getParentFile().getParentFile();
            }
            
            String uploadDir = projectRoot.getAbsolutePath() + File.separator + "src" + File.separator + "main" + File.separator + "webapp" + File.separator + "uploads" + File.separator + "noticesave" + File.separator;
            
            File dir = new File(uploadDir);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            
            // 파일명 생성 (타임스탬프 + 랜덤값 + 원본파일명)
            String originalFilename = photo.getOriginalFilename();
            String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String newFilename = System.currentTimeMillis() + "_" + (int)(Math.random() * 1000) + fileExtension;
            
            // 파일 저장
            File dest = new File(uploadDir + newFilename);
            photo.transferTo(dest);
            
            // 웹에서 접근 가능한 경로 반환 (context path 포함)
            return "/hotplace/uploads/noticesave/" + newFilename;
            
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
    
    // 공지사항 고정/고정취소 API
    @PostMapping(value = "/api/toggle-pinned/{noticeId}", 
                 consumes = "application/x-www-form-urlencoded", 
                 produces = "application/json")
    @ResponseBody
    public Map<String, Object> togglePinned(@PathVariable Long noticeId, 
                                           @RequestParam Boolean isPinned,
                                           @RequestHeader("Authorization") String authHeader) {
        Map<String, Object> response = new HashMap<>();
        
        logger.info("togglePinned method called with noticeId: {}, isPinned: {}", noticeId, isPinned);
        
        try {
            // 관리자 권한 확인
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                response.put("success", false);
                response.put("message", "인증이 필요합니다.");
                return response;
            }
            
            String token = authHeader.substring(7);
            if (!jwtUtils.validateToken(token)) {
                response.put("success", false);
                response.put("message", "유효하지 않은 토큰입니다.");
                return response;
            }
            
            String username = jwtUtils.getUseridFromToken(token);
            if (!"admin".equals(username)) {
                response.put("success", false);
                response.put("message", "관리자만 이 기능을 사용할 수 있습니다.");
                return response;
            }
            
            // 고정/고정취소 처리
            boolean result = noticeService.togglePinned(noticeId, isPinned);
            
            if (result) {
                response.put("success", true);
                response.put("message", isPinned ? "공지사항이 고정되었습니다." : "공지사항 고정이 취소되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "처리에 실패했습니다.");
            }
            
        } catch (Exception e) {
            logger.error("공지사항 고정/고정취소 중 오류 발생", e);
            response.put("success", false);
            response.put("message", "처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    // 공지사항 삭제 API
    @DeleteMapping(value = "/api/delete/{noticeId}", produces = "application/json")
    @ResponseBody
    public Map<String, Object> deleteNotice(@PathVariable Long noticeId,
                                           @RequestHeader("Authorization") String authHeader) {
        Map<String, Object> response = new HashMap<>();
        
        logger.info("deleteNotice method called with noticeId: {}", noticeId);
        
        try {
            // 관리자 권한 확인
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                response.put("success", false);
                response.put("message", "인증이 필요합니다.");
                return response;
            }
            
            String token = authHeader.substring(7);
            if (!jwtUtils.validateToken(token)) {
                response.put("success", false);
                response.put("message", "유효하지 않은 토큰입니다.");
                return response;
            }
            
            String username = jwtUtils.getUseridFromToken(token);
            if (!"admin".equals(username)) {
                response.put("success", false);
                response.put("message", "관리자만 이 기능을 사용할 수 있습니다.");
                return response;
            }
            
            // 삭제 처리
            boolean result = noticeService.deleteNotice(noticeId);
            
            if (result) {
                response.put("success", true);
                response.put("message", "공지사항이 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "삭제에 실패했습니다.");
            }
            
        } catch (Exception e) {
            logger.error("공지사항 삭제 중 오류 발생", e);
            response.put("success", false);
            response.put("message", "삭제 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
}
