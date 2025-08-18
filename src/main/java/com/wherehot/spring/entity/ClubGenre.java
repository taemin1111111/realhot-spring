package com.wherehot.spring.entity;

/**
 * 클럽 장르 엔티티
 */
public class ClubGenre {
    
    private int id;
    private String name;
    private String description;
    private String icon;
    private int sortOrder;
    private boolean active;
    
    // 기본 생성자
    public ClubGenre() {}
    
    // 생성자
    public ClubGenre(String name, String description) {
        this.name = name;
        this.description = description;
        this.active = true;
        this.sortOrder = 0;
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
    
    // Model1 호환성을 위한 메서드들
    public String getGenreName() {
        return name;
    }
    
    public void setGenreName(String genreName) {
        this.name = genreName;
    }
    
    @Override
    public String toString() {
        return "ClubGenre{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", icon='" + icon + '\'' +
                ", sortOrder=" + sortOrder +
                ", active=" + active +
                '}';
    }
}
