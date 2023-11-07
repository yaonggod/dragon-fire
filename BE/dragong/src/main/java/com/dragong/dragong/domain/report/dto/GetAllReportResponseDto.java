package com.dragong.dragong.domain.report.dto;

import java.util.ArrayList;
import java.util.List;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class GetAllReportResponseDto {

    List<GetReportDto> response = new ArrayList<>();

    @Builder
    public GetAllReportResponseDto(List<GetReportDto> response) {
        this.response = response;
    }
}
