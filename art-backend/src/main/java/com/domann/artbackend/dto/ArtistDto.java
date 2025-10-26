package com.domann.artbackend.dto;

import com.domann.artbackend.entity.Art;
import com.domann.artbackend.entity.Artist;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ArtistDto {
    private UUID id;
    private String displayName;
    private List<UUID> artworkIds;

    public ArtistDto(Artist artist) {
        this.id = artist.getId();
        this.displayName = artist.getDisplayName();
        this.artworkIds = artist.getArtworks().stream().map(Art::getId).toList();
    }
}
