package com.dragong.dragong.domain.game.service;

import com.dragong.dragong.domain.game.dto.GameRoomData;
import com.dragong.dragong.domain.game.dto.GiData;
import com.dragong.dragong.domain.game.dto.TokenData;
import com.dragong.dragong.domain.game.dto.WinData;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@Slf4j
public class GameService {
    private final Set<GameRoomData> gameRoom[] = new HashSet[100000]; //
    private final ArrayList<GiData> giDataRoom[] = new ArrayList[100000]; // 기 정보를 저장하기 위해서
    private final ArrayList<String> countDownandstartGame[] = new ArrayList[100000]; //54321
    private final Queue<TokenData> accessTokenRoom[] = new LinkedList[100000]; // accessToken을 저장하기 위해서
    private final Queue<Integer> user = new LinkedList<>(); // 입장하는 사람 정보
    private final int[] saving = new int[1000000];
    private int total = 0;
    private boolean visited[] = new boolean[2000000]; // 각 사용자가 들어올 떄마다 visited를 true로
    private final int[] whoisIn = new int[1000000];

    private final ArrayList<WinData> winInfo[] = new ArrayList[100000]; // 각 게임에서 승자 정보를 저장하기 위해서!

    @PostConstruct
    public void initializeGameRoom() {
        // 처음 한번 초기화를 해준다.
        for (int i = 0; i < gameRoom.length; i++) {
            gameRoom[i] = new HashSet<>();
            giDataRoom[i] = new ArrayList<>();
            countDownandstartGame[i] = new ArrayList<>();
            accessTokenRoom[i] = new LinkedList<>();
            winInfo[i] = new ArrayList<>();
            whoisIn[i] = 1;
        }
    }

    public void accessTokenUpdate(int roomId, String accessToken, String nickname) {
        // 처음 대기화면에서 방 배정을 받을 때 accessToken 값을 넣어준다.
        log.info(nickname + "이 nickname과 accessToken 값을 넣어줍니다.");
        TokenData tokenData = new TokenData(accessToken, nickname);
        log.info(tokenData.getAccessToken());
        log.info(tokenData.getNickname());
        accessTokenRoom[roomId].add(tokenData);
        log.info("현재 accessToken의 사이즈는?" + accessTokenRoom[roomId].size());
    }

    public void whoIn(int roomId, int nowNumber) {
        // 해당 방에 누가 들어있는지 계속 업데이트
        whoisIn[roomId] = nowNumber;
    }

    public int whoisInThere(int roomId) {
        // 지금 방에 혼자 있는게 누구인가!
        return whoisIn[roomId];
    }

    public void deleteAccessToken(int roomId) {
        log.info(roomId + "의 accessToken값을 초기화합니다");
        accessTokenRoom[roomId].clear();
    }

    public String winnerAndLoserToken(int roomId, String nickname) {
        // 승자의 nickname을 받아서 승자와 패자의 accessToken을 반환한다.
        TokenData tokenData1 = accessTokenRoom[roomId].poll();
        TokenData tokenData2 = accessTokenRoom[roomId].poll();

        if (tokenData1.getNickname().equals(nickname)) {
            // tokenData1이 승자의 nickname과 일치할 경우
            log.info("결과 업데이트를 위해 값을 반환합니다");
            log.info(tokenData1.getAccessToken() + ":" + tokenData2.getAccessToken());
            return tokenData1.getAccessToken() + ":" + tokenData2.getAccessToken();
        } else {
            //tokenData2가 승자의 nickname과 일치할 경우
            log.info("결과 업데이트를 위해 값을 반환합니다");
            log.info(tokenData2.getAccessToken() + ":" + tokenData1.getAccessToken());
            return tokenData2.getAccessToken() + ":" + tokenData1.getAccessToken();
        }
    }

    public int enter() {
        // 한 명 들어올 때마다 Queue에 넣어준다.
        // 그리고 한 명을 넣은 순간! 몇 명이 남아 있는지 확인해준다.
        // 처음 들어오자마자 하는 행위다. => visietd를 해줘야지?
        log.info("방에 입장합니다");
        total += 1;
        if (visited[total]) {
            // 이미 차지하고 있다면?
            while (visited[total]) {
                total += 1;
            }
            visited[total]=true;
        } else {
            // 빈 곳이라면?
            visited[total] = true;
        }

        user.add(total);
        log.info("Queue에 들어있는 사람의 수는 :" + user.size());
        return total;
    }

    public void gameStart() {
        // 게임을 시작하면 queue에서 2명을 빼준다.
        log.info("게임을 시작합니다 따라서 Queue에서 2명을 빼줍니다");
        user.poll();
        user.poll();

    }

    public void gameStop(int whoamI) {
        // 혼자 일 때 나가는 경우 => 2명이 나가는 경우는 생각하지 않는 이유가 2명이면 게임이 시작하니까
        log.info("한 명만 있는데 방을 나갑니다!.");
        user.poll();
        visited[whoamI] = false;
        total -= 1;
    }

    public void gameStopTemp() {
        log.info("에러가 발생한 경우의 방 해제");
        user.poll();

    }

    public void initWinData(int roomId, String nickname) {
        winInfo[roomId].add(new WinData(nickname, 0));
    }

    public void cleanWinData(int roomId) {
        winInfo[roomId].clear();
    }

    public String returnWinData(int roomId) {
        String result = "";
        WinData winData1 = winInfo[roomId].get(0);
        WinData winData2 = winInfo[roomId].get(1);

        String nick1 = winData1.getNickname();
        int score1 = winData1.getWin();
        String nick2 = winData2.getNickname();
        int score2 = winData2.getWin();

        result += nick1 + ":" + Integer.toString(score1) + " " + nick2 + ":" + Integer.toString(score2);

        return result;
    }

    public int giInit(int roomId, String nickname) {
        // 기 정보를 처음으로 초기화 해주고 넣어준다.
        log.info("기 정보를 초기화해줍니다");
        GiData giData = new GiData(nickname, 0);
        giDataRoom[roomId].add(giData);

        return giDataRoom[roomId].size();
    }

    public int giCnt(int roomId) {
        //그냥 현재 기 정보가 몇개 담겨 있는지 반환
        return giDataRoom[roomId].size();
    }

    public void giClear(int roomId) {
        log.info("현재 giDataRoom[roomId]에 있는 자료의 수는 : " + giDataRoom[roomId]);
        log.info("해당 데이터를 지웁니다");
        giDataRoom[roomId].clear();
    }


    public String giReturn(int roomId) {
        String answer = "";
        for (int i = 0; i < 2; i++) {
            GiData giData = giDataRoom[roomId].get(i);
            String player = giData.getNickname();

            String giCnt = Integer.toString(giData.getGi());
            answer += player + " " + giCnt + " ";
        }
        log.info("각각의 플레이어가 가지고 있는 기 정보를 반환합니다" + answer);
        return answer;
    }

    public void giReset(int roomId) {
        GiData gi1 = giDataRoom[roomId].get(0);
        GiData gi2 = giDataRoom[roomId].get(1);

        String nick1 = gi1.getNickname();
        String nick2 = gi2.getNickname();
        giDataRoom[roomId].set(0, new GiData(nick1, 0));
        giDataRoom[roomId].set(1, new GiData(nick2, 0));
    }

    public void gameStack(int roomId, String nickname, String picked) {
        //게임 결과를 하나씩 넣어주는 느낌
        log.info("각각의 플레이어가 선택한 값을 넣어줍니다");
        GameRoomData gameRoomData = new GameRoomData(nickname, picked);

        Map<String, GameRoomData> gameRoomMap = new HashMap<>();
        for (GameRoomData data : gameRoom[roomId]) {
            gameRoomMap.put(data.getNickname(), data);
        }
        gameRoomMap.put(nickname, gameRoomData);
        gameRoom[roomId].clear();
        gameRoom[roomId].addAll(gameRoomMap.values());

//        gameRoom[Integer.parseInt(roomId)].add(gameRoomData);
        System.out.println(gameRoom[roomId].size());
        //들어오는 값들을 확인하고
    }


    public void messageInsert(int roomId, String nickname) {
        // 양쪽에서 메시지 전달을 받았는지 확인하기 위한 용도
        log.info("양측에서 메시지를 보냈는지 확인하기 위해 nickname을 넣어줍니다");
        countDownandstartGame[roomId].add(nickname);
    }

    public String returnName(int roomId) {
        return countDownandstartGame[roomId].get(0);
    }

    public int evenReturn(int roomId) {
        // 들어있는 값이 짝수일 때 0을 return 한다는 것을 기억
        int answer = countDownandstartGame[roomId].size();
        return answer;
    }

    public void cleanList(int roomId) {
        countDownandstartGame[roomId].clear();
    }

    public void aliveCheck(int roomId) {
        // 들어있는 값이 짝수일 때 0을 return 한다는 것을 기억
        saving[roomId] += 1;
//        return saving[Integer.parseInt(roomId)];

    }

    public int savingReturn(int roomId) {
        return saving[roomId];
    }

    public void savingReset(int roomId) {
        saving[roomId] = 0;
    }


    public String gameResult(int roomId) {
        log.info("게임 결과를 확인합니다");
        //넣어준 gameStack에서 결과를 도출해내고 그걸 반환하는 함수
        // 여기서 예외 처리를 해줘야 하는데, 4가지 경우가 있을 것이다.
        // 1. 둘 다 제대로 제출한 경우, 2. 둘 중 한 명만 제출한 경우(이게 2가지), 4. 둘 다 제출하지 않은 경우
        String answer = "";
        GameRoomData grd1 = null;
        GameRoomData grd2 = null;
        String winner = null;
        if (gameRoom[roomId].size() == 2) {
            //둘다 제대로 정보를 입력한 경우
            ArrayList<GameRoomData> list = new ArrayList<>(gameRoom[roomId]);
            gameRoom[roomId].clear();
            //grd1 = gameRoom[Integer.parseInt(roomId)].poll();
            //grd2 = gameRoom[Integer.parseInt(roomId)].poll();
            grd1 = list.get(0);
            grd2 = list.get(1);
        } else if (gameRoom[roomId].size() == 1) {
            // 한 명만 정보를 입력한 경우 // 이건 바로 게임 중단 시킨다.
            ArrayList<GameRoomData> list = new ArrayList<>(gameRoom[roomId]);
            gameRoom[roomId].clear();
            //grd1 = gameRoom[Integer.parseInt(roomId)].poll();
            grd1 = list.get(0);
//            if (grd1.getNickname().equals(countDownandstartGame[roomId].get(0))) {
//
//            } else {
//                answer += grd1.getNickname() + ":" + grd1.getPicked() + " " + countDownandstartGame[roomId].get(0) + ":" + "미처리" + " " + grd1.getNickname();
//                winner = grd1.getNickname();
//            }
            //
            answer += grd1.getNickname() + ":" + grd1.getPicked() + " " + countDownandstartGame[roomId].get(1) + ":" + "미처리" + " " + grd1.getNickname();
            winner = grd1.getNickname();
            if (winner != null) {
                System.out.println("이거실행");
                if (winInfo[roomId].get(0).getNickname().equals(winner)) {
                    // 만약에 첫번째 인간의 nickname과 승자의 nickname이 같다면?
                    int win = winInfo[roomId].get(0).getWin();
                    winInfo[roomId].get(0).setWin(win + 1);
                    if (win + 1 == 2) {
                        // 이제 게임이 끝나야 하는 상황이다
                        answer += " 끝냅니다";
                    } else {
                        // 게임이 계속 되어야 하는 상황이다
                        answer += " 계속합니다";
                    }
                } else {
                    int win = winInfo[roomId].get(1).getWin();
                    winInfo[roomId].get(1).setWin(win + 1);
                    if (win + 1 == 2) {
                        //이제 게임이 끝나야 하는 상황이다
                        answer += " 끝냅니다";
                    } else {
                        // 게임이 계속 되어야 하는 상황이다
                        answer += " 계속합니다";
                    }
                }
            } else {
                answer += " 안끝남";
            }

            return answer;

        } else if (gameRoom[roomId].size() == 0) {
            // 둘 다 정보를 입력하지 않은 경우
            answer = countDownandstartGame[roomId].get(0) + ":미처리" + " " + countDownandstartGame[roomId].get(1) + ":미처리" + " " + "무효입니다" + " 끝냅니다";
            return answer;
        }
        String player1 = grd1.getNickname();
        String picked1 = grd1.getPicked();
        String player2 = grd2.getNickname();
        String picked2 = grd2.getPicked();

        answer += player1 + ":" + picked1 + " " + player2 + ":" + picked2 + " ";
        String nick1 = giDataRoom[roomId].get(0).getNickname();
        int gi1 = giDataRoom[roomId].get(0).getGi(); // Arraylist안의 첫번째 사람의 기 개수
        String nick2 = giDataRoom[roomId].get(1).getNickname();// Arraylist안의 두번째 사람의 닉네임
        int gi2 = giDataRoom[roomId].get(1).getGi();// Arraylist안의 두번째 사람의 기 개수

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

        giDataRoom[roomId].set(0, giData1);
        giDataRoom[roomId].set(1, giData2);
        // 이제 여기서 winner의 승 1점을 올려야 한다.

        if (winner != null) {
            System.out.println("이거실행");
            if (winInfo[roomId].get(0).getNickname().equals(winner)) {
                // 만약에 첫번째 인간의 nickname과 승자의 nickname이 같다면?
                int win = winInfo[roomId].get(0).getWin();
                winInfo[roomId].get(0).setWin(win + 1);
                if (win + 1 == 2) {
                    // 이제 게임이 끝나야 하는 상황이다
                    answer += " 끝냅니다";
                } else {
                    // 게임이 계속 되어야 하는 상황이다
                    answer += " 계속합니다";
                }
            } else {
                int win = winInfo[roomId].get(1).getWin();
                winInfo[roomId].get(1).setWin(win + 1);
                if (win + 1 == 2) {
                    //이제 게임이 끝나야 하는 상황이다
                    answer += " 끝냅니다";
                } else {
                    // 게임이 계속 되어야 하는 상황이다
                    answer += " 계속합니다";
                }
            }
        } else {
            answer += " 안끝남";
        }

        return answer;

    }

}
