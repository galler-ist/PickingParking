package a102.PickingParking.controller;

import a102.PickingParking.entity.User;
import a102.PickingParking.service.PointService;
import a102.PickingParking.service.UserService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/point")
@Tag(name = "포인트 API", description = "포인트 관련 API")
public class PointController {

    private final PointService pointService;
    private final UserService userService;

    public PointController(PointService pointService, UserService userService) {
        this.pointService = pointService;
        this.userService = userService;
    }

//    @PostMapping("/{userId}")
//    public ResponseEntity<Integer> getPoints(@PathVariable String userId) {
//        try {
//            int currentPoints = pointService.updateUserPoint(userId);
//            return ResponseEntity.ok(currentPoints);
//        } catch (IllegalArgumentException e) {
//            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
//        }
//    }

    @PostMapping("/{userId}")
    public ResponseEntity<Integer> getPoint(@PathVariable String userId) {
        User user = userService.getUserByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

        pointService.updateUserPoint(userId);

        return ResponseEntity.ok(user.getPoint());
    }
}

//@RestController
//@RequestMapping("/api/point")
//@Tag(name = "포인트 API", description = "포인트 관련 API")
//public class PointController {
//
//    private final PointService pointService;
//
//    public PointController(PointService pointService) {
//        this.pointService = pointService;
//    }
//
//    @PostMapping("/point")
//    public ResponseEntity<Integer> getPoints(@RequestParam String userId) {
//        try {
//            int currentPoints = pointService.getCurrentPoints(userId);
//            return ResponseEntity.ok(currentPoints);
//        } catch (IllegalArgumentException e) {
//            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
//        }
//    }
//}