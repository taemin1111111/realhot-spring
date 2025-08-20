package com.wherehot.spring.entity;

/**
 * 커뮤니티 카테고리 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class CommunityCategory {
    
    private int id;         // 카테고리 고유 ID
    private String name;    // 카테고리 이름
    private int postCount;  // 게시글 수 (통계용)
    
    // 기본 생성자
    public CommunityCategory() {}

    public CommunityCategory(int id, String name) {
        this.id = id;
        this.name = name;
    }

    // Getter & Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
    
    public int getPostCount() {
        return postCount;
    }
    
    public void setPostCount(int postCount) {
        this.postCount = postCount;
    }
}
