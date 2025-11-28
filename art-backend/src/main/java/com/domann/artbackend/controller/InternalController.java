package com.domann.artbackend.controller;

import com.domann.artbackend.dto.ArtistDto;
import com.domann.artbackend.dto.ArtistInitRequest;
import com.domann.artbackend.service.ArtistService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/internal")
@RequiredArgsConstructor
@Tag(name = "Internal")
public class InternalController {

    private final ArtistService artistService;

    @Value("${internal.secret}")
    private String INTERNAL_SECRET_FROM_ENV;

    @PostMapping("/artist/first-login")
    public ResponseEntity<?> createOnFirstLogin(@RequestHeader("X-Internal-Secret") String secret,
                                                @RequestBody ArtistInitRequest request) {

        if (!secret.equals(INTERNAL_SECRET_FROM_ENV)) {
            return ResponseEntity.status(403).build();
        }

        ArtistDto artistDto = artistService.findOrCreate(request.getCognitoSub(), request.getEmail());
        return ResponseEntity.ok(artistDto);
    }

}
