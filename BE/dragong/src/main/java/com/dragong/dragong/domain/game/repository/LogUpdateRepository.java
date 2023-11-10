package com.dragong.dragong.domain.game.repository;

import com.dragong.dragong.domain.playLog.entity.PlayLog;
import com.dragong.dragong.domain.playResult.entity.PlayResult;
import com.dragong.dragong.domain.playResult.entity.PlayResultEmpId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LogUpdateRepository extends JpaRepository<PlayLog, Long> {

}
