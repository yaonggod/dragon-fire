package com.dragong.dragong.member.service;

import com.dragong.dragong.global.util.JwtUtil;
import com.dragong.dragong.member.dto.request.RegistRequestDto;
import com.dragong.dragong.member.dto.request.LoginRequestDto;
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


    @Override
    @Transactional
    public void login(LoginRequestDto loginRequestDto, HttpServletResponse httpServletResponse) {

        //구글 로그인 여부 확인
        if (loginRequestDto.getSocialType() == SocialType.GOOGLE) {

            // access_token의 구글로부터 유저 이메일 요청
            String email = googleService.getGoogleEmailInfo(
                    loginRequestDto.getAccessToken());

            // DB에서 구글 이메일 조회
            GoogleAuth googleAuth = googleAuthRepository.findByEmail(email)
                    .orElseThrow(() -> new NoSuchElementException()); // 회원이 아닌 경우 예외처리

            // 회원인 경우
            // jwt 발급
            String accessToken = jwtUtil.generateAccessToken(googleAuth.getMemberId(),
                    googleAuth.getMember()
                            .getRole());
            String refreshToken = jwtUtil.generateRefreshToken();

            // 기존 회원정보 불러오기
            Member member = googleAuth.getMember();
            RefreshToken refreshTokenEntity = member.getRefreshToken();

            // 이미 리프레시 토큰이 db에 있는 경우 (but 만료된 경우)
            if(refreshTokenEntity != null){

                // db에 refreshToken update
                refreshTokenEntity.updateRefreshToken(refreshToken);

            // 첫 로그인 (리프레시 토큰을 저장했던 적이 없는 경우)
            }else {

                // db에 refreshToken 저장
                RefreshToken newRefreshTokenEntity = RefreshToken.builder()
                        .member(member)
                        .refreshToken(refreshToken)
                        .build();

                member.addRefreshToken(newRefreshTokenEntity);
                refreshTokenRepository.save(newRefreshTokenEntity);
            }

            httpServletResponse.setHeader("Authorization", "Bearer " + accessToken);
            httpServletResponse.setHeader("refreshToken", "Bearer " + refreshToken);

            // 네이버
        } else {
            String accessToken = "123";
            String refreshToken = "123";

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

            member.addMemberInfo(memberInfo);
            member.addGoogleAuth(googleAuth);
            memberInfoRepository.save(memberInfo);
            googleAuthRepository.save(googleAuth);

            // memberInfo 저장시 member 또한 저장됨
            // memberRepository.save(member);
        }
    }

}
