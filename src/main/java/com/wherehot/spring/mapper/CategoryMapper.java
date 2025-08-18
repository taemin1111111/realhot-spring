package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Category;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

/**
 * 카테고리 MyBatis Mapper
 */
@Mapper
public interface CategoryMapper {
    
    /**
     * 모든 카테고리 조회
     */
    List<Category> findAll();
    
    /**
     * 활성 카테고리만 조회
     */
    List<Category> findActiveCategories();
    
    /**
     * ID로 카테고리 조회
     */
    Optional<Category> findById(@Param("id") int id);
    
    /**
     * 이름으로 카테고리 조회
     */
    Optional<Category> findByName(@Param("name") String name);
    
    /**
     * 카테고리 등록
     */
    int insertCategory(Category category);
    
    /**
     * 카테고리 수정
     */
    int updateCategory(Category category);
    
    /**
     * 카테고리 삭제 (비활성화)
     */
    int deleteCategory(@Param("id") int id);
    
    /**
     * 정렬 순서 업데이트
     */
    int updateSortOrder(@Param("id") int id, @Param("sortOrder") int sortOrder);
    
    /**
     * 카테고리 활성/비활성 토글
     */
    int toggleActive(@Param("id") int id, @Param("active") boolean active);
}
