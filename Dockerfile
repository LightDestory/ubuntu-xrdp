FROM ubuntu:21.04
ENV DEBIAN_FRONTEND noninteractive
RUN apt -y update && apt -y install apt-utils software-properties-common
ENV BUILD_DEPS="git autoconf pkg-config libssl-dev libpam0g-dev \
  libx11-dev libxfixes-dev libxrandr-dev nasm xsltproc flex \
  bison libxml2-dev dpkg-dev libcap-dev build-essential libc6-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev qtbase5-dev zlib1g-dev libpulse-dev"
RUN apt -y update && apt -y full-upgrade && apt -yy install xrdp $BUILD_DEPS

# Install Stuff

RUN apt install -y \
  ca-certificates \
  crudini \
  less \
  locales \
  openssh-server \
  supervisor \
  uuid-runtime \
  wget \
  xauth \
  xautolock \
  xfce4 \
  xfce4-clipman-plugin \
  xfce4-cpugraph-plugin \
  xfce4-netload-plugin \
  xfce4-screenshooter \
  xfce4-taskmanager \
  xfce4-terminal \
  xfce4-xkb-plugin \
  xorgxrdp \
  xprintidle \
  mousepad \
  vlc \
  nano \
  curl \
  fish \
  aria2 \
  mkvtoolnix \ 
  mkvtoolnix-gui \
  mediainfo \
  mediainfo-gui \
  filezilla \
  ffmpeg \
  trash-cli \ 
  unrar \
  xarchiver \
  htop && \
  apt remove -y light-locker xscreensaver && \
  apt autoremove -y

# Chrome

WORKDIR /tmp
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
  apt install -y ./google-chrome-stable_current_amd64.deb

# Youtube-DLP

RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
  chmod a+rx /usr/local/bin/yt-dlp

# RenameMyTVSeries

WORKDIR /tmp
RUN wget https://www.tweaking4all.com/downloads/betas/RenameMyTVSeries-2.1.6-GTK-b23-beta-Linux-64bit-shared-ffmpeg.tar.gz && \
  mkdir /usr/share/RenameMyTVSeries && \
  tar -zxvf RenameMyTVSeries-2.1.6-GTK-b23-beta-Linux-64bit-shared-ffmpeg.tar.gz -C /usr/share/RenameMyTVSeries

# MakeMKV

WORKDIR /tmp
RUN wget https://www.makemkv.com/download/makemkv-bin-1.16.4.tar.gz && wget https://www.makemkv.com/download/makemkv-oss-1.16.4.tar.gz
RUN tar -zxvf makemkv-oss-1.16.4.tar.gz
WORKDIR /tmp/makemkv-oss-1.16.4
RUN ./configure && make && make install
WORKDIR /tmp
RUN tar -zxvf makemkv-bin-1.16.4.tar.gz
WORKDIR /tmp/makemkv-bin-1.16.4
RUN echo "yes" | make
RUN make install

# ADMVCP

WORKDIR /tmp
RUN wget http://ftp.gnu.org/gnu/coreutils/coreutils-8.32.tar.xz && tar -xvJf coreutils-8.32.tar.xz
WORKDIR /tmp/coreutils-8.32
RUN wget https://raw.githubusercontent.com/jarun/advcpmv/master/advcpmv-0.8-8.32.patch && \
patch -p1 -i advcpmv-0.8-8.32.patch && \
FORCE_UNSAFE_CONFIGURE=1 ./configure && \
make && \
mv ./src/cp /usr/local/bin/cpg && \
mv ./src/mv /usr/local/bin/mvg

# Scripts inejct

ADD bin /usr/bin
ADD etc /etc
ADD autostart /etc/xdg/autostart

# Configure

RUN mkdir /var/run/dbus && \
  cp /etc/X11/xrdp/xorg.conf /etc/X11 && \
  sed -i "s/console/anybody/g" /etc/X11/Xwrapper.config && \
  sed -i "s/xrdp\/xorg/xorg/g" /etc/xrdp/sesman.ini && \
  locale-gen en_US.UTF-8 && \
  sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
  service ssh restart

# Clean Up
WORKDIR /tmp
RUN rm -r *

# Pref apps fix
RUN echo "2" | update-alternatives --config x-terminal-emulator

# Fix vlc as root

RUN sed -i 's/geteuid/getppid/' /usr/bin/vlc 

# Docker config

EXPOSE 3389 22 9001
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["supervisord"]
