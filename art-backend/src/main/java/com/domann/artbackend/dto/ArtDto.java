package com.domann.artbackend.dto;

import com.domann.artbackend.entity.Art;
import com.domann.artbackend.entity.ArtType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ArtDto {
    private UUID id;
    private String title;
    private String description;
    private ArtType type;
    private UUID artistId;

    public ArtDto(Art art) {
        this.id = art.getId();
        this.title = art.getTitle();
        this.description = art.getDescription();
        this.type = art.getType();
        this.artistId = art.getArtist().getId();
    }
}
