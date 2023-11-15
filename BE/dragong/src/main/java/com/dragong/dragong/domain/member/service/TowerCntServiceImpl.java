package com.dragong.dragong.domain.member.service;

import com.dragong.dragong.domain.member.dto.request.AddMyChanceRequestDto;
import com.dragong.dragong.domain.member.dto.response.GetChanceResponseDto;
import com.dragong.dragong.domain.member.entity.MemberInfo;
import com.dragong.dragong.domain.member.repository.MemberInfoRepository;
import com.dragong.dragong.global.util.JwtUtil;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class TowerCntServiceImpl implements TowerCntService {

    @Autowired
    MemberInfoRepository memberInfoRepository;

    @Autowired
    JwtUtil jwtUtil;

    public void resetChance() {
        List<MemberInfo> memberInfoList = memberInfoRepository.findAll();

        if (memberInfoList.isEmpty()) {
            throw new NoSuchElementException();
        }

        for (MemberInfo memberInfo : memberInfoList) {
            if (memberInfo.getChance() >= 3) {
                continue;
            }

            memberInfo.resetChance();
            memberInfoRepository.save(memberInfo);
        }
    }

    @Override
    public GetChanceResponseDto getMyChance(String accessToken) {
        UUID UUID = jwtUtil.extractMemberId(accessToken.substring(7));

        MemberInfo memberInfo = memberInfoRepository.findById(UUID)
            .orElseThrow(() -> new NoSuchElementException());

        return GetChanceResponseDto.builder()
            .chance(memberInfo.getChance())
            .build();
    }

    @Override
    public void updateMyChance(String accessToken, AddMyChanceRequestDto addMyChanceRequestDto) {
        UUID UUID = jwtUtil.extractMemberId(accessToken.substring(7));

        MemberInfo memberInfo = memberInfoRepository.findById(UUID)
            .orElseThrow(() -> new NoSuchElementException());

        memberInfo.updateChance(addMyChanceRequestDto.getAddChance());
        memberInfoRepository.save(memberInfo);
    }


    @Scheduled(cron = "0 0 0 * * ?")
    void resetChanceCron() {
        log.info("타워 기회 횟수 초기화 중...");
        resetChance();
        log.info("타워 기회 횟수 초기화 완료...");
    }
}
