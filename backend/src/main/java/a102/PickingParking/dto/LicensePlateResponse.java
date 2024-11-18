package a102.PickingParking.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.aspectj.bridge.Message;

@Getter
@Setter
public class LicensePlateResponse {
    @JsonProperty("result")
    private String licensePlate;

    @JsonProperty("zone_seq")
    private Integer zoneSeq;
}
