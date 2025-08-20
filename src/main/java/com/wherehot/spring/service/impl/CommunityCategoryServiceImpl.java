package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.CommunityCategory;
import com.wherehot.spring.mapper.CommunityCategoryMapper;
import com.wherehot.spring.service.CommunityCategoryService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * 커뮤니티 카테고리 서비스 구현체 (기존 community_category 테이블 사용)
 */
@Service
@Transactional
public class CommunityCategoryServiceImpl implements CommunityCategoryService {
    
    private static final Logger logger = LoggerFactory.getLogger(CommunityCategoryServiceImpl.class);
    
    @Autowired
    private CommunityCategoryMapper communityCategoryMapper;
    
    @Override
    @Cacheable(value = "communityCategories", key = "'all'")
    @Transactional(readOnly = true)
    public List<CommunityCategory> findAllCategories() {
        try {
            logger.debug("커뮤니티 카테고리 조회 시작 (기존 community_category 테이블)");
            List<CommunityCategory> categories = communityCategoryMapper.findAll();
            
            // 각 카테고리별 게시글 수 조회
            for (CommunityCategory category : categories) {
                try {
                    int postCount = communityCategoryMapper.getPostCountByCategory(category.getId());
                    category.setPostCount(postCount);
                } catch (Exception e) {
                    logger.warn("카테고리 {}의 게시글 수 조회 실패: {}", category.getId(), e.getMessage());
                    category.setPostCount(0); // 기본값 설정
                }
            }
            
            logger.info("커뮤니티 카테고리 조회 완료: {} 개", categories.size());
            return categories;
        } catch (Exception e) {
            logger.error("커뮤니티 카테고리 조회 중 오류 발생", e);
            throw new RuntimeException("카테고리 조회에 실패했습니다.", e);
        }
    }
    
    @Override
    @Cacheable(value = "communityCategory", key = "#id")
    @Transactional(readOnly = true)
    public Optional<CommunityCategory> findCategoryById(int id) {
        try {
            logger.debug("커뮤니티 카테고리 ID로 조회: {}", id);
            Optional<CommunityCategory> category = communityCategoryMapper.findById(id);
            
            if (category.isPresent()) {
                // 게시글 수 조회
                try {
                    int postCount = communityCategoryMapper.getPostCountByCategory(id);
                    category.get().setPostCount(postCount);
                } catch (Exception e) {
                    logger.warn("카테고리 {}의 게시글 수 조회 실패: {}", id, e.getMessage());
                    category.get().setPostCount(0);
                }
                
                logger.info("커뮤니티 카테고리 조회 성공: ID={}, Name={}", id, category.get().getName());
            } else {
                logger.warn("커뮤니티 카테고리를 찾을 수 없음: ID={}", id);
            }
            
            return category;
        } catch (Exception e) {
            logger.error("커뮤니티 카테고리 ID 조회 중 오류 발생: ID={}", id, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<CommunityCategory> findCategoryByName(String name) {
        try {
            logger.debug("커뮤니티 카테고리 이름으로 조회: {}", name);
            Optional<CommunityCategory> category = communityCategoryMapper.findByName(name);
            
            if (category.isPresent()) {
                // 게시글 수 조회
                try {
                    int postCount = communityCategoryMapper.getPostCountByCategory(category.get().getId());
                    category.get().setPostCount(postCount);
                } catch (Exception e) {
                    logger.warn("카테고리 {}의 게시글 수 조회 실패: {}", name, e.getMessage());
                    category.get().setPostCount(0);
                }
                
                logger.info("커뮤니티 카테고리 이름으로 조회 성공: Name={}", name);
            } else {
                logger.warn("커뮤니티 카테고리를 찾을 수 없음: Name={}", name);
            }
            
            return category;
        } catch (Exception e) {
            logger.error("커뮤니티 카테고리 이름 조회 중 오류 발생: Name={}", name, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getPostCountByCategory(int categoryId) {
        try {
            logger.debug("카테고리별 게시글 수 조회: CategoryID={}", categoryId);
            int count = communityCategoryMapper.getPostCountByCategory(categoryId);
            logger.debug("카테고리별 게시글 수 조회 완료: CategoryID={}, Count={}", categoryId, count);
            return count;
        } catch (Exception e) {
            logger.error("카테고리별 게시글 수 조회 중 오류 발생: CategoryID={}", categoryId, e);
            return 0; // 오류 시 기본값 반환
        }
    }
}