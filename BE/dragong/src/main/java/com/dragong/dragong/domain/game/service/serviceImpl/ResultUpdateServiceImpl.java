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
    public int updateWinner(String accessToken, int logLength) {
        log.info("impl에서 updateWinnder 실행");
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기
        Member member = memberRepository.findById(myUUID).orElse(null);
        MemberInfo memberInfo = memberInfoRepository.findById(myUUID).orElse(null);
        memberInfo.updateCoin(10);
        memberInfoRepository.save(memberInfo);
        log.info(String.valueOf(member.getMemberId()));
        log.info("member를 출력합니다" + member.toString());
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId)
                .orElse(null);
        String result = "";
        if (playResult == null) {
            //playResult에 정보를 추가해줘야한다.

            playResult = new PlayResult();
            playResult.setLose(0);
            playResult.setWin(1);
            playResult.setPlayResultEmpId(playResultEmpId);
            playResult.setSeasonMaxScore(1020);
            playResult.setScore(1020);
            playResult.setWinningStreak(1);
            resultUpdateRepository.save(playResult);
            return 20;

        } else {
            //이미 정보가 있는 상태입니다.
            int nowScore = playResult.getScore();
            int nowMaxScore = playResult.getSeasonMaxScore();
            int nowStreak = playResult.getWinningStreak(); // 현재까지의 연승 정보
            playResult.setWin(playResult.getWin() + 1);
            playResult.setScore(nowScore + 20 + (nowStreak * 2) + (logLength / 4));
            playResult.setWinningStreak(playResult.getWinningStreak() + 1);
            playResult.setSeasonMaxWinningStreak(Math.max(playResult.getWinningStreak(),
                    playResult.getSeasonMaxWinningStreak()));
            if (nowScore + 20 + (nowStreak * 2) + (logLength / 4) > nowMaxScore) {
                playResult.setSeasonMaxScore(nowScore + 20 + (nowStreak * 2) + (logLength / 4));
            }

            return 20 + (nowStreak * 2) + (logLength / 4);
        }


    }

    @Override
    @Transactional
    public int updateLoser(String accessToken, int logLength) {
        log.info("impl에서 updateLoser 실행");
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기
        log.info("uuid 출력" + String.valueOf(myUUID));
        Member member = memberRepository.findById(myUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId)
                .orElse(null);
        String result = "";
        if (playResult == null) {
            //playResult에 정보를 추가해줘야한다.
            playResult = new PlayResult();
            playResult.setLose(1);
            playResult.setWin(0);
            playResult.setPlayResultEmpId(playResultEmpId);
            playResult.setSeasonMaxScore(980);
            playResult.setScore(980);
            playResult.setWinningStreak(0);
            resultUpdateRepository.save(playResult);

            return -20;

        } else {
            //이미 정보가 있는 상태입니다.
            int nowScore = playResult.getScore();
            playResult.setLose(playResult.getLose() + 1);
            playResult.setWinningStreak(0);
            int minusscore = 0;
            if (-20 + (logLength / 4) > -10) {
                minusscore = -10;
            } else {
                minusscore = -20 + (logLength / 4);
            }
            if (nowScore + minusscore < 0) {
                playResult.setScore(0);
            } else {
                playResult.setScore(nowScore + minusscore);
            }

            return minusscore;


        }

    }

    @Override
    public String getWinnerInfo(String accessToken) {
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기
        log.info("승자의 정보를 가져옵니다");
        log.info("uuid 출력" + String.valueOf(myUUID));
        Member member = memberRepository.findById(myUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId)
                .orElse(null);
        String answer = "";
        int win = playResult.getWin();
        int lose = playResult.getLose();
        int score = playResult.getScore();
        log.info("승" + win);
        log.info("패" + lose);
        log.info("점수" + score);
        answer += Integer.toString(win) + ":" + Integer.toString(lose) + ":" + Integer.toString(
                score);
        return answer;
    }

    @Override
    public String getLoserInfo(String accessToken) {
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기
        log.info("패자의 정보를 가져옵니다");
        log.info("uuid 출력" + String.valueOf(myUUID));
        Member member = memberRepository.findById(myUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId)
                .orElse(null);
        String answer = "";
        int win = playResult.getWin();
        int lose = playResult.getLose();
        int score = playResult.getScore();
        log.info("승" + win);
        log.info("패" + lose);
        log.info("점수" + score);
        answer += Integer.toString(win) + ":" + Integer.toString(lose) + ":" + Integer.toString(
                score);
        return answer;
    }

    @Override
    public Map<String, Object> gettingInfo(String accessToken1, String nickname1,
                                           String accessToken2, String nickname2) {
        Map<String, Object> data = new HashMap<>();
        UUID myUUID1 = jwtUtil.extractMemberId(accessToken1.substring(7)); // getUUID로 UUID 얻기
        UUID myUUID2 = jwtUtil.extractMemberId(accessToken2.substring(7)); // getUUID로 UUID 얻기
        log.info("사용자들의 승,패 정보를 가져옵니다");
        log.info("첫번째 사용자의 nickname: " + nickname1);
        log.info("첫번째 사용자의 accessToken: " + accessToken1);
        log.info("두번째 사용자의 nickname: " + nickname2);
//        log.info("두번째 사용자의 accessToken: " + accessToken2);
        Member member1 = memberRepository.findById(myUUID1).orElse(null);
        MemberInfo memberInfo1 = memberInfoRepository.findById(myUUID1).orElse(null);
        log.info("member1 :" + member1);
        PlayResultEmpId playResultEmpId1 = new PlayResultEmpId(season, member1);
        log.info("playResultEmpId1:" + playResultEmpId1);
        PlayResult playResult1 = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId1)
                .orElse(null);

        if (playResult1 == null) {
            playResult1 = new PlayResult();
            playResult1.setLose(0);
            playResult1.setWin(0);
            playResult1.setPlayResultEmpId(playResultEmpId1);
            playResult1.setSeasonMaxScore(1000);
            playResult1.setScore(1000);
            playResult1.setWinningStreak(0);
            data.put("nickname1", nickname1);
            data.put("user1Win", 0);
            data.put("user1Lose", 0);
            data.put("user1Score", 1000);
            data.put("user1WinningStreak", 0);
            data.put("user1Introduction", memberInfo1.getIntroduction());
            resultUpdateRepository.save(playResult1);
        } else {
            //
            data.put("nickname1", nickname1);
            data.put("user1Win", playResult1.getWin());
            data.put("user1Lose", playResult1.getLose());
            data.put("user1Score", playResult1.getScore());
            data.put("user1Introduction", memberInfo1.getIntroduction());
            data.put("user1WinningStreak", playResult1.getWinningStreak());
        }

        Member member2 = memberRepository.findById(myUUID2).orElse(null);
        MemberInfo memberInfo2 = memberInfoRepository.findById(myUUID2).orElse(null);
        PlayResultEmpId playResultEmpId2 = new PlayResultEmpId(season, member2);
        PlayResult playResult2 = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId2)
                .orElse(null);
        if (playResult2 == null) {
            playResult2 = new PlayResult();
            playResult2.setLose(0);
            playResult2.setWin(0);
            playResult2.setPlayResultEmpId(playResultEmpId2);
            playResult2.setSeasonMaxScore(1000);
            playResult2.setScore(1000);
            playResult2.setWinningStreak(0);
            data.put("nickname2", nickname2);
            data.put("user2Win", 0);
            data.put("user2Lose", 0);
            data.put("user2Score", 1000);
            data.put("user2WinningStreak", 0);
            data.put("user2Introduction", memberInfo2.getIntroduction());
            resultUpdateRepository.save(playResult2);
        } else {
            data.put("nickname2", nickname2);
            data.put("user2Win", playResult2.getWin());
            data.put("user2Lose", playResult2.getLose());
            data.put("user2Score", playResult2.getScore());
            data.put("user2Introduction", memberInfo2.getIntroduction());
            data.put("user2WinningStreak", playResult2.getWinningStreak());
        }

        return data;
    }

    @Override
    public Map<String, Object> getComAndMe(String accessToken1, String nickname1, UUID UUID2,
                                           String nickname2) {
        Map<String, Object> data = new HashMap<>();
        UUID myUUID1 = jwtUtil.extractMemberId(accessToken1.substring(7)); // getUUID로 UUID 얻기
        log.info("사용자들의 승,패 정보를 가져옵니다");
        log.info("첫번째 사용자의 nickname: " + nickname1);
        log.info("첫번째 사용자의 accessToken: " + accessToken1);
        log.info("두번째 사용자의 nickname: " + nickname2);
        Member member1 = memberRepository.findById(myUUID1).orElse(null);
        MemberInfo memberInfo1 = memberInfoRepository.findById(myUUID1).orElse(null);
        log.info("member1 :" + member1);
        PlayResultEmpId playResultEmpId1 = new PlayResultEmpId(season, member1);
        log.info("playResultEmpId1:" + playResultEmpId1);
        PlayResult playResult1 = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId1)
                .orElse(null);

        if (playResult1 == null) {
            //들어온 사용자가 만약에 null 이라면?
            playResult1 = new PlayResult();
            playResult1.setLose(0);
            playResult1.setWin(0);
            playResult1.setPlayResultEmpId(playResultEmpId1);
            playResult1.setSeasonMaxScore(1000);
            playResult1.setScore(1000);
            playResult1.setWinningStreak(0);
            playResult1.setSeasonMaxWinningStreak(0);
            data.put("nickname1", nickname1);
            data.put("user1Win", 0);
            data.put("user1Lose", 0);
            data.put("user1Score", 1000);
            data.put("user1WinningStreak", 0);
            data.put("user2Introduction", memberInfo1.getIntroduction());
            resultUpdateRepository.save(playResult1);
        } else {
            // 이미 등록된 사용자라면?
            data.put("nickname1", nickname1);
            data.put("user1Win", playResult1.getWin());
            data.put("user1Lose", playResult1.getLose());
            data.put("user1Score", playResult1.getScore());
            data.put("user2Introduction", memberInfo1.getIntroduction());
            data.put("user1WinningStreak", playResult1.getWinningStreak());
        }

        Member member2 = memberRepository.findById(UUID2).orElse(null);
        MemberInfo memberInfo2 = memberInfoRepository.findById(UUID2).orElse(null);
        PlayResultEmpId playResultEmpId2 = new PlayResultEmpId(season, member2);
        PlayResult playResult2 = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId2)
                .orElse(null);

        if (playResult2 == null) {
            // 만약에 이미 컴퓨터의 정보가 들어가 있지 않다면?
            playResult2 = new PlayResult();
            playResult2.setLose(0);
            playResult2.setWin(0);
            playResult2.setPlayResultEmpId(playResultEmpId2);
            playResult2.setSeasonMaxScore(1000);
            playResult2.setScore(1000);
            data.put("nickname2", nickname2);
            data.put("user2Win", 0);
            data.put("user2Lose", 0);
            data.put("user2Score", 1000);
            data.put("user2WinningStreak", 0);
            data.put("user2Introduction", memberInfo2.getIntroduction());
            resultUpdateRepository.save(playResult2);
        } else {
            // 만약에 컴퓨터의 정보가 db에 들어가 있다면?
            data.put("nickname2", nickname2);
            data.put("user2Win", playResult2.getWin());
            data.put("user2Lose", playResult2.getLose());
            data.put("user2Score", playResult2.getScore());
            data.put("user2Introduction", memberInfo2.getIntroduction());
            data.put("user2WinningStreak", playResult2.getWinningStreak());
        }

        return data;
    }

    @Override
    @Transactional
    public void updateWinComputer(UUID comUUID) {
        log.info("impl에서 computer가 승리해서 update 실행");
        Member member = memberRepository.findById(comUUID).orElse(null);
        MemberInfo memberInfo = memberInfoRepository.findById(comUUID).orElse(null);
        memberInfo.updateCoin(10);
        memberInfoRepository.save(memberInfo);
        log.info(String.valueOf(member.getMemberId()));
        log.info("member를 출력합니다" + member.toString());
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId)
                .orElse(null);
        String result = "";
        if (playResult == null) {
            //playResult에 정보를 추가해줘야한다.
            playResult = new PlayResult();
            playResult.setLose(0);
            playResult.setWin(1);
            playResult.setPlayResultEmpId(playResultEmpId);
            playResult.setSeasonMaxScore(1010);
            playResult.setScore(1010);
            playResult.setWinningStreak(1);
            playResult.setSeasonMaxWinningStreak(1);
            resultUpdateRepository.save(playResult);
        } else {
            //이미 정보가 있는 상태입니다.
            int nowScore = playResult.getScore();
            int nowMaxScore = playResult.getSeasonMaxScore();
            playResult.setWin(playResult.getWin() + 1);
            playResult.setScore(nowScore + 10);
            playResult.setWinningStreak(playResult.getWinningStreak() + 1);
            playResult.setSeasonMaxWinningStreak(Math.max(playResult.getSeasonMaxWinningStreak(),
                    playResult.getWinningStreak()));
            if (nowScore + 10 > nowMaxScore) {
                playResult.setSeasonMaxScore(nowScore + 10);
            }

        }
    }

    @Override
    @Transactional
    public void updateLoseComputer(UUID comUUID) {
        log.info("impl에서 computer가 져서 결과를 업데이트");
        Member member = memberRepository.findById(comUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId)
                .orElse(null);
        String result = "";
        if (playResult == null) {
            //playResult에 정보를 추가해줘야한다.
            playResult = new PlayResult();
            playResult.setLose(1);
            playResult.setWin(0);
            playResult.setPlayResultEmpId(playResultEmpId);
            playResult.setSeasonMaxScore(980);
            playResult.setScore(980);
            playResult.setWinningStreak(0);
            playResult.setSeasonMaxWinningStreak(0);
            resultUpdateRepository.save(playResult);

        } else {
            //이미 정보가 있는 상태입니다.
            int nowScore = playResult.getScore();
            playResult.setLose(playResult.getLose() + 1);
            playResult.setWinningStreak(0);
            if (nowScore - 20 < 0) {
                playResult.setScore(0);
            } else {
                playResult.setScore(nowScore - 20);
            }

        }

    }

    @Override
    public String getComWinnerInfo(UUID comUUID) {
        log.info("컴퓨터가 승리했고 컴퓨터의 정보를 가져옵니다.");
        Member member = memberRepository.findById(comUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId)
                .orElse(null);
        String answer = "";
        int win = playResult.getWin();
        int lose = playResult.getLose();
        int score = playResult.getScore();
        log.info("승" + win);
        log.info("패" + lose);
        log.info("점수" + score);
        answer += Integer.toString(win) + ":" + Integer.toString(lose) + ":" + Integer.toString(
                score);
        return answer;
    }

    @Override
    public String getComLoserInfo(UUID comUUID) {
        log.info("컴퓨터가 패배했고, 컴퓨터의 정보를 가져옵니다.");
        Member member = memberRepository.findById(comUUID).orElse(null);
        PlayResultEmpId playResultEmpId = new PlayResultEmpId(season, member);
        PlayResult playResult = resultUpdateRepository.findByPlayResultEmpId(playResultEmpId)
                .orElse(null);
        String answer = "";
        int win = playResult.getWin();
        int lose = playResult.getLose();
        int score = playResult.getScore();
        log.info("승" + win);
        log.info("패" + lose);
        log.info("점수" + score);
        answer += Integer.toString(win) + ":" + Integer.toString(lose) + ":" + Integer.toString(
                score);
        return answer;
    }

    @Override
    @Transactional
    public int getMaxFloor(String accessToken) {
        log.info("impl에서 getMaxFloor 실행");
        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7)); // getUUID로 UUID 얻기
        MemberInfo memberInfo = memberInfoRepository.findById(myUUID).orElse(null);
        return memberInfo.getTower();
    }

    @Override
    @Transactional
    public void updateMaxFloor(String accessToken, int nowFloor) {
        log.info("impl에서 updateMaxFloor 실행");
        log.info(accessToken);
        UUID myUUID = jwtUtil.extractMemberId(accessToken); // getUUID로 UUID 얻기
        MemberInfo memberInfo = memberInfoRepository.findById(myUUID).orElse(null);

        int nowMaxFloor = memberInfo.getTower();
        if (nowFloor + 1 > nowMaxFloor) {
            memberInfo.updateTower(nowFloor);
        }

    }


}
