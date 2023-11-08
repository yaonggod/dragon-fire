package com.dragong.dragong.domain.member.service;

import com.dragong.dragong.domain.member.dto.request.FcmTokenRequestDto;
import com.dragong.dragong.domain.member.dto.request.LoginRequestDto;
import com.dragong.dragong.domain.member.dto.request.RegistRequestDto;
import com.dragong.dragong.domain.member.dto.request.UpdateRequestDto;
import com.dragong.dragong.domain.member.dto.response.LoginResponseDto;
import com.dragong.dragong.domain.member.dto.response.NicknameUpdateResponseDto;
import com.dragong.dragong.domain.member.entity.FcmToken;
import com.dragong.dragong.domain.member.entity.Member;
import com.dragong.dragong.domain.member.entity.MemberInfo;
import com.dragong.dragong.domain.member.entity.Role;
import com.dragong.dragong.domain.member.entity.SocialType;
import com.dragong.dragong.domain.member.entity.auth.GoogleAuth;
import com.dragong.dragong.domain.member.entity.auth.NaverAuth;
import com.dragong.dragong.domain.member.entity.auth.RefreshToken;
import com.dragong.dragong.domain.member.repository.FcmTokenRepository;
import com.dragong.dragong.domain.member.repository.GoogleAuthRepository;
import com.dragong.dragong.domain.member.repository.MemberInfoRepository;
import com.dragong.dragong.domain.member.repository.MemberRepository;
import com.dragong.dragong.domain.member.repository.NaverAuthRepository;
import com.dragong.dragong.domain.member.repository.RefreshTokenRepository;
import com.dragong.dragong.global.util.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.NoSuchElementException;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class MemberServiceImpl implements MemberService {

    private final JwtUtil jwtUtil;
    private final MemberRepository memberRepository;
    private final MemberInfoRepository memberInfoRepository;
    private final GoogleAuthRepository googleAuthRepository;
    private final NaverAuthRepository naverAuthRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final OAuthService oAuthService;
    private final FcmTokenRepository fcmTokenRepository;

    @Override
    @Transactional
    public LoginResponseDto login(LoginRequestDto loginRequestDto,
            HttpServletResponse httpServletResponse) {

        //구글 로그인 여부 확인
        if (loginRequestDto.getSocialType() == SocialType.GOOGLE) {

            // access_token의 구글로부터 유저 이메일 요청
            String email = oAuthService.getGoogleEmailInfo(
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
            if (refreshTokenEntity != null) {

                // db에 refreshToken update
                refreshTokenEntity.updateRefreshToken(refreshToken);

                // 첫 로그인 (리프레시 토큰을 저장했던 적이 없는 경우)
            } else {

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

            LoginResponseDto response = LoginResponseDto.builder()
                    .nickname(member.getMemberInfo().getNickname())
                    .build();

            log.info("Google 로그인 성공: " + email);

            return response;
        } else {
            // AccessToken으로 네이버에 요청해서 유저 이메일 받아오기
            String email = oAuthService.getNaverEmailInfo(loginRequestDto.getAccessToken());

            // DB에서 네이버 이메일 조회
            NaverAuth naverAuth = naverAuthRepository.findByEmail(email)
                    .orElseThrow(() -> new NoSuchElementException()); // 회원이 아닌 경우 예외처리

            // 회원인 경우
            // jwt 발급
            String accessToken = jwtUtil.generateAccessToken(naverAuth.getMemberId(),
                    naverAuth.getMember()
                            .getRole());
            String refreshToken = jwtUtil.generateRefreshToken();

            // 기존 회원정보 불러오기
            Member member = naverAuth.getMember();

            // 회원 정보로 과거 리프레시 토큰 내역 가져오기
            RefreshToken refreshTokenEntity = member.getRefreshToken();

            // 이미 리프레시 토큰이 db에 있는 경우 (but 만료된 경우)
            if (refreshTokenEntity != null) {

                // db에 refreshToken update
                refreshTokenEntity.updateRefreshToken(refreshToken);

                // 첫 로그인 (리프레시 토큰을 저장했던 적이 없는 경우)
            } else {

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

            LoginResponseDto response = LoginResponseDto.builder()
                    .nickname(member.getMemberInfo().getNickname())
                    .build();

            log.info("Naver 로그인 성공: " + email);

            return response;
        }

    }

    @Override
    @Transactional
    public void regist(RegistRequestDto registRequestDto, SocialType socialType,
            HttpServletResponse httpServletResponse) {
        if (socialType == SocialType.GOOGLE) {

            String email = oAuthService.getGoogleEmailInfo(
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

            log.info("회원가입 완료: " + "Google");
            log.info("  UUID: " + memberId);
            log.info("  이메일: " + email);
            log.info("  닉네임: " + registRequestDto.getNickname());
            // memberInfo 저장시 member 또한 저장됨
            // memberRepository.save(member);

            // 네이버로 회원가입했음
        } else {
            // AccessToken으로 네이버의 이메일을 가져와서
            String email = oAuthService.getNaverEmailInfo(
                    registRequestDto.getAccessToken());

            System.out.println(email);

            // 이미 회원가입을 한 회원인 경우
            if (naverAuthRepository.findByEmail(email).isPresent()) {
                throw new RuntimeException();
            }

            // 멤버를 생성하자
            UUID memberId = UUID.randomUUID();

            Member member = Member.builder()
                    .memberId(memberId)
                    .socialType(socialType)
                    .role(Role.USER)
                    .build();

            // 유저가 앱에서 직접 입력한 닉네임은 유저 엔티티랑 분리해서 저장
            MemberInfo memberInfo = MemberInfo.builder()
                    .member(member)
                    .nickname(registRequestDto.getNickname())
                    .build();

            // 이 사람은 네이버로 가입한 사람임을 저장
            NaverAuth naverAuth = NaverAuth.builder()
                    .member(member)
                    .email(email)
                    .build();

            // 멤버에 멤버 정보와 네이버 Auth 엔티티 저장
            member.addMemberInfo(memberInfo);
            member.addNaverAuth(naverAuth);

            // 멤버 정보와 네이버 Auth 엔티티 각각 저장
            memberInfoRepository.save(memberInfo);
            naverAuthRepository.save(naverAuth);

            log.info("회원가입 완료: " + "Naver");
            log.info("  UUID: " + memberId);
            log.info("  이메일: " + email);
            log.info("  닉네임: " + registRequestDto.getNickname());
            // memberInfo 저장시 member 또한 저장됨
            // memberRepository.save(member);
        }
    }

    @Override
    @Transactional
    public NicknameUpdateResponseDto update(UpdateRequestDto updateRequestDto, String accessToken, String refreshToken,
            HttpServletResponse httpServletResponse) {

        MemberInfo memberInfo = getMyMemberInfo(accessToken, refreshToken,
                httpServletResponse);

        memberInfo.updateNickname(updateRequestDto.getNickname());

        log.info("회원정보 수정 완료: ");
        log.info("  UUID: " + memberInfo.getMemberId());
        log.info("  닉네임: " + memberInfo.getNickname());

        NicknameUpdateResponseDto responseDto = NicknameUpdateResponseDto.builder()
                .nickname(memberInfo.getNickname()).build();

        return responseDto;
    }

    @Override
    @Transactional
    public void nicknameCheck(String nickname) {
        if (memberInfoRepository.existsByNicknameAndMember_QuitFlagIsFalse(nickname)) {
            throw new RuntimeException();
        }
    }

    @Override
    public void logout(String accessToken, String refreshToken,
            HttpServletResponse httpServletResponse) {

        UUID memberId = jwtUtil.extractMemberId(accessToken.substring(7));

        Member member = memberRepository.findMemberByMemberIdAndAndQuitFlagIsFalse(memberId)
                .orElseThrow(() -> new NoSuchElementException());

        RefreshToken refreshTokenEntity = member.getRefreshToken();

        refreshTokenEntity.updateRefreshToken(null);

        log.info("로그아웃 완료: ");
        log.info("  UUID: " + member.getMemberId());
    }

    @Override
    @Transactional
    public void delete(String accessToken, String refreshToken,
            HttpServletResponse httpServletResponse) {

        Member member = getMyMember(accessToken, refreshToken.substring(7),
                httpServletResponse);

        member.deleteMember();

        log.info("회원탈퇴 완료: ");
        log.info("  UUID: " + member.getMemberId());
    }

    @Override
    public MemberInfo getMyMemberInfo(String accessToken, String refreshToken,
            HttpServletResponse httpServletResponse) {

        UUID memberId = jwtUtil.extractMemberId(accessToken.substring(7));

        MemberInfo memberInfo = memberInfoRepository.findMemberInfoByMemberId(memberId)
                .orElseThrow(() -> new NoSuchElementException());

        return memberInfo;
    }

    @Override
    public Member getMyMember(String accessToken, String refreshToken,
            HttpServletResponse httpServletResponse) {

        UUID memberId = jwtUtil.extractMemberId(accessToken.substring(7));

        Member member = memberRepository.findMemberByMemberIdAndAndQuitFlagIsFalse(memberId)
                .orElseThrow(() -> new NoSuchElementException());

        return member;
    }

    @Override
    public void updateFcmToken(String accessToken, String refreshToken,
            FcmTokenRequestDto fcmTokenRequestDto) {

        // 토큰으로 멤버를 찾읍시다
        UUID memberId = jwtUtil.extractMemberId(accessToken.substring(7));
        Member member = memberRepository.findMemberByMemberIdAndAndQuitFlagIsFalse(memberId)
                .orElseThrow(() -> new NoSuchElementException());

        FcmToken fcmToken = member.getFcmToken();

        if (fcmToken == null) {
            // 없으면 새로 빌드해줍시다
            FcmToken newFcmToken = FcmToken.builder()
                    .fcmToken(fcmTokenRequestDto.getFcmToken())
                    .member(member)
                    .build();
            member.addFcmToken(newFcmToken);
            fcmTokenRepository.save(newFcmToken);
        } else {
            // 있으면 대조해보고~
            if (!fcmToken.getFcmToken().equals(fcmTokenRequestDto.getFcmToken())) {
                fcmToken.updateFcmToken(fcmTokenRequestDto.getFcmToken());
                fcmTokenRepository.save(fcmToken);
            }
        }

    }


}
