package a102.PickingParking.controller;

import a102.PickingParking.dto.UserSignupRequestDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
//import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
//import yeomeong.common.dto.member.MemberSaveRequestDto;
//import yeomeong.common.service.MemberService;

@RestController
@Slf4j
@Tag(name = "인증/인가 API", description = "인증/인가 관련 API")
public class AuthController {


//    public AuthController(MemberService memberService, JwtService jwtService) {
//        this.memberService = memberService;
//        this.jwtService = jwtService;
//    }


    @PostMapping("/signup")
    public ResponseEntity<Void> signup(
            @RequestPart(required = false) MultipartFile picture,
            @RequestBody UserSignupRequestDto requestDto) {
        return ResponseEntity.status(HttpStatus.OK).build();
    }

//    @Operation(summary = "회원 로그인", description = "인증을 요청합니다.")
//    @PostMapping("/login")
//    public ResponseEntity<Void> fakeLogin(@RequestBody LoginRequestDto loginRequestDto) {
//        return ResponseEntity.status(HttpStatus.OK).build();
//    }

//    @Operation(summary = "회원 로그아웃", description = "로그아웃을 합니다.")
//    @PostMapping("/logout")
//    public ResponseEntity<Void> fakeLogout(@RequestHeader("Authorization") String accessToken) {
//        return ResponseEntity.status(HttpStatus.OK).build();
//    }


}
