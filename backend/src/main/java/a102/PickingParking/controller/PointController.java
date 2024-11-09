package a102.PickingParking.controller;

import a102.PickingParking.service.PointService;
import a102.PickingParking.service.UserService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/point")
@Tag(name = "포인트 API", description = "포인트 관련 API")
public class PointController {

    private final PointService pointService;

    public PointController(PointService pointService) {
        this.pointService = pointService;
    }

    @PostMapping("{userId}")
    public ResponseEntity<Integer> getPoints(@PathVariable String userId) {
        try {
            int currentPoints = pointService.getCurrentPoints(userId);
            return ResponseEntity.ok(currentPoints);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
        }
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