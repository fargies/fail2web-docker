FROM docker.io/nginx:stable

RUN apt update && apt install -y golang git

RUN git clone --depth=1 https://github.com/Sean-Der/fail2rest.git && \
    cd fail2rest && \
    go mod edit --replace github.com/sean-der/fail2go=github.com/fargies/fail2go@latest && \
    go mod tidy && \
    go install && \
    cd .. && rm -rf fail2rest

COPY fail2rest.conf /root/fail2rest.conf
COPY fail2rest.sh /docker-entrypoint.d/99-fail2rest.sh

RUN chmod +x /docker-entrypoint.d/99-fail2rest.sh

RUN git clone --depth=1 https://github.com/Sean-Der/fail2web.git && \
    mkdir -p /var/www && \
    mv fail2web/web /var/www/fail2web && \
    rm -rf fail2web

COPY nginx-fail2web.conf /etc/nginx/conf.d/default.conf

ENV FAIL2REST_CONFIG=/root/fail2rest.conf

EXPOSE 8080/tcp

RUN apt remove -y golang git && apt autoremove -y