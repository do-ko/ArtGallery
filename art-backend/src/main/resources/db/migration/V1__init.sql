CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS public.artist (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    sub             text UNIQUE NOT NULL,
    display_name    varchar(48) UNIQUE NOT NULL,
    description     varchar(256),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
    );

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'art_type') THEN
CREATE TYPE art_type AS ENUM (
      'PAINTING','DRAWING','PHOTOGRAPHY','DIGITAL_ART','SCULPTURE','COLLAGE',
      'PRINTMAKING','MIXED_MEDIA','INSTALLATION','STREET_ART','CRAFT',
      'ILLUSTRATION','GRAPHIC_DESIGN','CONCEPT_ART','CALLIGRAPHY',
      'ANIMATION_FRAME','OTHER'
    );
END IF;
END$$;

CREATE TABLE IF NOT EXISTS public.art (
    id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title            varchar(255) NOT NULL,
    description      varchar(1000),
    type             art_type,
    artist_id        uuid NOT NULL REFERENCES public.artist(id) ON DELETE RESTRICT,
    created_at       timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_art_artist_id ON public.art(artist_id);
CREATE INDEX IF NOT EXISTS idx_art_created_at ON public.art(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_artist_created_at ON public.artist(created_at DESC);
