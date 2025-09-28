CREATE TABLE class
(
    id             SERIAL PRIMARY KEY,
    name           VARCHAR(255) NOT NULL UNIQUE,
    order_position INTEGER DEFAULT 0,
    parent_id      INTEGER      REFERENCES class (id) ON DELETE SET NULL,
    unit_id        INTEGER      REFERENCES unit (id) ON DELETE SET NULL
);
