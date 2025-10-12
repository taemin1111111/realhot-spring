package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Hcomment;
import com.wherehot.spring.entity.HcommentVote;
import com.wherehot.spring.mapper.HcommentMapper;
import com.wherehot.spring.service.HcommentService;
import com.wherehot.spring.service.ExpService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@Transactional
public class HcommentServiceImpl implements HcommentService {

    @Autowired
    private HcommentMapper hcommentMapper;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private ExpService expService;

    @Override
    public List<Hcomment> getCommentsByPostId(int postId) {
        return hcommentMapper.findByPostId(postId);
    }
    
    @Override
    public List<Hcomment> getCommentsByPostIdWithUserReaction(int postId, String userId) {
        return hcommentMapper.findByPostIdWithUserReaction(postId, userId);
    }

    @Override
    public Hcomment createComment(Hcomment comment) {
        comment.setCreatedAt(LocalDateTime.now());
        hcommentMapper.insert(comment);
        
        // 댓글 작성 경험치 지급 (1개 = +3 Exp)
        if (comment.getIdAddress() != null && !comment.getIdAddress().trim().isEmpty()) {
            try {
                boolean expAdded = expService.addCommentExp(comment.getIdAddress(), 1);
                if (expAdded) {
                    System.out.println("Comment exp added successfully for user: " + comment.getIdAddress());
                } else {
                    System.out.println("Comment exp not added (daily limit reached) for user: " + comment.getIdAddress());
                }
            } catch (Exception e) {
                System.err.println("Error adding comment exp for user: " + comment.getIdAddress() + ", " + e.getMessage());
                // 경험치 지급 실패는 댓글 작성 자체를 실패시키지 않음
            }
        }
        
        return hcommentMapper.findById(comment.getId()).orElse(null);
    }

    @Override
    public Map<String, Object> toggleLike(int commentId, String userIdOrIp) {
        Map<String, Object> response = new HashMap<>();
        
        boolean isIpAddress = userIdOrIp.contains("."); // 간단한 IP 주소 형식 확인
        String userId = isIpAddress ? null : userIdOrIp;
        String ipAddress = isIpAddress ? userIdOrIp : null;

        Optional<HcommentVote> existingVote = hcommentMapper.findVoteByUserAndComment(userId, ipAddress, commentId);

        if (existingVote.isPresent()) {
            // 이미 'like' 라면 취소
            HcommentVote vote = existingVote.get();
            if ("like".equals(vote.getVoteType())) {
                hcommentMapper.deleteVote(vote.getId());
                response.put("action", "unliked");
            } else {
                // 다른 투표였다면 'like'로 변경
                vote.setVoteType("like");
                hcommentMapper.updateVote(vote);
                response.put("action", "liked");
            }
        } else {
            // 새로운 'like' 투표
            HcommentVote newVote = new HcommentVote();
            newVote.setCommentId(commentId);
            newVote.setUserId(userId);
            newVote.setIpAddress(ipAddress);
            newVote.setVoteType("like");
            hcommentMapper.insertVote(newVote);
            response.put("action", "liked");
        }

        // 좋아요 개수 업데이트
        int likeCount = hcommentMapper.countLikesByComment(commentId);
        Hcomment comment = hcommentMapper.findById(commentId).orElseThrow();
        comment.setLikes(likeCount);
        hcommentMapper.updateLikes(comment);

        response.put("success", true);
        response.put("likeCount", likeCount);
        response.put("userReaction", getUserVoteStatus(commentId, userId, ipAddress));
        return response;
    }

    private String getUserVoteStatus(int commentId, String userId, String ipAddress) {
        return hcommentMapper.findVoteByUserAndComment(userId, ipAddress, commentId)
                .map(HcommentVote::getVoteType)
                .orElse("none");
    }
    
    @Override
    public Map<String, Object> toggleReaction(int commentId, String userIdOrIp, String reactionType) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // userIdOrIp가 IP 주소인지 사용자 ID인지 확인
            boolean isIpAddress = userIdOrIp.contains(".") || userIdOrIp.contains(":");
            String userId = isIpAddress ? null : userIdOrIp;
            String ipAddress = isIpAddress ? userIdOrIp : null;
            
            System.out.println("DEBUG: toggleReaction - userIdOrIp: " + userIdOrIp + ", isIpAddress: " + isIpAddress);
            System.out.println("DEBUG: userId: " + userId + ", ipAddress: " + ipAddress);
            
            // 기존 투표 확인
            Optional<HcommentVote> existingVote = hcommentMapper.findVoteByUserAndComment(userId, ipAddress, commentId);
            
            if (existingVote.isPresent()) {
                HcommentVote vote = existingVote.get();
                // 대소문자 통일하여 비교
                if (reactionType.equalsIgnoreCase(vote.getVoteType())) {
                    // 같은 리액션이면 취소
                    hcommentMapper.deleteVote(vote.getId());
                    response.put("userReaction", "none");
                    System.out.println("DEBUG: 기존 리액션 취소됨");
                } else {
                    // 다른 리액션이면 변경
                    vote.setVoteType(reactionType);
                    hcommentMapper.updateVote(vote);
                    response.put("userReaction", reactionType);
                    System.out.println("DEBUG: 리액션 변경됨: " + reactionType);
                }
            } else {
                // 새로운 리액션
                HcommentVote newVote = new HcommentVote();
                newVote.setCommentId(commentId);
                newVote.setUserId(userId);
                newVote.setIpAddress(ipAddress);
                newVote.setVoteType(reactionType);
                hcommentMapper.insertVote(newVote);
                response.put("userReaction", reactionType);
                System.out.println("DEBUG: 새로운 리액션 추가됨: " + reactionType);
                
                // 좋아요를 받은 경우 댓글 작성자에게 경험치 지급
                if ("like".equalsIgnoreCase(reactionType)) {
                    try {
                        // 댓글 작성자 정보 조회
                        Hcomment comment = hcommentMapper.findById(commentId).orElse(null);
                        if (comment != null && comment.getIdAddress() != null && 
                            !comment.getIdAddress().trim().isEmpty() && 
                            !comment.getIdAddress().startsWith("anonymous|")) {
                            boolean expAdded = expService.addLikeExp(comment.getIdAddress(), 1);
                            if (expAdded) {
                                System.out.println("Like exp added successfully for comment author: " + comment.getIdAddress());
                            } else {
                                System.out.println("Like exp not added (daily limit reached) for comment author: " + comment.getIdAddress());
                            }
                        }
                    } catch (Exception e) {
                        System.err.println("Error adding like exp for comment author: " + e.getMessage());
                        // 경험치 지급 실패는 추천 자체를 실패시키지 않음
                    }
                }
            }
            
            // 좋아요/싫어요 개수 업데이트
            int likeCount = hcommentMapper.countLikesByComment(commentId);
            int dislikeCount = hcommentMapper.countDislikesByComment(commentId);
            
            System.out.println("DEBUG: 업데이트된 개수 - 좋아요: " + likeCount + ", 싫어요: " + dislikeCount);
            
            Hcomment comment = hcommentMapper.findById(commentId).orElseThrow();
            comment.setLikes(likeCount);
            comment.setDislikes(dislikeCount);
            hcommentMapper.updateLikes(comment);
            
            response.put("success", true);
            response.put("likeCount", likeCount);
            response.put("dislikeCount", dislikeCount);
            
            System.out.println("DEBUG: 응답 데이터: " + response);
            
        } catch (Exception e) {
            System.out.println("DEBUG: toggleReaction 오류: " + e.getMessage());
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "리액션 처리 중 오류가 발생했습니다.");
        }
        
        return response;
    }
    
    @Override
    public boolean deleteComment(int commentId, String nickname, String password) {
        try {
            // 댓글과 닉네임으로 조회
            Optional<Hcomment> commentOpt = hcommentMapper.findByIdAndNickname(commentId, nickname);
            if (!commentOpt.isPresent()) {
                return false;
            }
            
            Hcomment comment = commentOpt.get();
            
            // 비밀번호 확인 (비로그인 사용자의 경우)
            if (comment.getPasswd() != null && !passwordEncoder.matches(password, comment.getPasswd())) {
                return false;
            }
            
            // 댓글 삭제
            hcommentMapper.deleteComment(commentId);
            return true;
            
        } catch (Exception e) {
            return false;
        }
    }
    
    @Override
    public boolean deleteCommentByUser(int commentId, String userId) {
        try {
            // 사용자 ID로 댓글 조회
            Optional<Hcomment> commentOpt = hcommentMapper.findById(commentId);
            if (!commentOpt.isPresent()) {
                return false;
            }
            
            Hcomment comment = commentOpt.get();
            
            // 로그인한 사용자의 댓글인지 확인
            if (!userId.equals(comment.getIdAddress())) {
                return false;
            }
            
            // 댓글 삭제
            hcommentMapper.deleteComment(commentId);
            return true;
            
        } catch (Exception e) {
            return false;
        }
    }
}
