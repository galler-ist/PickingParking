package a102.PickingParking.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PointRequestDto {
    private String userId;
    private int point_price;
    private String point_source;

    public PointRequestDto(String userId, int point_price, String point_source) {
        this.userId = userId;
        this.point_price = point_price;
        this.point_source = point_source;
    }

}
