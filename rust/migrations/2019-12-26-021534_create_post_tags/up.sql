CREATE TABLE post_tags (
    id bigserial PRIMARY KEY,
    post_id bigint NOT NULL,
    tag_id bigint NOT NULL
);

ALTER TABLE ONLY post_tags
    ADD CONSTRAINT post_tags_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


ALTER TABLE ONLY post_tags
    ADD CONSTRAINT post_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE;

CREATE INDEX post_tags_post_id_index ON post_tags (post_id);
CREATE INDEX post_tags_tag_id_index ON post_tags (tag_id);
CREATE UNIQUE INDEX post_tags_post_id_tag_id_index ON post_tags (post_id, tag_id);
