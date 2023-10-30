package com.dragong.dragong.domain.report.dto;

import java.util.UUID;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class ReportRequestDto {

    private UUID suspect;
    private String reportDetail;

    @Builder
    public ReportRequestDto(UUID suspect, String reportDetail) {
        this.suspect = suspect;
        this.reportDetail = reportDetail;
    }
}
