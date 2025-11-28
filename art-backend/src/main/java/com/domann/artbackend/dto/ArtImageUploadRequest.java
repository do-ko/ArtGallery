package com.domann.artbackend.dto;

import lombok.Data;

@Data
public class ArtImageUploadRequest {
    private String filename;
    private String contentType;
}
