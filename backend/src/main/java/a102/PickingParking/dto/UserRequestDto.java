package a102.PickingParking.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserRequestDto {
    private String userId;
    private String user_pw;
    private String user_phone;

    public UserRequestDto(String userId, String user_pw, String user_phone) {
        this.userId = userId;
        this.user_pw = user_pw;
        this.user_phone = user_phone;
    }
}