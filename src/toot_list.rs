use std::collections::HashSet;
use std::fs::File;
use std::path::Path;

use serde_json;
use uuid::Uuid;

use error::Error;

#[derive(Debug, Serialize, Deserialize)]
pub struct Toot {
    pub item_id: Uuid,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TootList {
    toots: Vec<Toot>,
    uuids: HashSet<Uuid>,
}

impl TootList {
    pub fn load(path: &Path) -> Result<Self, Error> {
        let toot_list = File::open(path).map_err(Error::Io)?;
        let toots: Vec<Toot> = serde_json::from_reader(toot_list).map_err(Error::JsonError)?;
        let uuids = toots.iter().map(|toot| toot.item_id.clone()).collect();

        Ok(TootList { toots, uuids })
    }

    pub fn save(&self, path: &Path) -> Result<(), Error> {
        let toot_list = File::create(path).map_err(Error::Io)?;
        serde_json::to_writer_pretty(toot_list, &self.toots).map_err(Error::JsonError)
    }

    pub fn add_item(&mut self, item: Toot) {
        let uuid = item.item_id.clone();
        self.toots.push(item);
        self.uuids.insert(uuid);
    }

    pub fn contains(&self, uuid: &Uuid) -> bool {
        self.uuids.contains(uuid)
    }
}
