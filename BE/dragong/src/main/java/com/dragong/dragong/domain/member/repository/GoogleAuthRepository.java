package com.dragong.dragong.domain.member.repository;

import com.dragong.dragong.domain.member.entity.auth.GoogleAuth;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GoogleAuthRepository extends JpaRepository<GoogleAuth, UUID> {

    Optional<GoogleAuth> findByEmail(String email);
}
