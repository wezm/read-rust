CREATE TABLE IF NOT EXISTS creators (
    id bigserial PRIMARY KEY,
    name text NOT NULL,
    avatar text NOT NULL,
    support_link_name text NOT NULL,
    support_link_url text NOT NULL,
    code_link_name text NOT NULL,
    code_link_url text NOT NULL,
    description text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);
