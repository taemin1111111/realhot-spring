package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.ContentInfo;
import com.wherehot.spring.mapper.ContentInfoMapper;
import com.wherehot.spring.service.ContentInfoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 콘텐츠 정보 서비스 구현체
 */
@Service
@Transactional
public class ContentInfoServiceImpl implements ContentInfoService {
    
    private static final Logger logger = LoggerFactory.getLogger(ContentInfoServiceImpl.class);
    
    @Autowired
    private ContentInfoMapper contentInfoMapper;
    
    @Override
    @Transactional(readOnly = true)
    public ContentInfo getContentInfoByHotplaceId(int hotplaceId) {
        try {
            return contentInfoMapper.getContentInfoByHotplaceId(hotplaceId);
        } catch (Exception e) {
            logger.error("Error getting content info for hotplace: {}", hotplaceId, e);
            return null;
        }
    }
    
    @Override
    public boolean saveOrUpdateContentInfo(int hotplaceId, String contentText) {
        try {
            logger.info("Starting saveOrUpdateContentInfo for hotplaceId: {}, contentText: {}", hotplaceId, contentText);
            
            // 기존 콘텐츠 정보가 있는지 확인
            ContentInfo existingContent = contentInfoMapper.getContentInfoByHotplaceId(hotplaceId);
            logger.info("Existing content found: {}", existingContent != null);
            
            if (existingContent != null) {
                // 기존 정보가 있으면 수정
                existingContent.setContentText(contentText);
                existingContent.setUpdatedAt(LocalDateTime.now());
                int result = contentInfoMapper.updateContentInfo(existingContent);
                logger.info("Content info updated for hotplace: {}, result: {}", hotplaceId, result);
                return result > 0;
            } else {
                // 기존 정보가 없으면 새로 생성 (contentText가 null이 아닌 경우만)
                if (contentText != null && !contentText.trim().isEmpty()) {
                    ContentInfo newContent = new ContentInfo();
                    newContent.setHotplaceId(hotplaceId);
                    newContent.setContentText(contentText);
                    newContent.setCreatedAt(LocalDateTime.now());
                    newContent.setUpdatedAt(LocalDateTime.now());
                    logger.info("Attempting to insert new content: hotplaceId={}, contentText={}", hotplaceId, contentText);
                    int result = contentInfoMapper.insertContentInfo(newContent);
                    logger.info("Content info created for hotplace: {}, result: {}", hotplaceId, result);
                    return result > 0;
                } else {
                    // contentText가 null이거나 빈 문자열이면 아무것도 하지 않음
                    logger.info("Content text is null or empty, skipping insert for hotplaceId: {}", hotplaceId);
                    return true;
                }
            }
        } catch (Exception e) {
            logger.error("Error saving/updating content info for hotplace: {}", hotplaceId, e);
            e.printStackTrace();
            return false;
        }
    }
    
    @Override
    public boolean deleteContentInfo(int hotplaceId) {
        try {
            int result = contentInfoMapper.deleteContentInfo(hotplaceId);
            logger.info("Content info deleted for hotplace: {}, result: {}", hotplaceId, result);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error deleting content info for hotplace: {}", hotplaceId, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<ContentInfo> getAllContentInfos() {
        try {
            return contentInfoMapper.getAllContentInfos();
        } catch (Exception e) {
            logger.error("Error getting all content infos", e);
            return List.of();
        }
    }
}
