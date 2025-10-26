package com.domann.artbackend.dto;

import com.domann.artbackend.constants.ValidationConstants;
import com.domann.artbackend.entity.ArtType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AddArtRequest {

    @Schema(description = "Art's title with at most {max} characters", example = "My first art")
    @NotBlank(message = "Art's title must not be empty or contain only whitespaces")
    @Size(max = ValidationConstants.ART_TITLE_MAX_LENGTH,
            message = "Art's title has to have at most {max} characters")
    private String title;

    @Schema(description = "Art's description with at most {max} characters", example = "Some example description of my art.")
    @Size(max = ValidationConstants.ART_DESCRIPTION_MAX_LENGTH,
            message = "Art's description has to have at most {max} characters")
    private String description;

    @Schema(description = "Art type to assign to the art",
            example = "PAINTING")
    @NotNull(message = "Art type is required")
    private ArtType type;

    @Schema(description = "Artist id with at most {max} characters", example = "f4aa9f39-8f18-4c56-b8d8-aa61b255940")
    @NotBlank(message = "Artist id must not be empty or contain only whitespaces")
    private String artistId;
}
