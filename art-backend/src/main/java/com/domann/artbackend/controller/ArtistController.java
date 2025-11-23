package com.domann.artbackend.controller;

import com.domann.artbackend.dto.*;
import com.domann.artbackend.service.ArtistService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/artist")
@RequiredArgsConstructor
@Tag(name = "Artist")
public class ArtistController {

    private final ArtistService artistService;

    @PostMapping("/first-login")
    public ResponseEntity<ArtistDto> createOnFirstLogin(@AuthenticationPrincipal Jwt jwt) {
        String sub = jwt.getClaimAsString("sub");
        String email = jwt.getClaimAsString("username");

        ArtistDto artistDto = artistService.findOrCreate(sub, email);
        return ResponseEntity.ok(artistDto);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ArtistDto> findArtistById(@PathVariable String id) {
        ArtistDto artistDto = artistService.findById(id);
        return ResponseEntity.ok(artistDto);
    }
}
