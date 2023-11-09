package com.dragong.dragong.domain.game.service.serviceImpl;

import com.dragong.dragong.domain.game.repository.ResultUpdateRepository;
import com.dragong.dragong.domain.game.service.ResultUpdateService;
import com.dragong.dragong.domain.member.entity.Member;
import com.dragong.dragong.domain.member.entity.MemberInfo;
import com.dragong.dragong.domain.member.repository.MemberInfoRepository;
import com.dragong.dragong.domain.member.repository.MemberRepository;
import com.dragong.dragong.domain.playResult.entity.PlayResult;
import com.dragong.dragong.domain.playResult.entity.PlayResultEmpId;
import com.dragong.dragong.global.util.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;
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
    MemberInfoRepository memberInfoRepository;

    @Autowired
    ResultUpdateRepository resultUpdateRepository;

    @Override
    @Transactional
    public void updateWinner(String accessToken) {
        log.info("impl에서 updateWinnder 실행");
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기
        Member member = memberRepository.findById(myUUID).orElse(null);
        MemberInfo memberInfo = memberInfoRepository.findById(myUUID).orElse(null);
        memberInfo.updateCoin(10);
        memberInfoRepository.save(memberInfo);
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
        log.info("승자의 정보를 가져옵니다");
        log.info("uuid 출력" + String.valueOf(myUUID));
        Member member = memberRepository.findById(myUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId).orElse(null);
        String answer = "";
        int win = playResult.getWin();
        int lose = playResult.getLose();
        int score = playResult.getScore();
        log.info("승"+win);
        log.info("패"+lose);
        log.info("점수"+score);
        answer += Integer.toString(win) + ":" + Integer.toString(lose) + ":" + Integer.toString(score);
        return answer;
    }

    @Override
    public String getLoserInfo(String accessToken) {
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기
        log.info("패자의 정보를 가져옵니다");
        log.info("uuid 출력" + String.valueOf(myUUID));
        Member member = memberRepository.findById(myUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId).orElse(null);
        String answer = "";
        int win = playResult.getWin();
        int lose = playResult.getLose();
        int score = playResult.getScore();
        log.info("승"+win);
        log.info("패"+lose);
        log.info("점수"+score);
        answer += Integer.toString(win) + ":" + Integer.toString(lose) + ":" + Integer.toString(score);
        return answer;
    }

    @Override
    public Map<String, Object> gettingInfo(String accessToken1,String nickname1, String accessToken2, String nickname2){
        Map<String, Object> data = new HashMap<>();
        UUID myUUID1 = jwtUtil.extractMemberId(accessToken1.substring(7)); // getUUID로 UUID 얻기
        UUID myUUID2 = jwtUtil.extractMemberId(accessToken2.substring(7)); // getUUID로 UUID 얻기
        log.info("사용자들의 승,패 정보를 가져옵니다");

        Member member1 = memberRepository.findById(myUUID1).orElse(null);
        PlayResultEmpId playResultEmpId1 = new PlayResultEmpId(season, member1);
        PlayResult playResult1 = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId1).orElse(null);

        Member member2 = memberRepository.findById(myUUID2).orElse(null);
        PlayResultEmpId playResultEmpId2 = new PlayResultEmpId(season, member2);
        PlayResult playResult2 = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId2).orElse(null);

        data.put("nickname1",nickname1);
        data.put("user1Win",playResult1.getWin());
        data.put("user1Lose",playResult1.getLose());
        data.put("user1Score",playResult1.getScore());
        data.put("nickname2",nickname2);
        data.put("user2Win",playResult2.getWin());
        data.put("user2Lose",playResult2.getLose());
        data.put("user2Score",playResult2.getScore());

        return data;
    }



}
