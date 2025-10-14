package com.domann.artbackend.dto;

import com.domann.artbackend.entiy.Art;
import com.domann.artbackend.entiy.Artist;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ArtistDto {
    private String id;
    private String displayName;
    private List<String> artworkIds;

    public ArtistDto(Artist artist) {
        this.id = artist.getId();
        this.displayName = artist.getDisplayName();
        this.artworkIds = artist.getArtworks().stream().map(Art::getId).toList();
    }
}
