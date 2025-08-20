package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.MdWish;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * MD 찜 매퍼 (기존 md_wish 테이블 사용)
 * Model1 MdWishDao 기능을 Spring Mapper로 변환
 */
@Mapper
public interface MdWishMapper {
    
    /**
     * MD 찜 추가
     * Model1: addMdWish(int mdId, String userid)
     */
    @Insert("INSERT INTO md_wish (md_id, userid, created_at) VALUES (#{mdId}, #{userid}, NOW())")
    @Options(useGeneratedKeys = true, keyProperty = "wishId")
    int insertMdWish(MdWish mdWish);
    
    /**
     * MD 찜 삭제
     * Model1: removeMdWish(int mdId, String userid)
     */
    @Delete("DELETE FROM md_wish WHERE md_id = #{mdId} AND userid = #{userid}")
    int deleteMdWish(@Param("mdId") int mdId, @Param("userid") String userid);
    
    /**
     * 특정 MD가 찜되었는지 확인
     * Model1: isMdWished(int mdId, String userid)
     */
    @Select("SELECT COUNT(*) FROM md_wish WHERE md_id = #{mdId} AND userid = #{userid}")
    int countMdWish(@Param("mdId") int mdId, @Param("userid") String userid);
    
    /**
     * 사용자의 찜한 MD 목록 조회
     * Model1: getUserMdWishes(String userid)
     */
    @Select("SELECT * FROM md_wish WHERE userid = #{userid} ORDER BY created_at DESC")
    List<MdWish> findByUserid(String userid);
    
    /**
     * 특정 MD의 찜 개수 조회
     * Model1: getMdWishCount(int mdId)
     */
    @Select("SELECT COUNT(*) FROM md_wish WHERE md_id = #{mdId}")
    int countByMdId(int mdId);
    
    /**
     * 사용자의 MD 찜 개수 조회
     * Model1: getUserMdWishCount(String userid)
     */
    @Select("SELECT COUNT(*) FROM md_wish WHERE userid = #{userid}")
    int countByUserid(String userid);
    
    /**
     * 사용자의 찜한 MD 목록과 MD 정보 함께 조회
     * Model1: getUserMdWishesWithInfo(String userid, int limit)
     */
    @Select("SELECT w.wish_id, w.md_id, w.userid, w.created_at, " +
            "m.md_name, m.contact, m.description, m.photo, " +
            "p.name as place_name, p.address " +
            "FROM md_wish w " +
            "JOIN md_info m ON w.md_id = m.md_id " +
            "JOIN hotplace_info p ON m.place_id = p.id " +
            "WHERE w.userid = #{userid} " +
            "ORDER BY w.created_at DESC " +
            "LIMIT #{limit}")
    @Results({
        @Result(property = "wishId", column = "wish_id"),
        @Result(property = "mdId", column = "md_id"),
        @Result(property = "userid", column = "userid"),
        @Result(property = "createdAt", column = "created_at"),
        @Result(property = "mdName", column = "md_name"),
        @Result(property = "contact", column = "contact"),
        @Result(property = "description", column = "description"),
        @Result(property = "photo", column = "photo"),
        @Result(property = "placeName", column = "place_name"),
        @Result(property = "address", column = "address")
    })
    List<MdWish> findByUseridWithInfo(@Param("userid") String userid, @Param("limit") int limit);
    
    /**
     * 모든 찜 목록과 MD 정보 함께 조회 (관리자용)
     */
    @Select("SELECT w.wish_id, w.md_id, w.userid, w.created_at, " +
            "m.md_name, m.contact, m.description, m.photo, " +
            "p.name as place_name, p.address " +
            "FROM md_wish w " +
            "JOIN md_info m ON w.md_id = m.md_id " +
            "JOIN hotplace_info p ON m.place_id = p.id " +
            "ORDER BY w.created_at DESC")
    @Results({
        @Result(property = "wishId", column = "wish_id"),
        @Result(property = "mdId", column = "md_id"),
        @Result(property = "userid", column = "userid"),
        @Result(property = "createdAt", column = "created_at"),
        @Result(property = "mdName", column = "md_name"),
        @Result(property = "contact", column = "contact"),
        @Result(property = "description", column = "description"),
        @Result(property = "photo", column = "photo"),
        @Result(property = "placeName", column = "place_name"),
        @Result(property = "address", column = "address")
    })
    List<MdWish> findAllWithInfo();
}
