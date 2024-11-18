package a102.PickingParking.service;


import a102.PickingParking.dto.VehicleValidationResponse;
import a102.PickingParking.entity.Reservation;
import a102.PickingParking.repository.ReservationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class VehicleValidationService {

    private final ReservationRepository reservationRepository;

    @Autowired
    public VehicleValidationService(ReservationRepository reservationRepository) {
        this.reservationRepository = reservationRepository;
    }

    public VehicleValidationResponse validateVehicle(String licensePlate) {
        Optional<Reservation> reservation = reservationRepository.findByCarPlate(licensePlate);

        VehicleValidationResponse response = new VehicleValidationResponse();
        response.setLicensePlate(licensePlate);
        response.setIsMatched(reservation.isPresent());

        return response;
    }
}
