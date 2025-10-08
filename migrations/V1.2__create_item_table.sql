CREATE TABLE item
(
    id        SERIAL PRIMARY KEY,
    name      VARCHAR(255) NOT NULL UNIQUE,
    amount    INTEGER CHECK (amount >= 0) DEFAULT 0,
    price     INTEGER CHECK (price >= 0)  DEFAULT 0,
    change    TEXT                        DEFAULT NULL,
    class_id  INTEGER REFERENCES class (id) ON DELETE CASCADE,
    parent_id INTEGER      REFERENCES item (id) ON DELETE SET NULL
);
