docker run -d --restart=always --name=dropbox \
  -e DBOX_UID=1000 \
  -v /home/anpryl/Dropbox:/dbox/Dropbox \
  -v /etc/localtime:/etc/localtime:ro \
  --net="host" \
  janeczku/dropbox

