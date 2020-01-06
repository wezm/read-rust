CREATE MATERIALIZED VIEW search_view AS
    SELECT posts.id, setweight(to_tsvector('english', posts.title), 'A') ||
                     setweight(to_tsvector('english', string_agg(' ', tags.name)), 'B') ||
                     setweight(to_tsvector('english', posts.summary), 'C') AS vector
    FROM posts
    LEFT JOIN post_tags ON (post_tags.post_id = posts.id)
    LEFT JOIN tags ON (tags.id = post_tags.tag_id)
    GROUP BY posts.id;

CREATE INDEX search_index ON search_view USING GIN (vector);
