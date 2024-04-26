FROM nimlang/nim:2.0.4-alpine

RUN apk update
RUN apk add --no-cache pcre-dev

WORKDIR /ebolik
COPY . .

RUN ["nimble", "-y", "build"]

RUN [ "./bin/ebolik" ]
