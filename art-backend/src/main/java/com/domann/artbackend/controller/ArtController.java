package com.domann.artbackend.controller;

import com.domann.artbackend.dto.*;
import com.domann.artbackend.service.ArtService;
import com.domann.artbackend.service.ArtistService;
import com.domann.artbackend.service.AwsService;
import io.minio.errors.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;

@RestController
@RequestMapping("/api/art")
@RequiredArgsConstructor
@Tag(name = "Art")
public class ArtController {

    private final ArtService artService;
    private final AwsService awsService;
    private final ArtistService artistService;

    @Value("${app.minio.endpoint}")
    private String endpoint;

    @Value("${app.minio.bucket}")
    private String bucket;



    @GetMapping
    public ResponseEntity<Page<ArtDto>> getFilteredArts(@RequestParam(defaultValue = "") String title,
                                                        @RequestParam(defaultValue = "0") int page,
                                                        @RequestParam(defaultValue = "30") int size) {
        Page<ArtDto> pageWithArtDto = artService.findFilteredByTitle(title, page, size);
        return ResponseEntity.ok(pageWithArtDto);
    }

    @PostMapping
    public ResponseEntity<ArtDto> createNewArt(@AuthenticationPrincipal Jwt jwt,
                                               @Valid @RequestBody AddArtRequest request) {
        String sub = jwt.getClaimAsString("sub");
        String displayName = jwt.getClaimAsString("preferred_username");
        artistService.findOrCreate(sub, displayName);

        ArtDto artDto = artService.addNewArt(request, sub);
        return ResponseEntity.ok(artDto);
    }

    @PostMapping("/url")
    public ResponseEntity<PresignedUrlResponse> generateUrl(@AuthenticationPrincipal Jwt jwt,
                                                            @RequestBody ArtImageUploadRequest request) throws ServerException, InsufficientDataException, ErrorResponseException, IOException, NoSuchAlgorithmException, InvalidKeyException, InvalidResponseException, XmlParserException, InternalException {
        String sub = jwt.getClaimAsString("sub");
        String displayName = jwt.getClaimAsString("preferred_username");
        artistService.findOrCreate(sub, displayName);

        String key = "artworks/" + UUID.randomUUID() + "-" + request.getFilename();

        String uploadUrl = awsService.generateUploadUrl(key, request.getContentType());

        PresignedUrlResponse response = new PresignedUrlResponse(
                uploadUrl,
                endpoint + "/" + bucket + "/" + key);
        return ResponseEntity.ok(response);
    }
}
