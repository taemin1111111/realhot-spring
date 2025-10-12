package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.CourseReaction;
import com.wherehot.spring.mapper.CourseReactionMapper;
import com.wherehot.spring.mapper.CourseMapper;
import com.wherehot.spring.service.CourseReactionService;
import com.wherehot.spring.service.ExpService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
@Transactional
public class CourseReactionServiceImpl implements CourseReactionService {
    
    @Autowired
    private CourseReactionMapper courseReactionMapper;
    
    @Autowired
    private CourseMapper courseMapper;
    
    @Autowired
    private ExpService expService;
    
    @Override
    public Map<String, Object> toggleReaction(int courseId, String userKey, String reactionType) {
        Map<String, Object> result = new HashMap<>();
        
        // courseId 유효성 검사
        if (courseId <= 0) {
            result.put("success", false);
            result.put("message", "유효하지 않은 코스 ID입니다.");
            return result;
        }
        
        // 현재 사용자의 리액션 조회
        Optional<CourseReaction> existingReaction = courseReactionMapper.findByCourseIdAndUserKey(courseId, userKey);
        
        if (existingReaction.isPresent()) {
            CourseReaction reaction = existingReaction.get();
            
            // 같은 리액션을 다시 누르면 삭제 (토글)
            if (reactionType.equals(reaction.getReaction())) {
                courseReactionMapper.deleteReaction(courseId, userKey);
                result.put("currentReaction", null);
                result.put("action", "removed");
            } else {
                // 다른 리액션으로 변경
                reaction.setReaction(reactionType);
                reaction.setCreatedAt(LocalDateTime.now());
                courseReactionMapper.insertOrUpdateReaction(reaction);
                result.put("currentReaction", reactionType);
                result.put("action", "changed");
            }
        } else {
            // 새로운 리액션 추가
            CourseReaction newReaction = new CourseReaction();
            newReaction.setCourseId(courseId);
            newReaction.setUserKey(userKey);
            newReaction.setReaction(reactionType);
            newReaction.setCreatedAt(LocalDateTime.now());
            
            courseReactionMapper.insertOrUpdateReaction(newReaction);
            result.put("currentReaction", reactionType);
            result.put("action", "added");
            
            // 좋아요를 받은 경우 코스 작성자에게 경험치 지급
            if ("LIKE".equals(reactionType)) {
                try {
                    // 코스 작성자 정보 조회
                    String courseAuthor = courseMapper.getCourseAuthorById(courseId);
                    if (courseAuthor != null && !courseAuthor.trim().isEmpty() && !courseAuthor.startsWith("anonymous|")) {
                        boolean expAdded = expService.addLikeExp(courseAuthor, 1);
                        if (expAdded) {
                            System.out.println("Like exp added successfully for course author: " + courseAuthor);
                        } else {
                            System.out.println("Like exp not added (daily limit reached) for course author: " + courseAuthor);
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Error adding like exp for course author: " + e.getMessage());
                    // 경험치 지급 실패는 추천 자체를 실패시키지 않음
                }
            }
        }
        
        // 업데이트된 개수 조회
        Map<String, Integer> counts = getReactionCounts(courseId);
        result.put("likeCount", counts.get("likeCount"));
        result.put("dislikeCount", counts.get("dislikeCount"));
        
        return result;
    }
    
    @Override
    @Transactional(readOnly = true)
    public String getCurrentReaction(int courseId, String userKey) {
        try {
            Optional<CourseReaction> reaction = courseReactionMapper.findByCourseIdAndUserKey(courseId, userKey);
            return reaction.map(CourseReaction::getReaction).orElse(null);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Integer> getReactionCounts(int courseId) {
        Map<String, Integer> counts = new HashMap<>();
        try {
            counts.put("likeCount", courseReactionMapper.countLikesByCourseId(courseId));
            counts.put("dislikeCount", courseReactionMapper.countDislikesByCourseId(courseId));
        } catch (Exception e) {
            // 오류 발생 시 기본값 설정
            counts.put("likeCount", 0);
            counts.put("dislikeCount", 0);
            e.printStackTrace();
        }
        return counts;
    }
    
    @Override
    public boolean removeReaction(int courseId, String userKey) {
        return courseReactionMapper.deleteReaction(courseId, userKey) > 0;
    }
}
