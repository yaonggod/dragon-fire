package com.dragong.dragong.domain.report.service;

import com.dragong.dragong.domain.report.dto.GetAllReportResponseDto;
import com.dragong.dragong.domain.report.dto.ReportRequestDto;
import com.dragong.dragong.domain.report.dto.ReportUpdateRequestDto;

public interface ReportService {

    void createReport(ReportRequestDto request, String accessToken, String freshToken);

    void updateReport(ReportUpdateRequestDto request);

    GetAllReportResponseDto getAllReport();

    GetAllReportResponseDto getAllReportByID(String accessToken, String refreshToken);
}
