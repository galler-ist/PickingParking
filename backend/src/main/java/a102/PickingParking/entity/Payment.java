package a102.PickingParking.entity;

import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
public class Payment {
    // 결제 seq(payment_seq), 결제 금액(total_price), 주차장 seq, 결제 시간, 포인트 seq, 결제 상태
    // 결제 table에 "reservation"에서 온 것인지, "immediate"에서 온 것인지 어떻게 알지? 상속 관계처럼 상하관계는 아니야.

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name= "payment_seq")
    private int seq;

    @Column(name = "total_price")
    private int price;

    @ManyToOne()
    @JoinColumn(name = "zone_seq")
    private ParkingZone zone;

    @Column(name = "payment_time")
    private LocalDate time;

    @Column(name= "payment_source")
    @Enumerated(EnumType.STRING)
    private PaymentSource source; // IMMEDIATE, RESERVATION

    @ManyToOne()
    @JoinColumn(name = "point_seq")
    private Point point;

}
