echo "this is the test post-install"
sed -i 's/Welcome\ to\ nginx!/pegaz test page/' /usr/share/nginx/html/index.html
sed -i 's/If you see this page/this file was edited with post-install.sh/' /usr/share/nginx/html/index.html
