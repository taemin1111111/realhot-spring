package com.wherehot.spring.service;

import com.wherehot.spring.entity.ContentImage;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

/**
 * 콘텐츠 이미지 서비스 인터페이스
 */
public interface ContentImageService {
    
    /**
     * 특정 핫플레이스의 모든 이미지 조회
     */
    List<ContentImage> getImagesByHotplaceId(int hotplaceId);
    
    /**
     * 이미지 ID로 단일 이미지 조회
     */
    ContentImage getImageById(int imageId);
    
    /**
     * 이미지 업로드 및 저장
     */
    Map<String, Object> uploadImages(int placeId, MultipartFile[] images, String webappPath);
    
    /**
     * 이미지 삭제
     */
    Map<String, Object> deleteImage(int imageId, String webappPath);
    
    /**
     * 대표 이미지 설정
     */
    Map<String, Object> setMainImage(int imageId, int placeId);
    
    /**
     * 다음 이미지 순서 번호 조회
     */
    int getNextImageOrder(int hotplaceId);
    
    /**
     * 이미지 순서 재정렬
     */
    boolean reorderImagesAfterDelete(int hotplaceId);
    
    /**
     * 특정 핫플레이스의 대표 이미지 조회
     */
    ContentImage getMainImage(int hotplaceId);
    
    /**
     * 이미지 경로 유효성 검증
     */
    boolean validateImagePath(String imagePath);
    
    /**
     * 이미지 파일 크기 및 형식 검증
     */
    Map<String, Object> validateImageFile(MultipartFile file);
}
