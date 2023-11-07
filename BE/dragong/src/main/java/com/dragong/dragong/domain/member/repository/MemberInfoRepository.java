package com.dragong.dragong.domain.member.repository;

import com.dragong.dragong.domain.member.entity.MemberInfo;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MemberInfoRepository extends JpaRepository<MemberInfo, UUID> {

    boolean existsByNicknameAndMember_QuitFlagIsFalse(String nickname);

    Optional<MemberInfo> findMemberInfoByMemberId(UUID memberId);

    Optional<MemberInfo> findMemberInfoByNicknameAndMember_QuitFlagIsFalse(String nickname);

    Optional<MemberInfo> findByNickname(String nickname);
}
