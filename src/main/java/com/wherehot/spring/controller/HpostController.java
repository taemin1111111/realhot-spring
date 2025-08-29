package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Hpost;
import com.wherehot.spring.entity.Comment;
import com.wherehot.spring.entity.Category;
import com.wherehot.spring.service.HpostService;
import com.wherehot.spring.service.CategoryService;
import com.wherehot.spring.security.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@Controller
@RequestMapping("/hpost")
public class HpostController {
    
    @Value("${file.upload.hpost-path:src/main/webapp/uploads/hpost}")
    private String hpostUploadPath;
    
    @Autowired
    private ResourceLoader resourceLoader;
    
    @Autowired
    private HpostService hpostService;
    
    @Autowired
    private CategoryService categoryService;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    // 파일 업로드 처리
    private String handleFileUpload(MultipartFile file, String uploadPath) {
        if (file == null || file.isEmpty()) {
            return null;
        }
        
        try {
            // 업로드 디렉토리 생성
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // 파일명 생성 (타임스탬프 + 원본파일명)
            String originalFilename = file.getOriginalFilename();
            String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String newFilename = System.currentTimeMillis() + "_" + originalFilename;
            
            // 파일 저장
            File destFile = new File(uploadPath + File.separator + newFilename);
            file.transferTo(destFile);
            
            return newFilename;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
    
    // IP 주소 가져오기
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty() && !"unknown".equalsIgnoreCase(xForwardedFor)) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty() && !"unknown".equalsIgnoreCase(xRealIp)) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
    
    // 사용자 ID 결정 (로그인된 사용자면 userid, 아니면 IP)
    private String determineUserId(HttpServletRequest request) {
        try {
            // Authorization 헤더에서 JWT 토큰 추출
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                
                // JWT 토큰 유효성 검증
                if (jwtUtils.validateToken(token)) {
                    // 토큰에서 사용자 ID 추출
                    String userId = jwtUtils.getUseridFromToken(token);
                    if (userId != null && !userId.isEmpty()) {
                        return userId;
                    }
                }
            }
            
            // 쿠키에서 토큰 확인
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("jwt_token".equals(cookie.getName())) {
                        String token = cookie.getValue();
                        if (jwtUtils.validateToken(token)) {
                            String userId = jwtUtils.getUseridFromToken(token);
                            if (userId != null && !userId.isEmpty()) {
                                return userId;
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            // JWT 토큰 처리 중 오류 무시
            e.printStackTrace();
        }
        
        // 로그인되지 않은 경우 IP 주소 반환
        String ipAddress = getClientIpAddress(request);
        return ipAddress;
    }
    
    // 사용자 로그인 상태 확인
    private boolean isUserLoggedIn(HttpServletRequest request) {
        try {
            // Authorization 헤더에서 JWT 토큰 추출
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                
                // JWT 토큰 유효성 검증
                if (jwtUtils.validateToken(token)) {
                    String userId = jwtUtils.getUseridFromToken(token);
                    return userId != null && !userId.isEmpty();
                }
            }
            
            // 쿠키에서 토큰 확인
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("jwt_token".equals(cookie.getName())) {
                        String token = cookie.getValue();
                        if (jwtUtils.validateToken(token)) {
                            String userId = jwtUtils.getUseridFromToken(token);
                            return userId != null && !userId.isEmpty();
                        }
                    }
                }
            }
        } catch (Exception e) {
            // JWT 토큰 처리 중 오류 무시
            e.printStackTrace();
        }
        
        return false;
    }
    
    // 카테고리 데이터 로드
    private void loadCategoryData(Model model) {
        List<Category> categories = categoryService.findAllCategories();
        model.addAttribute("categories", categories);
    }
    
    // 게시글 목록 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("")
    public String hpostList(@RequestParam(defaultValue = "1") int page,
                          @RequestParam(defaultValue = "latest") String sort,
                          @RequestParam(defaultValue = "0") int categoryId,
                          Model model) {
        
        List<Hpost> hpostList;
        int totalCount;
        
        if (categoryId > 0) {
            // 카테고리별 조회
            if ("popular".equals(sort)) {
                hpostList = hpostService.getPopularHpostListByCategory(categoryId, page);
            } else {
                hpostList = hpostService.getLatestHpostListByCategory(categoryId, page);
            }
            totalCount = hpostService.getHpostCountByCategory(categoryId);
        } else {
            // 전체 조회
            if ("popular".equals(sort)) {
                hpostList = hpostService.getPopularHpostList(page);
            } else {
                hpostList = hpostService.getLatestHpostList(page);
            }
            totalCount = hpostService.getTotalHpostCount();
        }
        
        model.addAttribute("hpostList", hpostList);
        model.addAttribute("currentPage", page);
        model.addAttribute("sort", sort);
        model.addAttribute("categoryId", categoryId);
        model.addAttribute("totalCount", totalCount);
        
        // 카테고리 데이터 추가
        loadCategoryData(model);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "hpost/hpost.jsp");
        return "index";
    }
    
    // 게시글 상세 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/{id}")
    public String hpostDetail(@PathVariable int id, Model model, HttpSession session, HttpServletRequest request) {
        try {
            // ID 유효성 검사
            if (id <= 0) {
                return "redirect:/hpost";
            }
            
            // 조회수 증가 (세션 기반 중복 방지)
            String viewKey = "hpost_view_" + id;
            if (session.getAttribute(viewKey) == null) {
                hpostService.incrementViewCount(id);
                session.setAttribute(viewKey, true);
            }
            
            // 데이터 조회
            Hpost hpost = hpostService.getHpostByIdWithoutIncrement(id);
            
            if (hpost == null) {
                // 에러 페이지로 리다이렉트 또는 에러 처리
                return "redirect:/hpost";
            }
            
            // 사용자 식별 (JWT 토큰 또는 IP)
            String userKey = determineUserId(request);
            
            // 좋아요/싫어요 개수 조회
            model.addAttribute("hpost", hpost);
            model.addAttribute("userKey", userKey);
            model.addAttribute("isLoggedIn", isUserLoggedIn(request));
            
            // 기존 JSP Include 방식 유지
            model.addAttribute("mainPage", "hpost/hpost_detail.jsp");
            return "index";
            
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/hpost";
        }
    }
    
    // 게시글 작성 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/write")
    public String hpostWriteForm(Model model, HttpServletRequest request) {
        // 로그인 체크
        if (!isUserLoggedIn(request)) {
            return "redirect:/login";
        }
        
        // 카테고리 데이터 추가
        loadCategoryData(model);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "hpost/hpost_write.jsp");
        return "index";
    }
    
    // 게시글 등록 처리
    @PostMapping("/write")
    @ResponseBody
    public Map<String, Object> hpostWrite(@RequestParam("title") String title,
                                         @RequestParam("content") String content,
                                         @RequestParam("categoryId") int categoryId,
                                         @RequestParam(value = "photo1", required = false) MultipartFile photo1,
                                         @RequestParam(value = "photo2", required = false) MultipartFile photo2,
                                         @RequestParam(value = "photo3", required = false) MultipartFile photo3,
                                         HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 로그인 체크
            if (!isUserLoggedIn(request)) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            
            // 사용자 ID 결정
            String userKey = determineUserId(request);
            
            // 게시글 객체 생성
            Hpost hpost = new Hpost();
            hpost.setTitle(title);
            hpost.setContent(content);
            hpost.setCategoryId(categoryId);
            hpost.setUserid(userKey);
            hpost.setUserip(getClientIpAddress(request));
            hpost.setNickname("익명"); // 기본값, 나중에 사용자 정보에서 가져올 수 있음
            
            // 파일 업로드 처리
            if (photo1 != null && !photo1.isEmpty()) {
                String photo1Path = handleFileUpload(photo1, hpostUploadPath);
                hpost.setPhoto1(photo1Path);
            }
            
            if (photo2 != null && !photo2.isEmpty()) {
                String photo2Path = handleFileUpload(photo2, hpostUploadPath);
                hpost.setPhoto2(photo2Path);
            }
            
            if (photo3 != null && !photo3.isEmpty()) {
                String photo3Path = handleFileUpload(photo3, hpostUploadPath);
                hpost.setPhoto3(photo3Path);
            }
            
            // 게시글 저장
            int result = hpostService.createHpost(hpost);
            
            if (result > 0) {
                response.put("success", true);
                response.put("message", "게시글이 등록되었습니다.");
                response.put("postId", hpost.getId());
            } else {
                response.put("success", false);
                response.put("message", "게시글 등록에 실패했습니다.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다.");
        }
        
        return response;
    }
    
    // 게시글 수정 페이지
    @GetMapping("/{id}/edit")
    public String hpostEditForm(@PathVariable int id, Model model, HttpServletRequest request) {
        try {
            // 로그인 체크
            if (!isUserLoggedIn(request)) {
                return "redirect:/login";
            }
            
            // 게시글 조회
            Hpost hpost = hpostService.getHpostById(id);
            if (hpost == null) {
                return "redirect:/hpost";
            }
            
            // 작성자 체크
            String userKey = determineUserId(request);
            if (!userKey.equals(hpost.getUserid())) {
                return "redirect:/hpost/" + id;
            }
            
            model.addAttribute("hpost", hpost);
            
            // 카테고리 데이터 추가
            loadCategoryData(model);
            
            // 기존 JSP Include 방식 유지
            model.addAttribute("mainPage", "hpost/hpost_edit.jsp");
            return "index";
            
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/hpost";
        }
    }
    
    // 게시글 수정 처리
    @PostMapping("/{id}/edit")
    @ResponseBody
    public Map<String, Object> hpostEdit(@PathVariable int id,
                                        @RequestParam("title") String title,
                                        @RequestParam("content") String content,
                                        @RequestParam("categoryId") int categoryId,
                                        @RequestParam(value = "photo1", required = false) MultipartFile photo1,
                                        @RequestParam(value = "photo2", required = false) MultipartFile photo2,
                                        @RequestParam(value = "photo3", required = false) MultipartFile photo3,
                                        HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 로그인 체크
            if (!isUserLoggedIn(request)) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            
            // 게시글 조회
            Hpost hpost = hpostService.getHpostById(id);
            if (hpost == null) {
                response.put("success", false);
                response.put("message", "게시글을 찾을 수 없습니다.");
                return response;
            }
            
            // 작성자 체크
            String userKey = determineUserId(request);
            if (!userKey.equals(hpost.getUserid())) {
                response.put("success", false);
                response.put("message", "수정 권한이 없습니다.");
                return response;
            }
            
            // 게시글 정보 업데이트
            hpost.setTitle(title);
            hpost.setContent(content);
            hpost.setCategoryId(categoryId);
            
            // 파일 업로드 처리
            if (photo1 != null && !photo1.isEmpty()) {
                String photo1Path = handleFileUpload(photo1, hpostUploadPath);
                hpost.setPhoto1(photo1Path);
            }
            
            if (photo2 != null && !photo2.isEmpty()) {
                String photo2Path = handleFileUpload(photo2, hpostUploadPath);
                hpost.setPhoto2(photo2Path);
            }
            
            if (photo3 != null && !photo3.isEmpty()) {
                String photo3Path = handleFileUpload(photo3, hpostUploadPath);
                hpost.setPhoto3(photo3Path);
            }
            
            // 게시글 수정
            int result = hpostService.updateHpost(hpost);
            
            if (result > 0) {
                response.put("success", true);
                response.put("message", "게시글이 수정되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "게시글 수정에 실패했습니다.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다.");
        }
        
        return response;
    }
    
    // 게시글 삭제
    @PostMapping("/{id}/delete")
    @ResponseBody
    public Map<String, Object> hpostDelete(@PathVariable int id, HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 로그인 체크
            if (!isUserLoggedIn(request)) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            
            // 게시글 조회
            Hpost hpost = hpostService.getHpostById(id);
            if (hpost == null) {
                response.put("success", false);
                response.put("message", "게시글을 찾을 수 없습니다.");
                return response;
            }
            
            // 작성자 체크
            String userKey = determineUserId(request);
            if (!userKey.equals(hpost.getUserid())) {
                response.put("success", false);
                response.put("message", "삭제 권한이 없습니다.");
                return response;
            }
            
            // 게시글 삭제
            int result = hpostService.deleteHpost(id);
            
            if (result > 0) {
                response.put("success", true);
                response.put("message", "게시글이 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "게시글 삭제에 실패했습니다.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다.");
        }
        
        return response;
    }
    
    // 좋아요/싫어요 처리
    @PostMapping("/{id}/vote")
    @ResponseBody
    public Map<String, Object> hpostVote(@PathVariable int id,
                                        @RequestParam("voteType") String voteType,
                                        HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            String userKey = determineUserId(request);
            
            // 투표 처리
            hpostService.handleVote(id, userKey, voteType);
            
            // 업데이트된 게시글 정보 조회
            Hpost hpost = hpostService.getHpostById(id);
            
            response.put("success", true);
            response.put("likes", hpost.getLikes());
            response.put("dislikes", hpost.getDislikes());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "투표 처리 중 오류가 발생했습니다.");
        }
        
        return response;
    }
    
    // 게시글 신고
    @PostMapping("/{id}/report")
    @ResponseBody
    public Map<String, Object> hpostReport(@PathVariable int id,
                                          @RequestParam("reason") String reason,
                                          @RequestParam("content") String content,
                                          HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            String userKey = determineUserId(request);
            
            // 신고 처리
            hpostService.reportHpost(id, userKey, reason, content);
            
            response.put("success", true);
            response.put("message", "신고가 접수되었습니다.");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "신고 처리 중 오류가 발생했습니다.");
        }
        
        return response;
    }
    
    // 검색
    @GetMapping("/search")
    public String hpostSearch(@RequestParam("keyword") String keyword,
                             @RequestParam(defaultValue = "all") String searchType,
                             @RequestParam(defaultValue = "1") int page,
                             Model model) {
        
        List<Hpost> hpostList = hpostService.searchHposts(keyword, searchType, page);
        
        model.addAttribute("hpostList", hpostList);
        model.addAttribute("keyword", keyword);
        model.addAttribute("searchType", searchType);
        model.addAttribute("currentPage", page);
        
        // 카테고리 데이터 추가
        loadCategoryData(model);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "hpost/hpost_search.jsp");
        return "index";
    }
}
