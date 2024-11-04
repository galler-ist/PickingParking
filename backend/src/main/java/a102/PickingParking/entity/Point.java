package a102.PickingParking.entity;

import jakarta.persistence.*;

@Entity
public class Point {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "point_seq")
    private int seq;

    @ManyToOne()
    @JoinColumn(name = "user_seq")
    private User user;

    @Column(name= "point_source")
    @Enumerated(EnumType.STRING)
    private PointSource source; // PAYMENT, CHARGE

    @Column(name = "point_price")
    private int price; // 양수 : 충전|수익 , 음수 : 출금|지출
}
