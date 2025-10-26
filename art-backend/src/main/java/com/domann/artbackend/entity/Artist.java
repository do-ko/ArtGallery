package com.domann.artbackend.entity;

import com.domann.artbackend.constants.ValidationConstants;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(
        name = "artist",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_artist_cognito_sub", columnNames = "cognito_sub"),
                @UniqueConstraint(name = "uk_artist_display_name", columnNames = "display_name"),
                @UniqueConstraint(name = "uk_artist_email", columnNames = "email")
        }
)
public class Artist {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false)
    private UUID id;

    @Column(name = "display_name", nullable = false, length = ValidationConstants.ARTIST_DISPLAY_NAME_MAX_LENGTH)
    private String displayName;

    @Column(name = "email", length = 255)
    private String email;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    // =========== COGNITO ===========
    @Column(name = "cognito_sub", nullable = false, unique = true, length = 64, updatable = false)
    private String cognitoSub;

    // =========== RELACJE ===========
    @OneToMany(
            mappedBy = "artist",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    private Set<Art> artworks = new HashSet<>();

    // =========== AUDIT ===========
    @PrePersist
    public void onCreate() {
        Instant now = Instant.now();
        this.createdAt = now;
        this.updatedAt = now;
    }

    @PreUpdate
    public void onUpdate() {
        this.updatedAt = Instant.now();
    }
}
