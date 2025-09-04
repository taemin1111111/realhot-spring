package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Md;
import com.wherehot.spring.service.MdService;
import com.wherehot.spring.security.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.ModelAttribute;
import jakarta.servlet.http.HttpServletRequest;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

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
}
