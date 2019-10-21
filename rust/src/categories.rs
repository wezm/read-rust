use std::borrow::Borrow;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::rc::Rc;

use serde_json;

const JSON: &str = include_str!("../../content/_data/categories.json");

#[derive(Debug, Deserialize)]
pub struct Category {
    pub name: String,
    pub hashtag: String,
    pub path: String,
    pub description: String,
}

#[derive(Debug)]
pub struct Categories {
    categories: Vec<Rc<Category>>,
    tag_map: HashMap<String, Rc<Category>>,
}

impl Categories {
    pub fn load() -> Self {
        let categories: Vec<Category> = serde_json::from_str(JSON).unwrap(); // It's expected that the categories were valid at compile time
        let categories: Vec<_> = categories.into_iter().map(Rc::new).collect();

        let mut tag_map = HashMap::new();
        for category in categories.iter() {
            tag_map.insert(category.name.clone(), Rc::clone(&category));
        }

        Categories {
            categories,
            tag_map,
        }
    }

    pub fn hashtag_for_category(&self, category_name: &str) -> Option<&str> {
        self.tag_map.get(category_name).map(|category| {
            let cat: &Category = category.borrow();
            cat.hashtag.as_ref()
        })
    }

    pub fn with_ids(&self, ids: impl Iterator<Item = i16>) -> Vec<Rc<Category>> {
        ids.map(|id| Rc::clone(&self.categories[usize::try_from(id).unwrap()]))
            .collect()
    }
}
