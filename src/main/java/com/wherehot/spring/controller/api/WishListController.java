package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.WishList;
import com.wherehot.spring.service.WishListService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 위시리스트 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/wishlists")
public class WishListController {
    
    @Autowired
    private WishListService wishListService;
    
    /**
     * 사용자별 위시리스트 조회
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getWishListByUser(
            @PathVariable String userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<WishList> wishLists = wishListService.findWishListByUser(userId, page, size);
        int totalCount = wishListService.getWishListCountByUser(userId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("wishLists", wishLists);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("userId", userId);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 내 위시리스트 조회
     */
    @GetMapping("/my")
    public ResponseEntity<Map<String, Object>> getMyWishList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        if (userDetails == null) {
            return ResponseEntity.status(401).build(); // Unauthorized
        }
        
        String userId = userDetails.getUsername();
        List<WishList> wishLists = wishListService.findWishListByUser(userId, page, size);
        int totalCount = wishListService.getWishListCountByUser(userId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("wishLists", wishLists);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 핫플레이스별 위시리스트 조회
     */
    @GetMapping("/hotplace/{hotplaceId}")
    public ResponseEntity<Map<String, Object>> getWishListByHotplace(
            @PathVariable int hotplaceId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<WishList> wishLists = wishListService.findWishListByHotplace(hotplaceId, page, size);
        int totalCount = wishListService.getWishListCountByHotplace(hotplaceId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("wishLists", wishLists);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("hotplaceId", hotplaceId);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 위시리스트 추가
     */
    @PostMapping
    public ResponseEntity<WishList> addToWishList(@RequestBody Map<String, Object> request,
                                                 @AuthenticationPrincipal UserDetails userDetails) {
        try {
            if (userDetails == null) {
                return ResponseEntity.status(401).build(); // Unauthorized
            }
            
            String userId = userDetails.getUsername();
            int hotplaceId = Integer.parseInt(request.get("hotplaceId").toString());
            
            // 중복 체크
            boolean exists = wishListService.existsWishListByUserAndHotplace(userId, hotplaceId);
            if (exists) {
                return ResponseEntity.status(409).build(); // Conflict
            }
            
            WishList wishList = new WishList(userId, hotplaceId);
            WishList savedWishList = wishListService.saveWishList(wishList);
            
            return ResponseEntity.ok(savedWishList);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 위시리스트 삭제
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> removeFromWishList(@PathVariable int id,
                                                  @AuthenticationPrincipal UserDetails userDetails) {
        try {
            if (userDetails == null) {
                return ResponseEntity.status(401).build(); // Unauthorized
            }
            
            // 권한 확인을 위해 위시리스트 조회
            Optional<WishList> wishList = wishListService.findWishListByUserAndHotplace(userDetails.getUsername(), id);
            if (wishList.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            boolean deleted = wishListService.deleteWishList(id);
            return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 사용자와 핫플레이스로 위시리스트 삭제
     */
    @DeleteMapping("/user/{userId}/hotplace/{hotplaceId}")
    public ResponseEntity<Void> removeWishListByUserAndHotplace(
            @PathVariable String userId,
            @PathVariable int hotplaceId,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 본인 또는 관리자만 삭제 가능
            if (userDetails == null || (!userDetails.getUsername().equals(userId) 
                && !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN")))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            boolean deleted = wishListService.deleteWishListByUserAndHotplace(userId, hotplaceId);
            return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 위시리스트 존재 여부 확인
     */
    @GetMapping("/exists")
    public ResponseEntity<Map<String, Boolean>> checkWishListExists(
            @RequestParam int hotplaceId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        if (userDetails == null) {
            Map<String, Boolean> result = new HashMap<>();
            result.put("exists", false);
            return ResponseEntity.ok(result);
        }
        
        String userId = userDetails.getUsername();
        boolean exists = wishListService.existsWishListByUserAndHotplace(userId, hotplaceId);
        
        Map<String, Boolean> result = new HashMap<>();
        result.put("exists", exists);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 인기 핫플레이스 조회 (위시리스트 많은 순)
     */
    @GetMapping("/popular-hotplaces")
    public ResponseEntity<List<Integer>> getPopularHotplaces(@RequestParam(defaultValue = "10") int limit) {
        List<Integer> hotplaceIds = wishListService.findPopularHotplaceIds(limit);
        return ResponseEntity.ok(hotplaceIds);
    }
}
