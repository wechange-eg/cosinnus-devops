FROM python:2.7.15
ENV PYTHONUNBUFFERED 1
RUN apt-get update && apt-get install -y libgeos-dev

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs && \
      npm i -g npm

RUN mkdir /code
WORKDIR /code

ADD . /code/
COPY ./docker-entrypoint.sh /
COPY devops/settings_docker.py /code/devops/settings.py
RUN pip install -r /code/requirements_docker.txt

RUN /code/local_setup.sh
WORKDIR /code/cosinnus-core
RUN npm i --production && npm run production
WORKDIR /code
CMD ["/docker-entrypoint.sh"]
