package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 위시리스트 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class WishList {
    
    private int id;             // 찜 고유 번호
    private String userid;      // 유저 ID (member.userid 참조)
    private int place_id;       // 핫플레이스 ID (hotplace_info.id 참조)
    private LocalDateTime wishDate; // 찜한 날짜
    private String personal_note; // 개인 메모
    private String categoryName; // 카테고리명
    
    // 핫플레이스 정보 (JOIN 결과)
    private String hotplaceName;
    private String hotplaceAddress;
    private Double hotplaceLat;
    private Double hotplaceLng;
    private Integer hotplaceCategoryId;
    private Integer hotplaceRegionId;
    private LocalDateTime hotplaceCreatedAt;
    
    // 사용자 정보 (JOIN 결과)
    private String userNickname;

    // 생성자
    public WishList() {
        this.personal_note = null;
    }

    public WishList(int id, String userid, int place_id, LocalDateTime wishDate) {
        this.id = id;
        this.userid = userid;
        this.place_id = place_id;
        this.wishDate = wishDate;
        this.personal_note = null;
    }

    public WishList(int id, String userid, int place_id, LocalDateTime wishDate, String personal_note) {
        this.id = id;
        this.userid = userid;
        this.place_id = place_id;
        this.wishDate = wishDate;
        this.personal_note = personal_note;
    }

    // Getter & Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUserid() {
        return userid;
    }

    public void setUserid(String userid) {
        this.userid = userid;
    }

    public int getPlace_id() {
        return place_id;
    }

    public void setPlace_id(int place_id) {
        this.place_id = place_id;
    }

    public LocalDateTime getWishDate() {
        return wishDate;
    }

    public void setWishDate(LocalDateTime wishDate) {
        this.wishDate = wishDate;
    }

    public String getPersonal_note() {
        return personal_note;
    }

    public void setPersonal_note(String personal_note) {
        this.personal_note = personal_note;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    // 핫플레이스 정보 Getter & Setter
    public String getHotplaceName() {
        return hotplaceName;
    }

    public void setHotplaceName(String hotplaceName) {
        this.hotplaceName = hotplaceName;
    }

    public String getHotplaceAddress() {
        return hotplaceAddress;
    }

    public void setHotplaceAddress(String hotplaceAddress) {
        this.hotplaceAddress = hotplaceAddress;
    }

    public Double getHotplaceLat() {
        return hotplaceLat;
    }

    public void setHotplaceLat(Double hotplaceLat) {
        this.hotplaceLat = hotplaceLat;
    }

    public Double getHotplaceLng() {
        return hotplaceLng;
    }

    public void setHotplaceLng(Double hotplaceLng) {
        this.hotplaceLng = hotplaceLng;
    }

    public Integer getHotplaceCategoryId() {
        return hotplaceCategoryId;
    }

    public void setHotplaceCategoryId(Integer hotplaceCategoryId) {
        this.hotplaceCategoryId = hotplaceCategoryId;
    }

    public Integer getHotplaceRegionId() {
        return hotplaceRegionId;
    }

    public void setHotplaceRegionId(Integer hotplaceRegionId) {
        this.hotplaceRegionId = hotplaceRegionId;
    }

    public LocalDateTime getHotplaceCreatedAt() {
        return hotplaceCreatedAt;
    }

    public void setHotplaceCreatedAt(LocalDateTime hotplaceCreatedAt) {
        this.hotplaceCreatedAt = hotplaceCreatedAt;
    }

    // 사용자 정보 Getter & Setter
    public String getUserNickname() {
        return userNickname;
    }

    public void setUserNickname(String userNickname) {
        this.userNickname = userNickname;
    }
}
