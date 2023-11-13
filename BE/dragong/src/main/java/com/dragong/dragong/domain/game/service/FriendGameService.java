package com.dragong.dragong.domain.game.service;

import com.dragong.dragong.domain.friend.entity.Friend;
import com.dragong.dragong.domain.friend.repository.FriendRepository;
import com.dragong.dragong.domain.game.dto.request.FriendAcceptGameRequestDto;
import com.dragong.dragong.domain.game.dto.response.FriendAssignRoomResponseDto;
import com.dragong.dragong.domain.game.dto.GameRoomData;
import com.dragong.dragong.domain.game.dto.GiData;
import com.dragong.dragong.domain.game.dto.LogData;
import com.dragong.dragong.domain.game.dto.WinData;
import com.dragong.dragong.domain.game.dto.response.FriendConnectGameResponseDto;
import com.dragong.dragong.domain.game.repository.LogUpdateRepository;
import com.dragong.dragong.domain.member.entity.Member;
import com.dragong.dragong.domain.member.repository.MemberInfoRepository;
import com.dragong.dragong.domain.playLog.entity.PlayLog;
import com.dragong.dragong.global.util.JwtUtil;
import com.google.auth.oauth2.GoogleCredentials;
import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
@RequiredArgsConstructor
public class FriendGameService {

    private final JwtUtil jwtUtil;
    private final FriendRepository friendRepository;
    private final MemberInfoRepository memberInfoRepository;
    private final LogUpdateRepository logUpdateRepository;

    private final boolean[] friendUseRoom = new boolean[100000];
    private final Set<GameRoomData> friendGameRoom[] = new HashSet[100000]; //
    private final ArrayList<GiData> friendGiDataRoom[] = new ArrayList[100000]; // 기 정보를 저장하기 위해서
    private final ArrayList<String> friendCountDownAndStartGame[] = new ArrayList[100000]; //54321
    private final int[] friendSaving = new int[1000000];
    private int friendTotal = 0;
    private final ArrayList<WinData> friendWinInfo[] = new ArrayList[100000]; // 각 게임에서 승자 정보를 저장하기 위해서!
    private final ArrayList<LogData> logs[] = new ArrayList[100000]; // 로그를 담기 위한 arraylist
    public static final int FRIEND_WEBSOCKET_ROOM = 1_000_000;

    @PostConstruct
    public void initializeGameRoom() {
        // 처음 한번 초기화를 해준다.
        for (int i = 0; i < friendGameRoom.length; i++) {
            friendGameRoom[i] = new HashSet<>();
            friendGiDataRoom[i] = new ArrayList<>();
            friendCountDownAndStartGame[i] = new ArrayList<>();
            friendWinInfo[i] = new ArrayList<>();
            logs[i] = new ArrayList<>();
        }
    }

    // 처음 VS를 눌렀을 때 실행되는 함수
    // accessToken을 이용해서 닉네임 가져오기
    // roomId 구하기 및 리턴
    // winData 초기화 해주기
    public FriendAssignRoomResponseDto assignRoom(String accessToken, HttpServletResponse httpServletResponse) {

        // firebase AT를 헤더에 보내서 기기보고 스토리지에 등록하라고 하기
        try {
            httpServletResponse.setHeader("firebase", "Bearer " + getFirebaseAccessToken());
        } catch (Exception e) {
        }

        UUID memberId = jwtUtil.extractMemberId(accessToken.substring(7));
        String nickname = memberInfoRepository.findMemberInfoByMemberId(memberId)
                .orElse(null)
                .getNickname();

        int roomId = enter();
        friendUseRoom[roomId] = true;

        initWinData(roomId, nickname);

        return FriendAssignRoomResponseDto.builder()
                .roomId(roomId + FRIEND_WEBSOCKET_ROOM)
                .build();
    }

    // 친구 대전 VS 버튼을 눌렀을 때 게임방에 처음 들어가려고 하는 roomId를 구하는 로직
    // 사용되고 있지 않은 roomId를 구한다.
    public int enter() {
        while (friendUseRoom[friendTotal]) {
            if (++friendTotal >= 100_000) {
                friendTotal = 0;
            }
        }
        return friendTotal;
    }

    public void acceptGame(String accessToken, FriendAcceptGameRequestDto request){

        int roomId = request.getRoomId() - FRIEND_WEBSOCKET_ROOM;
        UUID memberId = jwtUtil.extractMemberId(accessToken.substring(7));
        String nickname = memberInfoRepository.findMemberInfoByMemberId(memberId)
                .orElse(null)
                .getNickname();

        initWinData(roomId, nickname);
    }

    public void rejectGame(FriendAcceptGameRequestDto request){

        stopGame(request.getRoomId() - FRIEND_WEBSOCKET_ROOM);
    }

    public int giInit(int roomId, String nickname) {
        // 기 정보를 처음으로 초기화 해주고 넣어준다.
//        log.info("기 정보를 초기화해줍니다");
        GiData giData = new GiData(nickname, 0);
        friendGiDataRoom[roomId].add(giData);

        return friendGiDataRoom[roomId].size();
    }

    public int giCnt(int roomId) {
        //그냥 현재 기 정보가 몇개 담겨 있는지 반환
        return friendGiDataRoom[roomId].size();
    }

    public String giReturn(int roomId) {
        String answer = "";
        for (int i = 0; i < 2; i++) {
            GiData giData = friendGiDataRoom[roomId].get(i);
            String player = giData.getNickname();

            String giCnt = Integer.toString(giData.getGi());
            answer += player + " " + giCnt + " ";
        }
//        log.info("각각의 플레이어가 가지고 있는 기 정보를 반환합니다" + answer);
        return answer;
    }

    public void giReset(int roomId) {
        GiData gi1 = friendGiDataRoom[roomId].get(0);
        GiData gi2 = friendGiDataRoom[roomId].get(1);

        String nick1 = gi1.getNickname();
        String nick2 = gi2.getNickname();
        friendGiDataRoom[roomId].set(0, new GiData(nick1, 0));
        friendGiDataRoom[roomId].set(1, new GiData(nick2, 0));
    }

    public void gameStack(int roomId, String nickname, String picked) {
        //게임 결과를 하나씩 넣어주는 느낌
//        log.info("각각의 플레이어가 선택한 값을 넣어줍니다");
        GameRoomData gameRoomData = new GameRoomData(nickname, picked);

        Map<String, GameRoomData> gameRoomMap = new HashMap<>();
        for (GameRoomData data : friendGameRoom[roomId]) {
            gameRoomMap.put(data.getNickname(), data);
        }
        gameRoomMap.put(nickname, gameRoomData);
        friendGameRoom[roomId].clear();
        friendGameRoom[roomId].addAll(gameRoomMap.values());

//        friendGameRoom[Integer.parseInt(roomId)].add(gameRoomData);
//        System.out.println(friendGameRoom[roomId].size());
        //들어오는 값들을 확인하고
    }

    public void giClear(int roomId) {
//        log.info("현재 friendGiDataRoom[roomId]에 있는 자료의 수는 : " + friendGiDataRoom[roomId]);
//        log.info("해당 데이터를 지웁니다");
        friendGiDataRoom[roomId].clear();
    }

    public void messageInsert(int roomId, String nickname) {
        // 양쪽에서 메시지 전달을 받았는지 확인하기 위한 용도
//        log.info("양측에서 메시지를 보냈는지 확인하기 위해 nickname을 넣어줍니다");
        friendCountDownAndStartGame[roomId].add(nickname);
    }

    public String returnName(int roomId) {
        return friendCountDownAndStartGame[roomId].get(0);
    }

    public int evenReturn(int roomId) {
        // 들어있는 값이 짝수일 때 0을 return 한다는 것을 기억
        int answer = friendCountDownAndStartGame[roomId].size();
        return answer;
    }

    public void cleanList(int roomId) {
        friendCountDownAndStartGame[roomId].clear();
    }

    public void aliveCheck(int roomId) {
        // 들어있는 값이 짝수일 때 0을 return 한다는 것을 기억
        friendSaving[roomId] += 1;
    }

    public int savingReturn(int roomId) {
        return friendSaving[roomId];
    }

    public void savingReset(int roomId) {
        friendSaving[roomId] = 0;
    }


    public String gameResult(int roomId) {
        log.info("친구 게임 결과를 확인합니다");
        //넣어준 gameStack에서 결과를 도출해내고 그걸 반환하는 함수
        // 여기서 예외 처리를 해줘야 하는데, 4가지 경우가 있을 것이다.
        // 1. 둘 다 제대로 제출한 경우, 2. 둘 중 한 명만 제출한 경우(이게 2가지), 4. 둘 다 제출하지 않은 경우
        String answer = "";
        GameRoomData grd1 = null;
        GameRoomData grd2 = null;
        String winner = null;
        if (friendGameRoom[roomId].size() == 2) {
            //둘다 제대로 정보를 입력한 경우
            ArrayList<GameRoomData> list = new ArrayList<>(friendGameRoom[roomId]);
            friendGameRoom[roomId].clear();
            //grd1 = friendGameRoom[Integer.parseInt(roomId)].poll();
            //grd2 = friendGameRoom[Integer.parseInt(roomId)].poll();
            grd1 = list.get(0);
            grd2 = list.get(1);
        } else if (friendGameRoom[roomId].size() == 1) {
            // 한 명만 정보를 입력한 경우 // 이건 바로 게임 중단 시킨다.
            ArrayList<GameRoomData> list = new ArrayList<>(friendGameRoom[roomId]);
            friendGameRoom[roomId].clear();
            //grd1 = friendGameRoom[Integer.parseInt(roomId)].poll();
            grd1 = list.get(0);
            answer += grd1.getNickname() + ":" + grd1.getPicked() + " "
                    + friendCountDownAndStartGame[roomId].get(1) + ":" + "미처리" + " "
                    + grd1.getNickname();
            winner = grd1.getNickname();

            // logs 추가하는 부분
            String p1 = logs[roomId].get(0).getNickname();
            String p2 = logs[roomId].get(1).getNickname();
            if (grd1.getNickname().equals(p1)) {
                // 이 부분 converter 만들어서 돌리자
                // 남아있는 사람이랑 p1이 같은 경우
                logs[roomId].set(0, new LogData(p1, logs[roomId].get(0).getLog() + grd1.getPicked() + ":"));
                logs[roomId].set(1, new LogData(p2, logs[roomId].get(1).getLog() + "노:"));
            } else {
                // 남아있는 사람이랑 p2가 같은 경우
                logs[roomId].set(1, new LogData(p2, logs[roomId].get(1).getLog() + grd1.getPicked() + ":"));
                logs[roomId].set(0, new LogData(p1, logs[roomId].get(0).getLog() + "노:"));
            }

            if (winner != null) {
//                System.out.println("이거실행");
                if (friendWinInfo[roomId].get(0).getNickname().equals(winner)) {
                    // 만약에 첫번째 인간의 nickname과 승자의 nickname이 같다면?
                    int win = friendWinInfo[roomId].get(0).getWin();
                    friendWinInfo[roomId].get(0).setWin(win + 1);
                    if (win + 1 == 2) {
                        // 이제 게임이 끝나야 하는 상황이다
                        answer += " 끝냅니다";
                    } else {
                        // 게임이 계속 되어야 하는 상황이다
                        answer += " 계속합니다";
                    }
                } else {
                    int win = friendWinInfo[roomId].get(1).getWin();
                    friendWinInfo[roomId].get(1).setWin(win + 1);
                    if (win + 1 == 2) {
                        //이제 게임이 끝나야 하는 상황이다
                        answer += " 끝냅니다";
                    } else {
                        // 게임이 계속 되어야 하는 상황이다
                        answer += " 계속합니다";
                    }
                }

                logs[roomId].set(0, new LogData(p1, logs[roomId].get(0).getLog() + "_"));
                logs[roomId].set(1, new LogData(p2, logs[roomId].get(1).getLog() + "_"));
            } else {
                answer += " 안끝남";
            }

            return answer;

        } else if (friendGameRoom[roomId].size() == 0) {
            // 둘 다 정보를 입력하지 않은 경우
            answer = friendCountDownAndStartGame[roomId].get(0) + ":미처리" + " "
                    + friendCountDownAndStartGame[roomId].get(1) + ":미처리" + " " + "무효입니다" + " 끝냅니다";
            return answer;
        }
        String player1 = grd1.getNickname();
        String picked1 = grd1.getPicked();
        String player2 = grd2.getNickname();
        String picked2 = grd2.getPicked();

        // logs 넣는 부분
        String p1 = logs[roomId].get(0).getNickname();
        String p2 = logs[roomId].get(1).getNickname();
        if (player1.equals(p1)) {
            // 이 부분 converter 만들어서 돌리자
            logs[roomId].set(0, new LogData(p1, logs[roomId].get(0).getLog() + picked1 + ":"));
            logs[roomId].set(1, new LogData(p2, logs[roomId].get(1).getLog() + picked2 + ":"));
        } else {
            // player1 == p2
            logs[roomId].set(0, new LogData(p1, logs[roomId].get(0).getLog() + picked2 + ":"));
            logs[roomId].set(1, new LogData(p2, logs[roomId].get(1).getLog() + picked1 + ":"));
        }

        answer += player1 + ":" + picked1 + " " + player2 + ":" + picked2 + " ";
        String nick1 = friendGiDataRoom[roomId].get(0).getNickname();
        int gi1 = friendGiDataRoom[roomId].get(0).getGi(); // Arraylist안의 첫번째 사람의 기 개수
        String nick2 = friendGiDataRoom[roomId].get(1).getNickname();// Arraylist안의 두번째 사람의 닉네임
        int gi2 = friendGiDataRoom[roomId].get(1).getGi();// Arraylist안의 두번째 사람의 기 개수

        if (player1.equals(nick1)) {
            if (picked1.equals("기")) {
                gi1 += 1;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi2 -= 1;
                    answer += player2;
                    winner = player2;
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi2 -= 3;
                    answer += player2;
                    winner = player2;
                }
            } else if (picked1.equals("파")) {
                gi1 -= 1;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += player1;
                    winner = player1;
                } else if (picked2.equals("파")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi2 -= 3;
                    answer += player2;
                    winner = player2;
                }

            } else if (picked1.equals("막기")) {
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else {
                    gi2 -= 3;
                    // 원기옥
                    answer += player2;
                    winner = player2;
                }

            } else if (picked1.equals("순간이동")) {
                gi1 -= 1;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi2 -= 3;
                    answer += "비겼습니다";
                }

            } else {
                gi1 -= 3;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += player1;
                    winner = player1;
                } else if (picked2.equals("파")) {
                    gi2 += 1;
                    answer += player1;
                    winner = player1;
                } else if (picked2.equals("막기")) {
                    answer += player1;
                    winner = player1;
                } else if (picked2.equals("순간이동")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else {
                    //원기옥
                    gi2 -= 3;
                    answer += "비겼습니다";
                }

            }

        } else {
            if (picked1.equals("기")) {
                gi2 += 1;
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    answer += player2;
                    winner = player2;
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi1 -= 3;
                    answer += player2;
                    winner = player2;
                }
            } else if (picked1.equals("파")) {
                gi2 -= 1;
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += player1;
                    winner = player1;
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi1 -= 3;
                    answer += player2;
                    winner = player2;
                }

            } else if (picked1.equals("막기")) {
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi1 -= 3;
                    answer += player2;
                    winner = player2;
                }

            } else if (picked1.equals("순간이동")) {
                gi2 -= 1;
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("막기")) {

                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi1 -= 3;
                    answer += "비겼습니다";
                }

            } else {
                gi2 -= 3;
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += player1;
                    winner = player1;
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    answer += player1;
                    winner = player1;
                } else if (picked2.equals("막기")) {
                    answer += player1;
                    winner = player1;
                } else if (picked2.equals("순간이동")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else {
                    //원기옥
                    gi1 -= 3;
                    answer += "비겼습니다";
                }

            }

        }
        // 이제 다시 넣어줘야한다.
        GiData giData1 = new GiData(nick1, gi1);
        GiData giData2 = new GiData(nick2, gi2);

        friendGiDataRoom[roomId].set(0, giData1);
        friendGiDataRoom[roomId].set(1, giData2);
        // 이제 여기서 winner의 승 1점을 올려야 한다.

        if (winner != null) {
//            System.out.println("이거실행");
            if (friendWinInfo[roomId].get(0).getNickname().equals(winner)) {
                // 만약에 첫번째 인간의 nickname과 승자의 nickname이 같다면?
                int win = friendWinInfo[roomId].get(0).getWin();
                friendWinInfo[roomId].get(0).setWin(win + 1);
                if (win + 1 == 2) {
                    // 이제 게임이 끝나야 하는 상황이다
                    answer += " 끝냅니다";
                } else {
                    // 게임이 계속 되어야 하는 상황이다
                    answer += " 계속합니다";
                }
            } else {
                int win = friendWinInfo[roomId].get(1).getWin();
                friendWinInfo[roomId].get(1).setWin(win + 1);
                if (win + 1 == 2) {
                    //이제 게임이 끝나야 하는 상황이다
                    answer += " 끝냅니다";
                } else {
                    // 게임이 계속 되어야 하는 상황이다
                    answer += " 계속합니다";
                }
            }

            logs[roomId].set(0, new LogData(p1, logs[roomId].get(0).getLog() + "_"));
            logs[roomId].set(1, new LogData(p2, logs[roomId].get(1).getLog() + "_"));
        } else {
            answer += " 안끝남";
        }

        return answer;

    }

    public void initWinData(int roomId, String nickname) {
        friendWinInfo[roomId].add(new WinData(nickname, 0));
    }

    public void cleanWinData(int roomId) {
        friendWinInfo[roomId].clear();
    }

    public String returnWinData(int roomId) {
        String result = "";
        WinData winData1 = friendWinInfo[roomId].get(0);
        WinData winData2 = friendWinInfo[roomId].get(1);

        String nick1 = winData1.getNickname();
        int score1 = winData1.getWin();
        String nick2 = winData2.getNickname();
        int score2 = winData2.getWin();

        result += nick1 + ":" + Integer.toString(score1) + " " + nick2 + ":" + Integer.toString(
                score2);

        return result;
    }

    // 게임 끝내기
    public void stopGame(int roomId) {

        log.info("친구 대전을 종료합니다.");
        giClear(roomId);
        savingReset(roomId);
        cleanWinData(roomId);
        cleanList(roomId);
        friendUseRoom[roomId] = false;
    }

    // 이 AT를 가지고 있어야 기기에서 다른 기기에 알림을 보낼 수 있음
    private String getFirebaseAccessToken() throws IOException {
        String firebaseConfigPath = "/service_key.json";
        GoogleCredentials googleCredentials = GoogleCredentials.fromStream(new ClassPathResource(firebaseConfigPath).getInputStream())
                .createScoped("https://www.googleapis.com/auth/cloud-platform");

        googleCredentials.refreshIfExpired();
        return googleCredentials.getAccessToken().getTokenValue();
    }

    // 유저1, 유저2의 친구 엔티티에 승 패 추가해주기
    @Transactional
    public String updateRecord(int roomId, String winner){
        String nick1 = logs[roomId].get(0).getNickname();
        String nick2 = logs[roomId].get(1).getNickname();

        Member user1 = memberInfoRepository.findMemberInfoByNicknameAndMember_QuitFlagIsFalse(nick1).orElse(null).getMember();
        Member user2 = memberInfoRepository.findMemberInfoByNicknameAndMember_QuitFlagIsFalse(nick2).orElse(null).getMember();

        Friend f1 = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(user1.getMemberId(), user2.getMemberId()).orElse(null);
        Friend f2 = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(user2.getMemberId(), user1.getMemberId()).orElse(null);

        String ret = "";

        if(nick1.equals(winner)){
            f1.updateWin();
            f2.updateLose();
            ret += f1.getWin() + ":" + f1.getLose() + ":" + f2.getWin() + ":" +f2.getLose();
        }else{
            f1.updateLose();
            f2.updateWin();
            ret += f2.getWin() + ":" + f2.getLose() + ":" + f1.getWin() + ":" +f1.getLose();
        }

        log.info("친구 대전 결과 업데이트 완료");
        return ret;
    }


    // 로그 업데이트 하기
    // 유저1, 유저2 에대한 로그들을 모두 추가하기
    @Transactional
    public void updateLog(int roomId, String winner){
        LogData logData1 = logs[roomId].get(0);
        LogData logData2 = logs[roomId].get(1);

        String log1 = logData1.getLog();
        String log2 = logData2.getLog();

        String nick1 = logData1.getNickname();
        String nick2 = logData2.getNickname();

        Member user1 = memberInfoRepository.findMemberInfoByNicknameAndMember_QuitFlagIsFalse(nick1).orElse(null).getMember();
        Member user2 = memberInfoRepository.findMemberInfoByNicknameAndMember_QuitFlagIsFalse(nick2).orElse(null).getMember();

        PlayLog playLog1 = new PlayLog();
        playLog1.setMyUUID(user1);
        playLog1.setOpponentUUID(user2);
        playLog1.setMyPlay(log1);
        playLog1.setOpponentPlay(log2);

        PlayLog playLog2 = new PlayLog();
        playLog2.setMyUUID(user2);
        playLog2.setOpponentUUID(user1);
        playLog2.setMyPlay(log2);
        playLog2.setOpponentPlay(log1);

        if(nick1.equals(winner)){
            playLog1.setPlayResult(true);
            playLog2.setPlayResult(false);
        }else{
            playLog1.setPlayResult(false);
            playLog2.setPlayResult(true);
        }

        logUpdateRepository.save(playLog1);
        logUpdateRepository.save(playLog2);

        log.info("친구 대전 로그 저장 완료");
    }

    // 친구가 대전에 참석하게 되면 시작하게 되는 함수
    public FriendConnectGameResponseDto getUserInfo(int roomId){

        String nick1 = friendWinInfo[roomId].get(0).getNickname();
        String nick2 = friendWinInfo[roomId].get(1).getNickname();

        Member user1 = memberInfoRepository.findMemberInfoByNicknameAndMember_QuitFlagIsFalse(nick1).orElse(null).getMember();
        Member user2 = memberInfoRepository.findMemberInfoByNicknameAndMember_QuitFlagIsFalse(nick2).orElse(null).getMember();

        Friend friend = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(user1.getMemberId(), user2.getMemberId()).orElse(null);

        FriendConnectGameResponseDto response = FriendConnectGameResponseDto.builder()
                .nickname1(nick1)
                .user1Win(friend.getWin())
                .user1Lose(friend.getLose())
                .nickname2(nick2)
                .user2Win(friend.getLose())
                .user2Lose(friend.getWin())
                .build();

        logs[roomId].add(new LogData(nick1, "")); //첫 시작은 아무것도 없게 해야하니 "" 를 넣어준다.
        logs[roomId].add(new LogData(nick2, "")); //첫 시작은 아무것도 없게 해야하니 "" 를 넣어준다.

        log.info("친구 대전 시작");

        return response;
    }
}
