package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Notice;
import com.wherehot.spring.service.NoticeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
public class NoticeController {
    
    @Autowired
    private NoticeService noticeService;
    
    // 공지사항 목록 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/notice")
    public String noticeList(@RequestParam(defaultValue = "1") int page,
                           Model model) {
        
        List<Notice> noticeList = noticeService.findAllNotices(page, 10);
        int totalCount = noticeService.getTotalNoticeCount();
        
        model.addAttribute("noticeList", noticeList);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalCount", totalCount);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "notice/noticemain.jsp");
        return "index";
    }
    
    // 공지사항 상세 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/notice/{id}")
    public String noticeDetail(@PathVariable int id, Model model) {
        Notice notice = noticeService.findNoticeById(id).orElse(null);
        model.addAttribute("notice", notice);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "notice/noticeDetail.jsp");
        return "index";
    }
    
    // 공지사항 작성 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/notice/write")
    public String noticeWriteForm(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "notice/noticeinset.jsp");
        return "index";
    }
}
