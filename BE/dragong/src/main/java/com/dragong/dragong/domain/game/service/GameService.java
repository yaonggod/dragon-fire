package com.dragong.dragong.domain.game.service;

import com.dragong.dragong.domain.game.dto.GameRoomData;
import com.dragong.dragong.domain.game.dto.GiData;
import com.dragong.dragong.domain.game.dto.TokenData;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
@Slf4j
public class GameService {
    private final Set<GameRoomData> gameRoom[] = new HashSet[100000]; //
    private final Map<String,String> gameRoom1[] = new HashMap[100000];
    private final ArrayList<GiData> giDataRoom[] = new ArrayList[100000]; // 기 정보를 저장하기 위해서
    private final ArrayList<String> countDownandstartGame[] = new ArrayList[100000]; //54321
    private final Queue<TokenData> accessTokenRoom[] = new LinkedList[100000]; // accessToken을 저장하기 위해서
    private final Queue<Integer> user = new LinkedList<>(); // 입장하는 사람 정보
    private final int[] saving= new int[1000000];
    private int total=0;

    @PostConstruct
    public void initializeGameRoom() {
        // 처음 한번 초기화를 해준다.
        for (int i = 0; i < gameRoom.length; i++) {
            gameRoom[i] = new HashSet<>();
            gameRoom1[i]= new HashMap<>();
            giDataRoom[i] = new ArrayList<>();
            countDownandstartGame[i] = new ArrayList<>();
            accessTokenRoom[i]= new LinkedList<>();
        }
    }

    public void accessTokenUpdate(int roomId,String accessToken,String nickname){
        // 처음 대기화면에서 방 배정을 받을 때 accessToken 값을 넣어준다.
        log.info(nickname+"이 nickname과 accessToken 값을 넣어줍니다.");
        TokenData tokenData = new TokenData(accessToken,nickname);
        log.info(tokenData.getAccessToken());
        log.info(tokenData.getNickname());
        accessTokenRoom[roomId].add(tokenData);
        log.info("현재 accessToken의 사이즈는?"+ accessTokenRoom[roomId].size());
    }


    public void deleteAccessToken(String roomId){
        log.info(roomId+"의 accessToken값을 초기화합니다");
        accessTokenRoom[Integer.parseInt(roomId)].clear();
    }
    public String winnerAndLoserToken(String roomId,String nickname){
        // 승자의 nickname을 받아서 승자와 패자의 accessToken을 반환한다.
        TokenData tokenData1 = accessTokenRoom[Integer.parseInt(roomId)].poll();
        TokenData tokenData2 = accessTokenRoom[Integer.parseInt(roomId)].poll();

        if(tokenData1.getNickname().equals(nickname)){
            // tokenData1이 승자의 nickname과 일치할 경우
            log.info("결과 업데이트를 위해 값을 반환합니다");
            log.info(tokenData1.getAccessToken()+":"+tokenData2.getAccessToken());
            return tokenData1.getAccessToken()+":"+tokenData2.getAccessToken();
        }else{
            //tokenData2가 승자의 nickname과 일치할 경우
            log.info("결과 업데이트를 위해 값을 반환합니다");
            log.info(tokenData2.getAccessToken()+":"+tokenData1.getAccessToken());
            return tokenData2.getAccessToken()+":"+tokenData1.getAccessToken();
        }
    }
    public int enter() {
        // 한 명 들어올 때마다 Queue에 넣어준다.
        // 그리고 한 명을 넣은 순간! 몇 명이 남아 있는지 확인해준다.
        log.info("방에 입장합니다");
        total+=1;
        user.add(total);
        log.info("Queue에 들어있는 사람의 수는 :"+ user.size());
        return total;
        //return user.peek();
    }

    public void gameStart(){
        // 게임을 시작하면 queue에서 2명을 빼준다.
        log.info("게임을 시작합니다 따라서 Queue에서 2명을 빼줍니다");
        user.poll();
        user.poll();

    }
    public void gameStop(){
        // 혼자 일 때 나가는 경우 => 2명이 나가는 경우는 생각하지 않는 이유가 2명이면 게임이 시작하니까
        log.info("한 명만 있는데 방을 나갑니다!.");
        user.poll();
        total-=1;
    }

    public int giInit(String roomId, String nickname) {
        // 기 정보를 처음으로 초기화 해주고 넣어준다.
        log.info("기 정보를 초기화해줍니다");
        GiData giData = new GiData(nickname, 0);
        giDataRoom[Integer.parseInt(roomId)].add(giData);

        return giDataRoom[Integer.parseInt(roomId)].size();
    }
    public int giCnt(String roomId){
        //그냥 현재 기 정보가 몇개 담겨 있는지 반환
        return giDataRoom[Integer.parseInt(roomId)].size();
    }

    public void giClear(String roomId){
        log.info("현재 giDataRoom[roomId]에 있는 자료의 수는 : "+ giDataRoom[Integer.parseInt(roomId)]);
        log.info("해당 데이터를 지웁니다");
        giDataRoom[Integer.parseInt(roomId)].clear();
    }


    public String giReturn(String roomId) {

        String answer = "";
        for (int i = 0; i < 2; i++) {
            GiData giData = giDataRoom[Integer.parseInt(roomId)].get(i);
            String player = giData.getNickname();
            String giCnt = Integer.toString(giData.getGi());
            answer += player + " " + giCnt + " ";
        }
        log.info("각각의 플레이어가 가지고 있는 기 정보를 반환합니다" + answer);
        return answer;
    }


    public void gameStack(String roomId, String nickname, String picked) {
        //게임 결과를 하나씩 넣어주는 느낌
        log.info("각각의 플레이어가 선택한 값을 넣어줍니다");
        GameRoomData gameRoomData = new GameRoomData(nickname, picked);

        Map<String, GameRoomData> gameRoomMap = new HashMap<>();
        for (GameRoomData data : gameRoom[Integer.parseInt(roomId)]) {
            gameRoomMap.put(data.getNickname(), data);
        }
        gameRoomMap.put(nickname, gameRoomData);
        gameRoom[Integer.parseInt(roomId)].clear();
        gameRoom[Integer.parseInt(roomId)].addAll(gameRoomMap.values());

//        gameRoom[Integer.parseInt(roomId)].add(gameRoomData);
        System.out.println(gameRoom[Integer.parseInt(roomId)].size());
        //들어오는 값들을 확인하고
    }


    public void messageInsert(String roomId, String nickname) {
        // 양쪽에서 메시지 전달을 받았는지 확인하기 위한 용도
        log.info("양측에서 메시지를 보냈는지 확인하기 위해 nickname을 넣어줍니다");
        countDownandstartGame[Integer.parseInt(roomId)].add(nickname);
    }

    public String returnName(String roomId) {
        return countDownandstartGame[Integer.parseInt(roomId)].get(0);
    }

    public int evenReturn(String roomId) {
        // 들어있는 값이 짝수일 때 0을 return 한다는 것을 기억
        int answer = countDownandstartGame[Integer.parseInt(roomId)].size();
        return answer;
    }

    public void aliveCheck(String roomId) {
        // 들어있는 값이 짝수일 때 0을 return 한다는 것을 기억
        saving[Integer.parseInt(roomId)]+=1;
//        return saving[Integer.parseInt(roomId)];

    }
    public int savingReturn(String roomId){
        return saving[Integer.parseInt(roomId)];
    }
    public void savingReset(String roomId){
        saving[Integer.parseInt(roomId)]=0;
    }

    public void cleanList(String roomId) {
        countDownandstartGame[Integer.parseInt(roomId)].clear();
    }

    public String gameResult(String roomId) {
        log.info("게임 결과를 확인합니다");
        //넣어준 gameStack에서 결과를 도출해내고 그걸 반환하는 함수
        // 여기서 예외 처리를 해줘야 하는데, 4가지 경우가 있을 것이다.
        // 1. 둘 다 제대로 제출한 경우, 2. 둘 중 한 명만 제출한 경우(이게 2가지), 4. 둘 다 제출하지 않은 경우
        String answer = "";
        GameRoomData grd1 = null;
        GameRoomData grd2 = null;
        if (gameRoom[Integer.parseInt(roomId)].size() == 2) {
            //둘다 제대로 정보를 입력한 경우
            ArrayList<GameRoomData> list = new ArrayList<>(gameRoom[Integer.parseInt(roomId)]);
            gameRoom[Integer.parseInt(roomId)].clear();
            //grd1 = gameRoom[Integer.parseInt(roomId)].poll();
            //grd2 = gameRoom[Integer.parseInt(roomId)].poll();
            grd1 = list.get(0);
            grd2= list.get(1);
        } else if (gameRoom[Integer.parseInt(roomId)].size() == 1) {
            // 한 명만 정보를 입력한 경우
            ArrayList<GameRoomData> list = new ArrayList<>(gameRoom[Integer.parseInt(roomId)]);
            gameRoom[Integer.parseInt(roomId)].clear();
            //grd1 = gameRoom[Integer.parseInt(roomId)].poll();
            grd1 = list.get(0);
            if (grd1.getNickname().equals(countDownandstartGame[Integer.parseInt(roomId)].get(0))) {
                answer += grd1.getNickname() + ":" + grd1.getPicked() + " " + countDownandstartGame[Integer.parseInt(roomId)].get(1) + ":" + "미처리" + " " + grd1.getNickname();
            } else {
                answer += grd1.getNickname() + ":" + grd1.getPicked() + " " + countDownandstartGame[Integer.parseInt(roomId)].get(0) + ":" + "미처리" + " " + grd1.getNickname();
            }

            return answer;

        } else if (gameRoom[Integer.parseInt(roomId)].size() == 0) {
            // 둘 다 정보를 입력하지 않은 경우
            answer = countDownandstartGame[Integer.parseInt(roomId)].get(0) + ":미처리" + " " + countDownandstartGame[Integer.parseInt(roomId)].get(1) + ":미처리" + " " + "무효입니다";
            return answer;
        }
        String player1 = grd1.getNickname();
        String picked1 = grd1.getPicked();
        String player2 = grd2.getNickname();
        String picked2 = grd2.getPicked();
        answer += player1 + ":" + picked1 + " " + player2 + ":" + picked2 + " ";
        String nick1 = giDataRoom[Integer.parseInt(roomId)].get(0).getNickname();
        int gi1 = giDataRoom[Integer.parseInt(roomId)].get(0).getGi(); // Arraylist안의 첫번째 사람의 기 개수
        String nick2 = giDataRoom[Integer.parseInt(roomId)].get(1).getNickname();// Arraylist안의 두번째 사람의 닉네임
        int gi2 = giDataRoom[Integer.parseInt(roomId)].get(1).getGi();// Arraylist안의 두번째 사람의 기 개수

        if (player1.equals(nick1)) {
            if (picked1.equals("기")) {
                gi1 += 1;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi2 -= 1;
                    answer += player2;
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi2 -= 3;
                    answer += player2;
                }
            } else if (picked1.equals("파")) {
                gi1 -= 1;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += player1;
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
                } else if (picked2.equals("파")) {
                    gi2 += 1;
                    answer += player1;
                } else if (picked2.equals("막기")) {
                    answer += player1;
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
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi1 -= 3;
                    answer += player2;
                }
            } else if (picked1.equals("파")) {
                gi2 -= 1;
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += player1;
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
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    answer += player1;
                } else if (picked2.equals("막기")) {
                    answer += player1;
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

        giDataRoom[Integer.parseInt(roomId)].set(0, giData1);
        giDataRoom[Integer.parseInt(roomId)].set(1, giData2);
        return answer;

    }

}
