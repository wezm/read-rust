all: feeds
	cobalt build
	cargo run --release --bin toot -- -n content/_data/tooted.json content/_data/rust/posts.json

feeds:
	cargo build --release --bin generate-rss
	./target/release/generate-rss content/_data/rust/posts.json content/all/feed.rss
	./target/release/generate-rss -t 'Community' content/_data/rust/posts.json content/community/feed.rss
	./target/release/generate-rss -t 'Computer Science' content/_data/rust/posts.json content/computer-science/feed.rss
	./target/release/generate-rss -t 'Crates' content/_data/rust/posts.json content/crates/feed.rss
	./target/release/generate-rss -t 'DevOps and Deployment' content/_data/rust/posts.json content/devops-and-deployment/feed.rss
	./target/release/generate-rss -t 'Embedded' content/_data/rust/posts.json content/embedded/feed.rss
	./target/release/generate-rss -t 'Games and Graphics' content/_data/rust/posts.json content/games-and-graphics/feed.rss
	./target/release/generate-rss -t 'Getting Started' content/_data/rust/posts.json content/getting-started/feed.rss
	./target/release/generate-rss -t 'Language' content/_data/rust/posts.json content/language/feed.rss
	./target/release/generate-rss -t 'Operating Systems' content/_data/rust/posts.json content/operating-systems/feed.rss
	./target/release/generate-rss -t 'Performance' content/_data/rust/posts.json content/performance/feed.rss
	./target/release/generate-rss -t 'Rust 2018' content/_data/rust/posts.json content/rust-2018/feed.rss
	./target/release/generate-rss -t 'Tools and Applications' content/_data/rust/posts.json content/tools-and-applications/feed.rss
	./target/release/generate-rss -t 'Web and Network Services' content/_data/rust/posts.json content/web-and-network-services/feed.rss

deploy: all
	aws s3 sync --delete --cache-control 'max-age=120, public' public s3://readrust.net
	cargo run --release --bin toot -- content/_data/tooted.json content/_data/rust/posts.json
	cargo run --release --bin tweet -- content/_data/tweeted.json content/_data/rust/posts.json
