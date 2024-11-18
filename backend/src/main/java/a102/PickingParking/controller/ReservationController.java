package a102.PickingParking.controller;

import a102.PickingParking.dto.ReservationRequest;
import a102.PickingParking.service.ReservationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/reservation")
@Tag(name = "예약 API", description = "예약 관련 API")
public class ReservationController {

    private final ReservationService reservationService;

    @Autowired
    public ReservationController(ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    // 예약 API
    @PostMapping()
    @Operation(summary = "예약 등록")
    public ResponseEntity<String> reserveTime(@RequestParam Integer zoneSeq,
                                              @RequestBody ReservationRequest request,
                                              @RequestParam String userId) {
        reservationService.createReservation(zoneSeq, request, userId);
        return ResponseEntity.ok("예약 완료");
    }
}
