FROM python:2.7.15
ENV PYTHONUNBUFFERED 1

RUN mkdir /code
WORKDIR /code

ADD . /code/
COPY ./docker-entrypoint.sh /
RUN pip install -r /code/requirements_docker.txt


RUN /code/local_setup.sh

CMD ["/docker-entrypoint.sh"]
