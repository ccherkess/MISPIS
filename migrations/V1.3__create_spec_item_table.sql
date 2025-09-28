CREATE TABLE spec_item
(
    id             SERIAL PRIMARY KEY,
    order_position INTEGER DEFAULT 0,
    amount         DOUBLE PRECISION CHECK (amount > 0),
    flag           BOOLEAN DEFAULT FALSE,
    item_id        INTEGER NOT NULL REFERENCES item (id) ON DELETE CASCADE,
    use_item_id    INTEGER NOT NULL REFERENCES item (id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX spec_item_index ON spec_item (item_id, order_position);
