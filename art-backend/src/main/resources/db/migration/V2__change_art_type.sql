ALTER TABLE art
ALTER
COLUMN type TYPE varchar(255);

DO
$$
BEGIN
    IF
EXISTS (SELECT 1 FROM pg_type WHERE typname = 'art_type') THEN
DROP TYPE art_type;
END IF;
END$$;