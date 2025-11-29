package com.domann.artbackend.service;

import com.domann.artbackend.dto.*;
import com.domann.artbackend.entity.Artist;
import com.domann.artbackend.repository.ArtistRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.management.BadAttributeValueExpException;
import java.util.NoSuchElementException;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ArtistService {

    private final ArtistRepository artistRepository;

    public ArtistDto findById(String id) {
        Artist artist = artistRepository.findById(id).orElseThrow(() -> new NoSuchElementException("Artist with id: " + id + " not found."));
        return new ArtistDto(artist);
    }

    public ArtistDto findByToken(String sub, String email) {
        Artist artist = artistRepository.findByCognitoSub(sub).orElseThrow(() -> new NoSuchElementException("Artist with sub: " + sub + " not found."));
        if (!artist.getEmail().equals(email)) {
            throw new NoSuchElementException("Provided email did not match one in the database: " + email);
        }
        return new ArtistDto(artist);
    }

    public ArtistDto findOrCreate(String sub, String email) {
        Optional<Artist> artistOptional = artistRepository.findByCognitoSub(sub);
        if (artistOptional.isPresent()) {
            return new ArtistDto(artistOptional.get());
        } else {
            Artist artist = new Artist();
            artist.setCognitoSub(sub);
            artist.setEmail(email);

            return new ArtistDto(artistRepository.save(artist));
        }
    }
}
