package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Notification;
import com.wherehot.spring.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 알림 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/notifications")
public class NotificationController {
    
    @Autowired
    private NotificationService notificationService;
    
    /**
     * 사용자의 알림 목록 조회 (최신순)
     */
    @GetMapping
    public ResponseEntity<List<Notification>> getUserNotifications(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).build();
        }
        
        String userid = authentication.getName();
        List<Notification> notifications = notificationService.getNotificationsByUserid(userid);
        return ResponseEntity.ok(notifications);
    }
    
    /**
     * 사용자의 읽지 않은 알림 개수 조회
     */
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Object>> getUnreadCount(Authentication authentication) {
        Map<String, Object> response = new HashMap<>();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            response.put("count", 0);
            return ResponseEntity.ok(response);
        }
        
        String userid = authentication.getName();
        int unreadCount = notificationService.getUnreadCountByUserid(userid);
        response.put("count", unreadCount);
        return ResponseEntity.ok(response);
    }
    
    /**
     * 알림을 읽음으로 표시
     */
    @PutMapping("/{notificationId}/read")
    public ResponseEntity<Map<String, Object>> markAsRead(
            @PathVariable Long notificationId, 
            Authentication authentication) {
        Map<String, Object> response = new HashMap<>();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            response.put("success", false);
            response.put("message", "인증이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }
        
        String userid = authentication.getName();
        boolean success = notificationService.markAsRead(notificationId, userid);
        
        if (success) {
            response.put("success", true);
            response.put("message", "알림을 읽음으로 표시했습니다.");
        } else {
            response.put("success", false);
            response.put("message", "알림을 찾을 수 없거나 권한이 없습니다.");
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 사용자의 모든 알림을 읽음으로 표시
     */
    @PutMapping("/mark-all-read")
    public ResponseEntity<Map<String, Object>> markAllAsRead(Authentication authentication) {
        Map<String, Object> response = new HashMap<>();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            response.put("success", false);
            response.put("message", "인증이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }
        
        String userid = authentication.getName();
        boolean success = notificationService.markAllAsRead(userid);
        
        if (success) {
            response.put("success", true);
            response.put("message", "모든 알림을 읽음으로 표시했습니다.");
        } else {
            response.put("success", false);
            response.put("message", "알림 처리 중 오류가 발생했습니다.");
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 알림 삭제
     */
    @DeleteMapping("/{notificationId}")
    public ResponseEntity<Map<String, Object>> deleteNotification(
            @PathVariable Long notificationId, 
            Authentication authentication) {
        Map<String, Object> response = new HashMap<>();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            response.put("success", false);
            response.put("message", "인증이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }
        
        String userid = authentication.getName();
        boolean success = notificationService.deleteNotification(notificationId, userid);
        
        if (success) {
            response.put("success", true);
            response.put("message", "알림을 삭제했습니다.");
        } else {
            response.put("success", false);
            response.put("message", "알림을 찾을 수 없거나 권한이 없습니다.");
        }
        
        return ResponseEntity.ok(response);
    }
}
