CREATE TABLE tags (
    id bigserial PRIMARY KEY,
    name text NOT NULL
);

CREATE UNIQUE INDEX tags_name_index ON tags (name);
