package com.wherehot.spring.service;

import com.wherehot.spring.entity.Notification;
import com.wherehot.spring.mapper.NotificationMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 알림 서비스
 */
@Service
public class NotificationService {
    
    @Autowired
    private NotificationMapper notificationMapper;
    
    /**
     * 알림 생성
     */
    public boolean createNotification(Notification notification) {
        try {
            int result = notificationMapper.insertNotification(notification);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 사용자별 알림 목록 조회 (최신순)
     */
    public List<Notification> getNotificationsByUserid(String userid) {
        return notificationMapper.selectNotificationsByUserid(userid);
    }
    
    /**
     * 사용자의 읽지 않은 알림 개수 조회
     */
    public int getUnreadCountByUserid(String userid) {
        return notificationMapper.selectUnreadCountByUserid(userid);
    }
    
    /**
     * 알림을 읽음으로 표시
     */
    public boolean markAsRead(Long notificationId, String userid) {
        try {
            int result = notificationMapper.updateNotificationAsRead(notificationId, userid);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 사용자의 모든 알림을 읽음으로 표시
     */
    public boolean markAllAsRead(String userid) {
        try {
            int result = notificationMapper.updateAllNotificationsAsRead(userid);
            return result >= 0; // 0개여도 성공으로 간주
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 알림 삭제
     */
    public boolean deleteNotification(Long notificationId, String userid) {
        try {
            int result = notificationMapper.deleteNotification(notificationId, userid);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 사용자의 모든 알림 삭제
     */
    public boolean deleteAllNotificationsByUserid(String userid) {
        try {
            int result = notificationMapper.deleteAllNotificationsByUserid(userid);
            return result >= 0; // 0개여도 성공으로 간주
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 특정 알림 조회
     */
    public Notification getNotificationById(Long notificationId) {
        return notificationMapper.selectNotificationById(notificationId);
    }
}
