package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Post;
import com.wherehot.spring.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
public class CommunityController {
    
    @Autowired
    private PostService postService;
    
    // 커뮤니티 목록 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/community")
    public String communityList(@RequestParam(defaultValue = "1") int page,
                              @RequestParam(defaultValue = "latest") String sort,
                              Model model) {
        
        List<Post> postList;
        int totalCount;
        
        if ("popular".equals(sort)) {
            postList = postService.findPopularPosts(10); // limit으로 변경
        } else {
            postList = postService.findRecentPosts(10); // limit으로 변경
        }
        totalCount = postService.getTotalPostCount();
        
        model.addAttribute("postList", postList);
        model.addAttribute("currentPage", page);
        model.addAttribute("sort", sort);
        model.addAttribute("totalCount", totalCount);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "community/cumain.jsp");
        return "index";
    }
    
    // 커뮤니티 상세 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/community/{id}")
    public String communityDetail(@PathVariable int id, Model model) {
        Post post = postService.findById(id);
        model.addAttribute("post", post);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "community/hpost_detail.jsp");
        return "index";
    }
    
    // 커뮤니티 글쓰기 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/community/write")
    public String communityWriteForm(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "community/hpost_insert.jsp");
        return "index";
    }
}
