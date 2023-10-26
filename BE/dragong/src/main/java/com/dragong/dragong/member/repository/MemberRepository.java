package com.dragong.dragong.member.repository;

import com.dragong.dragong.member.entity.Member;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MemberRepository extends JpaRepository<Member, UUID> {
    Optional<Member> findMemberByRefreshToken_RefreshToken(String refreshToken);
}
