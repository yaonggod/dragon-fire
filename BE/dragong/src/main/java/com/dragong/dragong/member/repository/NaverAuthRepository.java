package com.dragong.dragong.member.repository;

import com.dragong.dragong.member.entity.auth.NaverAuth;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface NaverAuthRepository extends JpaRepository<NaverAuth, UUID> {
    Optional<NaverAuth> findByEmail(String email);
}
