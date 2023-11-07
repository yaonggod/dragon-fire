package com.dragong.dragong.domain.playResult.repository;

import com.dragong.dragong.domain.playResult.entity.PlayResult;
import com.dragong.dragong.domain.playResult.entity.PlayResultEmpId;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PlayResultRepository extends JpaRepository<PlayResult, PlayResultEmpId> {

    Optional<List<PlayResult>> findByPlayResultEmpIdSeason(int season);

}
