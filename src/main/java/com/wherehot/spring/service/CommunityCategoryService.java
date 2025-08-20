package com.wherehot.spring.service;

import com.wherehot.spring.entity.CommunityCategory;

import java.util.List;
import java.util.Optional;

/**
 * 커뮤니티 카테고리 서비스 인터페이스 (기존 community_category 테이블 사용)
 */
public interface CommunityCategoryService {
    
    /**
     * 모든 커뮤니티 카테고리 조회 (기존 DAO.getAllCategories()와 동일)
     */
    List<CommunityCategory> findAllCategories();
    
    /**
     * ID로 커뮤니티 카테고리 조회
     */
    Optional<CommunityCategory> findCategoryById(int id);
    
    /**
     * 이름으로 커뮤니티 카테고리 조회
     */
    Optional<CommunityCategory> findCategoryByName(String name);
    
    /**
     * 카테고리별 게시글 수 조회
     */
    int getPostCountByCategory(int categoryId);
}