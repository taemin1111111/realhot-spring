package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.Hotplace;
import com.wherehot.spring.service.HotplaceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 핫플레이스 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/hotplaces")
public class HotplaceController {
    
    @Autowired
    private HotplaceService hotplaceService;
    
    /**
     * 모든 핫플레이스 조회
     */
    @GetMapping
    public ResponseEntity<List<Hotplace>> getAllHotplaces() {
        List<Hotplace> hotplaces = hotplaceService.findAllHotplaces();
        return ResponseEntity.ok(hotplaces);
    }
    
    /**
     * ID로 핫플레이스 조회
     */
    @GetMapping("/{id}")
    public ResponseEntity<Hotplace> getHotplaceById(@PathVariable int id) {
        Optional<Hotplace> hotplace = hotplaceService.findHotplaceById(id);
        return hotplace.map(ResponseEntity::ok)
                      .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * 카테고리별 핫플레이스 조회
     */
    @GetMapping("/category/{categoryId}")
    public ResponseEntity<List<Hotplace>> getHotplacesByCategory(@PathVariable int categoryId) {
        List<Hotplace> hotplaces = hotplaceService.findHotplacesByCategory(categoryId);
        return ResponseEntity.ok(hotplaces);
    }
    
    /**
     * 지역별 핫플레이스 조회
     */
    @GetMapping("/region/{region}")
    public ResponseEntity<List<Hotplace>> getHotplacesByRegion(@PathVariable String region) {
        List<Hotplace> hotplaces = hotplaceService.findHotplacesByRegion(region);
        return ResponseEntity.ok(hotplaces);
    }
    
    /**
     * 인기 핫플레이스 조회
     */
    @GetMapping("/popular")
    public ResponseEntity<List<Hotplace>> getPopularHotplaces(@RequestParam(defaultValue = "10") int limit) {
        List<Hotplace> hotplaces = hotplaceService.findPopularHotplaces(limit);
        return ResponseEntity.ok(hotplaces);
    }
    
    /**
     * 최신 핫플레이스 조회
     */
    @GetMapping("/recent")
    public ResponseEntity<List<Hotplace>> getRecentHotplaces(@RequestParam(defaultValue = "10") int limit) {
        List<Hotplace> hotplaces = hotplaceService.findRecentHotplaces(limit);
        return ResponseEntity.ok(hotplaces);
    }
    
    /**
     * 키워드로 핫플레이스 검색
     */
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchHotplaces(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Hotplace> hotplaces = hotplaceService.searchHotplaces(keyword, page, size);
        int totalCount = hotplaceService.getSearchResultCount(keyword);
        
        Map<String, Object> result = new HashMap<>();
        result.put("hotplaces", hotplaces);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 좌표 범위로 핫플레이스 검색
     */
    @GetMapping("/coordinate-range")
    public ResponseEntity<List<Hotplace>> getHotplacesByCoordinateRange(
            @RequestParam double minLat,
            @RequestParam double maxLat,
            @RequestParam double minLng,
            @RequestParam double maxLng) {
        
        List<Hotplace> hotplaces = hotplaceService.findHotplacesByCoordinateRange(minLat, maxLat, minLng, maxLng);
        return ResponseEntity.ok(hotplaces);
    }
    
    /**
     * 핫플레이스 등록
     */
    @PostMapping
    public ResponseEntity<Hotplace> createHotplace(@RequestBody Hotplace hotplace) {
        try {
            Hotplace savedHotplace = hotplaceService.saveHotplace(hotplace);
            return ResponseEntity.ok(savedHotplace);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 핫플레이스 수정
     */
    @PutMapping("/{id}")
    public ResponseEntity<Hotplace> updateHotplace(@PathVariable int id, @RequestBody Hotplace hotplace) {
        try {
            hotplace.setId(id);
            Hotplace updatedHotplace = hotplaceService.updateHotplace(hotplace);
            return ResponseEntity.ok(updatedHotplace);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 핫플레이스 삭제 (비활성화)
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteHotplace(@PathVariable int id) {
        boolean deleted = hotplaceService.deleteHotplace(id);
        return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
    }
    
    /**
     * 지역별 통계
     */
    @GetMapping("/statistics/region")
    public ResponseEntity<List<Map<String, Object>>> getRegionStatistics() {
        List<Map<String, Object>> statistics = hotplaceService.getRegionStatistics();
        return ResponseEntity.ok(statistics);
    }
    
    /**
     * 카테고리별 통계
     */
    @GetMapping("/statistics/category")
    public ResponseEntity<List<Map<String, Object>>> getCategoryStatistics() {
        List<Map<String, Object>> statistics = hotplaceService.getCategoryStatistics();
        return ResponseEntity.ok(statistics);
    }
}
