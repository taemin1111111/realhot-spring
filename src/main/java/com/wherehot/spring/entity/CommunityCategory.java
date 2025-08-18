package com.wherehot.spring.entity;

/**
 * 커뮤니티 카테고리 엔티티
 */
public class CommunityCategory {
    
    private int id;
    private String name;
    private String description;
    private String icon;
    private int sortOrder;
    private boolean active;
    
    // 기본 생성자
    public CommunityCategory() {}
    
    // 생성자
    public CommunityCategory(String name, String description) {
        this.name = name;
        this.description = description;
        this.active = true;
    }
    
    // Getters and Setters
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
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getIcon() {
        return icon;
    }
    
    public void setIcon(String icon) {
        this.icon = icon;
    }
    
    public int getSortOrder() {
        return sortOrder;
    }
    
    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }
    
    public boolean isActive() {
        return active;
    }
    
    public void setActive(boolean active) {
        this.active = active;
    }
    
    @Override
    public String toString() {
        return "CommunityCategory{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", icon='" + icon + '\'' +
                ", sortOrder=" + sortOrder +
                ", active=" + active +
                '}';
    }
}
