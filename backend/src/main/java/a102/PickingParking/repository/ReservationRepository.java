package a102.PickingParking.repository;

import a102.PickingParking.entity.AvailableTime;
import a102.PickingParking.entity.ParkingZone;
import a102.PickingParking.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Integer> {
    List<Reservation> findByZone(ParkingZone zone);

}
