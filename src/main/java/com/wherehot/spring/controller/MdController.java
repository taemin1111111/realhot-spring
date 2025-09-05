package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Md;
import com.wherehot.spring.service.MdService;
import com.wherehot.spring.security.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.ResponseEntity;
import jakarta.servlet.http.HttpServletRequest;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.UUID;

@Controller
@RequestMapping("/md")
public class MdController {
    
    @Autowired
    private MdService mdService;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    // MD 목록 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("")
    public String mdList(@RequestParam(defaultValue = "1") int page,
                        Model model) {
        
        // TODO: MdService의 실제 메서드 사용
        List<Md> mdList = new java.util.ArrayList<>();
        int totalCount = 0;
        
        model.addAttribute("mdList", mdList);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalCount", totalCount);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "clubmd/clubmd.jsp");
        return "index";
    }
    
    // MD 목록 API (AJAX용)
    @GetMapping("/api/list")
    @ResponseBody
    public Map<String, Object> getMdList(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "15") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String searchType,
            @RequestParam(defaultValue = "latest") String sort,
            HttpServletRequest request) {
        
        // 사용자 ID 결정 (JWT 토큰 또는 IP)
        String userId = determineUserId(request);
        System.out.println("=== MD 목록 조회 ===");
        System.out.println("userId: " + userId);
        
        // MdService를 통해 실제 데이터 조회
        return mdService.getMdList(page, size, keyword, searchType, sort, userId);
    }
    
    // 디버깅용: 모든 MD 조회 API
    @GetMapping("/api/debug/all")
    @ResponseBody
    public Map<String, Object> getAllMds(HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String userId = determineUserId(request);
            List<Md> allMds = mdService.getAllMds(userId);
            
            response.put("success", true);
            response.put("mds", allMds);
            response.put("count", allMds.size());
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "오류: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }
    
    // MD 찜하기 토글 API (추가/제거 통합)
    @PostMapping("/api/{mdId}/wish")
    @ResponseBody
    public Map<String, Object> addMdWish(@PathVariable int mdId, HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 사용자 ID 결정 (JWT 토큰 또는 IP)
            String userId = determineUserId(request);
            
            System.out.println("=== MD 찜하기 토글 요청 ===");
            System.out.println("mdId: " + mdId);
            System.out.println("userId: " + userId);
            
            // 현재 찜 상태 확인 (처리 전)
            boolean beforeWished = mdService.isMdWished(mdId, userId);
            System.out.println("처리 전 찜 상태: " + beforeWished);
            
            // MdService를 통해 찜하기 토글 처리
            boolean result = mdService.addMdWish(mdId, userId);
            System.out.println("찜하기 처리 결과: " + result);
            
            if (result) {
                // 현재 찜 상태 확인 (처리 후)
                boolean afterWished = mdService.isMdWished(mdId, userId);
                System.out.println("처리 후 찜 상태: " + afterWished);
                
                response.put("success", true);
                response.put("isWished", afterWished);
                response.put("message", afterWished ? "찜하기가 완료되었습니다." : "찜하기가 취소되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "찜하기 처리에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.out.println("찜하기 처리 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "찜하기 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    // MD 찜하기 취소 API
    @DeleteMapping("/api/{mdId}/wish")
    @ResponseBody
    public Map<String, Object> removeMdWish(@PathVariable int mdId, HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 사용자 ID 결정 (JWT 토큰 또는 IP)
            String userId = determineUserId(request);
            
            // MdService를 통해 실제 찜하기 취소 처리
            boolean result = mdService.removeMdWish(mdId, userId);
            
            if (result) {
                response.put("success", true);
                response.put("message", "찜하기가 취소되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "찜하기 취소에 실패했습니다.");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "찜하기 취소 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }
    
    // MD 상세 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/{id}")
    public String mdDetail(@PathVariable int id, Model model) {
        // TODO: MdService의 실제 메서드 사용
        Md md = null;
        model.addAttribute("md", md);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "clubmd/mdDetail.jsp");
        return "index";
    }
    
    // MD 등록 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/register")
    public String mdRegisterForm(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "clubmd/mdRegister.jsp");
        return "index";
    }
    
    // MD 등록 API
    @PostMapping("/api/register")
    @ResponseBody
    public Map<String, Object> registerMd(@ModelAttribute Md md, HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 사용자 ID 결정 (JWT 토큰 또는 IP)
            String userId = determineUserId(request);
            
            // MdService를 통해 실제 MD 등록 처리
            boolean result = mdService.registerMd(md);
            
            if (result) {
                response.put("success", true);
                response.put("message", "MD가 성공적으로 등록되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "MD 등록에 실패했습니다.");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "MD 등록 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }

    // MD 추가 API (관리자용)
    @PostMapping("/api/add")
    @ResponseBody
    public Map<String, Object> addMd(
            @RequestParam("mdName") String mdName,
            @RequestParam("placeId") int placeId,
            @RequestParam(value = "contact", required = false) String contact,
            @RequestParam(value = "description", required = false) String description,
            @RequestParam(value = "mdPhoto", required = false) MultipartFile mdPhoto,
            @RequestParam(value = "isVisible", defaultValue = "true") boolean isVisible,
            HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 확인
            String userId = determineUserId(request);
            if (userId == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            
            // JWT 토큰에서 관리자 권한 확인
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                try {
                    if (jwtUtils.validateToken(token)) {
                        String provider = jwtUtils.getProviderFromToken(token);
                        String status = jwtUtils.getStatusFromToken(token);
                        
                        if (!"admin".equals(provider)) {
                            response.put("success", false);
                            response.put("message", "관리자 권한이 필요합니다.");
                            return response;
                        }
                    }
                } catch (Exception e) {
                    response.put("success", false);
                    response.put("message", "권한 확인에 실패했습니다.");
                    return response;
                }
            }
            
            // 필수 필드 검증
            if (mdName == null || mdName.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "MD 이름을 입력해주세요.");
                return response;
            }
            
            if (placeId <= 0) {
                response.put("success", false);
                response.put("message", "가게를 선택해주세요.");
                return response;
            }
            
            // MD 객체 생성
            Md md = new Md();
            md.setMdName(mdName.trim());
            md.setContact(contact != null ? contact.trim() : null);
            md.setDescription(description != null ? description.trim() : null);
            md.setVisible(isVisible);
            md.setCreatedAt(LocalDateTime.now());
            
            // 사진 업로드 처리
            String photoPath = null;
            if (mdPhoto != null && !mdPhoto.isEmpty()) {
                photoPath = saveUploadedFile(mdPhoto);
                if (photoPath != null) {
                    md.setPhoto(photoPath);
                }
            }
            
            // 가게 정보 처리
            md.setPlaceId(placeId);
            
            // MdService를 통해 MD 등록
            boolean result = mdService.registerMd(md);
            
            if (result) {
                response.put("success", true);
                response.put("message", "MD가 성공적으로 추가되었습니다.");
                response.put("mdId", md.getMdId());
            } else {
                response.put("success", false);
                response.put("message", "MD 추가에 실패했습니다.");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "MD 추가 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }
    
    // 파일 업로드 처리 메서드
    private String saveUploadedFile(MultipartFile file) {
        try {
            // 업로드 디렉토리 생성
            String uploadDir = "src/main/webapp/uploads/mdsave/";
            File dir = new File(uploadDir);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            
            // 파일명 생성 (UUID + 원본 파일명)
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String filename = UUID.randomUUID().toString() + extension;
            
            // 파일 저장
            Path filePath = Paths.get(uploadDir + filename);
            Files.copy(file.getInputStream(), filePath);
            
            // 웹 접근 가능한 경로 반환
            return "/uploads/mdsave/" + filename;
            
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    // 검색 제안 API
    @GetMapping("/api/suggestions")
    @ResponseBody
    public Map<String, Object> getSearchSuggestions(
            @RequestParam String keyword,
            @RequestParam String searchType,
            @RequestParam(defaultValue = "5") int limit) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 간단한 검색 제안 로직 (실제로는 데이터베이스에서 검색)
            List<Map<String, String>> suggestions = new ArrayList<>();
            
            if ("mdName".equals(searchType) || "all".equals(searchType)) {
                suggestions.add(Map.of("suggestion", keyword + " MD", "type", "mdName"));
            }
            
            if ("placeName".equals(searchType) || "all".equals(searchType)) {
                suggestions.add(Map.of("suggestion", keyword + " 클럽", "type", "placeName"));
            }
            
            response.put("success", true);
            response.put("suggestions", suggestions);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "검색 제안을 가져오는데 실패했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }

    // 가게 목록 조회 API (MD 추가용)
    @GetMapping("/api/hotplaces")
    @ResponseBody
    public Map<String, Object> getHotplaceList() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Map<String, Object>> hotplaceList = mdService.getHotplaceList();
            
            response.put("success", true);
            response.put("hotplaces", hotplaceList);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "가게 목록을 불러오는데 실패했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }

    // 가게 검색 API (MD 추가용)
    @GetMapping("/api/hotplaces/search")
    @ResponseBody
    public Map<String, Object> searchHotplaces(@RequestParam String keyword) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Map<String, Object>> hotplaceList = mdService.searchHotplaces(keyword);
            
            response.put("success", true);
            response.put("hotplaces", hotplaceList);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "가게 검색에 실패했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }

    // MD 조회 API (수정용)
    @GetMapping("/api/{mdId}")
    @ResponseBody
    public Map<String, Object> getMd(@PathVariable int mdId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Md md = mdService.getMdById(mdId);
            
            if (md != null) {
                response.put("success", true);
                response.put("md", md);
            } else {
                response.put("success", false);
                response.put("message", "MD를 찾을 수 없습니다.");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "MD 조회 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }

    // MD 수정 API (관리자용)
    @PostMapping("/api/edit/{mdId}")
    @ResponseBody
    public Map<String, Object> editMd(
            @PathVariable int mdId,
            @RequestParam("editMdName") String mdName,
            @RequestParam("placeId") int placeId,
            @RequestParam(value = "editContact", required = false) String contact,
            @RequestParam(value = "editDescription", required = false) String description,
            @RequestParam(value = "editMdPhoto", required = false) MultipartFile mdPhoto,
            @RequestParam(value = "editIsVisible", defaultValue = "true") boolean isVisible,
            HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // JWT 토큰에서 관리자 권한 확인
            String authHeader = request.getHeader("Authorization");
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                response.put("success", false);
                response.put("message", "인증이 필요합니다.");
                return response;
            }
            
            String token = authHeader.substring(7);
            String provider = jwtUtils.getProviderFromToken(token);
            
            if (!"admin".equals(provider)) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return response;
            }
            
            // 필수 필드 검증
            if (mdName == null || mdName.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "MD 이름을 입력해주세요.");
                return response;
            }
            
            if (placeId <= 0) {
                response.put("success", false);
                response.put("message", "가게를 선택해주세요.");
                return response;
            }
            
            // 기존 MD 정보 조회
            Md existingMd = mdService.getMdById(mdId);
            if (existingMd == null) {
                response.put("success", false);
                response.put("message", "MD를 찾을 수 없습니다.");
                return response;
            }
            
            // MD 객체 업데이트
            existingMd.setMdName(mdName.trim());
            existingMd.setContact(contact != null ? contact.trim() : null);
            existingMd.setDescription(description != null ? description.trim() : null);
            existingMd.setVisible(isVisible);
            existingMd.setPlaceId(placeId);
            
            // 사진 업로드 처리
            if (mdPhoto != null && !mdPhoto.isEmpty()) {
                String photoPath = saveUploadedFile(mdPhoto);
                if (photoPath != null) {
                    existingMd.setPhoto(photoPath);
                }
            }
            
            // MdService를 통해 MD 수정
            boolean result = mdService.updateMd(existingMd);
            
            if (result) {
                response.put("success", true);
                response.put("message", "MD가 성공적으로 수정되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "MD 수정에 실패했습니다.");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "MD 수정 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }

    // 사용자 ID 결정 메서드 (JWT 토큰 기반)
    private String determineUserId(HttpServletRequest request) {
        // JWT 토큰에서 사용자 ID 추출
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            try {
                // JWT 토큰 유효성 검증
                if (jwtUtils.validateToken(token)) {
                    // JWT 토큰에서 사용자 ID 추출
                    return jwtUtils.getUseridFromToken(token);
                }
            } catch (Exception e) {
                // JWT 파싱 실패시 null 반환
                e.printStackTrace();
            }
        }
        return null; // 로그인하지 않은 사용자
    }
    
    // JWT 토큰 추출 메서드
    private String extractTokenFromRequest(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        return null;
    }
    
    // MD 삭제 API
    @DeleteMapping("/api/delete/{mdId}")
    public ResponseEntity<Map<String, Object>> deleteMd(@PathVariable int mdId, HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // JWT 토큰에서 사용자 정보 추출
            String token = extractTokenFromRequest(request);
            if (token == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(401).body(response);
            }
            
            // 관리자 권한 확인
            String provider = jwtUtils.getProviderFromToken(token);
            if (!"admin".equals(provider)) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }
            
            // MD 삭제 실행
            boolean success = mdService.deleteMd(mdId);
            
            if (success) {
                response.put("success", true);
                response.put("message", "MD가 성공적으로 삭제되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "MD 삭제에 실패했습니다.");
                return ResponseEntity.status(500).body(response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "MD 삭제 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }
    
    // 검색 자동완성 API
    @GetMapping("/api/search-suggestions")
    public ResponseEntity<Map<String, Object>> getSearchSuggestions(
            @RequestParam String keyword,
            @RequestParam String searchType) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Map<String, Object>> suggestions = mdService.getSearchSuggestions(keyword, searchType);
            
            response.put("success", true);
            response.put("suggestions", suggestions);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "검색 자동완성을 불러오는데 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }
}
