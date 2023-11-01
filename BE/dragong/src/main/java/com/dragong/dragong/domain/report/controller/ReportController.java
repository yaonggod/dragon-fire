package com.dragong.dragong.domain.report.controller;

import com.dragong.dragong.domain.report.dto.GetAllReportResponseDto;
import com.dragong.dragong.domain.report.dto.ReportRequestDto;
import com.dragong.dragong.domain.report.dto.ReportUpdateRequestDto;
import com.dragong.dragong.domain.report.service.ReportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/report")
@Slf4j
public class ReportController {

    private final ReportService reportService;

    @GetMapping("/all")
    public ResponseEntity<?> findAllReport(@RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken) {

        try{
            GetAllReportResponseDto response = reportService.getAllReport();
            return new ResponseEntity<>(response, HttpStatus.OK);
        }catch (Exception e){
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/my")
    public ResponseEntity<?> findAllMyReport(@RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken){
        try{
            GetAllReportResponseDto response = reportService.getAllReportByID(accessToken, refreshToken);
            return new ResponseEntity<>(response, HttpStatus.OK);
        }catch (Exception e){
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/new")
    public ResponseEntity<?> createReport(@RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken,@RequestBody ReportRequestDto request){
        try {
            reportService.createReport(request, accessToken, refreshToken);
            return new ResponseEntity<>(HttpStatus.OK);
        }catch (Exception e){
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @PatchMapping("/update")
    public ResponseEntity<?> processReport(@RequestBody ReportUpdateRequestDto request){
        try {
            reportService.updateReport(request);
            return new ResponseEntity<>(HttpStatus.OK);
        }catch (Exception e){
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
}
