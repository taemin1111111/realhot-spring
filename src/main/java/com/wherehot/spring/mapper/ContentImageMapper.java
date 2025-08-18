package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.ContentImages;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 콘텐츠 이미지 매퍼 인터페이스
 */
@Mapper
public interface ContentImageMapper {
    
    /**
     * 특정 핫플레이스의 모든 이미지 조회 (순서대로)
     */
    List<ContentImages> getImagesByHotplaceId(@Param("hotplaceId") int hotplaceId);
    
    /**
     * 이미지 ID로 단일 이미지 조회
     */
    ContentImages getImageById(@Param("imageId") int imageId);
    
    /**
     * 이미지 정보 저장
     */
    int insertImage(ContentImages contentImage);
    
    /**
     * 이미지 정보 수정
     */
    int updateImage(ContentImages contentImage);
    
    /**
     * 이미지 삭제
     */
    boolean deleteImage(@Param("imageId") int imageId);
    
    /**
     * 특정 핫플레이스의 최대 이미지 순서 조회
     */
    Integer getMaxImageOrder(@Param("hotplaceId") int hotplaceId);
    
    /**
     * 대표 이미지 설정 (해당 이미지를 1번으로, 기존 1번 이미지들을 뒤로 밀기)
     */
    boolean setAsMainImage(@Param("imageId") int imageId, @Param("placeId") int placeId);
    
    /**
     * 이미지 순서 재정렬 (삭제 후 순서 정리)
     */
    boolean reorderImages(@Param("hotplaceId") int hotplaceId);
    
    /**
     * 특정 핫플레이스의 총 이미지 수 조회
     */
    int getImageCount(@Param("hotplaceId") int hotplaceId);
    
    /**
     * 특정 순서의 이미지 조회
     */
    ContentImages getImageByOrder(@Param("hotplaceId") int hotplaceId, @Param("imageOrder") int imageOrder);
    
    /**
     * 이미지 순서 변경
     */
    boolean updateImageOrder(@Param("imageId") int imageId, @Param("newOrder") int newOrder);
    
    /**
     * 특정 핫플레이스의 모든 이미지 삭제
     */
    boolean deleteAllImagesByHotplace(@Param("hotplaceId") int hotplaceId);
}
