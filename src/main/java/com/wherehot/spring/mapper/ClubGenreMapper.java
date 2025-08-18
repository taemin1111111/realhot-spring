package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.ClubGenre;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 클럽 장르 MyBatis Mapper
 */
@Mapper
public interface ClubGenreMapper {
    
    /**
     * 특정 장소의 장르 목록 조회
     */
    List<ClubGenre> findGenresByPlaceId(@Param("placeId") int placeId);
    
    /**
     * 모든 기본 장르 목록 조회
     */
    List<ClubGenre> findAllGenres();
    
    /**
     * 모든 장르 목록과 특정 장소의 선택 여부 조회
     */
    List<Map<String, Object>> findAllGenresWithSelection(@Param("placeId") int placeId);
    
    /**
     * 장소에 장르 추가
     */
    int insertPlaceGenre(@Param("placeId") int placeId, @Param("genreId") int genreId);
    
    /**
     * 장소에서 특정 장르 제거
     */
    int deletePlaceGenre(@Param("placeId") int placeId, @Param("genreId") int genreId);
    
    /**
     * 장소의 모든 장르 제거
     */
    int deleteAllPlaceGenres(@Param("placeId") int placeId);
    
    /**
     * 장소-장르 관계 존재 여부 확인
     */
    int countPlaceGenre(@Param("placeId") int placeId, @Param("genreId") int genreId);
    
    /**
     * 인기 장르 순위 조회
     */
    List<Map<String, Object>> findPopularGenres(@Param("limit") int limit);
    
    /**
     * 장르 ID로 장르 조회
     */
    ClubGenre findGenreById(@Param("genreId") int genreId);
    
    /**
     * 장르명으로 장르 조회
     */
    ClubGenre findGenreByName(@Param("genreName") String genreName);
}
