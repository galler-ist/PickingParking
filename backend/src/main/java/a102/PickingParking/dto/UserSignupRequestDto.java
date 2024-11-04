package a102.PickingParking.dto;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserSignupRequestDto {
    private String user_id;
    private String user_pw;
    private String user_phone;
}