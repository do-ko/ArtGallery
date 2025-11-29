package com.domann.artbackend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(
        name = "art",
        indexes = {
                @Index(name = "idx_art_artist_id", columnList = "artist_id"),
                @Index(name = "idx_art_created_at", columnList = "created_at DESC")
        }
)
public class Art {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false)
    private UUID id;

    @Column(name = "title", nullable = false, length = 255)
    private String title;

    @Column(name = "description", length = 1000)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "type")
    private ArtType type;

    @Column(name = "imageUrl", length = 512)
    private String imageUrl;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    // =========== RELACJE ===========
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "artist_id", nullable = false)
    private Artist artist;

    // =========== AUDIT ===========
    @PrePersist
    public void onCreate() {
        this.createdAt = Instant.now();
    }
}
