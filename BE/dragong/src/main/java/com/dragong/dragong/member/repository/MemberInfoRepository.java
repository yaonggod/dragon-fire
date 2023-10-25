package com.dragong.dragong.member.repository;

import com.dragong.dragong.member.entity.MemberInfo;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MemberInfoRepository extends JpaRepository<MemberInfo, UUID> {

    boolean existsByNickname(String nickname);
}
