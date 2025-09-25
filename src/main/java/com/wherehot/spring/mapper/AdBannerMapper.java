package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.AdBanner;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AdBannerMapper {
    
    // 활성화된 광고 배너 목록 조회 (display_order 순으로 정렬)
    List<AdBanner> getActiveAdBanners();
    
    // 모든 광고 배너 목록 조회 (관리자용)
    List<AdBanner> getAllAdBanners();
    
    // 광고 배너 상세 조회
    AdBanner getAdBannerById(@Param("adId") int adId);
    
    // 광고 배너 추가
    int insertAdBanner(AdBanner adBanner);
    
    // 광고 배너 수정
    int updateAdBanner(AdBanner adBanner);
    
    // 광고 배너 삭제
    int deleteAdBanner(@Param("adId") int adId);
    
    // 광고 배너 활성화/비활성화 토글
    int toggleAdBannerStatus(@Param("adId") int adId, @Param("isActive") boolean isActive);
    
    // 광고 배너 순서 변경
    int updateDisplayOrder(@Param("adId") int adId, @Param("displayOrder") int displayOrder);
}
