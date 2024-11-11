package a102.PickingParking.dto;

import a102.PickingParking.entity.PointSource;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PointRequestDto {
    private String userId;
    private int point_price;
    private PointSource point_source;

    public PointRequestDto(String userId, int point_price, PointSource point_source) {
        this.userId = userId;
        this.point_price = point_price;
        this.point_source = point_source;
    }

}
