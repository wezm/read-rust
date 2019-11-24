table! {
    creators (id) {
        id -> Int8,
        name -> Text,
        avatar -> Text,
        support_link_name -> Text,
        support_link_url -> Text,
        code_link_name -> Text,
        code_link_url -> Text,
        description -> Text,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

table! {
    creator_tags (id) {
        id -> Int8,
        creator_id -> Int8,
        tag_id -> Int8,
    }
}

table! {
    migrations (id) {
        id -> Int4,
        version -> Int8,
    }
}

table! {
    post_categories (id) {
        id -> Int8,
        post_id -> Int8,
        category_id -> Int2,
    }
}

table! {
    posts (id) {
        id -> Int8,
        guid -> Uuid,
        title -> Text,
        url -> Text,
        twitter_url -> Nullable<Text>,
        mastodon_url -> Nullable<Text>,
        author -> Text,
        summary -> Text,
        tweeted_at -> Nullable<Timestamptz>,
        tooted_at -> Nullable<Timestamptz>,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

table! {
    tags (id) {
        id -> Int8,
        name -> Text,
    }
}

table! {
    users (id) {
        id -> Int8,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
        email -> Text,
        encrypted_password -> Text,
    }
}

joinable!(creator_tags -> creators (creator_id));
joinable!(creator_tags -> tags (tag_id));
joinable!(post_categories -> posts (post_id));

allow_tables_to_appear_in_same_query!(
    creators,
    creator_tags,
    migrations,
    post_categories,
    posts,
    tags,
    users,
);
