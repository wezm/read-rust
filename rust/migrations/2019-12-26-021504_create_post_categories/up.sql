CREATE TABLE IF NOT EXISTS post_categories (
    id bigserial PRIMARY KEY,
    post_id bigint NOT NULL,
    category_id smallint NOT NULL,
    CONSTRAINT post_categories_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS post_categories_post_id_category_id_index ON post_categories (post_id, category_id);
CREATE INDEX IF NOT EXISTS post_categories_post_id_index ON post_categories (post_id);
