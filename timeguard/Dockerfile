FROM ubuntu:16.04

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y wget && \
  apt-get install -y gconf2 && \
  apt-get install -y gconf-service && \
  apt-get install -y libnotify4 && \
  apt-get install -y libappindicator1 && \
  apt-get install -y libxtst6 && \
  apt-get install -y libnss3 && \
  apt-get install -y libxss1 && \
  apt-get install -y libasound2 && \
  wget https://tgms.qarea.org/distribution/linux/timeguard_0.17.38_amd64.deb && \
  dpkg -i timeguard_0.17.38_amd64.deb

VOLUME "/root/.config"

CMD timeguard
