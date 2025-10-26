package com.domann.artbackend.dto;

import com.domann.artbackend.constants.ValidationConstants;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class LoginRequest {
    @Schema(description = "Artist's email", example = "artist@email.com")
    @Email(message = "Email must be in a correct format")
    @NotBlank(message = "Email must not be empty or contain only whitespaces")
    private String email;

    @Size(min = ValidationConstants.ARTIST_PASSWORD_MIN_LENGTH,
            max = ValidationConstants.ARTIST_PASSWORD_MAX_LENGTH,
            message = "APassword has to be between {min} and {max} characters")
    @NotBlank(message = "Password must not be empty or contain only whitespaces")
    private String password;
}
