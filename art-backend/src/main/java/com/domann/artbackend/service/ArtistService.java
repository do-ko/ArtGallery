package com.domann.artbackend.service;

import com.domann.artbackend.dto.*;
import com.domann.artbackend.entiy.Artist;
import com.domann.artbackend.repository.ArtistRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
public class ArtistService {

    private final ArtistRepository artistRepository;

    public ArtistDto findById(String id) {
        Artist artist = artistRepository.findById(id).orElseThrow(() -> new NoSuchElementException("Artist with id: " + id + " not found."));
        return new ArtistDto(artist);
    }
}
