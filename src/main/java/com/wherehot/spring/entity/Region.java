package com.wherehot.spring.entity;

/**
 * 지역 정보 엔티티 - Model1 구조에 맞게 간소화
 */
public class Region {
    private Integer id;
    private String sido;
    private String sigungu;
    private String dong;
    private Double lat;
    private Double lng;
    
    // 생성자
    public Region() {}
    
    public Region(String sido, String sigungu, String dong, Double lat, Double lng) {
        this.sido = sido;
        this.sigungu = sigungu;
        this.dong = dong;
        this.lat = lat;
        this.lng = lng;
    }
    
    // Getter/Setter
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    
    public String getSido() { return sido; }
    public void setSido(String sido) { this.sido = sido; }
    
    public String getSigungu() { return sigungu; }
    public void setSigungu(String sigungu) { this.sigungu = sigungu; }
    
    public String getDong() { return dong; }
    public void setDong(String dong) { this.dong = dong; }
    
    public Double getLat() { return lat; }
    public void setLat(Double lat) { this.lat = lat; }
    
    public Double getLng() { return lng; }
    public void setLng(Double lng) { this.lng = lng; }
    
    @Override
    public String toString() {
        return "Region{" +
                "id=" + id +
                ", sido='" + sido + '\'' +
                ", sigungu='" + sigungu + '\'' +
                ", dong='" + dong + '\'' +
                ", lat=" + lat +
                ", lng=" + lng +
                '}';
    }
}
