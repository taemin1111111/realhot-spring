package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.MeetingDate;
import com.wherehot.spring.entity.MeetingDateWish;
import com.wherehot.spring.mapper.MeetingDateMapper;
import com.wherehot.spring.service.MeetingDateService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class MeetingDateServiceImpl implements MeetingDateService {
    
    private static final Logger logger = LoggerFactory.getLogger(MeetingDateServiceImpl.class);
    
    @Autowired
    private MeetingDateMapper meetingDateMapper;
    
    // MeetingDate 관련
    @Override
    @Transactional(readOnly = true)
    public List<MeetingDate> findAllMeetingDates(int page, int size) {
        try {
            int offset = (page - 1) * size;
            return meetingDateMapper.findAll(offset, size);
        } catch (Exception e) {
            logger.error("Error finding all meeting dates", e);
            throw new RuntimeException("모든 미팅/데이트 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<MeetingDate> findMeetingDateById(int id) {
        try {
            return meetingDateMapper.findById(id);
        } catch (Exception e) {
            logger.error("Error finding meeting date by id: {}", id, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<MeetingDate> findMeetingDatesByType(String meetingType, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return meetingDateMapper.findByMeetingType(meetingType, offset, size);
        } catch (Exception e) {
            logger.error("Error finding meeting dates by type: {}", meetingType, e);
            throw new RuntimeException("타입별 미팅/데이트 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<MeetingDate> findMeetingDatesByGender(String gender, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return meetingDateMapper.findByGender(gender, offset, size);
        } catch (Exception e) {
            logger.error("Error finding meeting dates by gender: {}", gender, e);
            throw new RuntimeException("성별별 미팅/데이트 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<MeetingDate> findMeetingDatesByLocation(String location, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return meetingDateMapper.findByLocation(location, offset, size);
        } catch (Exception e) {
            logger.error("Error finding meeting dates by location: {}", location, e);
            throw new RuntimeException("지역별 미팅/데이트 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<MeetingDate> findMeetingDatesByAuthor(String authorId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return meetingDateMapper.findByAuthorId(authorId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding meeting dates by author: {}", authorId, e);
            throw new RuntimeException("작성자별 미팅/데이트 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<MeetingDate> findRecruitingMeetingDates(int page, int size) {
        try {
            int offset = (page - 1) * size;
            return meetingDateMapper.findRecruiting(offset, size);
        } catch (Exception e) {
            logger.error("Error finding recruiting meeting dates", e);
            throw new RuntimeException("모집중인 미팅/데이트 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<MeetingDate> searchMeetingDates(String keyword, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return meetingDateMapper.searchMeetingDates(keyword, offset, size);
        } catch (Exception e) {
            logger.error("Error searching meeting dates with keyword: {}", keyword, e);
            throw new RuntimeException("미팅/데이트 검색 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<MeetingDate> findRecentMeetingDates(int limit) {
        try {
            return meetingDateMapper.findRecent(limit);
        } catch (Exception e) {
            logger.error("Error finding recent meeting dates", e);
            throw new RuntimeException("최신 미팅/데이트 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<MeetingDate> findPopularMeetingDates(int limit) {
        try {
            return meetingDateMapper.findPopular(limit);
        } catch (Exception e) {
            logger.error("Error finding popular meeting dates", e);
            throw new RuntimeException("인기 미팅/데이트 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public MeetingDate saveMeetingDate(MeetingDate meetingDate) {
        try {
            meetingDate.setCreatedAt(LocalDateTime.now());
            meetingDate.setUpdatedAt(LocalDateTime.now());
            if (meetingDate.getStatus() == null) {
                meetingDate.setStatus("RECRUITING");
            }
            
            int result = meetingDateMapper.insertMeetingDate(meetingDate);
            if (result > 0) {
                logger.info("MeetingDate saved successfully: title={}, authorId={}", 
                    meetingDate.getTitle(), meetingDate.getAuthorId());
                return meetingDate;
            } else {
                throw new RuntimeException("미팅/데이트 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving meeting date: title={}, authorId={}", 
                meetingDate.getTitle(), meetingDate.getAuthorId(), e);
            throw new RuntimeException("미팅/데이트 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public MeetingDate updateMeetingDate(MeetingDate meetingDate) {
        try {
            Optional<MeetingDate> existingMeetingDate = meetingDateMapper.findById(meetingDate.getId());
            if (existingMeetingDate.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 미팅/데이트입니다: " + meetingDate.getId());
            }
            
            meetingDate.setUpdatedAt(LocalDateTime.now());
            
            int result = meetingDateMapper.updateMeetingDate(meetingDate);
            if (result > 0) {
                logger.info("MeetingDate updated successfully: {}", meetingDate.getId());
                return meetingDate;
            } else {
                throw new RuntimeException("미팅/데이트 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error updating meeting date: {}", meetingDate.getId(), e);
            throw new RuntimeException("미팅/데이트 수정 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean deleteMeetingDate(int id) {
        try {
            Optional<MeetingDate> meetingDate = meetingDateMapper.findById(id);
            if (meetingDate.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 미팅/데이트입니다: " + id);
            }
            
            int result = meetingDateMapper.deleteMeetingDate(id);
            if (result > 0) {
                logger.info("MeetingDate deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting meeting date: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean incrementViewCount(int id) {
        try {
            int result = meetingDateMapper.updateViewCount(id);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error incrementing view count: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean incrementLikeCount(int id) {
        try {
            int result = meetingDateMapper.updateLikeCount(id);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error incrementing like count: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean addParticipant(int id) {
        try {
            int result = meetingDateMapper.updateParticipantCount(id, 1);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error adding participant: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean removeParticipant(int id) {
        try {
            int result = meetingDateMapper.updateParticipantCount(id, -1);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error removing participant: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean updateMeetingDateStatus(int id, String status) {
        try {
            int result = meetingDateMapper.updateStatus(id, status);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating meeting date status: id={}, status={}", id, status, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getTotalMeetingDateCount() {
        try {
            return meetingDateMapper.countAll();
        } catch (Exception e) {
            logger.error("Error getting total meeting date count", e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getRecruitingMeetingDateCount() {
        try {
            return meetingDateMapper.countRecruiting();
        } catch (Exception e) {
            logger.error("Error getting recruiting meeting date count", e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getSearchResultCount(String keyword) {
        try {
            return meetingDateMapper.countSearchResults(keyword);
        } catch (Exception e) {
            logger.error("Error getting search result count: {}", keyword, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getMeetingDateCountByAuthor(String authorId) {
        try {
            return meetingDateMapper.countByAuthorId(authorId);
        } catch (Exception e) {
            logger.error("Error getting meeting date count by author: {}", authorId, e);
            return 0;
        }
    }
    
    // MeetingDateWish 관련
    @Override
    public MeetingDateWish saveMeetingDateWish(MeetingDateWish wish) {
        try {
            wish.setCreatedAt(LocalDateTime.now());
            
            int result = meetingDateMapper.insertMeetingDateWish(wish);
            if (result > 0) {
                logger.info("MeetingDateWish saved successfully: userId={}, meetingDateId={}", 
                    wish.getUserId(), wish.getMeetingDateId());
                return wish;
            } else {
                throw new RuntimeException("미팅/데이트 위시 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving meeting date wish: userId={}, meetingDateId={}", 
                wish.getUserId(), wish.getMeetingDateId(), e);
            throw new RuntimeException("미팅/데이트 위시 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean deleteMeetingDateWish(int id) {
        try {
            int result = meetingDateMapper.deleteMeetingDateWish(id);
            if (result > 0) {
                logger.info("MeetingDateWish deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting meeting date wish: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean deleteMeetingDateWishByUserAndMeeting(String userId, int meetingDateId) {
        try {
            int result = meetingDateMapper.deleteMeetingDateWishByUserAndMeeting(userId, meetingDateId);
            if (result > 0) {
                logger.info("MeetingDateWish deleted successfully: userId={}, meetingDateId={}", userId, meetingDateId);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting meeting date wish by user and meeting: userId={}, meetingDateId={}", userId, meetingDateId, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<MeetingDateWish> findWishListByUser(String userId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return meetingDateMapper.findWishListByUserId(userId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding wish list by user: {}", userId, e);
            throw new RuntimeException("사용자별 미팅/데이트 위시리스트 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getWishCountByUser(String userId) {
        try {
            return meetingDateMapper.countWishByUserId(userId);
        } catch (Exception e) {
            logger.error("Error getting wish count by user: {}", userId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getWishCountByMeetingDate(int meetingDateId) {
        try {
            return meetingDateMapper.countWishByMeetingDateId(meetingDateId);
        } catch (Exception e) {
            logger.error("Error getting wish count by meeting date: {}", meetingDateId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public boolean existsWishByUserAndMeeting(String userId, int meetingDateId) {
        try {
            return meetingDateMapper.existsWishByUserAndMeeting(userId, meetingDateId);
        } catch (Exception e) {
            logger.error("Error checking wish existence: userId={}, meetingDateId={}", userId, meetingDateId, e);
            return false;
        }
    }
}
