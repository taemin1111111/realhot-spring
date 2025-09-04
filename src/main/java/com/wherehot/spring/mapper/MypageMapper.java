package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Member;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 마이페이지 관련 매퍼 인터페이스
 */
@Mapper
public interface MypageMapper {
    
    /**
     * 사용자 위시리스트 조회
     */
    List<Map<String, Object>> getUserWishlist(@Param("userid") String userid, 
                                             @Param("offset") int offset, 
                                             @Param("size") int size);
    
    /**
     * 사용자 위시리스트 개수 조회
     */
    int getUserWishlistCount(@Param("userid") String userid);
    
    /**
     * 사용자가 작성한 게시글 조회 (전체)
     */
    List<Map<String, Object>> getUserPosts(@Param("userid") String userid, 
                                          @Param("offset") int offset, 
                                          @Param("size") int size);
    
    /**
     * 사용자가 작성한 게시글 개수 조회 (전체)
     */
    int getUserPostsCount(@Param("userid") String userid);
    
    /**
     * 사용자가 작성한 course 게시글 조회
     */
    List<Map<String, Object>> getUserCoursePosts(@Param("userid") String userid, 
                                                @Param("offset") int offset, 
                                                @Param("size") int size);
    
    /**
     * 사용자가 작성한 hottalk 게시글 조회
     */
    List<Map<String, Object>> getUserHottalkPosts(@Param("userid") String userid, 
                                                 @Param("offset") int offset, 
                                                 @Param("size") int size);
    
    /**
     * 사용자가 작성한 course 게시글 개수 조회
     */
    int getUserCourseCount(@Param("userid") String userid);
    
    /**
     * 사용자가 작성한 hpost 게시글 개수 조회
     */
    int getUserHpostCount(@Param("userid") String userid);
    
    /**
     * 사용자가 작성한 댓글 조회
     */
    List<Map<String, Object>> getUserComments(@Param("userid") String userid, 
                                             @Param("offset") int offset, 
                                             @Param("size") int size);
    
    /**
     * 사용자가 작성한 댓글 개수 조회
     */
    int getUserCommentsCount(@Param("userid") String userid);
    
    /**
     * 사용자 정보 조회
     */
    Member getUserInfo(@Param("userid") String userid);
    
    /**
     * 사용자 프로필 정보 수정
     */
    int updateProfile(Member member);
    
    /**
     * 사용자 비밀번호 변경
     */
    int updatePassword(@Param("userid") String userid, @Param("password") String password);
    
    /**
     * 사용자 상태 변경
     */
    int updateMemberStatus(@Param("userid") String userid, @Param("status") String status);
    
    /**
     * 찜 해제
     */
    int removeWish(@Param("userid") String userid, @Param("wishId") Long wishId);
    
    /**
     * 사용자 MD 찜 목록 조회
     */
    List<Map<String, Object>> getMdWishList(@Param("userid") String userid, 
                                           @Param("offset") int offset, 
                                           @Param("size") int size);
    
    /**
     * 사용자 MD 찜 목록 개수 조회
     */
    int getMdWishListCount(@Param("userid") String userid);
    
    /**
     * MD 찜 해제
     */
    int removeMdWish(@Param("userid") String userid, @Param("wishId") int wishId);
}
