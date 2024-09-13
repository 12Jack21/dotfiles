FROM ubuntu:20.04
# port for ssh, http, https
EXPOSE 22 8080 443

# github to githubfast as mirror website
ARG GITHUB_DOMAIN="githubfast.com"

# skip time zone selection of tzdata(pack)
ENV DEBIAN_FRONTEND=noninteractive
# zsh statusline theme color
ENV TERM=xterm-256color

# configure apt mirror
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse\n\
\n\
deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse\n\
\n\
deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse\n\
\n\
# deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse\n\
# deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse\n\
\n\
deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse" \
> /etc/apt/sources.list  && apt update && apt upgrade && apt install curl lsb-release wget build-essential dpkg vim unzip fontconfig -y 

# configure nodejs mirror
RUN curl -s https://deb.nodesource.com/setup_16.x | bash &&  apt install nodejs -y && npm config set registry https://registry.npmmirror.com

# configure docker mirror
RUN mkdir /etc/docker && apt install docker -y && echo '{ \
    "registry-mirrors": [ \
        "https://docker.m.daocloud.io", \
        "https://dockerproxy.com", \
        "https://docker.mirrors.ustc.edu.cn", \
        "https://docker.nju.edu.cn", \
        "https://dockerhub.icu", \
        "https://docker.chenby.cn", \
        "https://docker.1panel.live", \
        "https://docker.awsl9527.cn", \
        "https://docker.anyhub.us.kg", \
        "https://dhub.kubesre.xyz" \
    ] \
}' | tee /etc/docker/daemon.json
# Reset DEBIAN_FRONTEND to the default
# ENV DEBIAN_FRONTEND=dialog

# configure go mirror
RUN apt install golang-go -y && go env -w GO111MODULE=on && go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct

# Docker does not support systemmd/systemctl, so snap/snapd is not available inside Docker
# Create necessary directories for snapd (docker cannot use systemctl or systemmd)
# RUN apt install snapd sudo squashfs-tools  -y && mkdir -p /var/lib/snapd /snap
# # RUN /usr/lib/snapd/snapd --daemon && /usr/bin/snap install btop lnav dust 
# RUN service snapd start
# # RUN /usr/bin/snap install btop lnav dust
# RUN snap install btop lnav dust


# extra apps installation (btop, lnav, duf, dust, autojump)  trash?
RUN apt install sudo squashfs-tools lnav autojump zsh git -y

# TODO: change password
RUN useradd -m siri
# WORKDIR /home/siri
RUN wget https://${GITHUB_DOMAIN}/aristocratos/btop/releases/download/v1.3.2/btop-x86_64-linux-musl.tbz && tar -xjf ./btop-x86_64-linux-musl.tbz && cd ./btop && make install
RUN wget https://${GITHUB_DOMAIN}/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_amd64.deb && dpkg -i duf_0.8.1_linux_amd64.deb
# install dust with deb-get(pack manager) or from release package
RUN wget https://${GITHUB_DOMAIN}/bootandy/dust/releases/download/v1.1.1/dust-v1.1.1-aarch64-unknown-linux-musl.tar.gz && tar -xvf dust-v1.1.1-aarch64-unknown-linux-musl.tar.gz && mv dust-v1.1.1-aarch64-unknown-linux-musl/dust /usr/local/bin/
# RUN curl -sL https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | bash -s install deb-get && deb-get install du-dust

# install tmux 3.4
RUN apt update && apt install libevent-dev ncurses-dev bison pkg-config -y
RUN wget https://${GITHUB_DOMAIN}/tmux/tmux/releases/download/3.4/tmux-3.4.tar.gz && tar vxf tmux-3.4.tar.gz && cd tmux-3.4 && ./configure && make && make install

# configure fzf
RUN wget https://${GITHUB_DOMAIN}/junegunn/fzf/releases/download/v0.55.0/fzf-0.55.0-linux_amd64.tar.gz && tar xvf fzf-0.55.0-linux_amd64.tar.gz && mv fzf /usr/local/bin/

# configure neovim (at least v0.10.1)
RUN wget https://${GITHUB_DOMAIN}/neovim/neovim/releases/download/v0.10.1/nvim-linux64.tar.gz && tar xzvf nvim-linux64.tar.gz && ln -s /nvim-linux64/bin/nvim /usr/local/bin/nvim
# RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/12Jack21/nvim/HEAD/scripts/install.sh)"

# yadm get dotfiles and bootstrap
RUN apt install yadm -y


# USER siri

RUN yadm clone --bootstrap -b main https://${GITHUB_DOMAIN}/12Jack21/dotfiles 

# locale issue (LANGUAGE)
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN apt install locales -y && locale-gen en_US.UTF-8 
# RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# install micromamba instead of anaconda
# Set SHELL environment variable globally
ENV SHELL=/bin/zsh
RUN zsh -c "$(curl -L micro.mamba.pm/install.sh)"

CMD zsh && cd ~
