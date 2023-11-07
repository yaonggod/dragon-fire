package com.dragong.dragong.domain.member.repository;

import com.dragong.dragong.domain.member.entity.auth.RefreshToken;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    Optional<RefreshToken> findRefreshTokenByRefreshToken(String refreshToken);
}
