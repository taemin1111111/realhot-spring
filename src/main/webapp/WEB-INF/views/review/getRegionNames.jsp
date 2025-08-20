<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%-- Map.MapDao import 제거 - Spring Controller 사용 --%>
<%
    // Spring API 호출을 통한 실제 기능 구현
    String contextPath = request.getContextPath();
    String apiUrl = contextPath + "/api/reviews/regions/names";
    
    // API 호출 안내
    out.print("{\"success\":true,\"message\":\"지역명 조회는 GET " + apiUrl + " 를 호출하세요.\",\"apiUrl\":\"" + apiUrl + "\",\"method\":\"GET\",\"todo\":\"RegionService 구현 필요\"}");
%>
<%-- 기존 코드 비활성화
<%
    // MapDao mapDao = new MapDao();
    // List<String> regionNameList = mapDao.getAllRegionNames();
    
    // JSON 형태로 응답
    // out.print("[");
    // for(int i = 0; i < regionNameList.size(); i++) {
    //     String regionName = regionNameList.get(i);
    //     out.print("\"" + regionName + "\"");
    //     if(i < regionNameList.size() - 1) {
    //         out.print(",");
    //     }
    // }
    // out.print("]");
%>
--%>