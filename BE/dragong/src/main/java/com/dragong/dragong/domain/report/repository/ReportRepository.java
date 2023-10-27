package com.dragong.dragong.domain.report.repository;

import com.dragong.dragong.domain.report.entity.Report;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReportRepository extends JpaRepository<Report, Long> {

}
