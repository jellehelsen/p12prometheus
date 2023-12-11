FROM python:3.11
MAINTAINER Jelle Helsen <jelle.helsen@hcode.be>

COPY requirements.txt /app/
RUN pip install -r /app/requirements.txt
COPY p12prometheus/cli.py /app/cli
CMD /app/cli
