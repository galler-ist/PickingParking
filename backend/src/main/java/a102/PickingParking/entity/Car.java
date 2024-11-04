package a102.PickingParking.entity;


import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Getter
public class Car {
    // 차량 seq(car_seq), 이용자 seq(user_seq), 차량번호(car_plate), 차량 등록증(car_submit_image)

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name= "car_seq")
    private int seq;

    @ManyToOne()
    @JoinColumn(name = "user_seq")
    private User user;

    @Column(name= "car_plate")
    private String plate;

    @Column(name = "car_submit_image")
    private String submitImage;
}
