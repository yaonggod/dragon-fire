package com.dragong.dragong.domain.report.entity;

import com.dragong.dragong.global.common.BaseTimeEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import java.util.UUID;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
@Table(name = "report", indexes = @Index(name = "idx__reporter", columnList = "reporter"))
public class Report extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long reportId;

    @Column
    private UUID reporter;

    @Column
    private UUID suspect;

    @Column
    private String reportDetail;

    @Column
    private boolean processed;

    @Builder
    public Report(UUID reporter, UUID suspect, String reportDetail){
        this.reporter = reporter;
        this.suspect = suspect;
        this.reportDetail = reportDetail;
        this.processed = false;
        this.reportId = 0;
    }

    public void setProcessed() {
        this.processed = !this.processed;
    }
}
