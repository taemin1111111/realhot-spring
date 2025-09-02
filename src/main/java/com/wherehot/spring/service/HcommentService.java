package com.wherehot.spring.service;

import com.wherehot.spring.entity.Hcomment;

import java.util.List;
import java.util.Map;

public interface HcommentService {

    List<Hcomment> getCommentsByPostId(int postId);
    
    List<Hcomment> getCommentsByPostIdWithUserReaction(int postId, String userId);

    Hcomment createComment(Hcomment comment);

    Map<String, Object> toggleLike(int commentId, String userId);
    
    // 추가된 메서드들
    Map<String, Object> toggleReaction(int commentId, String userIdOrIp, String reactionType);
    
    boolean deleteComment(int commentId, String nickname, String password);
    
    boolean deleteCommentByUser(int commentId, String userId);
}
