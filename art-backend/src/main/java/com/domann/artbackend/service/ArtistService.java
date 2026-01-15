package com.domann.artbackend.service;

import com.domann.artbackend.dto.*;
import com.domann.artbackend.entity.Art;
import com.domann.artbackend.entity.Artist;
import com.domann.artbackend.repository.ArtistRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.hibernate.Hibernate;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
public class ArtistService {

    private final ArtistRepository artistRepository;

    public ArtistDto findById(String id) {
        Artist artist = artistRepository.findById(id).orElseThrow(() -> new NoSuchElementException("Artist with id: " + id + " not found."));
        List<Art> artworks = new ArrayList<>(artist.getArtworks());
        return new ArtistDto(artist, artworks);
    }

    @Transactional
    public ArtistDto findOrCreate(String sub, String displayName) {
        Optional<Artist> artistOptional = artistRepository.findBySub(sub);
        if (artistOptional.isPresent()) {
            Artist artist = artistOptional.get();
            List<Art> artworks = new ArrayList<>(artist.getArtworks());
            return new ArtistDto(artist, artworks);
        } else {
            Artist artist = new Artist();
            artist.setSub(sub);
            artist.setDisplayName(displayName);
            artist.setDescription(null);
            artist.setArtworks(new ArrayList<>());

            artist = artistRepository.save(artist);
            List<Art> artworks = new ArrayList<>(artist.getArtworks());

            return new ArtistDto(artist, artworks);
        }
    }
}
