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
    @Column(nullable = false, unique = true, columnDefinition = "INT UNSIGNED")
    private int seq;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false, length = 100)
    private String password;

    @Builder.Default
    private int points = 0;

    @Column(name = "created_at")
    @Builder.Default
    private LocalDateTime createdDate = LocalDateTime.now();

    @Column(name = "unsubcribed_at")
    private LocalDateTime unsubcribedDate;

    @Column(length = 20)
    private String phoneNumber;
}