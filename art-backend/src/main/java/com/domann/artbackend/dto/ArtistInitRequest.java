package com.domann.artbackend.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ArtistInitRequest {
    @Schema(description = "Artist's cognito sub", example = "???")
    @NotBlank(message = "Congito sub must not be empty or contain only whitespaces")
    private String cognitoSub;

    @Schema(description = "Artist's email", example = "artist@email.com")
    @Email(message = "Email must be in a correct format")
    @NotBlank(message = "Email must not be empty or contain only whitespaces")
    private String email;
}
