package a102.PickingParking.repository;

import a102.PickingParking.entity.ParkingZone;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.Optional;

@Repository
public interface ParkingZoneRepository extends JpaRepository<ParkingZone, Integer> {
    // 주차장 이름으로 주차장 조회
    Optional<ParkingZone> findByPrkCmpr(String prk_cmpr);

    @Modifying
    @Query("UPDATE ParkingZone p SET p.status = 'Y' " +
            "WHERE p.status = 'B' " +
            "AND EXISTS (" +
            "   SELECT 1 FROM Reservation r " +
            "   WHERE r.zone.seq = p.seq " + // zone을 통해 zoneSeq에 접근
            "    AND r.startTime = :oneHourLater" +
            ")")
    void updateZoneStatusBeforeReservation(LocalDateTime oneHourLater);

    @Modifying
    @Query("UPDATE ParkingZone p SET p.status = 'R' " +
            "WHERE p.status = 'Y' " +
            "AND EXISTS (" +
            "   SELECT 1 FROM Reservation r " +
            "   WHERE r.zone.seq = p.seq " +
            "    AND CURRENT_TIMESTAMP BETWEEN r.startTime AND r.endTime" +
            ")")
    void updateZoneStatusDuringReservation();
}
