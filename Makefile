POSTS=content/_data/rust/posts.json
GENERATE_RSS=target/release/generate-rss
CATEGORIES=content/_data/categories.json
TWEETED=content/_data/tweeted.json
TOOTED=content/_data/tooted.json
FEEDS=\
	content/all/feed.rss \
	content/community/feed.rss \
	content/computer-science/feed.rss \
	content/crates/feed.rss \
	content/devops-and-deployment/feed.rss \
	content/embedded/feed.rss \
	content/games-and-graphics/feed.rss \
	content/getting-started/feed.rss \
	content/language/feed.rss \
	content/operating-systems/feed.rss \
	content/performance/feed.rss \
	content/rust-2018/feed.rss \
	content/rust-2019/feed.rss \
	content/security/feed.rss \
	content/tools-and-applications/feed.rss \
	content/web-and-network-services/feed.rss

all: feeds
	cobalt build
	cargo run --release --bin toot -- -n ${TOOTED} ${POSTS} ${CATEGORIES}
	cargo run --release --bin tweet -- -n ${TWEETED} ${POSTS} ${CATEGORIES}

feeds: ${FEEDS}

${GENERATE_RSS}: src/bin/generate-rss.rs
	cargo build --release --bin generate-rss

content/all/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} ${POSTS} content/all/feed.rss

content/community/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Community' ${POSTS} content/community/feed.rss

content/computer-science/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Computer Science' ${POSTS} content/computer-science/feed.rss

content/crates/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Crates' ${POSTS} content/crates/feed.rss

content/devops-and-deployment/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'DevOps and Deployment' ${POSTS} content/devops-and-deployment/feed.rss

content/embedded/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Embedded' ${POSTS} content/embedded/feed.rss

content/games-and-graphics/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Games and Graphics' ${POSTS} content/games-and-graphics/feed.rss

content/getting-started/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Getting Started' ${POSTS} content/getting-started/feed.rss

content/language/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Language' ${POSTS} content/language/feed.rss

content/operating-systems/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Operating Systems' ${POSTS} content/operating-systems/feed.rss

content/performance/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Performance' ${POSTS} content/performance/feed.rss

content/rust-2018/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Rust 2018' ${POSTS} content/rust-2018/feed.rss

content/rust-2019/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Rust 2019' ${POSTS} content/rust-2019/feed.rss

content/security/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Security' ${POSTS} content/security/feed.rss

content/tools-and-applications/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Tools and Applications' ${POSTS} content/tools-and-applications/feed.rss

content/web-and-network-services/feed.rss: ${POSTS} ${GENERATE_RSS}
	${GENERATE_RSS} -t 'Web and Network Services' ${POSTS} content/web-and-network-services/feed.rss

sync:
	aws s3 sync --delete --exclude '*.rss' --cache-control 'max-age=120, public' public s3://readrust.net

syncfeeds:
	find public -name '*.rss' -print0 | sed 's/public\///g' | xargs -0 -n 1 -P 0 -I xxxfeed aws s3 cp --cache-control 'max-age=120, public' --content-type 'application/rss+xml' public/xxxfeed s3://readrust.net/xxxfeed

deploy: all sync syncfeeds
	cargo run --release --bin toot -- ${TOOTED} ${POSTS} content/_data/categories.json
	cargo run --release --bin tweet -- ${TWEETED} ${POSTS} content/_data/categories.json
