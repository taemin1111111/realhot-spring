package Member;

import DB.DbConnect;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 회원 DAO (기존 시스템 호환용)
 */
public class MemberDAO {
    
    /**
     * 회원 정보 조회
     */
    public MemberDTO getMember(String userid) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        MemberDTO member = null;
        
        try {
            conn = DbConnect.getConnection();
            String sql = "SELECT * FROM member WHERE userid = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userid);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                member = new MemberDTO();
                member.setUserid(rs.getString("userid"));
                member.setPasswd(rs.getString("password"));
                member.setName(rs.getString("name"));
                member.setNickname(rs.getString("nickname"));
                member.setEmail(rs.getString("email"));
                member.setPhone(rs.getString("phone"));
                member.setBirth(rs.getDate("birth"));
                member.setGender(rs.getString("gender"));
                member.setProvider(rs.getString("provider"));
                member.setStatus(rs.getString("status"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return member;
    }
    
    /**
     * 아이디 중복 체크
     */
    public boolean isDuplicateId(String userid) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean exists = false;
        
        try {
            conn = DbConnect.getConnection();
            String sql = "SELECT COUNT(*) FROM member WHERE userid = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userid);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                exists = rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return exists;
    }
    
    /**
     * 이메일 중복 체크
     */
    public boolean isDuplicateEmail(String email) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean exists = false;
        
        try {
            conn = DbConnect.getConnection();
            String sql = "SELECT COUNT(*) FROM member WHERE email = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                exists = rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return exists;
    }
    
    /**
     * 닉네임 중복 체크
     */
    public boolean isDuplicateNickname(String nickname) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean exists = false;
        
        try {
            conn = DbConnect.getConnection();
            String sql = "SELECT COUNT(*) FROM member WHERE nickname = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, nickname);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                exists = rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return exists;
    }
    
    /**
     * 전체 회원 목록 조회 (관리자용)
     */
    public List<MemberDTO> getAllMembers() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<MemberDTO> memberList = new ArrayList<>();
        
        try {
            conn = DbConnect.getConnection();
            String sql = "SELECT * FROM member WHERE status != '탈퇴' ORDER BY userid";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                MemberDTO member = new MemberDTO();
                member.setUserid(rs.getString("userid"));
                member.setPasswd(rs.getString("password"));
                member.setName(rs.getString("name"));
                member.setNickname(rs.getString("nickname"));
                member.setEmail(rs.getString("email"));
                member.setPhone(rs.getString("phone"));
                member.setBirth(rs.getDate("birth"));
                member.setGender(rs.getString("gender"));
                member.setProvider(rs.getString("provider"));
                member.setStatus(rs.getString("status"));
                memberList.add(member);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return memberList;
    }
    
    /**
     * 회원 상태 업데이트
     */
    public boolean updateMemberStatus(String userid, String status) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        
        try {
            conn = DbConnect.getConnection();
            String sql = "UPDATE member SET status = ? WHERE userid = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, status);
            pstmt.setString(2, userid);
            
            int result = pstmt.executeUpdate();
            success = result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return success;
    }
    
    /**
     * 회원 삭제 (실제로는 탈퇴 상태로 변경)
     */
    public boolean deleteMember(String userid) {
        return updateMemberStatus(userid, "탈퇴");
    }
}
