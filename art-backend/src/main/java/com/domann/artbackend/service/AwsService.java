package com.domann.artbackend.service;

import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MinioClient;
import io.minio.errors.*;
import io.minio.http.Method;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import java.io.IOException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AwsService {

    @Value("${app.minio.bucket}")
    private String bucket;

    private final MinioClient minioClient;

    public String generateUploadUrl(String key, String contentType) throws ServerException, InsufficientDataException, ErrorResponseException, IOException, NoSuchAlgorithmException, InvalidKeyException, InvalidResponseException, XmlParserException, InternalException {
        Map<String, String> headers = new HashMap<>();
        headers.put("Content-Type", contentType);

        return minioClient.getPresignedObjectUrl(GetPresignedObjectUrlArgs.builder()
                .method(Method.PUT)
                .bucket(bucket)
                .object(key)
                .expiry(600)
                .extraHeaders(headers)
                .build());
    }
}
