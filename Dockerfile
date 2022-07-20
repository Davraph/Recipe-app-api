FROM python:3.9-alpine3.13
LABEL maintainer="developsrapheal28@gmail.com"



ENV PYTHONUNBUFFERED 1


COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

COPY ./app /app
WORKDIR /app
EXPOSE 8000


ARG DEV=false
#create  a new virtual env in docker image
RUN python -m venv /py && \
#this upgrade pip in Venv
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    #install requirement in docker image
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    #best not to use root user if compromise attack have full access 
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

#update path in env variable
ENV PATH="/py/bin:$PATH"

USER django-user
