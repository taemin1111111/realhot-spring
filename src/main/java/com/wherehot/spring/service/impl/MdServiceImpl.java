package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Md;
import com.wherehot.spring.mapper.MdMapper;
import com.wherehot.spring.service.MdService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@Transactional
public class MdServiceImpl implements MdService {

    private static final Logger log = LoggerFactory.getLogger(MdServiceImpl.class);

    @Autowired
    private MdMapper mdMapper;
    
    @Value("${app.upload.path:uploads/mdphotos}")
    private String uploadPath;

    @Override
    public void registerMd(Md md, MultipartFile photo) throws Exception {
        // 사진 파일 처리
        if (photo != null && !photo.isEmpty()) {
            String savedFileName = savePhotoFile(photo);
            md.setPhoto(savedFileName);
        }
        
        // MD 등록
        int result = mdMapper.insertMd(md);
        if (result <= 0) {
            throw new RuntimeException("MD 등록에 실패했습니다.");
        }
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Map<String, Object>> getMdListWithPlace(Pageable pageable, String keyword, String sort, String searchType) {
        String loginId = getCurrentLoginId();
        
        int offset = (int) pageable.getOffset();
        int size = pageable.getPageSize();
        
        List<Map<String, Object>> mdList = mdMapper.selectMdListWithPlace(offset, size, keyword, sort, loginId, searchType);
        int totalCount = mdMapper.selectMdCount(keyword, searchType);
        
        return new PageImpl<>(mdList, pageable, totalCount);
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getMdDetail(Integer mdId) {
        String loginId = getCurrentLoginId();
        return mdMapper.selectMdDetail(mdId, loginId);
    }



    /**
     * 사진 파일 저장
     */
    private String savePhotoFile(MultipartFile photo) throws IOException {
        // 업로드 디렉터리 생성
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // 원본 파일명에서 확장자 추출
        String originalFilename = photo.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        
        // 고유한 파일명 생성
        String savedFileName = UUID.randomUUID().toString() + extension;
        
        // 파일 저장
        File destFile = new File(uploadDir, savedFileName);
        photo.transferTo(destFile);
        
        return savedFileName;
    }

    @Override
    public List<Map<String, Object>> getSearchSuggestions(String keyword, String searchType, int limit) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return new ArrayList<>();
        }
        return mdMapper.selectSearchSuggestions(keyword.trim(), searchType, limit);
    }

    /**
     * 현재 로그인한 사용자 ID 가져오기
     */
    private String getCurrentLoginId() {
        try {
            ServletRequestAttributes attr = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
            HttpSession session = attr.getRequest().getSession(false);
            if (session != null) {
                return (String) session.getAttribute("loginid");
            }
        } catch (Exception e) {
            log.debug("Failed to get current login ID", e);
        }
        return null;
    }
}