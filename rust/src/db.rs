use std::rc::Rc;

use diesel::pg::PgConnection;
use diesel::prelude::*;

use crate::categories::{Categories, Category};
use crate::models::Post;
use crate::models::PostCategory;

const BATCH_SIZE: i64 = 1;

pub fn establish_connection(database_url: &str) -> Result<PgConnection, ConnectionError> {
    PgConnection::establish(database_url)
}

pub fn untooted_posts(connection: &PgConnection) -> QueryResult<Vec<Post>> {
    use crate::schema::posts::dsl::*;

    posts
        .filter(tooted_at.is_null())
        .order_by(created_at.asc())
        .limit(BATCH_SIZE)
        .load::<Post>(connection)
}

pub fn mark_post_tooted(connection: &PgConnection, post: Post) -> QueryResult<()> {
    use crate::schema::posts;
    use diesel::expression::dsl::now;

    diesel::update(&post)
        .set(posts::tooted_at.eq(now))
        .execute(connection)
        .map(|_rows_updated| ())
}

pub fn untweeted_posts(connection: &PgConnection) -> QueryResult<Vec<Post>> {
    use crate::schema::posts::dsl::*;

    posts
        .filter(tweeted_at.is_null())
        .order_by(created_at.asc())
        .limit(BATCH_SIZE)
        .load::<Post>(connection)
}

pub fn mark_post_tweeted(connection: &PgConnection, post: Post) -> QueryResult<()> {
    use crate::schema::posts;
    use diesel::expression::dsl::now;

    diesel::update(&post)
        .set(posts::tweeted_at.eq(now))
        .execute(connection)
        .map(|_rows_updated| ())
}

pub fn post_categories(
    connection: &PgConnection,
    post: &Post,
    categories: &Categories,
) -> QueryResult<Vec<Rc<Category>>> {
    use crate::schema::post_categories::dsl::*;

    let category_ids = post_categories
        .filter(post_id.eq(post.id))
        .load::<PostCategory>(connection)?
        .into_iter()
        .map(|post_category| post_category.category_id);

    Ok(categories.with_ids(category_ids))
}
