package a102.PickingParking.repository;

import a102.PickingParking.entity.AvailableTime;
import a102.PickingParking.entity.ParkingZone;
import a102.PickingParking.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Integer> {
    List<Reservation> findByZone(ParkingZone zone);
    @Query("SELECT r FROM Reservation r WHERE r.user.userId = :userId")
    List<Reservation> findByUserId(@Param("userId") String userId); // 사용자 ID로 예약 목록 조회

}
