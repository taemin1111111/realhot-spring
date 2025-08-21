package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Md;
import com.wherehot.spring.service.MdService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
public class MdController {
    
    @Autowired
    private MdService mdService;
    
    // MD 목록 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/md")
    public String mdList(@RequestParam(defaultValue = "1") int page,
                        Model model) {
        
        // TODO: MdService의 실제 메서드 사용
        List<Md> mdList = new java.util.ArrayList<>();
        int totalCount = 0;
        
        model.addAttribute("mdList", mdList);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalCount", totalCount);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "clubmd/clubmd.jsp");
        return "index";
    }
    
    // MD 상세 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/md/{id}")
    public String mdDetail(@PathVariable int id, Model model) {
        // TODO: MdService의 실제 메서드 사용
        Md md = null;
        model.addAttribute("md", md);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "clubmd/mdDetail.jsp");
        return "index";
    }
    
    // MD 등록 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/md/register")
    public String mdRegisterForm(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "clubmd/mdRegister.jsp");
        return "index";
    }
}
