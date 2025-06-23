FROM nimlang/nim:2.2.4-ubuntu-regular

RUN apt update
RUN apt install -y libpcre3 libpcre3-dev

WORKDIR /ebolik
COPY . .

RUN ["nimble", "-y", "build"]

CMD [ "./bin/ebolik" ]
