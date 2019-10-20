use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::result::Error as DieselError;

use crate::models::Post;

const BATCH_SIZE: i64 = 5;

pub fn establish_connection(database_url: &str) -> Result<PgConnection, ConnectionError> {
    PgConnection::establish(database_url)
}

pub fn untooted_posts(connection: &PgConnection) -> Result<Vec<Post>, DieselError> {
    use crate::schema::posts::dsl::*;

    posts
        .filter(tooted_at.is_null())
        .limit(BATCH_SIZE)
        .load::<Post>(connection)
}

pub fn untweeted_posts(connection: &PgConnection) -> Result<Vec<Post>, DieselError> {
    use crate::schema::posts::dsl::*;

    // TODO: Add order by
    posts
        .filter(tweeted_at.is_null())
        .limit(BATCH_SIZE)
        .load::<Post>(connection)
}
