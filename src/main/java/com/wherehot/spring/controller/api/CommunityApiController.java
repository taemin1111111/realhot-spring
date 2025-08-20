package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.Comment;
import com.wherehot.spring.entity.Post;
import com.wherehot.spring.entity.PostReport;
import com.wherehot.spring.entity.CommunityCategory;
import com.wherehot.spring.service.CommentService;
import com.wherehot.spring.service.PostService;
import com.wherehot.spring.service.PostReportService;
import com.wherehot.spring.service.CommunityCategoryService;
import com.wherehot.spring.service.PostVoteService;
import com.wherehot.spring.service.CommentVoteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 커뮤니티 통합 API 컨트롤러
 */
@RestController
@RequestMapping("/api/community")
public class CommunityApiController {

    @Autowired
    private PostService postService;

    @Autowired
    private CommentService commentService;
    
    @Autowired
    private PostReportService postReportService;

    @Autowired
    private CommunityCategoryService communityCategoryService;
    
    @Autowired
    
    private PostVoteService postVoteService;
    
    @Autowired
    private CommentVoteService commentVoteService;
    
    @Value("${file.upload.community-path:src/main/webapp/uploads/hpostsave}")
    private String communityUploadPath;

    /**
     * 커뮤니티 카테고리 목록 조회
     */
    @GetMapping("/categories")
    public ResponseEntity<Map<String, Object>> getCategories() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 실제 커뮤니티 카테고리 조회 (기존 community_category 테이블에서)
            // 서비스에서 이미 게시글 수까지 포함해서 조회함
            List<CommunityCategory> categories = communityCategoryService.findAllCategories();
            
            response.put("success", true);
            response.put("categories", categories);
            response.put("total", categories.size());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "카테고리 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 게시글 조회수 증가
     */
    @PostMapping("/post/{postId}/view")
    public ResponseEntity<Map<String, Object>> incrementPostView(@PathVariable int postId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean success = postService.incrementViewCount(postId);
            
            if (success) {
                response.put("success", true);
                response.put("message", "조회수가 증가되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "조회수 증가에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "조회수 증가 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 게시글 상세 조회 (Model1 호환)
     */
    @GetMapping("/post/{postId}")
    public ResponseEntity<Map<String, Object>> getPostDetail(@PathVariable int postId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Post post = postService.findById(postId);
            
            if (post != null) {
                response.put("success", true);
                response.put("post", post);
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "게시글을 찾을 수 없습니다.");
                return ResponseEntity.notFound().build();
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "게시글 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 게시글 좋아요/싫어요 처리
     */
    @PostMapping("/post/{postId}/vote")
    public ResponseEntity<Map<String, Object>> votePost(
            @PathVariable int postId,
            @RequestParam String action, // "like" or "dislike"
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (userDetails == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(401).body(response);
            }
            
            String username = userDetails.getUsername();
            
            // 투표 처리
            PostVoteService.VoteResult voteResult = postVoteService.votePost(postId, username, action);
            
            response.put("success", voteResult.isSuccess());
            response.put("message", voteResult.getMessage());
            
            if (voteResult.isSuccess()) {
                response.put("action", voteResult.getAction());
                response.put("voteType", voteResult.getVoteType());
                response.put("likeCount", voteResult.getLikeCount());
                response.put("dislikeCount", voteResult.getDislikeCount());
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "투표 처리 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 댓글 추가
     */
    @PostMapping("/post/{postId}/comment")
    public ResponseEntity<Map<String, Object>> addComment(
            @PathVariable int postId,
            @RequestParam String content,
            @RequestParam(required = false) String nickname,
            @RequestParam(required = false) String passwd,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            Comment comment = new Comment();
            comment.setPost_id(postId);
            comment.setContent(content);
            
            if (userDetails != null) {
                // 로그인 사용자
                comment.setNickname(userDetails.getUsername());
            } else {
                // 비로그인 사용자
                if (nickname == null || passwd == null) {
                    response.put("success", false);
                    response.put("message", "닉네임과 비밀번호가 필요합니다.");
                    return ResponseEntity.badRequest().body(response);
                }
                comment.setNickname(nickname);
                comment.setPasswd(passwd); // TODO: 비밀번호 암호화 저장
            }
            
            Comment savedComment = commentService.saveComment(comment);
            
            if (savedComment != null) {
                response.put("success", true);
                response.put("message", "댓글이 등록되었습니다.");
                response.put("comment", savedComment);
            } else {
                response.put("success", false);
                response.put("message", "댓글 등록에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "댓글 등록 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 댓글 목록 조회
     */
    @GetMapping("/post/{postId}/comments")
    public ResponseEntity<Map<String, Object>> getComments(@PathVariable int postId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // TODO: CommentService에 findByPostId 메서드 구현 필요
            List<Comment> comments = new java.util.ArrayList<>();
            
            response.put("success", true);
            response.put("comments", comments);
            response.put("totalCount", comments.size());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "댓글 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 댓글 투표 처리
     */
    @PostMapping("/comment/{commentId}/vote")
    public ResponseEntity<Map<String, Object>> voteComment(
            @PathVariable int commentId,
            @RequestParam String action, // "like" or "dislike"
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (userDetails == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(401).body(response);
            }
            
            String username = userDetails.getUsername();
            
            // 댓글 투표 처리
            CommentVoteService.VoteResult voteResult = commentVoteService.voteComment(commentId, username, action);
            
            response.put("success", voteResult.isSuccess());
            response.put("message", voteResult.getMessage());
            
            if (voteResult.isSuccess()) {
                response.put("action", voteResult.getAction());
                response.put("voteType", voteResult.getVoteType());
                response.put("likeCount", voteResult.getLikeCount());
                response.put("dislikeCount", voteResult.getDislikeCount());
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "댓글 투표 처리 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 게시글 삭제 (작성자 본인 또는 관리자)
     */
    @DeleteMapping("/post/{postId}")
    public ResponseEntity<Map<String, Object>> deletePost(
            @PathVariable int postId,
            @RequestParam(required = false) String passwd,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            Post post = postService.findById(postId);
            if (post == null) {
                response.put("success", false);
                response.put("message", "게시글을 찾을 수 없습니다.");
                return ResponseEntity.notFound().build();
            }
            
            // 권한 확인
            boolean hasPermission = false;
            
            if (userDetails != null) {
                String username = userDetails.getUsername();
                // 작성자 본인이거나 관리자인 경우
                if (post.getUserid().equals(username) || isAdmin(userDetails)) {
                    hasPermission = true;
                }
            } else {
                // 비로그인 사용자는 비밀번호 확인
                // TODO: 비밀번호 검증 로직 구현
                if (passwd != null && !passwd.isEmpty()) {
                    // hasPermission = passwordEncoder.matches(passwd, post.getPassword());
                    response.put("success", false);
                    response.put("message", "비밀번호 검증 기능은 추후 구현 예정입니다.");
                    return ResponseEntity.ok(response);
                }
            }
            
            if (!hasPermission) {
                response.put("success", false);
                response.put("message", "삭제 권한이 없습니다.");
                return ResponseEntity.status(403).body(response);
            }
            
            boolean success = postService.deletePost(postId);
            
            if (success) {
                response.put("success", true);
                response.put("message", "게시글이 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "게시글 삭제에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "게시글 삭제 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 게시글 신고 (Model1: report action)
     */
    @PostMapping("/post/{postId}/report")
    public ResponseEntity<Map<String, Object>> reportPost(
            @PathVariable int postId,
            @RequestParam String reason,
            @RequestParam(required = false) String detail,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (userDetails == null) {
                response.put("success", false);
                response.put("message", "로그인 후 이용해 주세요.");
                return ResponseEntity.status(401).body(response);
            }
            
            String userId = userDetails.getUsername();
            
            if (reason == null || reason.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "신고 사유가 필요합니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 중복 신고 체크
            if (postReportService.hasUserReported(postId, userId)) {
                response.put("success", false);
                response.put("message", "이미 신고하셨습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 신고 정보를 PostReport 엔티티에 저장
            PostReport postReport = new PostReport(postId, userId, reason, detail != null ? detail : "");
            PostReport savedReport = postReportService.createReport(postReport);
            
            if (savedReport != null) {
                // 게시글의 신고 수도 증가
                boolean postUpdateSuccess = postService.incrementReportCount(postId);
                
                if (postUpdateSuccess) {
                    response.put("success", true);
                    response.put("message", "신고가 성공적으로 접수되었습니다.");
                    response.put("reportId", savedReport.getId());
                } else {
                    response.put("success", true);
                    response.put("message", "신고가 접수되었으나 게시글 업데이트에 실패했습니다.");
                    response.put("reportId", savedReport.getId());
                }
            } else {
                response.put("success", false);
                response.put("message", "신고 처리 실패");
                return ResponseEntity.internalServerError().body(response);
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "신고 처리 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 신고 상태 확인 (Model1: checkReport action)
     */
    @GetMapping("/post/{postId}/report/check")
    public ResponseEntity<Map<String, Object>> checkReportStatus(
            @PathVariable int postId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (userDetails == null) {
                response.put("alreadyReported", false);
                response.put("message", "로그인 후 이용해 주세요.");
                return ResponseEntity.status(401).body(response);
            }
            
            String userId = userDetails.getUsername();
            boolean alreadyReported = postReportService.hasUserReported(postId, userId);
            
            response.put("success", true);
            response.put("alreadyReported", alreadyReported);
            response.put("reportCount", postReportService.getReportCountByPostId(postId));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "신고 상태 확인 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 게시글별 신고 목록 조회 (관리자용)
     */
    @GetMapping("/post/{postId}/reports")
    public ResponseEntity<Map<String, Object>> getPostReports(
            @PathVariable int postId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (userDetails == null || !isAdmin(userDetails)) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }
            
            List<PostReport> reports = postReportService.findReportsByPostId(postId);
            
            response.put("success", true);
            response.put("reports", reports);
            response.put("totalCount", reports.size());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "신고 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 전체 신고 목록 조회 (관리자용)
     */
    @GetMapping("/reports")
    public ResponseEntity<Map<String, Object>> getAllReports(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (userDetails == null || !isAdmin(userDetails)) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }
            
            List<PostReport> reports = postReportService.findAllReportsWithPostInfoPaged(page, pageSize);
            int totalCount = postReportService.getTotalReportCount();
            int totalPages = postReportService.getTotalPages(pageSize);
            
            response.put("success", true);
            response.put("reports", reports);
            response.put("totalCount", totalCount);
            response.put("totalPages", totalPages);
            response.put("currentPage", page);
            response.put("pageSize", pageSize);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "신고 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 신고 삭제 (관리자용)
     */
    @DeleteMapping("/report/{reportId}")
    public ResponseEntity<Map<String, Object>> deleteReport(
            @PathVariable int reportId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (userDetails == null || !isAdmin(userDetails)) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }
            
            boolean success = postReportService.deleteReport(reportId);
            
            if (success) {
                response.put("success", true);
                response.put("message", "신고가 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "신고 삭제에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "신고 삭제 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 게시글 목록 조회 (카테고리별, 정렬, 페이징)
     * Model1의 hpost_list.jsp 로직을 REST API로 변환
     */
    @GetMapping("/posts")
    public ResponseEntity<Map<String, Object>> getPostList(
            @RequestParam(defaultValue = "1") int categoryId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "30") int perPage,
            @RequestParam(required = false) String sort) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Post> posts;
            int totalCount;
            
            if ("popular".equals(sort)) {
                // 인기글 정렬 (좋아요 수 기준)
                posts = postService.findPopularPostsByCategory(categoryId, page, perPage);
                totalCount = postService.getPostCountByCategory(categoryId);
            } else {
                // 최신순 정렬 (기본)
                posts = postService.findPostsByCategory(categoryId, page, perPage);
                totalCount = postService.getPostCountByCategory(categoryId);
            }
            
            int totalPages = (int) Math.ceil((double) totalCount / perPage);
            
            // 각 게시글의 추가 정보는 별도로 조회하여 응답에 포함
            // Post Entity에는 commentCount, likeCount, dislikeCount 필드가 없음
            
            response.put("success", true);
            response.put("posts", posts);
            response.put("totalCount", totalCount);
            response.put("totalPages", totalPages);
            response.put("currentPage", page);
            response.put("perPage", perPage);
            response.put("categoryId", categoryId);
            response.put("sortType", sort);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "게시글 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 게시글 작성
     */
    @PostMapping(value = "/posts", consumes = {"multipart/form-data"})
    public ResponseEntity<Map<String, Object>> createPost(
            @RequestParam("categoryId") int categoryId,
            @RequestParam("title") String title,
            @RequestParam("content") String content,
            @RequestParam(value = "photo1", required = false) MultipartFile photo1,
            @RequestParam(value = "photo2", required = false) MultipartFile photo2,
            @RequestParam(value = "photo3", required = false) MultipartFile photo3,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (userDetails == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(401).body(response);
            }
            
            String userId = userDetails.getUsername();
            
            // 게시글 생성
            Post post = new Post();
            post.setCategory_id(categoryId);
            post.setUserid(userId);
            post.setTitle(title);
            post.setContent(content);
            
            // 3개 사진 업로드 처리 (Model1 호환)
            Path uploadPath = Paths.get(communityUploadPath);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            // photo1 처리
            if (photo1 != null && !photo1.isEmpty()) {
                try {
                    String fileName1 = System.currentTimeMillis() + "_1_" + photo1.getOriginalFilename();
                    Path filePath1 = uploadPath.resolve(fileName1);
                    Files.copy(photo1.getInputStream(), filePath1);
                    post.setPhoto1(fileName1);
                } catch (IOException e) {
                    response.put("success", false);
                    response.put("message", "첫 번째 사진 업로드에 실패했습니다: " + e.getMessage());
                    return ResponseEntity.status(500).body(response);
                }
            }
            
            // photo2 처리
            if (photo2 != null && !photo2.isEmpty()) {
                try {
                    String fileName2 = System.currentTimeMillis() + "_2_" + photo2.getOriginalFilename();
                    Path filePath2 = uploadPath.resolve(fileName2);
                    Files.copy(photo2.getInputStream(), filePath2);
                    post.setPhoto2(fileName2);
                } catch (IOException e) {
                    response.put("success", false);
                    response.put("message", "두 번째 사진 업로드에 실패했습니다: " + e.getMessage());
                    return ResponseEntity.status(500).body(response);
                }
            }
            
            // photo3 처리
            if (photo3 != null && !photo3.isEmpty()) {
                try {
                    String fileName3 = System.currentTimeMillis() + "_3_" + photo3.getOriginalFilename();
                    Path filePath3 = uploadPath.resolve(fileName3);
                    Files.copy(photo3.getInputStream(), filePath3);
                    post.setPhoto3(fileName3);
                } catch (IOException e) {
                    response.put("success", false);
                    response.put("message", "세 번째 사진 업로드에 실패했습니다: " + e.getMessage());
                    return ResponseEntity.status(500).body(response);
                }
            }
            
            // 게시글 저장
            Post savedPost = postService.savePost(post);
            
            if (savedPost != null) {
                response.put("success", true);
                response.put("message", "게시글이 성공적으로 작성되었습니다.");
                response.put("postId", savedPost.getId());
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "게시글 작성에 실패했습니다.");
                return ResponseEntity.internalServerError().body(response);
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "게시글 작성 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 이미지 업로드 (CommunityController에서 이동)
     */
    @PostMapping("/upload-image")
    public ResponseEntity<Map<String, Object>> uploadImage(@RequestParam("file") MultipartFile file) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 업로드 디렉토리 설정
            Path uploadPath = Paths.get(communityUploadPath);
            
            // 디렉토리가 없으면 생성
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            // 파일명 생성 (중복 방지를 위해 타임스탬프 추가)
            String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            Path filePath = uploadPath.resolve(fileName);
            
            // 파일 저장
            Files.copy(file.getInputStream(), filePath);
            
            // 성공 응답
            response.put("success", true);
            response.put("fileName", fileName);
            response.put("message", "이미지가 성공적으로 업로드되었습니다.");
            
            return ResponseEntity.ok(response);
            
        } catch (IOException e) {
            response.put("success", false);
            response.put("message", "이미지 업로드에 실패했습니다: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 이미지 서빙 (CommunityController에서 이동)
     */
    @GetMapping("/images/{filename:.+}")
    public ResponseEntity<Resource> serveImage(@PathVariable String filename) {
        try {
            // 이미지 파일 경로
            Path imagePath = Paths.get(communityUploadPath).resolve(filename);
            Resource resource = new UrlResource(imagePath.toUri());
            
            if (resource.exists() && resource.isReadable()) {
                return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + filename + "\"")
                    .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }

    /**
     * 관리자 권한 확인
     */
    private boolean isAdmin(UserDetails userDetails) {
        return userDetails.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("ROLE_ADMIN"));
    }
}
