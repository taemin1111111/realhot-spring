package com.wherehot.spring.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;

import com.wherehot.spring.entity.CommunityCategory;
import com.wherehot.spring.entity.Post;
import com.wherehot.spring.service.CategoryService;
import com.wherehot.spring.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import java.util.List;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.io.IOException;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Controller
public class CommunityController {

    private static final Logger logger = LoggerFactory.getLogger(CommunityController.class);
    
    @Autowired
    private CategoryService categoryService;
    
    @Autowired
    private PostService postService;

    /**
     * 커뮤니티 카테고리 목록 API
     */
    @GetMapping(value = "/api/community/categories", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public List<CommunityCategory> getCategories() {
        // 임시로 빈 리스트 반환 (CommunityCategory 서비스 구현 필요)
        return java.util.Collections.emptyList();
    }
    
    /**
     * 카테고리별 게시글 목록 조회
     */
    @GetMapping("/api/community/posts")
    public String getCategoryPosts(
            @RequestParam(required = false) Integer category,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(required = false) String sort,
            Model model) {
        
        if (category != null) model.addAttribute("categoryId", category);
        model.addAttribute("page", page);
        if (sort != null) model.addAttribute("sort", sort);
        
        return "community/hpost_list";
    }
    
    /**
     * 게시글 상세 조회
     */
    @GetMapping("/api/community/post/detail")
    public String getPostDetail(@RequestParam int id, Model model) {
        model.addAttribute("postId", id);
        return "community/hpost_detail";
    }
    
    /**
     * 게시글 액션 처리 (좋아요, 싫어요, 신고 등)
     */
    @GetMapping("/api/community/post/action")
    public String getPostAction(
            @RequestParam String action,
            @RequestParam int id,
            Model model) {
        
        model.addAttribute("action", action);
        model.addAttribute("postId", id);
        
        return "community/hpost_action";
    }
    
    /**
     * 게시글 액션 처리 (POST 방식)
     */
    @PostMapping("/api/community/post/action")
    public String postAction(
            @RequestParam String action,
            @RequestParam int id,
            Model model) {
        
        model.addAttribute("action", action);
        model.addAttribute("postId", id);
        
        return "community/hpost_action";
    }
    
    /**
     * 댓글 목록 조회 (HTML 반환)
     */
    @GetMapping("/api/community/comments")
    public String getComments(
            @RequestParam String action,
            @RequestParam int post_id,
            @RequestParam(defaultValue = "latest") String sort,
            Model model) {
        
        model.addAttribute("action", action);
        model.addAttribute("postId", post_id);
        model.addAttribute("sortType", sort);
        
        return "community/hpost_comment_action";
    }
    
    /**
     * 댓글 액션 처리 (작성, 수정, 삭제) - GET
     */
    @GetMapping("/api/community/comment/action")
    public String getCommentAction(
            @RequestParam String action,
            @RequestParam(required = false) Integer post_id,
            @RequestParam(required = false) Integer comment_id,
            @RequestParam(required = false) String content,
            Model model) {
        
        model.addAttribute("action", action);
        if (post_id != null) model.addAttribute("postId", post_id);
        if (comment_id != null) model.addAttribute("commentId", comment_id);
        if (content != null) model.addAttribute("content", content);
        
        return "community/hpost_comment_action";
    }
    
    /**
     * 댓글 액션 처리 (작성, 수정, 삭제) - POST
     */
    @PostMapping("/api/community/comment/action")
    public String commentAction(
            @RequestParam String action,
            @RequestParam(required = false) Integer post_id,
            @RequestParam(required = false) Integer comment_id,
            @RequestParam(required = false) String content,
            Model model) {
        
        model.addAttribute("action", action);
        if (post_id != null) model.addAttribute("postId", post_id);
        if (comment_id != null) model.addAttribute("commentId", comment_id);
        if (content != null) model.addAttribute("content", content);
        
        return "community/hpost_comment_action";
    }
    
    /**
     * 댓글 투표 처리 (좋아요, 싫어요) - GET
     */
    @GetMapping("/api/community/comment/vote")
    public String getCommentVote(
            @RequestParam String action,
            @RequestParam int comment_id,
            Model model) {
        
        model.addAttribute("action", action);
        model.addAttribute("commentId", comment_id);
        
        return "community/hpost_comment_vote_action";
    }
    
    /**
     * 댓글 투표 처리 (좋아요, 싫어요) - POST
     */
    @PostMapping("/api/community/comment/vote")
    public String commentVote(
            @RequestParam String action,
            @RequestParam int comment_id,
            Model model) {
        
        model.addAttribute("action", action);
        model.addAttribute("commentId", comment_id);
        
        return "community/hpost_comment_vote_action";
    }
    
    /**
     * 게시글 삭제 - GET
     */
    @GetMapping("/api/community/post/delete")
    public String getDeletePost(@RequestParam int id, Model model) {
        model.addAttribute("postId", id);
        return "community/hpost_delete_action";
    }
    
    /**
     * 게시글 삭제 - POST
     */
    @PostMapping("/api/community/post/delete")
    public String deletePost(@RequestParam int id, Model model) {
        model.addAttribute("postId", id);
        return "community/hpost_delete_action";
    }

    // 글쓰기 폼
    @GetMapping("/api/community/post/write")
    public String getWriteForm(@RequestParam(defaultValue = "1") int category, Model model) {
        // 카테고리별 정보 설정
        String categoryIcon = "❤️";
        String categoryName = "헌팅썰";
        
        switch(category) {
            case 1:
                categoryIcon = "❤️";
                categoryName = "헌팅썰";
                break;
            case 2:
                categoryIcon = "📍";
                categoryName = "코스 추천";
                break;
            case 3:
                categoryIcon = "👥";
                categoryName = "같이 갈래";
                break;
            default:
                categoryIcon = "💬";
                categoryName = "커뮤니티";
                break;
        }
        
        model.addAttribute("categoryId", category);
        model.addAttribute("categoryIcon", categoryIcon);
        model.addAttribute("categoryName", categoryName);
        return "community/hpost_insert";
    }

    // 글쓰기 처리 (GET) - 테스트용
    @GetMapping("/api/community/post/insert")
    public String getPostInsert(@RequestParam String action, @RequestParam(required = false) Integer category, Model model) {
        model.addAttribute("action", action);
        model.addAttribute("success", false);
        model.addAttribute("message", "GET 요청은 지원되지 않습니다. POST 요청을 사용하세요.");
        return "community/hpost_insertaction";
    }

    @PostMapping("/api/community/post/insert")
    public String postInsert(
        @RequestParam String action,
        @RequestParam int category_id,
        @RequestParam(required = false) String userid,
        @RequestParam(required = false) String userip,
        @RequestParam String nickname,
        @RequestParam String passwd,
        @RequestParam String title,
        @RequestParam String content,
        @RequestParam(required = false) MultipartFile photo1,
        @RequestParam(required = false) MultipartFile photo2,
        @RequestParam(required = false) MultipartFile photo3,
        HttpServletRequest request,
        Model model) {
        
        logger.info("글쓰기 요청 수신: action={}, category_id={}, nickname={}, title={}", 
                   action, category_id, nickname, title);
        
        try {
            // 이미지 파일 업로드 처리
            String photo1Name = null;
            String photo2Name = null;
            String photo3Name = null;
            
            if (photo1 != null && !photo1.isEmpty()) {
                photo1Name = saveUploadedFile(photo1);
            }
            if (photo2 != null && !photo2.isEmpty()) {
                photo2Name = saveUploadedFile(photo2);
            }
            if (photo3 != null && !photo3.isEmpty()) {
                photo3Name = saveUploadedFile(photo3);
            }
            
            // Entity에 데이터 설정
            Post post = new Post();
            post.setCategoryId(category_id);
            post.setAuthorId(userid);
            post.setAuthorNickname(nickname);
            post.setTitle(title);
            post.setContent(content);
            // 첫 번째 이미지만 설정 (나머지는 별도 처리 필요)
            if (photo1Name != null) {
                post.setImageUrl("/uploads/hpostsave/" + photo1Name);
            }
            
            // Service로 데이터베이스에 저장
            Post savedPost = postService.savePost(post);
            
            if(savedPost != null && savedPost.getId() > 0) {
                // 페이지 계산 (임시로 1페이지로 설정)
                int targetPage = 1;
                
                model.addAttribute("success", true);
                model.addAttribute("message", "글이 성공적으로 작성되었습니다!");
                model.addAttribute("targetPage", targetPage);
                model.addAttribute("categoryId", category_id);
            } else {
                model.addAttribute("success", false);
                model.addAttribute("message", "글 작성에 실패했습니다.");
            }
            
        } catch (Exception e) {
            logger.error("글쓰기 처리 중 오류 발생", e);
            model.addAttribute("success", false);
            model.addAttribute("message", "글 작성 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return "community/hpost_insertaction";
    }
    
    // 파일 저장 헬퍼 메서드
    private String saveUploadedFile(MultipartFile file) throws IOException {
        // 업로드 디렉토리 설정
        String uploadDir = "src/main/webapp/uploads/hpostsave/";
        Path uploadPath = Paths.get(uploadDir);
        
        // 디렉토리가 없으면 생성
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        // 파일명 생성 (중복 방지를 위해 타임스탬프 추가)
        String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
        Path filePath = uploadPath.resolve(fileName);
        
        // 파일 저장
        Files.copy(file.getInputStream(), filePath);
        
        return fileName;
    }

    // 이미지 업로드 API
    @PostMapping("/api/community/upload-image")
    @ResponseBody
    public ResponseEntity<String> uploadImage(@RequestParam("file") MultipartFile file) {
        try {
            // 업로드 디렉토리 설정 (src/main/webapp/uploads/hpostsave/)
            String uploadDir = "src/main/webapp/uploads/hpostsave/";
            Path uploadPath = Paths.get(uploadDir);
            
            // 디렉토리가 없으면 생성
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            // 파일명 생성 (중복 방지를 위해 타임스탬프 추가)
            String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            Path filePath = uploadPath.resolve(fileName);
            
            // 파일 저장
            Files.copy(file.getInputStream(), filePath);
            
            // 성공 응답 (파일명 반환)
            return ResponseEntity.ok(fileName);
            
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("업로드 실패");
        }
    }

    // 이미지 서빙 API
    @GetMapping("/api/community/images/{filename:.+}")
    public ResponseEntity<Resource> serveImage(@PathVariable String filename) {
        try {
            // 이미지 파일 경로
            Path imagePath = Paths.get("src/main/webapp/uploads/hpostsave/").resolve(filename);
            Resource resource = new UrlResource(imagePath.toUri());
            
            if (resource.exists() && resource.isReadable()) {
                return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + filename + "\"")
                    .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).build();
        }
    }

    // 커뮤니티 액션들은 별도 REST API로 전환 예정
}
