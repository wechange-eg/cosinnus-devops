FROM python:2.7.15
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD . /code/
COPY devops/settings_docker.py /code/devops/settings.py

#RUN /code/local_setup.sh
RUN pip install -r /code/requirements_docker.txt

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]