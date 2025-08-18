package com.wherehot.spring.service;

import com.wherehot.spring.entity.ClubGenre;

import java.util.List;
import java.util.Map;

/**
 * 클럽 장르 서비스 인터페이스
 */
public interface ClubGenreService {
    
    /**
     * 특정 장소의 장르 목록 조회
     */
    List<ClubGenre> getGenresByPlaceId(int placeId);
    
    /**
     * 모든 장르 목록 조회 (장르 편집용)
     */
    List<Map<String, Object>> getAllGenresWithSelection(int placeId);
    
    /**
     * 장소에 장르 추가
     */
    boolean addGenreToPlace(int placeId, int genreId);
    
    /**
     * 장소에서 장르 제거
     */
    boolean removeGenreFromPlace(int placeId, int genreId);
    
    /**
     * 장소의 모든 장르 제거
     */
    boolean removeAllGenresFromPlace(int placeId);
    
    /**
     * 장소의 장르를 일괄 설정
     */
    boolean setPlaceGenres(int placeId, List<Integer> genreIds);
    
    /**
     * 모든 기본 장르 목록 조회
     */
    List<ClubGenre> getAllGenres();
    
    /**
     * 장르 이름 목록을 문자열로 반환
     */
    String getGenreNamesAsString(int placeId);
    
    /**
     * 인기 장르 순위 조회
     */
    List<Map<String, Object>> getPopularGenres(int limit);
}
