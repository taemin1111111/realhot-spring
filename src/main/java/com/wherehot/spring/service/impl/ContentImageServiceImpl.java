package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.ContentImages;
import com.wherehot.spring.mapper.ContentImageMapper;
import com.wherehot.spring.service.ContentImageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.*;

/**
 * 콘텐츠 이미지 서비스 구현체
 */
@Service
@Transactional
public class ContentImageServiceImpl implements ContentImageService {
    
    @Autowired
    private ContentImageMapper contentImageMapper;
    
    // 지원하는 이미지 포맷
    private static final Set<String> SUPPORTED_FORMATS = Set.of(
        "image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"
    );
    
    // 최대 파일 크기 (10MB)
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024;
    
    @Override
    public List<ContentImages> getImagesByHotplaceId(int hotplaceId) {
        try {
            return contentImageMapper.getImagesByHotplaceId(hotplaceId);
        } catch (Exception e) {
            throw new RuntimeException("핫플레이스 이미지 조회 중 오류가 발생했습니다: " + e.getMessage(), e);
        }
    }
    
    @Override
    public ContentImages getImageById(int imageId) {
        try {
            return contentImageMapper.getImageById(imageId);
        } catch (Exception e) {
            throw new RuntimeException("이미지 조회 중 오류가 발생했습니다: " + e.getMessage(), e);
        }
    }
    
    @Override
    public Map<String, Object> uploadImages(int placeId, MultipartFile[] images, String webappPath) {
        Map<String, Object> result = new HashMap<>();
        List<String> uploadedPaths = new ArrayList<>();
        
        try {
            // 업로드 디렉토리 생성
            String uploadDir = webappPath + "uploads" + File.separator + "places" + File.separator + placeId + File.separator;
            Path uploadPath = Paths.get(uploadDir);
            
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            // 각 이미지 파일 처리
            for (MultipartFile image : images) {
                if (image.isEmpty()) continue;
                
                // 파일 유효성 검증
                Map<String, Object> validation = validateImageFile(image);
                if (!(Boolean) validation.get("valid")) {
                    result.put("success", false);
                    result.put("message", validation.get("message"));
                    return result;
                }
                
                // 파일명 생성 (타임스탬프 + 원본파일명)
                String originalFilename = image.getOriginalFilename();
                String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
                String newFilename = System.currentTimeMillis() + "_" + originalFilename;
                
                // 파일 저장
                Path targetPath = uploadPath.resolve(newFilename);
                Files.copy(image.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);
                
                // DB에 이미지 정보 저장
                ContentImages contentImage = new ContentImages();
                contentImage.setHotplaceId(placeId);
                contentImage.setImagePath("/uploads/places/" + placeId + "/" + newFilename);
                contentImage.setImageOrder(getNextImageOrder(placeId));
                
                contentImageMapper.insertImage(contentImage);
                uploadedPaths.add(contentImage.getImagePath());
            }
            
            result.put("success", true);
            result.put("message", "이미지가 성공적으로 업로드되었습니다.");
            result.put("uploadedPaths", uploadedPaths);
            
        } catch (IOException e) {
            result.put("success", false);
            result.put("message", "파일 저장 중 오류가 발생했습니다: " + e.getMessage());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "이미지 업로드 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
    
    @Override
    public Map<String, Object> deleteImage(int imageId, String webappPath) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 이미지 정보 조회
            ContentImages image = contentImageMapper.getImageById(imageId);
            
            if (image == null) {
                result.put("success", false);
                result.put("message", "해당 이미지를 찾을 수 없습니다.");
                return result;
            }
            
            // 물리적 파일 삭제
            try {
                String fullPath = webappPath + image.getImagePath().substring(1); // /uploads/... -> uploads/...
                Path filePath = Paths.get(fullPath);
                
                if (Files.exists(filePath)) {
                    Files.delete(filePath);
                }
            } catch (IOException e) {
                // 파일 삭제 실패해도 DB 삭제는 진행
                System.err.println("파일 삭제 실패: " + e.getMessage());
            }
            
            // DB에서 이미지 정보 삭제
            boolean deleted = contentImageMapper.deleteImage(imageId);
            
            if (!deleted) {
                result.put("success", false);
                result.put("message", "DB에서 이미지 삭제에 실패했습니다.");
                return result;
            }
            
            // 이미지 순서 재정렬
            boolean reordered = reorderImagesAfterDelete(image.getHotplaceId());
            
            if (!reordered) {
                // 롤백은 하지 않고 경고만 로그
                System.err.println("이미지 순서 재정렬 실패 - 장소 ID: " + image.getHotplaceId());
            }
            
            result.put("success", true);
            result.put("message", "이미지가 성공적으로 삭제되었습니다.");
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "이미지 삭제 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
    
    @Override
    public Map<String, Object> setMainImage(int imageId, int placeId) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 이미지 존재 여부 확인
            ContentImages image = contentImageMapper.getImageById(imageId);
            
            if (image == null || image.getHotplaceId() != placeId) {
                result.put("success", false);
                result.put("message", "해당 이미지를 찾을 수 없거나 장소 정보가 일치하지 않습니다.");
                return result;
            }
            
            // 대표 이미지 설정 (순서를 1로 변경하고 기존 1번을 뒤로 밀기)
            boolean success = contentImageMapper.setAsMainImage(imageId, placeId);
            
            if (success) {
                result.put("success", true);
                result.put("message", "대표 이미지가 성공적으로 변경되었습니다.");
            } else {
                result.put("success", false);
                result.put("message", "대표 이미지 변경에 실패했습니다.");
            }
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "대표 이미지 설정 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
    
    @Override
    public int getNextImageOrder(int hotplaceId) {
        try {
            Integer maxOrder = contentImageMapper.getMaxImageOrder(hotplaceId);
            return (maxOrder != null) ? maxOrder + 1 : 1;
        } catch (Exception e) {
            return 1; // 오류 시 기본값
        }
    }
    
    @Override
    public boolean reorderImagesAfterDelete(int hotplaceId) {
        try {
            return contentImageMapper.reorderImages(hotplaceId);
        } catch (Exception e) {
            return false;
        }
    }
    
    @Override
    public ContentImages getMainImage(int hotplaceId) {
        try {
            List<ContentImages> images = contentImageMapper.getImagesByHotplaceId(hotplaceId);
            return images.isEmpty() ? null : images.get(0); // 첫 번째 이미지가 대표 이미지
        } catch (Exception e) {
            return null;
        }
    }
    
    @Override
    public boolean validateImagePath(String imagePath) {
        if (imagePath == null || imagePath.trim().isEmpty()) {
            return false;
        }
        
        // 상대 경로 형태인지 확인
        return imagePath.startsWith("/uploads/places/");
    }
    
    @Override
    public Map<String, Object> validateImageFile(MultipartFile file) {
        Map<String, Object> result = new HashMap<>();
        
        // 파일 존재 여부
        if (file == null || file.isEmpty()) {
            result.put("valid", false);
            result.put("message", "파일이 선택되지 않았습니다.");
            return result;
        }
        
        // 파일 크기 검증
        if (file.getSize() > MAX_FILE_SIZE) {
            result.put("valid", false);
            result.put("message", "파일 크기가 10MB를 초과할 수 없습니다.");
            return result;
        }
        
        // 파일 형식 검증
        String contentType = file.getContentType();
        if (contentType == null || !SUPPORTED_FORMATS.contains(contentType.toLowerCase())) {
            result.put("valid", false);
            result.put("message", "지원하지 않는 파일 형식입니다. (지원 형식: JPG, PNG, GIF, WebP)");
            return result;
        }
        
        // 파일명 검증
        String filename = file.getOriginalFilename();
        if (filename == null || !filename.contains(".")) {
            result.put("valid", false);
            result.put("message", "유효하지 않은 파일명입니다.");
            return result;
        }
        
        result.put("valid", true);
        result.put("message", "유효한 파일입니다.");
        return result;
    }
}
