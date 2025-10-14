package com.domann.artbackend.entiy;

import com.domann.artbackend.constants.ValidationConstants;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

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

    @Column(nullable = false, updatable = false, length = 64)
    private String cognitoSub; // from JWT "sub" - prepared for using cognito later!

    @Column(nullable = false, length = ValidationConstants.ARTIST_DISPLAY_NAME_MAX_LENGTH)
    private String displayName;

    @OneToMany(mappedBy = "artist",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY)
    private Set<Art> artworks = new HashSet<>();
}
