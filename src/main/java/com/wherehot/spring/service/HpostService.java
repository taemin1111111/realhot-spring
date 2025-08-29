package com.wherehot.spring.service;

import com.wherehot.spring.entity.Hpost;
import com.wherehot.spring.entity.Comment;
import com.wherehot.spring.mapper.HpostMapper;
import com.wherehot.spring.mapper.CommentMapper;
import com.wherehot.spring.mapper.PostVoteMapper;
import com.wherehot.spring.mapper.PostReportMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.util.List;

@Service
public class HpostService {
    
    @Autowired
    private HpostMapper hpostMapper;
    
    @Autowired
    private CommentMapper commentMapper;
    
    @Autowired
    private PostVoteMapper postVoteMapper;
    
    @Autowired
    private PostReportMapper postReportMapper;
    
    @Value("${file.upload.path:uploads/hpost}")
    private String uploadPath;
    
    // 페이징 크기
    private static final int PAGE_SIZE = 12;
    
    // 최신글 목록 조회
    public List<Hpost> getLatestHpostList(int page) {
        int offset = (page - 1) * PAGE_SIZE;
        List<Hpost> hposts = hpostMapper.getLatestHpostList(offset, PAGE_SIZE);
        // 각 게시글의 댓글 정보 로드
        for (Hpost hpost : hposts) {
            List<Comment> comments = commentMapper.getCommentsByPostId(hpost.getId());
            hpost.setComments(comments);
        }
        return hposts;
    }
    
    // 인기글 목록 조회
    public List<Hpost> getPopularHpostList(int page) {
        int offset = (page - 1) * PAGE_SIZE;
        List<Hpost> hposts = hpostMapper.getPopularHpostList(offset, PAGE_SIZE);
        // 각 게시글의 댓글 정보 로드
        for (Hpost hpost : hposts) {
            List<Comment> comments = commentMapper.getCommentsByPostId(hpost.getId());
            hpost.setComments(comments);
        }
        return hposts;
    }
    
    // 카테고리별 최신글 조회
    public List<Hpost> getLatestHpostListByCategory(int categoryId, int page) {
        int offset = (page - 1) * PAGE_SIZE;
        List<Hpost> hposts = hpostMapper.getHpostListByCategory(categoryId, offset, PAGE_SIZE);
        // 각 게시글의 댓글 정보 로드
        for (Hpost hpost : hposts) {
            List<Comment> comments = commentMapper.getCommentsByPostId(hpost.getId());
            hpost.setComments(comments);
        }
        return hposts;
    }
    
    // 카테고리별 인기글 조회
    public List<Hpost> getPopularHpostListByCategory(int categoryId, int page) {
        int offset = (page - 1) * PAGE_SIZE;
        List<Hpost> hposts = hpostMapper.getPopularHpostListByCategory(categoryId, offset, PAGE_SIZE);
        // 각 게시글의 댓글 정보 로드
        for (Hpost hpost : hposts) {
            List<Comment> comments = commentMapper.getCommentsByPostId(hpost.getId());
            hpost.setComments(comments);
        }
        return hposts;
    }
    
    // 게시글 상세 조회 (조회수 증가 없음)
    @Transactional
    public Hpost getHpostById(int id) {
        return hpostMapper.getHpostById(id);
    }
    
    // 게시글 상세 조회 (조회수 증가 없음)
    @Transactional
    public Hpost getHpostByIdWithoutIncrement(int id) {
        return hpostMapper.getHpostById(id);
    }
    
    // 조회수 증가
    @Transactional
    public void incrementViewCount(int id) {
        hpostMapper.incrementViewCount(id);
    }
    
    // 게시글 등록
    @Transactional
    public int createHpost(Hpost hpost) {
        return hpostMapper.insertHpost(hpost);
    }
    
    // 게시글 수정
    @Transactional
    public int updateHpost(Hpost hpost) {
        return hpostMapper.updateHpost(hpost);
    }
    
    // 게시글 삭제
    @Transactional
    public int deleteHpost(int id) {
        return hpostMapper.deleteHpost(id);
    }
    
    // 좋아요/싫어요 처리
    @Transactional
    public void handleVote(int postId, String userKey, String voteType) {
        // 기존 투표 확인
        boolean existingVote = postVoteMapper.existsVote(postId, userKey);
        
        if (existingVote) {
            // 기존 투표 삭제
            postVoteMapper.deleteVote(postId, userKey);
            // 카운트 감소
            if ("like".equals(voteType)) {
                hpostMapper.decrementLikeCount(postId);
            } else if ("dislike".equals(voteType)) {
                hpostMapper.decrementDislikeCount(postId);
            }
        } else {
            // 새 투표 추가
            postVoteMapper.insertVote(postId, userKey, voteType);
            // 카운트 증가
            if ("like".equals(voteType)) {
                hpostMapper.incrementLikeCount(postId);
            } else if ("dislike".equals(voteType)) {
                hpostMapper.incrementDislikeCount(postId);
            }
        }
    }
    
    // 신고 처리
    @Transactional
    public void reportHpost(int postId, String userKey, String reason, String content) {
        postReportMapper.insertReport(postId, userKey, reason, content);
        hpostMapper.incrementReportCount(postId);
    }
    
    // 검색
    public List<Hpost> searchHposts(String keyword, String searchType, int page) {
        int offset = (page - 1) * PAGE_SIZE;
        return hpostMapper.searchHposts(keyword, searchType, offset, PAGE_SIZE);
    }
    
    // 전체 게시글 수 조회
    public int getTotalHpostCount() {
        return hpostMapper.getTotalHpostCount();
    }
    
    // 카테고리별 게시글 수 조회
    public int getHpostCountByCategory(int categoryId) {
        return hpostMapper.getHpostCountByCategory(categoryId);
    }
}
