package com.dragong.dragong.domain.playLog.repository;

import com.dragong.dragong.domain.member.entity.Member;
import com.dragong.dragong.domain.playLog.entity.PlayLog;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PlayLogRepository extends JpaRepository<PlayLog, Long> {

}
