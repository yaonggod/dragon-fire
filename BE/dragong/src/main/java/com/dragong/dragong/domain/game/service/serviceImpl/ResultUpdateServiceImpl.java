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
        log.info("impl에서 updateWinnder 실행");
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기
        Member member = memberRepository.findById(myUUID).orElse(null);
        log.info(String.valueOf(member.getMemberId()));
        log.info("member를 출력합니다" + member.toString());
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId).orElse(null);
        String result = "";
        if (playResult == null) {
            //playResult에 정보를 추가해줘야한다.

            playResult = new PlayResult();
            playResult.setLose(0);
            playResult.setWin(1);
            playResult.setPlayResultEmpId(playResultEmpId);
            playResult.setSeasonMaxScore(1020);
            playResult.setScore(1020);
            resultUpdateRepository.save(playResult);

        } else {
            //이미 정보가 있는 상태입니다.
            int nowScore = playResult.getScore();
            int nowMaxScore = playResult.getSeasonMaxScore();
            playResult.setWin(playResult.getWin() + 1);
            playResult.setScore(nowScore + 20);
            if (nowScore + 20 > nowMaxScore) {
                playResult.setSeasonMaxScore(nowScore + 20);
            }

        }


    }

    @Override
    @Transactional
    public void updateLoser(String accessToken) {
        log.info("impl에서 updateLoser 실행");
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기
        log.info("uuid 출력" + String.valueOf(myUUID));
        Member member = memberRepository.findById(myUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId).orElse(null);
        String result = "";
        if (playResult == null) {
            //playResult에 정보를 추가해줘야한다.
            playResult = new PlayResult();
            playResult.setLose(1);
            playResult.setWin(0);
            playResult.setPlayResultEmpId(playResultEmpId);
            playResult.setSeasonMaxScore(980);
            playResult.setScore(980);
            resultUpdateRepository.save(playResult);

        } else {
            //이미 정보가 있는 상태입니다.
            int nowScore = playResult.getScore();
            playResult.setLose(playResult.getLose() + 1);
            if (nowScore - 20 < 0) {
                playResult.setScore(0);
            } else {
                playResult.setScore(nowScore - 20);
            }

        }

    }

    @Override
    public String getWinnerInfo(String accessToken) {
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기
        log.info("uuid 출력" + String.valueOf(myUUID));
        Member member = memberRepository.findById(myUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId).orElse(null);
        return null;
    }

    @Override
    public String getLoserInfo(String accessToken) {
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기
        log.info("uuid 출력" + String.valueOf(myUUID));
        Member member = memberRepository.findById(myUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId).orElse(null);
        return null;
    }

}
