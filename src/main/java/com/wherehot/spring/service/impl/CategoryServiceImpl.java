package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Category;
import com.wherehot.spring.mapper.CategoryMapper;
import com.wherehot.spring.service.CategoryService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * 카테고리 서비스 구현체
 */
@Service
@Transactional
public class CategoryServiceImpl implements CategoryService {
    
    private static final Logger logger = LoggerFactory.getLogger(CategoryServiceImpl.class);
    
    @Autowired
    private CategoryMapper categoryMapper;
    
    @Override
    @Transactional(readOnly = true)
    public List<Category> findAllCategories() {
        try {
            return categoryMapper.findAll();
        } catch (Exception e) {
            logger.error("Error finding all categories", e);
            throw new RuntimeException("카테고리 목록 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Category> findActiveCategories() {
        try {
            return categoryMapper.findActiveCategories();
        } catch (Exception e) {
            logger.error("Error finding active categories", e);
            throw new RuntimeException("활성 카테고리 목록 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<Category> findCategoryById(int id) {
        try {
            return categoryMapper.findById(id);
        } catch (Exception e) {
            logger.error("Error finding category by id: {}", id, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<Category> findCategoryByName(String name) {
        try {
            return categoryMapper.findByName(name);
        } catch (Exception e) {
            logger.error("Error finding category by name: {}", name, e);
            return Optional.empty();
        }
    }
    
    @Override
    public Category saveCategory(Category category) {
        try {
            // 중복 이름 체크
            Optional<Category> existingCategory = categoryMapper.findByName(category.getName());
            if (existingCategory.isPresent()) {
                throw new IllegalArgumentException("이미 존재하는 카테고리 이름입니다: " + category.getName());
            }
            
            int result = categoryMapper.insertCategory(category);
            if (result > 0) {
                logger.info("Category saved successfully: {}", category.getName());
                return category;
            } else {
                throw new RuntimeException("카테고리 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving category: {}", category.getName(), e);
            throw new RuntimeException("카테고리 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Category updateCategory(Category category) {
        try {
            // 기존 카테고리 존재 확인
            Optional<Category> existingCategory = categoryMapper.findById(category.getId());
            if (existingCategory.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 카테고리입니다: " + category.getId());
            }
            
            // 이름 중복 체크 (자신 제외)
            Optional<Category> duplicateCategory = categoryMapper.findByName(category.getName());
            if (duplicateCategory.isPresent() && duplicateCategory.get().getId() != category.getId()) {
                throw new IllegalArgumentException("이미 존재하는 카테고리 이름입니다: " + category.getName());
            }
            
            int result = categoryMapper.updateCategory(category);
            if (result > 0) {
                logger.info("Category updated successfully: {}", category.getName());
                return category;
            } else {
                throw new RuntimeException("카테고리 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error updating category: {}", category.getId(), e);
            throw new RuntimeException("카테고리 수정 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean deleteCategory(int id) {
        try {
            // 카테고리 존재 확인
            Optional<Category> category = categoryMapper.findById(id);
            if (category.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 카테고리입니다: " + id);
            }
            
            int result = categoryMapper.deleteCategory(id);
            if (result > 0) {
                logger.info("Category deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting category: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean updateSortOrder(int id, int sortOrder) {
        try {
            int result = categoryMapper.updateSortOrder(id, sortOrder);
            if (result > 0) {
                logger.info("Category sort order updated: id={}, sortOrder={}", id, sortOrder);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error updating category sort order: id={}, sortOrder={}", id, sortOrder, e);
            return false;
        }
    }
    
    @Override
    public boolean toggleCategoryActive(int id, boolean active) {
        try {
            int result = categoryMapper.toggleActive(id, active);
            if (result > 0) {
                logger.info("Category active status toggled: id={}, active={}", id, active);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error toggling category active status: id={}, active={}", id, active, e);
            return false;
        }
    }
}
