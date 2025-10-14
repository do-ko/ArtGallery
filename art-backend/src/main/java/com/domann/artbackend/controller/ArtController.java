package com.domann.artbackend.controller;

import com.domann.artbackend.dto.AddArtRequest;
import com.domann.artbackend.dto.ArtDto;
import com.domann.artbackend.service.ArtService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/art")
@RequiredArgsConstructor
@Tag(name = "Art")
public class ArtController {

    private final ArtService artService;

    @GetMapping
    public ResponseEntity<Page<ArtDto>> getFilteredArts(@RequestParam(defaultValue = "") String title,
                                             @RequestParam(defaultValue = "0") int page,
                                             @RequestParam(defaultValue = "30") int size){
        Page<ArtDto> pageWithArtDto = artService.findFilteredByTitle(title, page, size);
        return ResponseEntity.ok(pageWithArtDto);
    }

    @PostMapping
    public ResponseEntity<ArtDto> createNewArtist(@Valid @RequestBody AddArtRequest request) {
        ArtDto artDto = artService.addNewArt(request);
        return ResponseEntity.ok(artDto);
    }
}
