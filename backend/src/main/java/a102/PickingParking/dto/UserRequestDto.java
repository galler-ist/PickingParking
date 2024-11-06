package a102.PickingParking.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserRequestDto {
    private String user_id;
    private String user_pw;
    private String user_phone;

    public UserRequestDto(String user_id, String user_pw, String user_phone) {
        this.user_id = user_id;
        this.user_pw = user_pw;
        this.user_phone = user_phone;
    }
}