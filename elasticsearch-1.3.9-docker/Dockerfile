FROM ubuntu:16.04

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
    openjdk-8-jdk-headless

COPY elasticsearch-1.3.9.tar.gz /elasticsearch-1.3.9.tar.gz
RUN tar xzvf /elasticsearch-1.3.9.tar.gz

ENV PATH=$PATH:/elasticsearch-1.3.9/bin

CMD ["elasticsearch"]

EXPOSE 9200 9300
