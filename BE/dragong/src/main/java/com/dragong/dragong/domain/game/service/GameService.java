package com.dragong.dragong.domain.game.service;

import com.dragong.dragong.domain.game.dto.GameRoomData;
import com.dragong.dragong.domain.game.dto.GiData;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;

import java.sql.Array;
import java.util.*;

@Service
public class GameService {
    private final Set<GameRoomData> gameRoom[] = new HashSet[100000];
    private final ArrayList<GiData> giDataRoom[] = new ArrayList[100000];

    private final ArrayList<String> countDownandstartGame[] = new ArrayList[100000];

    private final Queue<Integer> user = new LinkedList<>();
    private int total=0;

    @PostConstruct
    public void initializeGameRoom() {
        for (int i = 0; i < gameRoom.length; i++) {
            gameRoom[i] = new HashSet<>();
            giDataRoom[i] = new ArrayList<>();
            countDownandstartGame[i] = new ArrayList<>();
        }
    }

    public int enter() {
        // 한 명 들어올 때마다 Queue에 넣어준다.
        // 그리고 한 명을 넣은 순간! 몇 명이 남아 있는지 확인해준다.
        System.out.println("현재 userQueue에 있는 사람의 수는: "+user.size());
        total+=1;
        user.add(total);
        return user.peek();
    }

    public void gameStart(){
        // 2 명을 빼준다
        user.poll();
        user.poll();

    }
    public void gameStop(){
        user.poll(); // 혼자 일 때 나가는 경우
        total-=1;
    }

    public int giInit(String roomId, String nickname) {
        // 기 정보를 처음으로 초기화 해주고 넣어준다.
        GiData giData = new GiData(nickname, 0);
        giDataRoom[Integer.parseInt(roomId)].add(giData);

        return giDataRoom[Integer.parseInt(roomId)].size();
    }
    public void giClear(String roomId){
        System.out.println("현재 giDataRoom[roomId]에 있는 자료의 수는: "+giDataRoom[Integer.parseInt(roomId)].size());
        System.out.println("이를 지웁니다");
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
        return answer;
    }


    public void gameStack(String roomId, String nickname, String picked) {
        //게임 결과를 하나씩 넣어주는 느낌
        GameRoomData gameRoomData = new GameRoomData(nickname, picked);
        gameRoom[Integer.parseInt(roomId)].add(gameRoomData);
        System.out.println(gameRoom[Integer.parseInt(roomId)].size());
        //들어오는 값들을 확인하고
    }

    public void messageInsert(String roomId, String nickname) {
        // 양쪽에서 메시지 전달을 받았는지 확인하기 위한 용도

        System.out.println("message를 넣습니다"+ nickname);
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

    public void cleanList(String roomId) {
        countDownandstartGame[Integer.parseInt(roomId)].clear();
    }

    public String gameResult(String roomId) {
        System.out.println("gameResult 확인!");
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
                    answer += player2;
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
                    answer += player2;
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
