build:
	cp content/rust2018/feed.json content/_data/rust/posts.json
	cobalt build

deploy: build
	rsync -avz --delete public/ eforce.binarytrance.com:/usr/local/www/readrust.net/
