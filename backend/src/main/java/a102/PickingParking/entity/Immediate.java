package a102.PickingParking.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class Immediate {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "INT UNSIGNED", name= "immediate_seq")
    private Integer seq;

    @Column(nullable = false, name = "start_time")
    private LocalDateTime startTime;

    @Column(nullable = false, name = "end_time")
    private LocalDateTime endTime;

    @OneToOne()
    @JoinColumn(columnDefinition  = "INT UNSIGNED", name = "payment_seq")
    private Payment payment;

    @ManyToOne(optional = false)
    @JoinColumn(nullable = false, columnDefinition  = "INT UNSIGNED", name = "user_seq")
    private User user;

    @ManyToOne(optional = false)
    @JoinColumn(nullable = false, columnDefinition  = "INT UNSIGNED", name = "zone_seq")
    private ParkingZone zone;

    @Column(name = "immediate_status")
    @Enumerated(EnumType.STRING)
    private ImmediateStatus status; // REFUND, ONGOING, FINISH
}