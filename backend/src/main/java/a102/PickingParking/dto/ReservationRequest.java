package a102.PickingParking.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
public class ReservationRequest {
    private LocalDateTime startTime;
    private LocalDateTime endTime;
}
