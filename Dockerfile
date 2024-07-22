FROM crystallang/crystal:1.12.1-alpine AS builder
RUN apk add --no-cache sqlite-static yaml-static git
ARG release
RUN mkdir /invidious
WORKDIR /git
RUN git clone https://github.com/iv-org/invidious.git
WORKDIR /git/invidious
RUN cp shard.yml shard.lock /invidious/
RUN cp -r src .git scripts assets videojs-dependencies.yml /invidious/
WORKDIR /invidious
RUN shards install --production
RUN crystal spec --warnings all \
    --link-flags "-lxml2 -llzma"
RUN crystal spec --warnings all \
    --link-flags "-lxml2 -llzma"    
RUN if [[ "${release}" == 1 ]] ; then \
        crystal build ./src/invidious.cr \
        --release \
        --static --warnings all \
        --link-flags "-lxml2 -llzma"; \
    else \
        crystal build ./src/invidious.cr \
        --static --warnings all \
        --link-flags "-lxml2 -llzma"; \
    fi

FROM alpine:latest
RUN apk add --no-cache rsvg-convert font-opensans tini
WORKDIR /invidious
RUN addgroup -g 1000 -S invidious && adduser -u 1000 -S invidious -G invidious 
COPY --from=builder --chown=invidious /git/invidious/config/config.* ./config/
RUN mv -n config/config.example.yml config/config.yml

COPY --from=builder /git/invidious/config/sql/ ./config/sql/
COPY --from=builder /git/invidious/locales/ ./locales/

COPY --from=builder /invidious/assets ./assets/
COPY --from=builder /invidious/invidious .

RUN chmod o+rX -R ./assets ./config ./locales

EXPOSE 3000
USER invidious
CMD [ "/invidious/invidious" ]
