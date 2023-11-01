package com.dragong.dragong.domain.game.service.serviceImpl;

import com.dragong.dragong.domain.game.repository.ResultUpdateRepository;
import com.dragong.dragong.domain.game.service.ResultUpdateService;
import com.dragong.dragong.domain.member.entity.Member;
import com.dragong.dragong.domain.member.repository.MemberRepository;
import com.dragong.dragong.domain.playResult.entity.PlayResult;
import com.dragong.dragong.domain.playResult.entity.PlayResultEmpId;
import com.dragong.dragong.global.util.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@Slf4j
public class ResultUpdateServiceImpl implements ResultUpdateService {
    static int season = 1;

    @Autowired
    JwtUtil jwtUtil;

    @Autowired
    MemberRepository memberRepository;

    @Autowired
    ResultUpdateRepository resultUpdateRepository;

    @Override
    @Transactional
    public void updateWinner(String accessToken) {
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기

        Member member = memberRepository.findById(myUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId).orElse(null);
        int winCount = playResult.getWin();

        int nowScore = playResult.getScore();
        int maxScore = playResult.getSeasonMaxScore();
        playResult.setWin(winCount + 1);
        playResult.setScore(nowScore + 20);
        if (nowScore + 20 > maxScore) {
            playResult.setSeasonMaxScore(nowScore + 20);
        }

    }

    @Override
    @Transactional
    public void updateLoser(String accessToken) {
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기

        Member member = memberRepository.findById(myUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId).orElse(null);
        int loseCount = playResult.getLose();
        int nowScore = playResult.getScore();
        playResult.setLose(loseCount + 1);
        playResult.setScore(nowScore - 20);

    }
//    @Override
//    @Transactional
//    public void testing() {
//        String uuidString = "2452fece-2846-47c1-be38-5e7be4e9d152";
//        try {
//            UUID uuid = UUID.fromString(uuidString);
//            System.out.println("Parsed UUID: " + uuid);
//            Member member = memberRepository.findById(uuid).orElse(null);
//            PlayResultEmpId playResultEmpId = new PlayResultEmpId(season,member);
//            PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId).orElse(null);
//            playResult.setLose(150);
//        } catch (IllegalArgumentException e) {
//            System.err.println("Invalid UUID string: " + uuidString);
//        }
//    }


}
