ALL_POSTS=content/_data/rust/posts.json
GENERATE_RSS=target/release/generate-rss
CATEGORIES=content/_data/categories.json
TWEETED=content/_data/tweeted.json
TOOTED=content/_data/tooted.json

all: feeds
	cobalt build
	cargo run --release --bin toot -- -n ${TOOTED} ${ALL_POSTS} ${CATEGORIES}
	cargo run --release --bin tweet -- -n ${TWEETED} ${ALL_POSTS} ${CATEGORIES}

feeds:
	cargo build --release --bin generate-rss
	${GENERATE_RSS} ${ALL_POSTS} content/all/feed.rss
	${GENERATE_RSS} -t 'Community' ${ALL_POSTS} content/community/feed.rss
	${GENERATE_RSS} -t 'Computer Science' ${ALL_POSTS} content/computer-science/feed.rss
	${GENERATE_RSS} -t 'Crates' ${ALL_POSTS} content/crates/feed.rss
	${GENERATE_RSS} -t 'DevOps and Deployment' ${ALL_POSTS} content/devops-and-deployment/feed.rss
	${GENERATE_RSS} -t 'Embedded' ${ALL_POSTS} content/embedded/feed.rss
	${GENERATE_RSS} -t 'Games and Graphics' ${ALL_POSTS} content/games-and-graphics/feed.rss
	${GENERATE_RSS} -t 'Getting Started' ${ALL_POSTS} content/getting-started/feed.rss
	${GENERATE_RSS} -t 'Language' ${ALL_POSTS} content/language/feed.rss
	${GENERATE_RSS} -t 'Operating Systems' ${ALL_POSTS} content/operating-systems/feed.rss
	${GENERATE_RSS} -t 'Performance' ${ALL_POSTS} content/performance/feed.rss
	${GENERATE_RSS} -t 'Rust 2018' ${ALL_POSTS} content/rust-2018/feed.rss
	${GENERATE_RSS} -t 'Tools and Applications' ${ALL_POSTS} content/tools-and-applications/feed.rss
	${GENERATE_RSS} -t 'Web and Network Services' ${ALL_POSTS} content/web-and-network-services/feed.rss

deploy: all
	aws s3 sync --delete --cache-control 'max-age=120, public' public s3://readrust.net
	cargo run --release --bin toot -- ${TOOTED} ${ALL_POSTS} content/_data/categories.json
	cargo run --release --bin tweet -- ${TWEETED} ${ALL_POSTS} content/_data/categories.json
