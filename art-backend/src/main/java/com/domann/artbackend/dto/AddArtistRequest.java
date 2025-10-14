package com.domann.artbackend.dto;

import com.domann.artbackend.constants.ValidationConstants;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AddArtistRequest {
    @Schema(description = "Artist's display name with at most {max} characters", example = "Artist123")
    @NotBlank(message = "Artist's display name must not be empty or contain only whitespaces")
    @Size(max = ValidationConstants.ARTIST_DISPLAY_NAME_MAX_LENGTH,
            message = "Artist's display name has to have at most {max} characters")
    private String displayName;
}
