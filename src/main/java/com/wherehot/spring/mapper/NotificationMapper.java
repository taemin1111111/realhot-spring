package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Notification;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 알림 MyBatis Mapper
 * notification 테이블과 매핑
 */
@Mapper
public interface NotificationMapper {
    
    /**
     * 알림 생성
     */
    int insertNotification(Notification notification);
    
    /**
     * 사용자별 알림 목록 조회 (최신순)
     */
    List<Notification> selectNotificationsByUserid(@Param("userid") String userid);
    
    /**
     * 사용자의 읽지 않은 알림 개수 조회
     */
    int selectUnreadCountByUserid(@Param("userid") String userid);
    
    /**
     * 알림을 읽음으로 표시
     */
    int updateNotificationAsRead(@Param("notificationId") Long notificationId, @Param("userid") String userid);
    
    /**
     * 사용자의 모든 알림을 읽음으로 표시
     */
    int updateAllNotificationsAsRead(@Param("userid") String userid);
    
    /**
     * 알림 삭제
     */
    int deleteNotification(@Param("notificationId") Long notificationId, @Param("userid") String userid);
    
    /**
     * 사용자의 모든 알림 삭제
     */
    int deleteAllNotificationsByUserid(@Param("userid") String userid);
    
    /**
     * 특정 알림 조회
     */
    Notification selectNotificationById(@Param("notificationId") Long notificationId);
}
