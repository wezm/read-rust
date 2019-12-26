CREATE TABLE creator_tags (
    id bigserial PRIMARY KEY,
    creator_id bigint NOT NULL,
    tag_id bigint NOT NULL
);

ALTER TABLE ONLY creator_tags
    ADD CONSTRAINT creator_tags_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES creators(id) ON DELETE CASCADE;

ALTER TABLE ONLY creator_tags
    ADD CONSTRAINT creator_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE;

CREATE INDEX creator_tags_creator_id_index ON creator_tags (creator_id);
CREATE INDEX creator_tags_tag_id_index ON creator_tags (tag_id);
CREATE UNIQUE INDEX creator_tags_creator_id_tag_id_index ON creator_tags (creator_id, tag_id);
