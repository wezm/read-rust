CREATE MATERIALIZED VIEW search_view AS
    SELECT posts.id,
           posts.summary,
           setweight(to_tsvector('english', posts.title), 'A') ||
               setweight(to_tsvector('english', coalesce(string_agg(tags.name, ' '), '')), 'B') ||
               setweight(to_tsvector('english', posts.summary), 'C') ||
               setweight(to_tsvector('english', posts.author), 'D') AS vector
    FROM posts
    LEFT JOIN post_tags ON (posts.id = post_tags.post_id)
    LEFT JOIN tags ON (post_tags.tag_id = tags.id)
    GROUP BY posts.id;

CREATE INDEX search_index ON search_view USING GIN (vector);
