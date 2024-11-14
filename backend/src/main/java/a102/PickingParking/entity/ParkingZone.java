package a102.PickingParking.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Entity
@Table(name = "parking_zone")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class ParkingZone {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "INT UNSIGNED", name = "zone_seq")
    private Integer seq;

    @Column(nullable = false, unique = true, length = 100)
    private String location;

    @Column(nullable = false, precision = 10, scale = 6, name = "location_x")
    private BigDecimal latitude;
    @Column(nullable = false, precision = 10, scale = 6, name = "location_y")
    private BigDecimal longitude;

    @Column(nullable = false)
    private Integer price;

    @Column(name = "zone_status")
    @Enumerated(EnumType.STRING)
    private ZoneStatus status; // R, B, Y

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(columnDefinition  = "INT UNSIGNED", name = "user_seq")
    private User user;

    @Column(nullable = false, unique = true, length = 20, name = "prk_cmpr")
    private String prkCmpr;
}
