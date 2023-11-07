package com.dragong.dragong.domain.member.repository;

import com.dragong.dragong.domain.member.entity.FcmToken;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FcmTokenRepository extends JpaRepository<FcmToken, UUID> {

}
