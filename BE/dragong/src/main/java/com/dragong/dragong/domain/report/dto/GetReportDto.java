package com.dragong.dragong.domain.report.dto;

import java.util.UUID;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class GetReportDto {

    private long reportId;

    private UUID reporter;

    private UUID suspect;

    private String reportDetail;

    private boolean processed;

    @Builder
    public GetReportDto(long reportId, UUID reporter, UUID suspect, String reportDetail,
            boolean processed) {

        this.reportId = reportId;
        this.reporter = reporter;
        this.suspect = suspect;
        this.reportDetail = reportDetail;
        this.processed = processed;
    }
}
