package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.PostReport;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.Optional;

/**
 * 게시글 신고 매퍼 (기존 hottalk_report 테이블 사용)
 * Model1 Hottalk_ReportDao 기능을 Spring Mapper로 변환
 */
@Mapper
public interface PostReportMapper {
    
    /**
     * 신고 추가
     * Model1: insertReport(Hottalk_ReportDto dto)
     */
    @Insert("INSERT INTO hottalk_report (post_id, user_id, reason, content, report_time) " +
            "VALUES (#{postId}, #{userId}, #{reason}, #{content}, NOW())")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertReport(PostReport postReport);
    
    /**
     * 특정 글의 신고 목록 조회
     * Model1: getReportsByPostId(int postId)
     */
    @Select("SELECT * FROM hottalk_report WHERE post_id = #{postId} ORDER BY report_time DESC")
    List<PostReport> findByPostId(int postId);
    
    /**
     * 전체 신고 목록 조회
     * Model1: getAllReports()
     */
    @Select("SELECT * FROM hottalk_report ORDER BY report_time DESC")
    List<PostReport> findAll();
    
    /**
     * 전체 신고 목록 조회 (게시글 정보 포함)
     * 관리자용 - 게시글 제목, 작성자와 함께 조회
     */
    @Select("SELECT r.*, p.title as post_title, p.nickname as post_author " +
            "FROM hottalk_report r " +
            "JOIN hottalk_post p ON r.post_id = p.id " +
            "ORDER BY r.report_time DESC")
    @Results({
        @Result(property = "id", column = "id"),
        @Result(property = "postId", column = "post_id"),
        @Result(property = "userId", column = "user_id"),
        @Result(property = "reason", column = "reason"),
        @Result(property = "content", column = "content"),
        @Result(property = "reportTime", column = "report_time"),
        @Result(property = "postTitle", column = "post_title"),
        @Result(property = "postAuthor", column = "post_author")
    })
    List<PostReport> findAllWithPostInfo();
    
    /**
     * 특정 신고 조회
     * Model1: getReportById(int id)
     */
    @Select("SELECT * FROM hottalk_report WHERE id = #{id}")
    Optional<PostReport> findById(int id);
    
    /**
     * 신고 삭제
     * Model1: deleteReport(int id)
     */
    @Delete("DELETE FROM hottalk_report WHERE id = #{id}")
    int deleteReport(int id);
    
    /**
     * 특정 글의 신고 개수 조회
     * Model1: getReportCountByPostId(int postId)
     */
    @Select("SELECT COUNT(*) FROM hottalk_report WHERE post_id = #{postId}")
    int countByPostId(int postId);
    
    /**
     * 특정 글에 대해 해당 user_id가 이미 신고했는지 확인
     * Model1: hasUserReported(int postId, String userId)
     */
    @Select("SELECT COUNT(*) FROM hottalk_report WHERE post_id = #{postId} AND user_id = #{userId}")
    int countByPostIdAndUserId(@Param("postId") int postId, @Param("userId") String userId);
    
    /**
     * 신고된 게시물 ID 목록 조회 (중복 제거)
     * Model1: getReportedPostIds()
     */
    @Select("SELECT DISTINCT post_id FROM hottalk_report ORDER BY post_id DESC")
    List<Integer> findReportedPostIds();
    
    /**
     * 특정 사용자의 신고 목록 조회
     */
    @Select("SELECT r.*, p.title as post_title, p.nickname as post_author " +
            "FROM hottalk_report r " +
            "JOIN hottalk_post p ON r.post_id = p.id " +
            "WHERE r.user_id = #{userId} " +
            "ORDER BY r.report_time DESC")
    @Results({
        @Result(property = "id", column = "id"),
        @Result(property = "postId", column = "post_id"),
        @Result(property = "userId", column = "user_id"),
        @Result(property = "reason", column = "reason"),
        @Result(property = "content", column = "content"),
        @Result(property = "reportTime", column = "report_time"),
        @Result(property = "postTitle", column = "post_title"),
        @Result(property = "postAuthor", column = "post_author")
    })
    List<PostReport> findByUserId(String userId);
    
    /**
     * 신고 처리 상태 업데이트 (처리 완료)
     */
    @Update("UPDATE hottalk_report SET status = #{status}, processed_at = NOW() WHERE id = #{id}")
    int updateReportStatus(@Param("id") int id, @Param("status") String status);
    
    /**
     * 페이징을 위한 신고 목록 조회
     */
    @Select("SELECT r.*, p.title as post_title, p.nickname as post_author " +
            "FROM hottalk_report r " +
            "JOIN hottalk_post p ON r.post_id = p.id " +
            "ORDER BY r.report_time DESC " +
            "LIMIT #{pageSize} OFFSET #{offset}")
    @Results({
        @Result(property = "id", column = "id"),
        @Result(property = "postId", column = "post_id"),
        @Result(property = "userId", column = "user_id"),
        @Result(property = "reason", column = "reason"),
        @Result(property = "content", column = "content"),
        @Result(property = "reportTime", column = "report_time"),
        @Result(property = "postTitle", column = "post_title"),
        @Result(property = "postAuthor", column = "post_author")
    })
    List<PostReport> findAllWithPostInfoPaged(@Param("pageSize") int pageSize, @Param("offset") int offset);
    
    /**
     * 전체 신고 개수 조회
     */
    @Select("SELECT COUNT(*) FROM hottalk_report")
    int countAll();
}
