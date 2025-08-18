package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.Category;
import com.wherehot.spring.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * 카테고리 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/categories")
public class CategoryController {
    
    @Autowired
    private CategoryService categoryService;
    
    /**
     * 모든 카테고리 조회
     */
    @GetMapping
    public ResponseEntity<List<Category>> getAllCategories() {
        List<Category> categories = categoryService.findAllCategories();
        return ResponseEntity.ok(categories);
    }
    
    /**
     * 활성 카테고리만 조회
     */
    @GetMapping("/active")
    public ResponseEntity<List<Category>> getActiveCategories() {
        List<Category> categories = categoryService.findActiveCategories();
        return ResponseEntity.ok(categories);
    }
    
    /**
     * ID로 카테고리 조회
     */
    @GetMapping("/{id}")
    public ResponseEntity<Category> getCategoryById(@PathVariable int id) {
        Optional<Category> category = categoryService.findCategoryById(id);
        return category.map(ResponseEntity::ok)
                      .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * 카테고리 등록
     */
    @PostMapping
    public ResponseEntity<Category> createCategory(@RequestBody Category category) {
        try {
            Category savedCategory = categoryService.saveCategory(category);
            return ResponseEntity.ok(savedCategory);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 카테고리 수정
     */
    @PutMapping("/{id}")
    public ResponseEntity<Category> updateCategory(@PathVariable int id, @RequestBody Category category) {
        try {
            category.setId(id);
            Category updatedCategory = categoryService.updateCategory(category);
            return ResponseEntity.ok(updatedCategory);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 카테고리 삭제 (비활성화)
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCategory(@PathVariable int id) {
        boolean deleted = categoryService.deleteCategory(id);
        return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
    }
    
    /**
     * 정렬 순서 업데이트
     */
    @PatchMapping("/{id}/sort-order")
    public ResponseEntity<Void> updateSortOrder(@PathVariable int id, @RequestParam int sortOrder) {
        boolean updated = categoryService.updateSortOrder(id, sortOrder);
        return updated ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
    }
    
    /**
     * 카테고리 활성/비활성 토글
     */
    @PatchMapping("/{id}/toggle-active")
    public ResponseEntity<Void> toggleActive(@PathVariable int id, @RequestParam boolean active) {
        boolean updated = categoryService.toggleCategoryActive(id, active);
        return updated ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
    }
}
