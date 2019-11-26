FROM alpine:3.10.3 AS rbenv_builder
ENV HOME /root

# ==================================================
# INSTALLING RUBY SDK INSTALLER
# =========================

RUN echo "\n=================\n INSTALLING RUBY SDK INSTALLER \n=================\n"
RUN apk add --no-cache bash gcc git libc-dev make

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN cd ~/.rbenv && src/configure && make -C src
ENV PATH $HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH

RUN mkdir -p "$(rbenv root)"/plugins
RUN git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

# ==================================================
# ==================================================

FROM alpine:3.10.3 AS final
ENV HOME /root

RUN apk add --no-cache bash g++ linux-headers make openssl-dev readline-dev zlib-dev

WORKDIR "$HOME"
COPY --from=rbenv_builder $HOME/.rbenv $HOME/.rbenv
ENV PATH $HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /root/.bash_profile
RUN echo 'echo "running profile"' >> /root/.bash_profile

# ==================================================
# INSTALLING NGINX
# =========================

RUN echo "\n=================\n INSTALLING NGINX \n=================\n"
RUN apk add --no-cache nginx
RUN mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
COPY nginx/nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /run/nginx

# ==================================================
# INSTALLING RUBY
# =========================
RUN echo "\n=================\n INSTALLING RUBY \n=================\n"
RUN rbenv install 2.6.4
