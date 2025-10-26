package com.domann.artbackend.repository;

import com.domann.artbackend.entity.Art;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ArtRepository extends JpaRepository<Art, String> {

    Page<Art> findAllByTitleContainingIgnoreCase(String title, Pageable pageable);
}
