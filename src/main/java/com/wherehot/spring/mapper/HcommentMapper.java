package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Hcomment;
import com.wherehot.spring.entity.HcommentVote;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

@Mapper
public interface HcommentMapper {

    List<Hcomment> findByPostId(@Param("postId") int postId);
    
    List<Hcomment> findByPostIdWithUserReaction(@Param("postId") int postId, @Param("userId") String userId);

    int insert(Hcomment comment);

    Optional<Hcomment> findById(@Param("id") int id);

    void updateLikes(Hcomment comment);

    // 댓글 좋아요/싫어요 투표 관련
    Optional<HcommentVote> findVoteByUserAndComment(@Param("userId") String userId, @Param("ipAddress") String ipAddress, @Param("commentId") int commentId);

    void insertVote(HcommentVote vote);

    void updateVote(HcommentVote vote);

    void deleteVote(@Param("id") int id);

    int countLikesByComment(@Param("commentId") int commentId);
    
    // 추가된 메서드들
    int countDislikesByComment(@Param("commentId") int commentId);
    
    void deleteComment(@Param("id") int id);
    
    Optional<Hcomment> findByIdAndNickname(@Param("id") int id, @Param("nickname") String nickname);
}
