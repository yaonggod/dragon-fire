package com.dragong.dragong.domain.playResult.Controller;

import com.dragong.dragong.domain.playResult.dto.GetMyRankRequestDto;
import com.dragong.dragong.domain.playResult.dto.GetNicknameRequestDto;
import com.dragong.dragong.domain.playResult.dto.GetRankRequestDto;
import com.dragong.dragong.domain.playResult.service.PlayResultService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/rank")
public class PlayResultController {

    @Autowired
    PlayResultService playResultService;

    @GetMapping
    public ResponseEntity<?> getRank() {
        List<GetRankRequestDto> getRankRequestDto = playResultService.getRank();
        return new ResponseEntity<>(getRankRequestDto, HttpStatus.OK);
    }

    @GetMapping("/my")
    public ResponseEntity<?> getMyRank(@RequestHeader("Authorization") String accessToken) {
        // accessToken으로 내 UUID를 가져오는 코드는 service에서
        GetMyRankRequestDto getMyRankRequestDto = playResultService.getMyRank(accessToken);
        return new ResponseEntity<>(getMyRankRequestDto, HttpStatus.OK);
    }

    @GetMapping("/nickname")
    public ResponseEntity<?> getNicknameRank(@RequestParam("nickname") String memberName) {
        GetNicknameRequestDto getNicknameRequestDto = new GetNicknameRequestDto(memberName);
        return new ResponseEntity<>(playResultService.getNicknameRank(getNicknameRequestDto), HttpStatus.OK);
    }

}
