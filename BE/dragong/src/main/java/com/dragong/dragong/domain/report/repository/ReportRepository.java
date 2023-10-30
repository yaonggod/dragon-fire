package com.dragong.dragong.domain.report.repository;

import com.dragong.dragong.domain.report.entity.Report;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReportRepository extends JpaRepository<Report, Long> {

    // 신고 아이디를 통해 검색
    Optional<Report> findByReportId(long reportId);

    // 유저가 자신의 아이디로 검색
    List<Report> findAllByReporter(UUID reporter);

    // 관리자가 신고 접수 후 처리가 안된 신고 확인
    List<Report> findAllByProcessedIsFalse();
}
