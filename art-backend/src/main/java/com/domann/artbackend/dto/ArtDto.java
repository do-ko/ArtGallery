package com.domann.artbackend.dto;

import com.domann.artbackend.entiy.Art;
import com.domann.artbackend.entiy.ArtType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ArtDto {
    private String id;
    private String title;
    private String description;
    private ArtType type;
    private String artistId;

    public ArtDto(Art art) {
        this.id = art.getId();
        this.title = art.getTitle();
        this.description = art.getDescription();
        this.type = art.getType();
        this.artistId = art.getArtist().getId();
    }
}
