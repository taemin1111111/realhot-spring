package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.MeetingDate;
import com.wherehot.spring.entity.MeetingDateWish;
import com.wherehot.spring.service.MeetingDateService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 미팅/데이트 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/meeting-dates")
public class MeetingDateController {
    
    @Autowired
    private MeetingDateService meetingDateService;
    
    /**
     * 모든 미팅/데이트 조회 (페이징)
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllMeetingDates(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<MeetingDate> meetingDates = meetingDateService.findAllMeetingDates(page, size);
        int totalCount = meetingDateService.getTotalMeetingDateCount();
        
        Map<String, Object> result = new HashMap<>();
        result.put("meetingDates", meetingDates);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * ID로 미팅/데이트 조회
     */
    @GetMapping("/{id}")
    public ResponseEntity<MeetingDate> getMeetingDateById(@PathVariable int id) {
        Optional<MeetingDate> meetingDate = meetingDateService.findMeetingDateById(id);
        if (meetingDate.isPresent()) {
            // 조회수 증가
            meetingDateService.incrementViewCount(id);
            return ResponseEntity.ok(meetingDate.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    /**
     * 타입별 미팅/데이트 조회
     */
    @GetMapping("/type/{meetingType}")
    public ResponseEntity<Map<String, Object>> getMeetingDatesByType(
            @PathVariable String meetingType,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<MeetingDate> meetingDates = meetingDateService.findMeetingDatesByType(meetingType, page, size);
        
        Map<String, Object> result = new HashMap<>();
        result.put("meetingDates", meetingDates);
        result.put("currentPage", page);
        result.put("meetingType", meetingType);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 성별별 미팅/데이트 조회
     */
    @GetMapping("/gender/{gender}")
    public ResponseEntity<Map<String, Object>> getMeetingDatesByGender(
            @PathVariable String gender,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<MeetingDate> meetingDates = meetingDateService.findMeetingDatesByGender(gender, page, size);
        
        Map<String, Object> result = new HashMap<>();
        result.put("meetingDates", meetingDates);
        result.put("currentPage", page);
        result.put("gender", gender);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 지역별 미팅/데이트 조회
     */
    @GetMapping("/location/{location}")
    public ResponseEntity<Map<String, Object>> getMeetingDatesByLocation(
            @PathVariable String location,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<MeetingDate> meetingDates = meetingDateService.findMeetingDatesByLocation(location, page, size);
        
        Map<String, Object> result = new HashMap<>();
        result.put("meetingDates", meetingDates);
        result.put("currentPage", page);
        result.put("location", location);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 모집중인 미팅/데이트 조회
     */
    @GetMapping("/recruiting")
    public ResponseEntity<Map<String, Object>> getRecruitingMeetingDates(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<MeetingDate> meetingDates = meetingDateService.findRecruitingMeetingDates(page, size);
        int totalCount = meetingDateService.getRecruitingMeetingDateCount();
        
        Map<String, Object> result = new HashMap<>();
        result.put("meetingDates", meetingDates);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 미팅/데이트 검색
     */
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchMeetingDates(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<MeetingDate> meetingDates = meetingDateService.searchMeetingDates(keyword, page, size);
        int totalCount = meetingDateService.getSearchResultCount(keyword);
        
        Map<String, Object> result = new HashMap<>();
        result.put("meetingDates", meetingDates);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("keyword", keyword);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 최신 미팅/데이트 조회
     */
    @GetMapping("/recent")
    public ResponseEntity<List<MeetingDate>> getRecentMeetingDates(@RequestParam(defaultValue = "10") int limit) {
        List<MeetingDate> meetingDates = meetingDateService.findRecentMeetingDates(limit);
        return ResponseEntity.ok(meetingDates);
    }
    
    /**
     * 인기 미팅/데이트 조회
     */
    @GetMapping("/popular")
    public ResponseEntity<List<MeetingDate>> getPopularMeetingDates(@RequestParam(defaultValue = "10") int limit) {
        List<MeetingDate> meetingDates = meetingDateService.findPopularMeetingDates(limit);
        return ResponseEntity.ok(meetingDates);
    }
    
    /**
     * 작성자별 미팅/데이트 조회
     */
    @GetMapping("/author/{authorId}")
    public ResponseEntity<Map<String, Object>> getMeetingDatesByAuthor(
            @PathVariable String authorId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<MeetingDate> meetingDates = meetingDateService.findMeetingDatesByAuthor(authorId, page, size);
        int totalCount = meetingDateService.getMeetingDateCountByAuthor(authorId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("meetingDates", meetingDates);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("authorId", authorId);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 미팅/데이트 등록
     */
    @PostMapping
    public ResponseEntity<MeetingDate> createMeetingDate(@RequestBody MeetingDate meetingDate,
                                                        @AuthenticationPrincipal UserDetails userDetails) {
        try {
            if (userDetails != null) {
                meetingDate.setAuthorId(userDetails.getUsername());
            }
            
            MeetingDate savedMeetingDate = meetingDateService.saveMeetingDate(meetingDate);
            return ResponseEntity.ok(savedMeetingDate);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 미팅/데이트 수정
     */
    @PutMapping("/{id}")
    public ResponseEntity<MeetingDate> updateMeetingDate(@PathVariable int id,
                                                        @RequestBody MeetingDate meetingDate,
                                                        @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 기존 미팅/데이트 조회
            Optional<MeetingDate> existingMeetingDate = meetingDateService.findMeetingDateById(id);
            if (existingMeetingDate.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            // 작성자 권한 확인
            if (userDetails == null || !existingMeetingDate.get().getAuthorId().equals(userDetails.getUsername())) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            meetingDate.setId(id);
            MeetingDate updatedMeetingDate = meetingDateService.updateMeetingDate(meetingDate);
            return ResponseEntity.ok(updatedMeetingDate);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 미팅/데이트 삭제
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMeetingDate(@PathVariable int id,
                                                 @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 기존 미팅/데이트 조회
            Optional<MeetingDate> existingMeetingDate = meetingDateService.findMeetingDateById(id);
            if (existingMeetingDate.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            // 작성자 권한 확인 (또는 관리자)
            if (userDetails == null || (!existingMeetingDate.get().getAuthorId().equals(userDetails.getUsername()) 
                && !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN")))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            boolean deleted = meetingDateService.deleteMeetingDate(id);
            return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 좋아요 처리
     */
    @PostMapping("/{id}/like")
    public ResponseEntity<Map<String, Object>> likeMeetingDate(@PathVariable int id) {
        try {
            boolean updated = meetingDateService.incrementLikeCount(id);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", updated);
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 참가 신청
     */
    @PostMapping("/{id}/participate")
    public ResponseEntity<Map<String, Object>> participateInMeetingDate(@PathVariable int id) {
        try {
            boolean updated = meetingDateService.addParticipant(id);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", updated);
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 참가 취소
     */
    @DeleteMapping("/{id}/participate")
    public ResponseEntity<Map<String, Object>> cancelParticipation(@PathVariable int id) {
        try {
            boolean updated = meetingDateService.removeParticipant(id);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", updated);
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 상태 변경 (작성자 또는 관리자)
     */
    @PatchMapping("/{id}/status")
    public ResponseEntity<Void> updateMeetingDateStatus(@PathVariable int id,
                                                       @RequestParam String status,
                                                       @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 기존 미팅/데이트 조회
            Optional<MeetingDate> existingMeetingDate = meetingDateService.findMeetingDateById(id);
            if (existingMeetingDate.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            // 작성자 또는 관리자 권한 확인
            if (userDetails == null || (!existingMeetingDate.get().getAuthorId().equals(userDetails.getUsername()) 
                && !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN")))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            boolean updated = meetingDateService.updateMeetingDateStatus(id, status);
            return updated ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    // 위시리스트 관련 API
    
    /**
     * 위시리스트 추가
     */
    @PostMapping("/{meetingDateId}/wish")
    public ResponseEntity<MeetingDateWish> addToWishList(@PathVariable int meetingDateId,
                                                        @AuthenticationPrincipal UserDetails userDetails) {
        try {
            if (userDetails == null) {
                return ResponseEntity.status(401).build(); // Unauthorized
            }
            
            String userId = userDetails.getUsername();
            
            // 중복 체크
            boolean exists = meetingDateService.existsWishByUserAndMeeting(userId, meetingDateId);
            if (exists) {
                return ResponseEntity.status(409).build(); // Conflict
            }
            
            MeetingDateWish wish = new MeetingDateWish(userId, meetingDateId);
            MeetingDateWish savedWish = meetingDateService.saveMeetingDateWish(wish);
            
            return ResponseEntity.ok(savedWish);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 위시리스트 삭제
     */
    @DeleteMapping("/{meetingDateId}/wish")
    public ResponseEntity<Void> removeFromWishList(@PathVariable int meetingDateId,
                                                  @AuthenticationPrincipal UserDetails userDetails) {
        try {
            if (userDetails == null) {
                return ResponseEntity.status(401).build(); // Unauthorized
            }
            
            String userId = userDetails.getUsername();
            boolean deleted = meetingDateService.deleteMeetingDateWishByUserAndMeeting(userId, meetingDateId);
            
            return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 내 위시리스트 조회
     */
    @GetMapping("/my-wishlist")
    public ResponseEntity<Map<String, Object>> getMyWishList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        if (userDetails == null) {
            return ResponseEntity.status(401).build(); // Unauthorized
        }
        
        String userId = userDetails.getUsername();
        List<MeetingDateWish> wishList = meetingDateService.findWishListByUser(userId, page, size);
        int totalCount = meetingDateService.getWishCountByUser(userId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("wishList", wishList);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 위시리스트 존재 여부 확인
     */
    @GetMapping("/{meetingDateId}/wish/exists")
    public ResponseEntity<Map<String, Boolean>> checkWishExists(@PathVariable int meetingDateId,
                                                               @AuthenticationPrincipal UserDetails userDetails) {
        
        if (userDetails == null) {
            Map<String, Boolean> result = new HashMap<>();
            result.put("exists", false);
            return ResponseEntity.ok(result);
        }
        
        String userId = userDetails.getUsername();
        boolean exists = meetingDateService.existsWishByUserAndMeeting(userId, meetingDateId);
        
        Map<String, Boolean> result = new HashMap<>();
        result.put("exists", exists);
        
        return ResponseEntity.ok(result);
    }
}
