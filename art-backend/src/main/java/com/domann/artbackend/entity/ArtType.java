package com.domann.artbackend.entity;

import lombok.Getter;

@Getter
public enum ArtType {
    PAINTING("Painting"),
    DRAWING("Drawing"),
    PHOTOGRAPHY("Photography"),
    DIGITAL_ART("Digital Art"),
    SCULPTURE("Sculpture"),
    COLLAGE("Collage"),
    PRINTMAKING("Printmaking"),
    MIXED_MEDIA("Mixed Media"),
    INSTALLATION("Installation"),
    STREET_ART("Street Art"),
    CRAFT("Craft"),
    ILLUSTRATION("Illustration"),
    GRAPHIC_DESIGN("Graphic Design"),
    CONCEPT_ART("Concept Art"),
    CALLIGRAPHY("Calligraphy"),
    ANIMATION_FRAME("Animation Frame"),
    OTHER("Other");

    private final String label;

    ArtType(String label) {
        this.label = label;
    }
}
