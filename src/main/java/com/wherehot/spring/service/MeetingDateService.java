package com.wherehot.spring.service;

import com.wherehot.spring.entity.MeetingDate;
import com.wherehot.spring.entity.MeetingDateWish;

import java.util.List;
import java.util.Optional;

/**
 * 미팅/데이트 서비스 인터페이스
 */
public interface MeetingDateService {
    
    // MeetingDate 관련
    List<MeetingDate> findAllMeetingDates(int page, int size);
    Optional<MeetingDate> findMeetingDateById(int id);
    List<MeetingDate> findMeetingDatesByType(String meetingType, int page, int size);
    List<MeetingDate> findMeetingDatesByGender(String gender, int page, int size);
    List<MeetingDate> findMeetingDatesByLocation(String location, int page, int size);
    List<MeetingDate> findMeetingDatesByAuthor(String authorId, int page, int size);
    List<MeetingDate> findRecruitingMeetingDates(int page, int size);
    List<MeetingDate> searchMeetingDates(String keyword, int page, int size);
    List<MeetingDate> findRecentMeetingDates(int limit);
    List<MeetingDate> findPopularMeetingDates(int limit);
    
    MeetingDate saveMeetingDate(MeetingDate meetingDate);
    MeetingDate updateMeetingDate(MeetingDate meetingDate);
    boolean deleteMeetingDate(int id);
    boolean incrementViewCount(int id);
    boolean incrementLikeCount(int id);
    boolean addParticipant(int id);
    boolean removeParticipant(int id);
    boolean updateMeetingDateStatus(int id, String status);
    
    int getTotalMeetingDateCount();
    int getRecruitingMeetingDateCount();
    int getSearchResultCount(String keyword);
    int getMeetingDateCountByAuthor(String authorId);
    
    // MeetingDateWish 관련
    MeetingDateWish saveMeetingDateWish(MeetingDateWish wish);
    boolean deleteMeetingDateWish(int id);
    boolean deleteMeetingDateWishByUserAndMeeting(String userId, int meetingDateId);
    List<MeetingDateWish> findWishListByUser(String userId, int page, int size);
    int getWishCountByUser(String userId);
    int getWishCountByMeetingDate(int meetingDateId);
    boolean existsWishByUserAndMeeting(String userId, int meetingDateId);
}
