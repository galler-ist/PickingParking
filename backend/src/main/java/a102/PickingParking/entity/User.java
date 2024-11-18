package a102.PickingParking.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "INT UNSIGNED", name = "user_seq")
    private Integer seq;

    @Column(nullable = false, unique = true, length = 20, name = "user_id")
    private String userId;

    @Column(nullable = false, length = 255, name = "user_pw")
    private String password;

    @Column(nullable = false)
    @Builder.Default
    private Integer point = 0;

    @Column(name = "created_at")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm", timezone = "Asia/Seoul")
    @Builder.Default
    private LocalDateTime createdDate = LocalDateTime.now();

    @Column(name = "unsubcribed_at")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm", timezone = "Asia/Seoul")
    private LocalDateTime unsubcribedDate;

    @Column(nullable = false, length = 20, name = "user_phone")
    private String phoneNumber;
}