deploy:
	rsync -avz --delete public/ eforce.binarytrance.com:/usr/local/www/readrust.net/
