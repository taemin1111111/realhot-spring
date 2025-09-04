package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.ContentImage;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 콘텐츠 이미지 매퍼 인터페이스
 */
@Mapper
public interface ContentImageMapper {
    
    /**
     * 특정 콘텐츠의 모든 이미지 조회 (순서대로)
     */
    List<ContentImage> getImagesByContentId(@Param("contentId") int contentId);
    
    /**
     * 이미지 ID로 단일 이미지 조회
     */
    ContentImage getImageById(@Param("imageId") int imageId);
    
    /**
     * 이미지 정보 저장
     */
    int insertImage(ContentImage contentImage);
    
    /**
     * 이미지 정보 수정
     */
    int updateImage(ContentImage contentImage);
    
    /**
     * 이미지 삭제
     */
    boolean deleteImage(@Param("imageId") int imageId);
    
    /**
     * 특정 콘텐츠의 최대 이미지 순서 조회
     */
    Integer getMaxImageOrder(@Param("contentId") int contentId);
    
    /**
     * 대표 이미지 설정 (해당 이미지를 1번으로, 기존 1번 이미지들을 뒤로 밀기)
     */
    boolean setAsMainImage(@Param("imageId") int imageId, @Param("contentId") int contentId);
    
    /**
     * 이미지 순서 재정렬 (삭제 후 순서 정리)
     */
    boolean reorderImages(@Param("contentId") int contentId);
    
    /**
     * 특정 콘텐츠의 총 이미지 수 조회
     */
    int getImageCount(@Param("contentId") int contentId);
    
    /**
     * 특정 순서의 이미지 조회
     */
    ContentImage getImageByOrder(@Param("contentId") int contentId, @Param("imageOrder") int imageOrder);
    
    /**
     * 이미지 순서 변경
     */
    boolean updateImageOrder(@Param("imageId") int imageId, @Param("newOrder") int newOrder);
    
    /**
     * 특정 콘텐츠의 모든 이미지 삭제
     */
    boolean deleteAllImagesByContent(@Param("contentId") int contentId);
}
