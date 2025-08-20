package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.Post;
import com.wherehot.spring.service.PostService;
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
 * 게시글 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/posts")
public class PostController {
    
    @Autowired
    private PostService postService;
    
    /**
     * 모든 게시글 조회 (페이징)
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllPosts(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Post> posts = postService.findAllPosts(page, size);
        int totalCount = postService.getTotalPostCount();
        
        Map<String, Object> result = new HashMap<>();
        result.put("posts", posts);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * ID로 게시글 조회
     */
    @GetMapping("/{id}")
    public ResponseEntity<Post> getPostById(@PathVariable int id) {
        Optional<Post> post = postService.findPostById(id);
        if (post.isPresent()) {
            // 조회수 증가
            postService.incrementViewCount(id);
            return ResponseEntity.ok(post.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    /**
     * 카테고리별 게시글 조회
     */
    @GetMapping("/category/{categoryId}")
    public ResponseEntity<Map<String, Object>> getPostsByCategory(
            @PathVariable int categoryId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Post> posts = postService.findPostsByCategory(categoryId, page, size);
        int totalCount = postService.getPostCountByCategory(categoryId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("posts", posts);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("categoryId", categoryId);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 게시글 검색
     */
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchPosts(
            @RequestParam(defaultValue = "all") String searchType,
            @RequestParam String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Post> posts = postService.searchPosts(searchType, keyword, page, size);
        int totalCount = postService.getSearchResultCount(searchType, keyword);
        
        Map<String, Object> result = new HashMap<>();
        result.put("posts", posts);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("searchType", searchType);
        result.put("keyword", keyword);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 인기 게시글 조회
     */
    @GetMapping("/popular")
    public ResponseEntity<List<Post>> getPopularPosts(@RequestParam(defaultValue = "10") int limit) {
        List<Post> posts = postService.findPopularPosts(limit);
        return ResponseEntity.ok(posts);
    }
    
    /**
     * 최신 게시글 조회
     */
    @GetMapping("/recent")
    public ResponseEntity<List<Post>> getRecentPosts(@RequestParam(defaultValue = "10") int limit) {
        List<Post> posts = postService.findRecentPosts(limit);
        return ResponseEntity.ok(posts);
    }
    
    /**
     * 공지사항 조회
     */
    @GetMapping("/notices")
    public ResponseEntity<List<Post>> getNotices() {
        List<Post> notices = postService.findNotices();
        return ResponseEntity.ok(notices);
    }
    
    /**
     * 고정 게시글 조회
     */
    @GetMapping("/pinned")
    public ResponseEntity<List<Post>> getPinnedPosts() {
        List<Post> pinnedPosts = postService.findPinnedPosts();
        return ResponseEntity.ok(pinnedPosts);
    }
    
    /**
     * 작성자별 게시글 조회
     */
    @GetMapping("/author/{authorId}")
    public ResponseEntity<Map<String, Object>> getPostsByAuthor(
            @PathVariable String authorId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Post> posts = postService.findPostsByAuthor(authorId, page, size);
        int totalCount = postService.getPostCountByAuthor(authorId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("posts", posts);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("authorId", authorId);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 게시글 등록
     */
    @PostMapping
    public ResponseEntity<Post> createPost(@RequestBody Post post, 
                                          @AuthenticationPrincipal UserDetails userDetails) {
        try {
            if (userDetails != null) {
                post.setUserid(userDetails.getUsername());
            }
            
            Post savedPost = postService.savePost(post);
            return ResponseEntity.ok(savedPost);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 게시글 수정
     */
    @PutMapping("/{id}")
    public ResponseEntity<Post> updatePost(@PathVariable int id, 
                                          @RequestBody Post post,
                                          @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 기존 게시글 조회
            Optional<Post> existingPost = postService.findPostById(id);
            if (existingPost.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            // 작성자 권한 확인
            if (userDetails == null || !existingPost.get().getUserid().equals(userDetails.getUsername())) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            post.setId(id);
            Post updatedPost = postService.updatePost(post);
            return ResponseEntity.ok(updatedPost);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 게시글 삭제
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePost(@PathVariable int id,
                                          @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 기존 게시글 조회
            Optional<Post> existingPost = postService.findPostById(id);
            if (existingPost.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            // 작성자 권한 확인 (또는 관리자)
            if (userDetails == null || (!existingPost.get().getUserid().equals(userDetails.getUsername()) 
                && !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN")))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            boolean deleted = postService.deletePost(id);
            return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 좋아요 처리
     */
    @PostMapping("/{id}/like")
    public ResponseEntity<Map<String, Object>> likePost(@PathVariable int id) {
        try {
            Optional<Post> post = postService.findPostById(id);
            if (post.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            int newLikeCount = post.get().getLikes() + 1;
            boolean updated = postService.updateLikeCount(id, newLikeCount);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", updated);
            result.put("likeCount", newLikeCount);
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 카테고리별 통계
     */
    @GetMapping("/statistics/category")
    public ResponseEntity<List<Map<String, Object>>> getCategoryStatistics() {
        List<Map<String, Object>> statistics = postService.getCategoryStatistics();
        return ResponseEntity.ok(statistics);
    }
    
    /**
     * 월별 통계
     */
    @GetMapping("/statistics/monthly")
    public ResponseEntity<List<Map<String, Object>>> getMonthlyStatistics() {
        List<Map<String, Object>> statistics = postService.getMonthlyStatistics();
        return ResponseEntity.ok(statistics);
    }
}
