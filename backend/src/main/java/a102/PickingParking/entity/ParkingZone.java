package a102.PickingParking.entity;

import jakarta.persistence.*;
import lombok.Getter;

import java.math.BigDecimal;

@Entity
@Getter
public class ParkingZone {
    // 주차장 seq(zone_seq), 주차장 위치(location), 위도(location_x), 경도(location_y), 요금(price), 이용가능 여부(zone_status), 이용자 seq(user_seq), 주차장 구획 번호(prk_cmpr)

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name= "zone_seq")
    private int seq;

    private String location;

    @Column(precision = 10, scale = 6, name = "location_x")
    private BigDecimal latitude;
    @Column(precision = 10, scale = 6, name = "location_y")
    private BigDecimal longitude;

    private int price;

    @Column(name= "zone_status")
    @Enumerated(EnumType.STRING)
    private ZoneStatus status; // R, B, Y

    @ManyToOne()
    @JoinColumn(name = "user_seq")
    private User user;

    private String prk_cmpr;
}
