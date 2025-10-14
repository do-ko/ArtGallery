package com.domann.artbackend.controller;

import com.domann.artbackend.dto.AddArtistRequest;
import com.domann.artbackend.dto.ArtistDto;
import com.domann.artbackend.service.ArtistService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/artist")
@RequiredArgsConstructor
@Tag(name = "Artist")
public class ArtistController {

    private final ArtistService artistService;

    @GetMapping("/{id}")
    public ResponseEntity<ArtistDto> findArtistById(@PathVariable String id) {
        ArtistDto artistDto = artistService.findById(id);
        return ResponseEntity.ok(artistDto);
    }

    @PostMapping
    public ResponseEntity<ArtistDto> createNewArtist(@Valid @RequestBody AddArtistRequest request) {
        ArtistDto artistDto = artistService.addNewArtist(request);
        return ResponseEntity.ok(artistDto);
    }
}
