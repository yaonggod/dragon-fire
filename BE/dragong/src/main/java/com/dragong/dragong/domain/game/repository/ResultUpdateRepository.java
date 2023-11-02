package com.dragong.dragong.domain.game.repository;

import com.dragong.dragong.domain.playResult.entity.PlayResult;
import com.dragong.dragong.domain.playResult.entity.PlayResultEmpId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
@Repository
public interface ResultUpdateRepository extends JpaRepository<PlayResult, PlayResultEmpId> {

    Optional<PlayResult> findByPlayResultEmpId(PlayResultEmpId playResultEmpId);



}
