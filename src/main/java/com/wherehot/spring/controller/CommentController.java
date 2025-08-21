package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Comment;
import com.wherehot.spring.service.CommentService;
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
 * 댓글 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/comments")
public class CommentController {
    
    @Autowired
    private CommentService commentService;
    
    /**
     * 게시글별 댓글 조회
     */
    @GetMapping("/post/{postId}")
    public ResponseEntity<Map<String, Object>> getCommentsByPost(
            @PathVariable int postId,
            @RequestParam(defaultValue = "false") boolean usePaging,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        List<Comment> comments;
        if (usePaging) {
            comments = commentService.findCommentsByPostWithPaging(postId, page, size);
        } else {
            comments = commentService.findCommentsByPost(postId);
        }
        
        int totalCount = commentService.getCommentCountByPost(postId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("comments", comments);
        result.put("totalCount", totalCount);
        result.put("postId", postId);
        
        if (usePaging) {
            result.put("currentPage", page);
            result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        }
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * ID로 댓글 조회
     */
    @GetMapping("/{id}")
    public ResponseEntity<Comment> getCommentById(@PathVariable int id) {
        Optional<Comment> comment = commentService.findCommentById(id);
        return comment.map(ResponseEntity::ok)
                     .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * 부모 댓글의 답글 조회
     */
    @GetMapping("/{parentId}/replies")
    public ResponseEntity<Map<String, Object>> getRepliesByParent(@PathVariable int parentId) {
        List<Comment> replies = commentService.findRepliesByParent(parentId);
        int replyCount = commentService.getRepliesCountByParent(parentId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("replies", replies);
        result.put("replyCount", replyCount);
        result.put("parentCommentId", parentId);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 작성자별 댓글 조회
     */
    @GetMapping("/author/{authorId}")
    public ResponseEntity<Map<String, Object>> getCommentsByAuthor(
            @PathVariable String authorId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Comment> comments = commentService.findCommentsByAuthor(authorId, page, size);
        int totalCount = commentService.getCommentCountByAuthor(authorId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("comments", comments);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("authorId", authorId);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 최신 댓글 조회
     */
    @GetMapping("/recent")
    public ResponseEntity<List<Comment>> getRecentComments(@RequestParam(defaultValue = "10") int limit) {
        List<Comment> comments = commentService.findRecentComments(limit);
        return ResponseEntity.ok(comments);
    }
    
    /**
     * 댓글 등록
     */
    @PostMapping
    public ResponseEntity<Comment> createComment(@RequestBody Comment comment,
                                               @AuthenticationPrincipal UserDetails userDetails) {
        try {
            if (userDetails == null) {
                return ResponseEntity.status(401).build(); // Unauthorized
            }
            
            comment.setNickname(userDetails.getUsername());
            Comment savedComment = commentService.saveComment(comment);
            return ResponseEntity.ok(savedComment);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 댓글 수정
     */
    @PutMapping("/{id}")
    public ResponseEntity<Comment> updateComment(@PathVariable int id,
                                               @RequestBody Comment comment,
                                               @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 기존 댓글 조회
            Optional<Comment> existingComment = commentService.findCommentById(id);
            if (existingComment.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            // 작성자 권한 확인
            if (userDetails == null || !existingComment.get().getNickname().equals(userDetails.getUsername())) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            comment.setId(id);
            comment.setNickname(userDetails.getUsername());
            Comment updatedComment = commentService.updateComment(comment);
            return ResponseEntity.ok(updatedComment);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 댓글 삭제 (소프트 삭제)
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteComment(@PathVariable int id,
                                             @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 기존 댓글 조회
            Optional<Comment> existingComment = commentService.findCommentById(id);
            if (existingComment.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            // 작성자 권한 확인 (또는 관리자)
            if (userDetails == null || (!existingComment.get().getNickname().equals(userDetails.getUsername()) 
                && !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN")))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            boolean deleted = commentService.deleteComment(id);
            return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 댓글 완전 삭제 (관리자 전용)
     */
    @DeleteMapping("/{id}/hard")
    public ResponseEntity<Void> hardDeleteComment(@PathVariable int id,
                                                 @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 관리자 권한 확인
            if (userDetails == null || !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            boolean deleted = commentService.hardDeleteComment(id);
            return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 댓글 좋아요
     */
    @PostMapping("/{id}/like")
    public ResponseEntity<Map<String, Object>> likeComment(@PathVariable int id) {
        try {
            Optional<Comment> comment = commentService.findCommentById(id);
            if (comment.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            int newLikeCount = comment.get().getLikes() + 1;
            boolean updated = commentService.updateLikeCount(id, newLikeCount);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", updated);
            result.put("likeCount", newLikeCount);
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 댓글 싫어요
     */
    @PostMapping("/{id}/dislike")
    public ResponseEntity<Map<String, Object>> dislikeComment(@PathVariable int id) {
        try {
            Optional<Comment> comment = commentService.findCommentById(id);
            if (comment.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            int newDislikeCount = comment.get().getDislikes() + 1;
            boolean updated = commentService.updateDislikeCount(id, newDislikeCount);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", updated);
            result.put("dislikeCount", newDislikeCount);
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 댓글 상태 변경 (관리자 전용)
     */
    @PatchMapping("/{id}/status")
    public ResponseEntity<Void> updateCommentStatus(@PathVariable int id,
                                                   @RequestParam String status,
                                                   @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 관리자 권한 확인
            if (userDetails == null || !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            boolean updated = commentService.updateCommentStatus(id, status);
            return updated ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 전체 댓글 통계
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getCommentStatistics() {
        Map<String, Object> statistics = new HashMap<>();
        statistics.put("totalComments", commentService.getTotalCommentCount());
        statistics.put("activeComments", commentService.getActiveCommentCount());
        
        return ResponseEntity.ok(statistics);
    }
}
