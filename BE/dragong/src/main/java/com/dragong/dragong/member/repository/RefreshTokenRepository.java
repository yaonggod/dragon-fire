package com.dragong.dragong.member.repository;

import com.dragong.dragong.member.entity.auth.RefreshToken;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {
}
