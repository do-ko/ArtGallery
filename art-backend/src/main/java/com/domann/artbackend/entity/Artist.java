package com.domann.artbackend.entity;

import com.domann.artbackend.constants.ValidationConstants;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(
        name = "artist",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_artist_sub", columnNames = "sub"),
                @UniqueConstraint(name = "uk_artist_display_name", columnNames = "display_name")
        }
)
public class Artist {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false)
    private UUID id;

    @Column(name = "display_name", nullable = false, length = ValidationConstants.ARTIST_DISPLAY_NAME_MAX_LENGTH)
    private String displayName;

    @Column(name = "description")
    private String description;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    // =========== KEYCLOAK ===========
    @Column(name = "sub", nullable = false, unique = true, updatable = false)
    private String sub;

    // =========== RELACJE ===========
    @OneToMany(
            mappedBy = "artist",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    private List<Art> artworks = new ArrayList<>();

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
