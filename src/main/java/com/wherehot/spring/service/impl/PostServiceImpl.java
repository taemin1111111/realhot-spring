package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Post;
import com.wherehot.spring.mapper.PostMapper;
import com.wherehot.spring.service.PostService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 게시글 서비스 구현체
 */
@Service
@Transactional
public class PostServiceImpl implements PostService {
    
    private static final Logger logger = LoggerFactory.getLogger(PostServiceImpl.class);
    
    @Autowired
    private PostMapper postMapper;
    
    @Override
    @Transactional(readOnly = true)
    public List<Post> findAllPosts(int page, int size) {
        try {
            int offset = (page - 1) * size;
            return postMapper.findAll(offset, size);
        } catch (Exception e) {
            logger.error("Error finding all posts: page={}, size={}", page, size, e);
            throw new RuntimeException("게시글 목록 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<Post> findPostById(int id) {
        try {
            return postMapper.findById(id);
        } catch (Exception e) {
            logger.error("Error finding post by id: {}", id, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Post> findPostsByCategory(int categoryId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return postMapper.findByCategoryId(categoryId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding posts by category: categoryId={}, page={}, size={}", categoryId, page, size, e);
            throw new RuntimeException("카테고리별 게시글 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Post> findPostsByAuthor(String authorId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return postMapper.findByAuthorId(authorId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding posts by author: authorId={}, page={}, size={}", authorId, page, size, e);
            throw new RuntimeException("작성자별 게시글 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Post> searchPosts(String searchType, String keyword, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return postMapper.searchPosts(searchType, keyword, offset, size);
        } catch (Exception e) {
            logger.error("Error searching posts: searchType={}, keyword={}, page={}, size={}", searchType, keyword, page, size, e);
            throw new RuntimeException("게시글 검색 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Post> findPopularPosts(int limit) {
        try {
            return postMapper.findPopularPosts(limit);
        } catch (Exception e) {
            logger.error("Error finding popular posts: limit={}", limit, e);
            throw new RuntimeException("인기 게시글 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Post> findRecentPosts(int limit) {
        try {
            return postMapper.findRecentPosts(limit);
        } catch (Exception e) {
            logger.error("Error finding recent posts: limit={}", limit, e);
            throw new RuntimeException("최신 게시글 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Post> findNotices() {
        try {
            return postMapper.findNotices();
        } catch (Exception e) {
            logger.error("Error finding notices", e);
            throw new RuntimeException("공지사항 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Post> findPinnedPosts() {
        try {
            return postMapper.findPinnedPosts();
        } catch (Exception e) {
            logger.error("Error finding pinned posts", e);
            throw new RuntimeException("고정 게시글 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Post savePost(Post post) {
        try {
            post.setCreatedAt(LocalDateTime.now());
            post.setUpdatedAt(LocalDateTime.now());
            
            int result = postMapper.insertPost(post);
            if (result > 0) {
                logger.info("Post saved successfully: {}", post.getTitle());
                return post;
            } else {
                throw new RuntimeException("게시글 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving post: {}", post.getTitle(), e);
            throw new RuntimeException("게시글 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Post updatePost(Post post) {
        try {
            // 기존 게시글 존재 확인
            Optional<Post> existingPost = postMapper.findById(post.getId());
            if (existingPost.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 게시글입니다: " + post.getId());
            }
            
            post.setUpdatedAt(LocalDateTime.now());
            
            int result = postMapper.updatePost(post);
            if (result > 0) {
                logger.info("Post updated successfully: {}", post.getId());
                return post;
            } else {
                throw new RuntimeException("게시글 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error updating post: {}", post.getId(), e);
            throw new RuntimeException("게시글 수정 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean deletePost(int id) {
        try {
            // 게시글 존재 확인
            Optional<Post> post = postMapper.findById(id);
            if (post.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 게시글입니다: " + id);
            }
            
            int result = postMapper.deletePost(id);
            if (result > 0) {
                logger.info("Post deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting post: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean incrementViewCount(int id) {
        try {
            int result = postMapper.updateViewCount(id);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error incrementing view count: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean updateLikeCount(int id, int likeCount) {
        try {
            int result = postMapper.updateLikeCount(id, likeCount);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating like count: id={}, likeCount={}", id, likeCount, e);
            return false;
        }
    }
    
    @Override
    public boolean updateCommentCount(int id, int commentCount) {
        try {
            int result = postMapper.updateCommentCount(id, commentCount);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating comment count: id={}, commentCount={}", id, commentCount, e);
            return false;
        }
    }
    
    @Override
    public boolean updatePostStatus(int id, String status) {
        try {
            int result = postMapper.updateStatus(id, status);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating post status: id={}, status={}", id, status, e);
            return false;
        }
    }
    
    @Override
    public boolean updateNoticeStatus(int id, boolean isNotice) {
        try {
            int result = postMapper.updateNoticeStatus(id, isNotice);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating notice status: id={}, isNotice={}", id, isNotice, e);
            return false;
        }
    }
    
    @Override
    public boolean updatePinnedStatus(int id, boolean isPinned) {
        try {
            int result = postMapper.updatePinnedStatus(id, isPinned);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating pinned status: id={}, isPinned={}", id, isPinned, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getTotalPostCount() {
        try {
            return postMapper.countAll();
        } catch (Exception e) {
            logger.error("Error getting total post count", e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getPostCountByCategory(int categoryId) {
        try {
            return postMapper.countByCategoryId(categoryId);
        } catch (Exception e) {
            logger.error("Error getting post count by category: {}", categoryId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getSearchResultCount(String searchType, String keyword) {
        try {
            return postMapper.countSearchResults(searchType, keyword);
        } catch (Exception e) {
            logger.error("Error getting search result count: searchType={}, keyword={}", searchType, keyword, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getPostCountByAuthor(String authorId) {
        try {
            return postMapper.countByAuthorId(authorId);
        } catch (Exception e) {
            logger.error("Error getting post count by author: {}", authorId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getCategoryStatistics() {
        try {
            return postMapper.getCategoryStatistics();
        } catch (Exception e) {
            logger.error("Error getting category statistics", e);
            throw new RuntimeException("카테고리 통계 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getMonthlyStatistics() {
        try {
            return postMapper.getMonthlyStatistics();
        } catch (Exception e) {
            logger.error("Error getting monthly statistics", e);
            throw new RuntimeException("월별 통계 조회 중 오류가 발생했습니다.", e);
        }
    }
}
