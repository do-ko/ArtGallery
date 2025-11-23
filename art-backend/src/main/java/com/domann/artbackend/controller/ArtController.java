package com.domann.artbackend.controller;

import com.domann.artbackend.dto.AddArtRequest;
import com.domann.artbackend.dto.ArtDto;
import com.domann.artbackend.dto.ArtistDto;
import com.domann.artbackend.service.ArtService;
import com.domann.artbackend.service.ArtistService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/art")
@RequiredArgsConstructor
@Tag(name = "Art")
public class ArtController {

    private final ArtService artService;
    private final ArtistService artistService;

    @GetMapping
    public ResponseEntity<Page<ArtDto>> getFilteredArts(@RequestParam(defaultValue = "") String title,
                                             @RequestParam(defaultValue = "0") int page,
                                             @RequestParam(defaultValue = "30") int size){
        Page<ArtDto> pageWithArtDto = artService.findFilteredByTitle(title, page, size);
        return ResponseEntity.ok(pageWithArtDto);
    }

    @PostMapping
    public ResponseEntity<ArtDto> createNewArt(@AuthenticationPrincipal Jwt jwt,
                                               @Valid @RequestBody AddArtRequest request) {
        String sub = jwt.getClaimAsString("sub");
        ArtDto artDto = artService.addNewArt(request, sub);
        return ResponseEntity.ok(artDto);
    }
}
