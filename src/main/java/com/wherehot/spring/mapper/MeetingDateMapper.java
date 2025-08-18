package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.MeetingDate;
import com.wherehot.spring.entity.MeetingDateWish;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

/**
 * 미팅/데이트 MyBatis Mapper
 */
@Mapper
public interface MeetingDateMapper {
    
    // MeetingDate 관련
    List<MeetingDate> findAll(@Param("offset") int offset, @Param("size") int size);
    Optional<MeetingDate> findById(@Param("id") int id);
    List<MeetingDate> findByMeetingType(@Param("meetingType") String meetingType, @Param("offset") int offset, @Param("size") int size);
    List<MeetingDate> findByGender(@Param("gender") String gender, @Param("offset") int offset, @Param("size") int size);
    List<MeetingDate> findByLocation(@Param("location") String location, @Param("offset") int offset, @Param("size") int size);
    List<MeetingDate> findByAuthorId(@Param("authorId") String authorId, @Param("offset") int offset, @Param("size") int size);
    List<MeetingDate> findRecruiting(@Param("offset") int offset, @Param("size") int size);
    List<MeetingDate> searchMeetingDates(@Param("keyword") String keyword, @Param("offset") int offset, @Param("size") int size);
    List<MeetingDate> findRecent(@Param("limit") int limit);
    List<MeetingDate> findPopular(@Param("limit") int limit);
    
    int insertMeetingDate(MeetingDate meetingDate);
    int updateMeetingDate(MeetingDate meetingDate);
    int deleteMeetingDate(@Param("id") int id);
    int updateViewCount(@Param("id") int id);
    int updateLikeCount(@Param("id") int id);
    int updateParticipantCount(@Param("id") int id, @Param("change") int change);
    int updateStatus(@Param("id") int id, @Param("status") String status);
    
    int countAll();
    int countRecruiting();
    int countSearchResults(@Param("keyword") String keyword);
    int countByAuthorId(@Param("authorId") String authorId);
    
    // MeetingDateWish 관련
    int insertMeetingDateWish(MeetingDateWish wish);
    int deleteMeetingDateWish(@Param("id") int id);
    int deleteMeetingDateWishByUserAndMeeting(@Param("userId") String userId, @Param("meetingDateId") int meetingDateId);
    List<MeetingDateWish> findWishListByUserId(@Param("userId") String userId, @Param("offset") int offset, @Param("size") int size);
    int countWishByUserId(@Param("userId") String userId);
    int countWishByMeetingDateId(@Param("meetingDateId") int meetingDateId);
    boolean existsWishByUserAndMeeting(@Param("userId") String userId, @Param("meetingDateId") int meetingDateId);
}
