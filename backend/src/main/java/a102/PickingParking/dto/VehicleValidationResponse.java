package a102.PickingParking.dto;


import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VehicleValidationResponse {
    private Boolean isMatched;
    private String licensePlate;
}
