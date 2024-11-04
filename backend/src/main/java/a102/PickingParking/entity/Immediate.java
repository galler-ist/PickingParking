package a102.PickingParking.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class Immediate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name= "immediate_seq")
    private int seq;

    @Column(name = "start_time")
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;


    // 이제 주차장 , 결제, 이용자 seq 넣어야하는데,
    // 관계 아직 몰라~~~~~~~~~~

    @ManyToOne()
    @JoinColumn(name = "zone_seq")
    private ParkingZone zone;

    @OneToOne
    @JoinColumn(name = "payment_seq")
    private Payment payment;


    @ManyToOne()
    @JoinColumn(name = "user_seq")
    private User user;

    @Column(name= "immediate_status")
    @Enumerated(EnumType.STRING)
    private ImmediateStatus status; // REFUND, ONGOING, FINISH



}
