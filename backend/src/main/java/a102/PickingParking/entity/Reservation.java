package a102.PickingParking.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class Reservation {
    // 예약 seq(reservation_seq), 시작시간 & 끝 시간 (start_time, end_time), 결제 seq(payment_seq), 주차장 seq(zone_seq), 이용자 seq(user_seq), 예약 상태(reservation_status)


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name= "reservation_seq")
    private int seq;

    @Column(name = "start_time")
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;


    // 이제 주차장 , 결제, 이용자 seq 넣어야하는데,
    // 관계 아직 몰라~~~~~~~~~~

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "zone_seq")
    private ParkingZone zone;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payment_seq")
    private Payment payment;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_seq")
    private User user;

    @Column(name= "reservation_status")
    @Enumerated(EnumType.STRING)
    private ReservationStatus status; // REFUND, RESERVATION, ONGOING, FINISH



}
