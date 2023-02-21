FROM nimlang/nim:alpine

RUN apk update
RUN apk add --no-cache pcre-dev

WORKDIR /ebolik
COPY . .

RUN ["nimble", "-y", "--gc:orc", "-d:release", "--opt:speed", "-d:ssl", "-d:discordCompress", "build"]

ENTRYPOINT [ "./bin/ebolik" ]