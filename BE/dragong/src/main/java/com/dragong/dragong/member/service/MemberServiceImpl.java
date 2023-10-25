package com.dragong.dragong.member.service;

import com.dragong.dragong.global.util.JwtUtil;
import com.dragong.dragong.member.dto.request.RegistRequestDto;
import com.dragong.dragong.member.dto.request.LoginRequestDto;
import com.dragong.dragong.member.dto.response.LoginResponseDto;
import com.dragong.dragong.member.entity.Member;
import com.dragong.dragong.member.entity.MemberInfo;
import com.dragong.dragong.member.entity.Role;
import com.dragong.dragong.member.entity.SocialType;
import com.dragong.dragong.member.entity.auth.GoogleAuth;
import com.dragong.dragong.member.entity.auth.RefreshToken;
import com.dragong.dragong.member.repository.GoogleAuthRepository;
import com.dragong.dragong.member.repository.MemberInfoRepository;
import com.dragong.dragong.member.repository.RefreshTokenRepository;
import jakarta.servlet.http.HttpServletResponse;
import java.util.NoSuchElementException;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MemberServiceImpl implements MemberService {

    private final JwtUtil jwtUtil;
    private final MemberInfoRepository memberInfoRepository;
    private final GoogleAuthRepository googleAuthRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final OAuthService googleService;

    // 이미 있는 유저인지 확인
    @Override
    @Transactional
    public LoginResponseDto checkMember(LoginRequestDto verifyMemberRequestDto,
            SocialType socialType, HttpServletResponse httpServletResponse) {
        if (socialType == SocialType.GOOGLE) {
            // access_token으로 구글로부터 유저 이메일을 불러옴
            String email = googleService.getGoogleEmailInfo(
                    verifyMemberRequestDto.getAccessToken());

            // DB에서 이메일 조회
            GoogleAuth googleAuth = googleAuthRepository.findByEmail(email)
                    .orElseThrow(() -> new NoSuchElementException());

            //jwt 발급
            String accessToken = jwtUtil.generateAccessToken(googleAuth.getMemberId(),
                    googleAuth.getMember()
                            .getRole());
            String refreshToken = jwtUtil.generateRefreshToken();

            LoginResponseDto loginResponseDto = LoginResponseDto.builder()
                    .accessToken(accessToken)
                    .refreshToken(refreshToken)
                    .build();

            Member member = googleAuth.getMember();

            RefreshToken refreshTokenEntity = RefreshToken.builder()
                    .member(member)
                    .refreshToken(refreshToken)
                    .build();

            member.addRefreshToken(refreshTokenEntity);
            refreshTokenRepository.save(refreshTokenEntity);

            // 헤더에 토큰 담기
            jwtUtil.setHeaderRefreshToken(httpServletResponse, loginResponseDto.getRefreshToken());
            jwtUtil.setHeaderAccessToken(httpServletResponse, loginResponseDto.getAccessToken());

            return loginResponseDto;

            // 네이버
        } else {
            String accessToken = "123";
            String refreshToken = "123";

            LoginResponseDto loginResponseDto = LoginResponseDto.builder()
                    .accessToken(accessToken)
                    .refreshToken(refreshToken)
                    .build();
            return loginResponseDto;
        }
    }

    @Override
    @Transactional
    public void regist(RegistRequestDto registRequestDto, SocialType socialType,
            HttpServletResponse httpServletResponse) {
        if (socialType == SocialType.GOOGLE) {

            String email = googleService.getGoogleEmailInfo(
                    registRequestDto.getAccessToken());

            // 이미 회원가입을 한 회원인 경우
            if (googleAuthRepository.findByEmail(email).isPresent()) {
                throw new RuntimeException();
            }

            UUID memberId = UUID.randomUUID();

            Member member = Member.builder()
                    .memberId(memberId)
                    .socialType(socialType)
                    .role(Role.USER)
                    .build();

            MemberInfo memberInfo = MemberInfo.builder()
                    .member(member)
                    .nickname(registRequestDto.getNickname())
                    .build();

            GoogleAuth googleAuth = GoogleAuth.builder()
                    .member(member)
                    .email(email)
                    .build();

            String accessToken = jwtUtil.generateAccessToken(memberId,
                    member.getRole());
            String refreshToken = jwtUtil.generateRefreshToken();

            RefreshToken refreshTokenEntity = RefreshToken.builder()
                    .member(member)
                    .refreshToken(refreshToken)
                    .build();

            member.addMemberInfo(memberInfo);
            member.addGoogleAuth(googleAuth);
            member.addRefreshToken(refreshTokenEntity);
            memberInfoRepository.save(memberInfo);
            googleAuthRepository.save(googleAuth);
            refreshTokenRepository.save(refreshTokenEntity);

            // memberInfo 저장시 member 또한 저장됨
            // memberRepository.save(member);

            // 헤더에 토큰 담기
            jwtUtil.setHeaderRefreshToken(httpServletResponse, accessToken);
            jwtUtil.setHeaderAccessToken(httpServletResponse, refreshToken);
        }
    }

}
