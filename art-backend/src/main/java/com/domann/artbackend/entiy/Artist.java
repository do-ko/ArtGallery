package com.domann.artbackend.entiy;

import com.domann.artbackend.constants.ValidationConstants;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "artist")
public class Artist {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false, length = ValidationConstants.ARTIST_DISPLAY_NAME_MAX_LENGTH)
    private String displayName;

    private Instant createdAt;
    private Instant updatedAt;

    // =========== COGNITO FIELDS ===========
    @Column(length = 64, updatable = false)
    private String cognitoSub;


    @OneToMany(mappedBy = "artist",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY)
    private Set<Art> artworks = new HashSet<>();

    @PrePersist
    public void onCreate() {
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    @PreUpdate
    public void onUpdate() {
        this.updatedAt = Instant.now();
    }
}
