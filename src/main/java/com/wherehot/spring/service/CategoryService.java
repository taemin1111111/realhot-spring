package com.wherehot.spring.service;

import com.wherehot.spring.entity.Category;

import java.util.List;
import java.util.Optional;

/**
 * 카테고리 서비스 인터페이스
 */
public interface CategoryService {
    
    /**
     * 모든 카테고리 조회
     */
    List<Category> findAllCategories();
    
    /**
     * 활성 카테고리만 조회
     */
    List<Category> findActiveCategories();
    
    /**
     * ID로 카테고리 조회
     */
    Optional<Category> findCategoryById(int id);
    
    /**
     * 이름으로 카테고리 조회
     */
    Optional<Category> findCategoryByName(String name);
    
    /**
     * 카테고리 등록
     */
    Category saveCategory(Category category);
    
    /**
     * 카테고리 수정
     */
    Category updateCategory(Category category);
    
    /**
     * 카테고리 삭제 (비활성화)
     */
    boolean deleteCategory(int id);
    
    /**
     * 정렬 순서 업데이트
     */
    boolean updateSortOrder(int id, int sortOrder);
    
    /**
     * 카테고리 활성/비활성 토글
     */
    boolean toggleCategoryActive(int id, boolean active);
}
