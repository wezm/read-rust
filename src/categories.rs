use std::fs::File;
use std::path::Path;
use std::collections::HashMap;
use std::rc::Rc;
use std::borrow::Borrow;

use serde_json;

use error::Error;

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
    pub fn load(path: &Path) -> Result<Self, Error> {
        let categories_file = File::open(path).map_err(Error::Io)?;
        let categories: Vec<Category> =
            serde_json::from_reader(categories_file).map_err(Error::JsonError)?;
        let categories: Vec<_> = categories.into_iter().map(Rc::new).collect();

        let mut tag_map = HashMap::new();
        for category in categories.iter() {
            tag_map.insert(category.name.clone(), Rc::clone(&category));
        }

        Ok(Categories {
            categories,
            tag_map,
        })
    }

    pub fn hashtag_for_category(&self, category_name: &str) -> Option<&str> {
        self.tag_map.get(category_name).map(|category| {
            let cat: &Category = category.borrow();
            cat.hashtag.as_ref()
        })
    }
}
