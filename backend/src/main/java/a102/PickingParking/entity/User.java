package a102.PickingParking.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
@Entity
@Table(name = "users")
@Getter
@Setter
@Builder

public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(nullable = false, unique = true, columnDefinition = "BIGINT UNSIGNED")
    private Long seq;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false, length = 100)
    private String password;

    @Builder.Default
    private int points = 0;

    @Builder.Default
    private LocalDateTime signupDate = LocalDateTime.now();

    private LocalDateTime withdrawalDate;

    @Column(length = 20)
    private String phoneNumber;
}