package a102.PickingParking.dto;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserSignupRequestDto {
    private String username;
    private String password;
    private String phoneNumber;
}