CREATE TABLE IF NOT EXISTS tags (
    id bigserial PRIMARY KEY,
    name text NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS tags_name_index ON tags (name);
