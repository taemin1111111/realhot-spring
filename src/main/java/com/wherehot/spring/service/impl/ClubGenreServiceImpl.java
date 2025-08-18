package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.ClubGenre;
import com.wherehot.spring.mapper.ClubGenreMapper;
import com.wherehot.spring.service.ClubGenreService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 클럽 장르 서비스 구현체
 */
@Service
@Transactional
public class ClubGenreServiceImpl implements ClubGenreService {
    
    private static final Logger logger = LoggerFactory.getLogger(ClubGenreServiceImpl.class);
    
    @Autowired
    private ClubGenreMapper clubGenreMapper;
    
    @Override
    @Transactional(readOnly = true)
    public List<ClubGenre> getGenresByPlaceId(int placeId) {
        try {
            logger.info("장르 조회 시작 - Place ID: {}", placeId);
            
            // 먼저 모든 장르 확인
            List<ClubGenre> allGenres = clubGenreMapper.findAllGenres();
            logger.info("전체 장르 수: {}", allGenres.size());
            
            // 특정 장소의 장르 조회
            List<ClubGenre> result = clubGenreMapper.findGenresByPlaceId(placeId);
            logger.info("장르 조회 결과 - Place ID: {}, 조회된 장르 수: {}", placeId, result.size());
            
            if (!result.isEmpty()) {
                for (ClubGenre genre : result) {
                    logger.info("조회된 장르 - ID: {}, Name: '{}'", genre.getId(), genre.getGenreName());
                }
            } else {
                logger.warn("Place ID {}에 대한 장르가 없습니다. hotplace_genre_map 테이블을 확인하세요.", placeId);
            }
            
            return result;
        } catch (Exception e) {
            logger.error("Error getting genres for place id: {}", placeId, e);
            e.printStackTrace(); // 스택 트레이스 출력
            return new java.util.ArrayList<>();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllGenresWithSelection(int placeId) {
        try {
            logger.info("모든 장르 목록 조회 시작 - Place ID: {}", placeId);
            List<Map<String, Object>> result = clubGenreMapper.findAllGenresWithSelection(placeId);
            logger.info("모든 장르 목록 조회 결과 - Place ID: {}, 조회된 장르 수: {}", placeId, result.size());
            if (!result.isEmpty()) {
                for (Map<String, Object> genre : result) {
                    logger.info("조회된 장르 - ID: {}, Name: '{}', Selected: {}", 
                        genre.get("genreId"), genre.get("genreName"), genre.get("isSelected"));
                }
            }
            return result;
        } catch (Exception e) {
            logger.error("Error getting all genres with selection for place id: {}", placeId, e);
            return new java.util.ArrayList<>();
        }
    }
    
    @Override
    public boolean addGenreToPlace(int placeId, int genreId) {
        try {
            // 이미 존재하는지 확인
            int count = clubGenreMapper.countPlaceGenre(placeId, genreId);
            if (count > 0) {
                logger.warn("Genre {} already exists for place {}", genreId, placeId);
                return true; // 이미 존재하므로 성공으로 처리
            }
            
            int result = clubGenreMapper.insertPlaceGenre(placeId, genreId);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error adding genre {} to place {}", genreId, placeId, e);
            return false;
        }
    }
    
    @Override
    public boolean removeGenreFromPlace(int placeId, int genreId) {
        try {
            int result = clubGenreMapper.deletePlaceGenre(placeId, genreId);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error removing genre {} from place {}", genreId, placeId, e);
            return false;
        }
    }
    
    @Override
    public boolean removeAllGenresFromPlace(int placeId) {
        try {
            clubGenreMapper.deleteAllPlaceGenres(placeId);
            return true;
        } catch (Exception e) {
            logger.error("Error removing all genres from place {}", placeId, e);
            return false;
        }
    }
    
    @Override
    public boolean setPlaceGenres(int placeId, List<Integer> genreIds) {
        try {
            // 기존 장르 모두 제거
            removeAllGenresFromPlace(placeId);
            
            // 새 장르들 추가
            for (Integer genreId : genreIds) {
                if (!addGenreToPlace(placeId, genreId)) {
                    logger.error("Failed to add genre {} to place {}", genreId, placeId);
                    return false;
                }
            }
            return true;
        } catch (Exception e) {
            logger.error("Error setting genres for place {}", placeId, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<ClubGenre> getAllGenres() {
        try {
            return clubGenreMapper.findAllGenres();
        } catch (Exception e) {
            logger.error("Error getting all genres", e);
            return new java.util.ArrayList<>();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public String getGenreNamesAsString(int placeId) {
        try {
            List<ClubGenre> genres = getGenresByPlaceId(placeId);
            return genres.stream()
                    .map(ClubGenre::getGenreName)
                    .collect(Collectors.joining(", "));
        } catch (Exception e) {
            logger.error("Error getting genre names as string for place {}", placeId, e);
            return "";
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getPopularGenres(int limit) {
        try {
            return clubGenreMapper.findPopularGenres(limit);
        } catch (Exception e) {
            logger.error("Error getting popular genres", e);
            return new java.util.ArrayList<>();
        }
    }
}
