CREATE TABLE unit
(
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(255)     NOT NULL UNIQUE,
    abbreviation VARCHAR(20)      NOT NULL UNIQUE,
    coefficient  DOUBLE PRECISION NOT NULL DEFAULT 1,
    parent_id    INTEGER REFERENCES unit (id) ON DELETE CASCADE
);
