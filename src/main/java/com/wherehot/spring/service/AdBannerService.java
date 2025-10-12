package com.wherehot.spring.service;

import com.wherehot.spring.entity.AdBanner;
import com.wherehot.spring.mapper.AdBannerMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class AdBannerService {

    @Autowired
    private AdBannerMapper adBannerMapper;

    // 업로드 디렉토리 경로 (절대 경로)
    private static final String UPLOAD_DIR = "/opt/tomcat/webapps/taeminspring/uploads/adsave/";

    /**
     * 활성화된 광고 배너 목록 조회
     */
    public List<AdBanner> getActiveAdBanners() {
        return adBannerMapper.getActiveAdBanners();
    }

    /**
     * 모든 광고 배너 목록 조회 (관리자용)
     */
    public List<AdBanner> getAllAdBanners() {
        return adBannerMapper.getAllAdBanners();
    }

    /**
     * 광고 배너 상세 조회
     */
    public AdBanner getAdBannerById(int adId) {
        return adBannerMapper.getAdBannerById(adId);
    }

    /**
     * 광고 배너 추가
     */
    public int addAdBanner(AdBanner adBanner, MultipartFile imageFile) throws IOException {
        // 이미지 파일 처리
        if (imageFile != null && !imageFile.isEmpty()) {
            String imagePath = saveImageFile(imageFile);
            adBanner.setImagePath(imagePath);
        }

        // 기본값 설정
        if (adBanner.getDisplayOrder() <= 0) {
            adBanner.setDisplayOrder(1);
        }
        adBanner.setActive(true);
        adBanner.setCreatedAt(LocalDateTime.now());
        adBanner.setUpdatedAt(LocalDateTime.now());

        return adBannerMapper.insertAdBanner(adBanner);
    }

    /**
     * 광고 배너 수정
     */
    public int updateAdBanner(AdBanner adBanner, MultipartFile imageFile) throws IOException {
        // 기존 광고 배너 정보 가져오기
        AdBanner existingBanner = adBannerMapper.getAdBannerById(adBanner.getAdId());
        if (existingBanner == null) {
            throw new RuntimeException("광고 배너를 찾을 수 없습니다.");
        }

        // 새로운 이미지가 업로드된 경우
        if (imageFile != null && !imageFile.isEmpty()) {
            // 기존 이미지 파일 삭제
            deleteImageFile(existingBanner.getImagePath());
            
            // 새로운 이미지 저장
            String imagePath = saveImageFile(imageFile);
            adBanner.setImagePath(imagePath);
        } else {
            // 기존 이미지 경로 유지
            adBanner.setImagePath(existingBanner.getImagePath());
        }

        adBanner.setUpdatedAt(LocalDateTime.now());
        return adBannerMapper.updateAdBanner(adBanner);
    }

    /**
     * 광고 배너 삭제
     */
    public int deleteAdBanner(int adId) {
        // 기존 광고 배너 정보 가져오기
        AdBanner existingBanner = adBannerMapper.getAdBannerById(adId);
        if (existingBanner != null) {
            // 이미지 파일 삭제
            deleteImageFile(existingBanner.getImagePath());
        }

        return adBannerMapper.deleteAdBanner(adId);
    }

    /**
     * 광고 배너 활성화/비활성화 토글
     */
    public int toggleAdBannerStatus(int adId) {
        AdBanner banner = adBannerMapper.getAdBannerById(adId);
        if (banner == null) {
            throw new RuntimeException("광고 배너를 찾을 수 없습니다.");
        }

        boolean newStatus = !banner.isActive();
        return adBannerMapper.toggleAdBannerStatus(adId, newStatus);
    }

    /**
     * 광고 배너 순서 변경
     */
    public int updateDisplayOrder(int adId, int displayOrder) {
        return adBannerMapper.updateDisplayOrder(adId, displayOrder);
    }

    /**
     * 이미지 파일 저장
     */
    private String saveImageFile(MultipartFile file) throws IOException {
        // 업로드 디렉토리 생성
        File uploadDir = new File(UPLOAD_DIR);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // 고유한 파일명 생성
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String filename = UUID.randomUUID().toString() + extension;

        // 파일 저장
        Path filePath = Paths.get(UPLOAD_DIR + filename);
        Files.copy(file.getInputStream(), filePath);

        return "/uploads/adsave/" + filename;
    }

    /**
     * 이미지 파일 삭제
     */
    private void deleteImageFile(String imagePath) {
        if (imagePath != null && !imagePath.isEmpty()) {
            try {
                // 경로에서 앞의 "/" 제거하고 절대 경로로 변환
                String relativePath = imagePath.startsWith("/") ? imagePath.substring(1) : imagePath;
                String filePath = "/opt/tomcat/webapps/taeminspring/" + relativePath;
                File file = new File(filePath);
                if (file.exists()) {
                    file.delete();
                }
            } catch (Exception e) {
                // 파일 삭제 실패는 로그만 남기고 계속 진행
                System.err.println("이미지 파일 삭제 실패: " + imagePath + ", " + e.getMessage());
            }
        }
    }
}
