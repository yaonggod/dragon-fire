package com.dragong.dragong.domain.playLog.service;

import com.dragong.dragong.domain.playLog.dto.GetMyPlayListRequestDto;
import com.dragong.dragong.domain.playLog.dto.GetMyPlayListResponseDto;
import java.util.List;

public interface PlayLogService {

    List<GetMyPlayListResponseDto> getMyPlayList(GetMyPlayListRequestDto getMyPlayListRequestDto);

}
