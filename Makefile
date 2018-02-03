all: feeds
	cobalt build

feeds:
	cargo build --release --bin generate-rss
	./target/release/generate-rss content/_data/rust/posts.json content/all/feed.rss
	./target/release/generate-rss -t 'Crates' content/_data/rust/posts.json content/crates/feed.rss
	./target/release/generate-rss -t 'Embedded' content/_data/rust/posts.json content/embedded/feed.rss
	./target/release/generate-rss -t 'Performance' content/_data/rust/posts.json content/performance/feed.rss
	./target/release/generate-rss -t 'Rust 2018' content/_data/rust/posts.json content/rust-2018/feed.rss
	./target/release/generate-rss -t 'Tools and Applications' content/_data/rust/posts.json content/tools-and-applications/feed.rss
	./target/release/generate-rss -t 'Web and Network Services' content/_data/rust/posts.json content/web-and-network-services/feed.rss

deploy: all
	rsync -avz --delete public/ eforce.binarytrance.com:/usr/local/www/readrust.net/
