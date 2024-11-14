package a102.PickingParking.controller;


import a102.PickingParking.dto.ParkingZoneResponse;
import a102.PickingParking.dto.PrkCmprDto;
import a102.PickingParking.entity.ParkingZone;
import a102.PickingParking.entity.User;
import a102.PickingParking.service.ParkingZoneService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@Tag(name = "주차장 API", description = "주차장 관련 API")
@RequestMapping("/api/zone")
public class ParkingZoneController {

    private final ParkingZoneService parkingZoneService;

    @Autowired
    public ParkingZoneController(ParkingZoneService parkingZoneService) {
        this.parkingZoneService = parkingZoneService;
    }

    // 주차장 주인 등록
    @PutMapping("/user/{userId}")
    public ResponseEntity<ParkingZoneResponse> registerParkingUser(@PathVariable String userId, @RequestBody PrkCmprDto prkCmprDto) {
        ParkingZoneResponse updatedZoneResponse = parkingZoneService.registerParkingUser(userId, prkCmprDto.getPrk_cmpr());
        return ResponseEntity.ok(updatedZoneResponse);
    }

    // 특정 주차장의 정보 조회
    @GetMapping("/{zoneSeq}")
    public ResponseEntity<ParkingZoneResponse> getUserByZoneId(@PathVariable Integer zoneSeq) {
        ParkingZoneResponse parkingZoneResponse = parkingZoneService.getParkingZoneBySeq(zoneSeq);
        return ResponseEntity.ok(parkingZoneResponse);
    }
}
