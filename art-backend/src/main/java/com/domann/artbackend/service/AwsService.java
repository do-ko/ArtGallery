package com.domann.artbackend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;

import java.net.URL;
import java.time.Duration;

@Service
@RequiredArgsConstructor
public class AwsService {

    private final S3Presigner presigner;

    @Value("${app.s3.bucket}")
    private String bucket;

    public URL generateUploadUrl(String key, String contentType) {

        PutObjectRequest putRequest = PutObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .contentType(contentType)
                .build();

        PresignedPutObjectRequest presigned = presigner.presignPutObject(
                b -> b.signatureDuration(Duration.ofMinutes(10))
                        .putObjectRequest(putRequest)
        );

        return presigned.url();
    }
}
