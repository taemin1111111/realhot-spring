package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.PostReport;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PostReportMapper {
    
    // 신고 추가
    int insertReport(@Param("postId") int postId, @Param("userKey") String userKey, 
                    @Param("reason") String reason, @Param("content") String content);
    
    // 게시글별 신고 조회
    List<PostReport> getReportsByPostId(@Param("postId") int postId);
    
    // 사용자별 신고 조회
    List<PostReport> getReportsByUserKey(@Param("userKey") String userKey);
    
    // 전체 신고 조회
    List<PostReport> getAllReports();
}
