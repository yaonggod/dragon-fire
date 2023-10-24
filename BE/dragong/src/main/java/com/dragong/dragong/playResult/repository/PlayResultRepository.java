package com.dragong.dragong.playResult.repository;

import com.dragong.dragong.playResult.entity.PlayResult;
import com.dragong.dragong.playResult.entity.PlayResultEmpId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlayResultRepository extends JpaRepository<PlayResult, PlayResultEmpId> {

}
