package com.domann.artbackend.service;

import com.domann.artbackend.dto.AddArtRequest;
import com.domann.artbackend.dto.ArtDto;
import com.domann.artbackend.entity.Art;
import com.domann.artbackend.entity.Artist;
import com.domann.artbackend.repository.ArtRepository;
import com.domann.artbackend.repository.ArtistRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
public class ArtService {

    private final ArtRepository artRepository;
    private final ArtistRepository artistRepository;

    public Page<ArtDto> findFilteredByTitle(String title, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Art> pageWithArt = artRepository.findAllByTitleContainingIgnoreCase(title, pageable);
        return pageWithArt.map(ArtDto::new);
    }

    @Transactional
    public ArtDto addNewArt(AddArtRequest addArtRequest, String sub) {
        Artist artist = artistRepository.findBySub(sub)
                .orElseThrow(() -> new NoSuchElementException("Artist with sub: " + sub + " not found."));

        Art art = new Art();
        art.setTitle(addArtRequest.getTitle());
        art.setDescription(addArtRequest.getDescription());
        art.setType(addArtRequest.getType());
        art.setImageUrl(addArtRequest.getImageUrl());
        art.setArtist(artist);

        Art savedArt = artRepository.save(art);
        return new ArtDto(savedArt);
    }
}
