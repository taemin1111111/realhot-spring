package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Hpost;
import com.wherehot.spring.entity.Hcomment;
import com.wherehot.spring.service.HpostService;
import com.wherehot.spring.service.HpostVoteService;
import com.wherehot.spring.service.HcommentService;
import com.wherehot.spring.security.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Controller
@RequestMapping("/hpost")
public class HpostController {
    
    @Value("${app.upload.dir:}")
    private String uploadPath;
    
    @Autowired
    private HpostService hpostService;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private HpostVoteService hpostVoteService;
    
    @Autowired
    private HcommentService hcommentService;
    
    /**
     * 인증 정보를 바탕으로 사용자 ID를 안전하게 가져오는 통합 메소드
     */
    private String getUserId(Authentication authentication, HttpServletRequest request) {
        System.out.println("=== getUserId 메서드 시작 ===");
        System.out.println("Authentication 객체: " + (authentication != null ? authentication.getName() : "null"));
        System.out.println("Authentication 인증 상태: " + (authentication != null ? authentication.isAuthenticated() : "null"));
        
        // 1. Spring Security의 Authentication 객체에서 직접 사용자 정보 확인 (가장 표준적인 방법)
        if (authentication != null && authentication.isAuthenticated() && !"anonymousUser".equals(authentication.getName())) {
            System.out.println("Spring Security Authentication으로 사용자 ID 획득: " + authentication.getName());
            return authentication.getName();
        }

        // 2. (Fallback) Authentication 객체가 비어있을 경우를 대비해, HTTP 헤더에서 직접 JWT 토큰 파싱
        String token = request.getHeader("Authorization");
        System.out.println("Authorization 헤더: " + (token != null ? token.substring(0, Math.min(50, token.length())) + "..." : "null"));
        
        if (token != null && token.startsWith("Bearer ")) {
            try {
                String jwtToken = token.substring(7);
                System.out.println("JWT 토큰 추출: " + jwtToken.substring(0, Math.min(30, jwtToken.length())) + "...");
                
                boolean isValid = jwtUtils.validateToken(jwtToken);
                System.out.println("JWT 토큰 유효성 검증 결과: " + isValid);
                
                if (isValid) {
                    String userId = jwtUtils.getUseridFromToken(jwtToken);
                    System.out.println("JWT 토큰에서 사용자 ID 획득: " + userId);
                    return userId;
                } else {
                    System.out.println("JWT 토큰이 유효하지 않음");
                }
            } catch (Exception e) {
                // 토큰 파싱 실패 시, 오류 로깅 후 null 반환
                System.out.println("JWT 토큰 파싱 오류 (getUserId): " + e.getMessage());
                e.printStackTrace();
                return null;
            }
        }
        
        // 3. request attribute에서 사용자 ID 확인 (JWT 필터에서 설정된 값)
        String useridFromAttribute = (String) request.getAttribute("userid");
        if (useridFromAttribute != null) {
            System.out.println("request attribute에서 사용자 ID 획득: " + useridFromAttribute);
            return useridFromAttribute;
        }
        
        System.out.println("사용자 ID 획득 실패 - 비로그인 사용자로 간주");
        // 두 방법 모두 실패 시, 비로그인 사용자로 간주
        return null;
    }

    /**
     * 핫플썰 메인 페이지
     */
    @GetMapping({"", "/"})
    public String hpostMain(@RequestParam(defaultValue = "1") int page,
                           @RequestParam(defaultValue = "latest") String sort,
                           Model model) {
        
        // 페이지 번호 검증
        if (page < 1) {
            page = 1;
        }
        
        int pageSize = 10;
        int offset = (page - 1) * pageSize;
        
        List<Hpost> hpostList;
        int totalCount;
        
        if ("popular".equals(sort)) {
            hpostList = hpostService.getPopularHpostList(offset);
            totalCount = hpostService.getTotalHpostCount();
        } else {
            hpostList = hpostService.getLatestHpostList(offset);
            totalCount = hpostService.getTotalHpostCount();
        }
        
        // 시간 포맷팅
        for (Hpost hpost : hpostList) {
            hpost.setFormattedTime(formatTimeAgo(hpost.getCreatedAt()));
        }
        
        model.addAttribute("hpostList", hpostList);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("currentPage", page);
        model.addAttribute("sort", sort);
        model.addAttribute("mainPage", "hpost/hpost.jsp");
        
        return "index";
    }
    
    /**
     * 핫플썰 상세 페이지
     */
    @GetMapping("/{id}")
    public String hpostDetail(@PathVariable int id, Model model) {
        Hpost hpost = hpostService.getHpostById(id);
        
        if (hpost != null) {
            hpost.setFormattedTime(formatTimeAgo(hpost.getCreatedAt()));
            
            // 좋아요/싫어요 개수 조회
            Map<String, Object> voteStats = hpostVoteService.getVoteStatistics(id);
            model.addAttribute("likeCount", voteStats.get("likes"));
            model.addAttribute("dislikeCount", voteStats.get("dislikes"));
        }
        
        model.addAttribute("hpost", hpost);
        model.addAttribute("mainPage", "hpost/hpostdetail.jsp");
        
        return "index";
    }
    
    /**
     * 글쓰기 처리
     */
    @PostMapping("/write")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> writePost(
            @RequestParam("title") String title,
            @RequestParam("nickname") String nickname,
            @RequestParam("passwd") String passwd,
            @RequestParam("content") String content,
            @RequestParam(value = "photo1", required = false) MultipartFile photo1,
            @RequestParam(value = "photo2", required = false) MultipartFile photo2,
            @RequestParam(value = "photo3", required = false) MultipartFile photo3,
            HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 입력값 검증
            if (title == null || title.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "제목을 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            if (nickname == null || nickname.trim().isEmpty() || nickname.length() > 5) {
                response.put("success", false);
                response.put("message", "닉네임은 5글자 이하로 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            if (passwd == null || passwd.length() != 4 || !passwd.matches("\\d{4}")) {
                response.put("success", false);
                response.put("message", "비밀번호는 숫자 4자리로 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            if (content == null || content.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "내용을 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // JWT 토큰에서 사용자 정보 추출
            String token = request.getHeader("Authorization");
            String userid = null;
            String userip = null;
            
            // ✅ 1. FormData에서 userid 확인 (클라이언트에서 전송한 경우)
            String formUserId = request.getParameter("userid");
            if (formUserId != null && !formUserId.trim().isEmpty()) {
                userid = formUserId.trim();
                userip = null;
                System.out.println("FormData에서 사용자 ID 획득: " + userid);
            }
            // ✅ 2. JWT 토큰에서 사용자 정보 추출 (백업)
            else if (token != null && token.startsWith("Bearer ")) {
                String jwtToken = token.substring(7);
                if (jwtUtils.validateToken(jwtToken)) {
                    userid = jwtUtils.getUseridFromToken(jwtToken);
                    userip = null;
                    System.out.println("JWT 토큰에서 사용자 ID 획득: " + userid);
                }
            }
            
            // ✅ 3. 비로그인 사용자의 경우 IP 주소 사용
            if (userid == null) {
                userid = null; // 비로그인 사용자는 사용자 ID를 null로 설정
                userip = getClientIpAddress(request);
                System.out.println("비로그인 사용자 - IP 주소 사용: " + userip);
            } else {
                System.out.println("로그인된 사용자 - 사용자 ID 사용: " + userid);
            }
            
            // 비밀번호 해시화
            String hashedPassword = passwordEncoder.encode(passwd);
            
            // Hpost 객체 생성
            Hpost hpost = new Hpost();
            hpost.setUserid(userid);
            hpost.setUserip(userip);
            hpost.setNickname(nickname.trim());
            hpost.setPasswd(hashedPassword);
            hpost.setTitle(title.trim());
            hpost.setContent(content.trim());
            hpost.setViews(0);
            hpost.setLikes(0);
            hpost.setDislikes(0);
            hpost.setReports(0);
            hpost.setCreatedAt(LocalDateTime.now());
            
            // 사진 파일 처리
            String photo1Name = saveImageFile(photo1);
            String photo2Name = saveImageFile(photo2);
            String photo3Name = saveImageFile(photo3);
            
            hpost.setPhoto1(photo1Name);
            hpost.setPhoto2(photo2Name);
            hpost.setPhoto3(photo3Name);
            
            // 데이터베이스에 저장
            hpostService.saveHpost(hpost);
            
            response.put("success", true);
            response.put("message", "글이 성공적으로 작성되었습니다.");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "글 작성 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 클라이언트 IP 주소 추출
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty() && !"unknown".equalsIgnoreCase(xForwardedFor)) {
            return xForwardedFor.split(",")[0];
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty() && !"unknown".equalsIgnoreCase(xRealIp)) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
    
    /**
     * JWT 토큰에서 사용자 ID 추출 (로그인한 사용자만)
     */
    private String getUserIdFromToken(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            try {
                String jwtToken = token.substring(7);
                if (jwtUtils.validateToken(jwtToken)) {
                    return jwtUtils.getUseridFromToken(jwtToken);
                }
            } catch (Exception e) {
                System.out.println("JWT 토큰 파싱 오류: " + e.getMessage());
            }
        }
        return null;
    }
    
  
    
    /**
     * 이미지 파일 저장
     */
    private String saveImageFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return null;
        }
        
        try {
            // 파일 확장자 확인
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            
            // 허용된 확장자 확인
            if (!extension.toLowerCase().matches("\\.(jpg|jpeg|png|gif)$")) {
                throw new IllegalArgumentException("지원하지 않는 파일 형식입니다.");
            }
            
            // 고유한 파일명 생성
            String fileName = System.currentTimeMillis() + "_" + UUID.randomUUID().toString() + extension;
            
            // 저장 경로 설정 - 절대 경로 사용
            String absoluteUploadPath = System.getProperty("user.dir") + "/src/main/webapp/uploads/hpostsave";
            File dir = new File(absoluteUploadPath);
            if (!dir.exists()) {
                boolean created = dir.mkdirs();
                if (!created) {
                    throw new RuntimeException("업로드 디렉토리를 생성할 수 없습니다: " + absoluteUploadPath);
                }
            }
            
            // 파일 저장
            File dest = new File(absoluteUploadPath + "/" + fileName);
            file.transferTo(dest);
            
            return fileName;
            
        } catch (IOException e) {
            e.printStackTrace();
            throw new RuntimeException("파일 저장 중 오류가 발생했습니다.");
        }
    }
    
    /**
     * 시간 포맷팅 (몇분전, 몇시간전, 몇일전, 몇주전)
     */
    private String formatTimeAgo(LocalDateTime createdAt) {
        if (createdAt == null) {
            return "";
        }
        
        LocalDateTime now = LocalDateTime.now();
        long minutes = java.time.Duration.between(createdAt, now).toMinutes();
        
        if (minutes < 1) {
            return "방금 전";
        } else if (minutes < 60) {
            return minutes + "분 전";
        } else if (minutes < 1440) { // 24시간
            long hours = minutes / 60;
            return hours + "시간 전";
        } else if (minutes < 10080) { // 7일
            long days = minutes / 1440;
            return days + "일 전";
        } else {
            long weeks = minutes / 10080;
            return weeks + "주 전";
        }
    }
    
    /**
     * 투표 처리 API (좋아요/싫어요) - 로그인/비로그인 모두 지원
     */
    @PostMapping("/{postId}/vote")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> processVote(
            @PathVariable int postId,
            @RequestParam("voteType") String voteType,
            Authentication authentication, // Authentication 객체를 직접 주입받음
            HttpServletRequest request) {
        
        System.out.println("투표 요청 받음 - postId: " + postId + ", voteType: " + voteType);
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            System.out.println("=== 투표 처리 시작 ===");
            System.out.println("Authentication 객체: " + (authentication != null ? authentication.getName() : "null"));
            
            // 투표 타입 검증
            if (!"like".equals(voteType) && !"dislike".equals(voteType)) {
                response.put("success", false);
                response.put("message", "잘못된 투표 타입입니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            String userId = getUserId(authentication, request);
            System.out.println("getUserId 결과: " + userId);

            if (userId != null) {
                // 로그인한 사용자: 사용자 ID로 투표 처리
                System.out.println("투표 요청 - 로그인한 사용자 ID: " + userId);
                Map<String, Object> voteResult = hpostVoteService.processVote(postId, userId, voteType);
                return ResponseEntity.ok(voteResult);
            } else {
                // 비로그인 사용자: IP 주소로 투표 처리
                String ipAddress = getClientIpAddress(request);
                System.out.println("투표 요청 - 비로그인 사용자 IP: " + ipAddress);
                Map<String, Object> voteResult = hpostVoteService.processVote(postId, ipAddress, voteType);
                return ResponseEntity.ok(voteResult);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "투표 처리 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 투표 통계 조회 API
     */
    @GetMapping("/{postId}/vote-stats")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getVoteStatistics(@PathVariable int postId) {
        try {
            Map<String, Object> statistics = hpostVoteService.getVoteStatistics(postId);
            statistics.put("success", true);
            return ResponseEntity.ok(statistics);
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "투표 통계 조회 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 사용자 투표 상태 조회 API - 로그인/비로그인 모두 지원
     */
    @PostMapping("/{postId}/vote-status") // URL 경로 변경: user-vote -> vote-status
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getUserVoteStatus(
            @PathVariable int postId,
            @RequestParam(value = "check", required = false) String check, // 성공하는 API와 시그니처를 맞추기 위한 더미 파라미터
            Authentication authentication, // Authentication 객체를 직접 주입받음
            HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            System.out.println("=== 투표 상태 확인 시작 ===");
            System.out.println("Authentication 객체: " + (authentication != null ? authentication.getName() : "null"));
            
            String userId = getUserId(authentication, request);
            System.out.println("getUserId 결과: " + userId);

            if (userId != null) {
                System.out.println("투표 상태 확인 - 로그인한 사용자 ID: " + userId);
                String voteStatus = hpostVoteService.getUserVoteStatus(postId, userId);
                
                response.put("success", true);
                response.put("voteStatus", voteStatus);
                response.put("isLoggedIn", true);
                response.put("userId", userId);
                
                System.out.println("로그인한 사용자 응답: " + response);
                return ResponseEntity.ok(response);
            }
            
            // 비로그인 사용자인 경우: IP 주소로 투표 상태 확인
            String ipAddress = getClientIpAddress(request);
            System.out.println("투표 상태 확인 - 비로그인 사용자 IP: " + ipAddress);
            
            String voteStatus = hpostVoteService.getUserVoteStatus(postId, ipAddress);
            response.put("success", true);
            response.put("voteStatus", voteStatus);
            response.put("isLoggedIn", false);
            response.put("ipAddress", ipAddress);
            
            System.out.println("비로그인 사용자 응답: " + response);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "투표 상태 조회 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }

    // ================= 댓글 API 추가 =================

    /**
     * 댓글 목록 조회 API
     */
    @GetMapping("/{postId}/comments")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getComments(
            @PathVariable int postId,
            @RequestParam(value = "sort", defaultValue = "latest") String sort,
            Authentication authentication, // Authentication 객체를 직접 주입받음
            HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        try {
            String userIdOrIp;
            String userId = getUserId(authentication, request);
            
            if (userId != null) {
                userIdOrIp = userId;
                System.out.println("댓글 목록 조회 - 로그인한 사용자 ID: " + userIdOrIp);
            } else {
                userIdOrIp = getClientIpAddress(request);
                System.out.println("댓글 목록 조회 - 비로그인 사용자 IP: " + userIdOrIp);
            }
            
            List<Hcomment> comments = hcommentService.getCommentsByPostIdWithUserReaction(postId, userIdOrIp);
            
            // 정렬 처리
            if ("popular".equals(sort)) {
                // 인기순: 좋아요 수 기준으로 내림차순 정렬
                comments.sort((a, b) -> {
                    int aLikes = a.getLikes() != null ? a.getLikes() : 0;
                    int bLikes = b.getLikes() != null ? b.getLikes() : 0;
                    if (aLikes != bLikes) {
                        return Integer.compare(bLikes, aLikes); // 좋아요 수 내림차순
                    } else {
                        // 좋아요 수가 같으면 최신순으로 정렬
                        return a.getCreatedAt().compareTo(b.getCreatedAt());
                    }
                });
            } else {
                // 최신순: 기본값, createdAt 기준으로 내림차순 정렬
                comments.sort((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()));
            }
            
            response.put("success", true);
            response.put("comments", comments);
            response.put("totalCount", comments.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "댓글을 불러오는데 실패했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 댓글 작성 API
     */
    @PostMapping("/{postId}/comment")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addComment(
            @PathVariable int postId,
            @RequestParam("nickname") String nickname,
            @RequestParam(value = "password", required = false) String password,
            @RequestParam("content") String content,
            Authentication authentication, // Authentication 객체를 직접 주입받음
            HttpServletRequest request) {

        Map<String, Object> response = new HashMap<>();
        try {
            Hcomment comment = new Hcomment();
            comment.setPostId(postId);
            comment.setNickname(nickname);
            comment.setContent(content);

            String userId = getUserId(authentication, request);
            
            if (userId != null) {
                // 로그인한 사용자
                comment.setIpAddress(null);
                comment.setIdAddress(userId);
                comment.setPasswd(null);
                System.out.println("댓글 작성 - 로그인한 사용자 ID: " + userId);
            } else {
                // 비로그인 사용자: IP 주소 사용
                String ipAddress = getClientIpAddress(request);
                comment.setIpAddress(ipAddress);
                comment.setIdAddress(null);
                
                if (password == null || password.trim().isEmpty()) {
                    response.put("success", false);
                    response.put("message", "비밀번호를 입력해주세요.");
                    return ResponseEntity.badRequest().body(response);
                }
                comment.setPasswd(passwordEncoder.encode(password));
                System.out.println("댓글 작성 - 비로그인 사용자 IP: " + ipAddress);
            }

            Hcomment createdComment = hcommentService.createComment(comment);
            
            response.put("success", true);
            response.put("comment", createdComment);
            response.put("message", "댓글이 성공적으로 등록되었습니다.");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "댓글 등록 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 댓글 좋아요 API
     */
    @PostMapping("/comment/{commentId}/like")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> likeComment(
            @PathVariable int commentId,
            HttpServletRequest request) {
        
        Map<String, Object> response;
        try {
            // JWT 토큰에서 사용자 ID 추출 시도
            String userId = getUserIdFromToken(request);
            String userIdOrIp;
            
            if (userId != null) {
                userIdOrIp = userId;
                System.out.println("댓글 좋아요 - 로그인한 사용자 ID: " + userId);
            } else {
                userIdOrIp = getClientIpAddress(request);
                System.out.println("댓글 좋아요 - 비로그인 사용자 IP: " + userIdOrIp);
            }
            
            response = hcommentService.toggleLike(commentId, userIdOrIp);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            response = new HashMap<>();
            response.put("success", false);
            response.put("message", "좋아요 처리 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 댓글 좋아요/싫어요 토글 API
     */
    @PostMapping("/comment/{commentId}/reaction")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> toggleCommentReaction(
            @PathVariable int commentId,
            @RequestParam("reactionType") String reactionType,
            Authentication authentication, // Authentication 객체를 직접 주입받음
            HttpServletRequest request) {
        
        Map<String, Object> response;
        try {
            String userIdOrIp;
            String userId = getUserId(authentication, request);
            
            if (userId != null) {
                userIdOrIp = userId;
                System.out.println("댓글 리액션 - 로그인한 사용자 ID: " + userIdOrIp);
            } else {
                userIdOrIp = getClientIpAddress(request);
                System.out.println("댓글 리액션 - 비로그인 사용자 IP: " + userIdOrIp);
            }
            
            response = hcommentService.toggleReaction(commentId, userIdOrIp, reactionType);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            response = new HashMap<>();
            response.put("success", false);
            response.put("message", "리액션 처리 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 댓글 삭제 API
     */
    @DeleteMapping("/{postId}/comment/{commentId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteComment(
            @PathVariable int postId,
            @PathVariable int commentId,
            @RequestParam(value = "nickname", required = false) String nickname,
            @RequestParam(value = "password", required = false) String password,
            Authentication authentication, // Authentication 객체를 직접 주입받음
            HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();
        try {
            String userId = getUserId(authentication, request);

            boolean deleteResult;
            if (userId != null) {
                // 로그인한 사용자
                System.out.println("댓글 삭제 - 로그인한 사용자 ID: " + userId);
                deleteResult = hcommentService.deleteCommentByUser(commentId, userId);
            } else {
                // 비로그인 사용자
                System.out.println("댓글 삭제 - 비로그인 사용자");
                if (nickname == null || password == null) {
                    response.put("success", false);
                    response.put("message", "닉네임과 비밀번호를 입력해주세요.");
                    return ResponseEntity.badRequest().body(response);
                }
                deleteResult = hcommentService.deleteComment(commentId, nickname, password);
            }
            
            if (deleteResult) {
                response.put("success", true);
                response.put("message", "댓글이 삭제되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "댓글 삭제에 실패했습니다. 권한을 확인해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "댓글 삭제 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 게시글 삭제 API
     */
    @DeleteMapping("/{id}/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteHpost(
            @PathVariable int id,
            @RequestBody Map<String, String> requestBody,
            HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();
        try {
            String password = requestBody.get("password");
            
            if (password == null || password.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "비밀번호를 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 게시글 조회
            Hpost hpost = hpostService.getHpostById(id);
            if (hpost == null) {
                response.put("success", false);
                response.put("message", "게시글을 찾을 수 없습니다.");
                return ResponseEntity.notFound().build();
            }
            
            // 비밀번호 확인 (해시화된 비밀번호와 비교)
            if (!passwordEncoder.matches(password, hpost.getPasswd())) {
                response.put("success", false);
                response.put("message", "비밀번호가 일치하지 않습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 게시글 삭제 (연관된 데이터도 함께 삭제)
            boolean deleteResult = hpostService.deleteHpostWithAllData(id);
            
            if (deleteResult) {
                // 파일 삭제
                deleteHpostFiles(hpost);
                
                response.put("success", true);
                response.put("message", "게시글이 삭제되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "게시글 삭제에 실패했습니다.");
                return ResponseEntity.internalServerError().body(response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "게시글 삭제 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 게시글 관련 파일 삭제
     */
    private void deleteHpostFiles(Hpost hpost) {
        try {
            if (uploadPath != null && !uploadPath.isEmpty()) {
                // photo1 삭제
                if (hpost.getPhoto1() != null && !hpost.getPhoto1().trim().isEmpty()) {
                    File photo1File = new File(uploadPath + "/hpostsave/" + hpost.getPhoto1());
                    if (photo1File.exists()) {
                        photo1File.delete();
                        System.out.println("파일 삭제 완료: " + hpost.getPhoto1());
                    }
                }
                
                // photo2 삭제
                if (hpost.getPhoto2() != null && !hpost.getPhoto2().trim().isEmpty()) {
                    File photo2File = new File(uploadPath + "/hpostsave/" + hpost.getPhoto2());
                    if (photo2File.exists()) {
                        photo2File.delete();
                        System.out.println("파일 삭제 완료: " + hpost.getPhoto2());
                    }
                }
                
                // photo3 삭제
                if (hpost.getPhoto3() != null && !hpost.getPhoto3().trim().isEmpty()) {
                    File photo3File = new File(uploadPath + "/hpostsave/" + hpost.getPhoto3());
                    if (photo3File.exists()) {
                        photo3File.delete();
                        System.out.println("파일 삭제 완료: " + hpost.getPhoto3());
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("파일 삭제 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
