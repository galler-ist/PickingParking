package a102.PickingParking.entity;

import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
public class Charge {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name= "charge_seq")
    private int seq;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_seq")
    private User user;

    @Column(name = "charge_price")
    private int price;  // 양수:충전, 음수:출금

    @Column(name = "charge_time")
    private LocalDate time;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "point_seq")
    private Point point;

}
