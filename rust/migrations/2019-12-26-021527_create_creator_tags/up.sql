CREATE TABLE IF NOT EXISTS creator_tags (
    id bigserial PRIMARY KEY,
    creator_id bigint NOT NULL,
    tag_id bigint NOT NULL,
    CONSTRAINT creator_tags_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES creators(id) ON DELETE CASCADE,
    CONSTRAINT creator_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS creator_tags_creator_id_index ON creator_tags (creator_id);
CREATE INDEX IF NOT EXISTS creator_tags_tag_id_index ON creator_tags (tag_id);
CREATE UNIQUE INDEX IF NOT EXISTS creator_tags_creator_id_tag_id_index ON creator_tags (creator_id, tag_id);
