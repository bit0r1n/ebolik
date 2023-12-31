FROM nimlang/nim:2.0.0-alpine

RUN apk update
RUN apk add --no-cache pcre-dev

WORKDIR /ebolik
COPY . .

RUN ["nimble", "-y", "--mm:refc", "-d:release", "--opt:speed", "-d:ssl", "-d:discordCompress", "build"]

ENTRYPOINT [ "./bin/ebolik" ]
