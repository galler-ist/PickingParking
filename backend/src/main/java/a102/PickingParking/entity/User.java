package a102.PickingParking.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;


@Entity
@Table(name = "user")
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(nullable = false, unique = true, columnDefinition = "INT UNSIGNED", name = "user_seq")
    private int seq;

    @Column(nullable = false, unique = true, length = 50, name = "user_id")
    private String username;

    @Column(nullable = false, length = 100, name = "user_pw")
    private String password;

    @Builder.Default
    private int point = 0;

    @Column(name = "created_at")
    @Builder.Default
    private LocalDateTime createdDate = LocalDateTime.now();

    @Column(name = "unsubcribed_at")
    private LocalDateTime unsubcribedDate;

    @Column(length = 20, name = "user_phone")
    private String phoneNumber;
}