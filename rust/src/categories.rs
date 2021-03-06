use std::rc::Rc;

use serde::Deserialize;
use serde_json;

const JSON: &str = include_str!("../../content/_data/categories.json");

#[derive(Debug, Deserialize)]
pub struct Category {
    pub id: i16,
    pub name: String,
    pub hashtag: String,
    pub slug: String,
    pub description: String,
}

#[derive(Debug)]
pub struct Categories {
    categories: Vec<Rc<Category>>,
}

impl Categories {
    pub fn load() -> Self {
        let categories: Vec<Category> = serde_json::from_str(JSON).unwrap(); // It's expected that the categories were valid at compile time
        let categories: Vec<_> = categories.into_iter().map(Rc::new).collect();

        Categories { categories }
    }

    pub fn with_ids(&self, ids: impl Iterator<Item = i16>) -> Option<Vec<Rc<Category>>> {
        ids.map(|id| {
            self.categories
                .iter()
                .find(|cat| cat.id == id)
                .map(|found| Rc::clone(found))
        })
        .collect()
    }
}
