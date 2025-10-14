package com.domann.artbackend.service;

import com.domann.artbackend.dto.AddArtistRequest;
import com.domann.artbackend.dto.ArtistDto;
import com.domann.artbackend.entiy.Artist;
import com.domann.artbackend.repository.ArtistRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
public class ArtistService {

    private final ArtistRepository artistRepository;

    private final String TEMPORARY_COGNITO_SUB = "temorary_cognito_sub_for_testing";

    public ArtistDto findById(String id) {
        Artist artist = artistRepository.findById(id).orElseThrow(() -> new NoSuchElementException("Artist with id: " + id + " not found."));
        return new ArtistDto(artist);
    }

    public ArtistDto addNewArtist(AddArtistRequest addArtistRequest) {
        Artist artist = new Artist();
        artist.setDisplayName(addArtistRequest.getDisplayName());
        artist.setCognitoSub(TEMPORARY_COGNITO_SUB);
        artist.setArtworks(new HashSet<>());

        Artist savedArtist = artistRepository.save(artist);

        return new ArtistDto(savedArtist);
    }
}
