package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.CommunityCategory;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.Optional;

/**
 * 커뮤니티 카테고리 매퍼 (기존 community_category 테이블 사용)
 */
@Mapper
public interface CommunityCategoryMapper {
    
    /**
     * 모든 커뮤니티 카테고리 조회 (기존 DAO와 동일)
     */
    @Select("SELECT id, name FROM community_category ORDER BY id")
    List<CommunityCategory> findAll();
    
    /**
     * ID로 카테고리 조회
     */
    @Select("SELECT id, name FROM community_category WHERE id = #{id}")
    Optional<CommunityCategory> findById(int id);
    
    /**
     * 이름으로 카테고리 조회
     */
    @Select("SELECT id, name FROM community_category WHERE name = #{name}")
    Optional<CommunityCategory> findByName(String name);
    
    /**
     * 카테고리별 게시글 수 조회 (posts 테이블과 조인)
     * TODO: posts 테이블 구조 확인 후 수정 필요
     */
    @Select("SELECT COUNT(*) FROM posts WHERE category_id = #{categoryId}")
    int getPostCountByCategory(int categoryId);
    
    /**
     * 전체 카테고리 수 조회
     */
    @Select("SELECT COUNT(*) FROM community_category")
    int getTotalCount();
}