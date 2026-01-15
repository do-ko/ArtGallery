package com.domann.artbackend.repository;

import com.domann.artbackend.entity.Artist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ArtistRepository extends JpaRepository<Artist, String> {
    Optional<Artist> findBySub(String sub);
}
