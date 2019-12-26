CREATE TABLE posts (
    id bigserial PRIMARY KEY,
    guid uuid NOT NULL,
    title text NOT NULL,
    url text NOT NULL,
    twitter_url text,
    mastodon_url text,
    author text NOT NULL,
    summary text NOT NULL,
    tweeted_at timestamp with time zone,
    tooted_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE UNIQUE INDEX posts_url_index ON posts (url);
