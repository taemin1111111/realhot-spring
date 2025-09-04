package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * MD 찜하기 엔티티
 */
public class MdWish {
    private int wishId;
    private int mdId;
    private String userid;
    private LocalDateTime createdAt;
    
    // 기본 생성자
    public MdWish() {}
    
    // 2개 파라미터 생성자 (새 위시 생성용)
    public MdWish(int mdId, String userid) {
        this.mdId = mdId;
        this.userid = userid;
        this.createdAt = LocalDateTime.now();
    }
    
    // 전체 생성자
    public MdWish(int wishId, int mdId, String userid, LocalDateTime createdAt) {
        this.wishId = wishId;
        this.mdId = mdId;
        this.userid = userid;
        this.createdAt = createdAt;
    }
    
    // Getter와 Setter 메서드들
    public int getWishId() { return wishId; }
    public void setWishId(int wishId) { this.wishId = wishId; }
    
    public int getMdId() { return mdId; }
    public void setMdId(int mdId) { this.mdId = mdId; }
    
    public String getUserid() { return userid; }
    public void setUserid(String userid) { this.userid = userid; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    @Override
    public String toString() {
        return "MdWish{" +
                "wishId=" + wishId +
                ", mdId=" + mdId +
                ", userid='" + userid + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}