package a102.PickingParking.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.aspectj.bridge.Message;

@Getter
@Setter
public class LicensePlateResponse {
    private Message message;

    @Getter
    @Setter
    public static class Message {
        private Integer zone_seq;
        private String result;

    }
}