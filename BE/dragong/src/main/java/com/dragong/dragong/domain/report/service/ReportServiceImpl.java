package com.dragong.dragong.domain.report.service;

import com.dragong.dragong.domain.report.dto.GetAllReportResponseDto;
import com.dragong.dragong.domain.report.dto.GetReportDto;
import com.dragong.dragong.domain.report.dto.ReportRequestDto;
import com.dragong.dragong.domain.report.dto.ReportUpdateRequestDto;
import com.dragong.dragong.domain.report.entity.Report;
import com.dragong.dragong.domain.report.repository.ReportRepository;
import com.dragong.dragong.global.util.JwtUtil;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReportServiceImpl implements ReportService {

    private final ReportRepository repository;
    private final JwtUtil jwtUtil;

    /**
     * 신고를 생성하는 함수
     *
     * @param request 상대방 UUID, 리포트 내용
     * @param accessToken 내 아이디를 담기 위한 토큰
     * @param freshToken
     */
    @Override
    @Transactional
    public void createReport(ReportRequestDto request, String accessToken, String freshToken) {

        UUID memberId = jwtUtil.extractMemberId(accessToken.substring(7));

        Report report = Report.builder()
                .reporter(memberId)
                .suspect(request.getSuspect())
                .reportDetail(request.getReportDetail())
                .build();

        System.out.println(report.getReporter() + " " + report.getSuspect() + " " + report.getReportDetail());

        repository.save(report);
    }

    /**
     * 신고를 처리하는 함수
     *
     * @param request long으로 된 reportId를 가지고 있다.
     */
    @Override
    @Transactional
    public void updateReport(ReportUpdateRequestDto request) {

        Report report = repository.findByReportId(request.getReportId()).orElseThrow();

        report.setProcessed();
    }

    /**
     * 관리자가 활성화된 모든 신고를 가져오는 함수
     *
     * @return GetAllReportResponseDto GetReportDto의 리스트
     */
    @Override
    public GetAllReportResponseDto getAllReport() {

        List<GetReportDto> reportDtoList = new ArrayList<>();

        for (Report report : repository.findAllByProcessedIsFalse()) {

            GetReportDto rep = GetReportDto.builder()
                    .reporter(report.getReporter())
                    .suspect(report.getSuspect())
                    .reportDetail(report.getReportDetail())
                    .reportId(report.getReportId())
                    .processed(report.isProcessed())
                    .build();

            reportDtoList.add(rep);

//            System.out.println(rep.getReportId() + " " + rep.getReporter() + " " + rep.);
        }

        GetAllReportResponseDto response = GetAllReportResponseDto.builder()
                .response(reportDtoList)
                .build();

        return response;
    }

    /**
     * 자신이 신고한 내역을 볼 수 있는 함수
     *
     * @param accessToken 자신의 아이디를 얻기 위한 토큰
     * @param refreshToken
     * @return GetAllReportResponseDto GetReportDto의 리스트
     */
    @Override
    public GetAllReportResponseDto getAllReportByID(String accessToken, String refreshToken) {

        UUID memberId = jwtUtil.extractMemberId(accessToken.substring(7));

        List<GetReportDto> reportDtoList = new ArrayList<>();

        for (Report report : repository.findAllByReporter(memberId)) {
            GetReportDto reportDto = GetReportDto.builder()
                    .reportId(report.getReportId())
                    .reporter(report.getReporter())
                    .suspect(report.getSuspect())
                    .reportDetail(report.getReportDetail())
                    .processed(report.isProcessed())
                    .build();

            reportDtoList.add(reportDto);
        }

        GetAllReportResponseDto response = GetAllReportResponseDto.builder()
                .response(reportDtoList)
                .build();

        return response;
    }
}
