package a102.PickingParking.repository;

import a102.PickingParking.entity.ParkingZone;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ParkingZoneRepository extends JpaRepository<ParkingZone, Integer> {
    // 주차장 이름으로 주차장 조회
    Optional<ParkingZone> findByPrkCmpr(String prk_cmpr);
}
