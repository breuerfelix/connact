FROM python:3
WORKDIR /radicale

# bcrypt dependencies
#RUN apk add --update musl-dev gcc cargo
RUN apt-get update
RUN apt-get install -y build-essential cargo

COPY auth_plugin auth_plugin
RUN python3 -m pip install ./auth_plugin

COPY radicale.conf /etc/radicale/radicale.conf

EXPOSE 5232
CMD ["python3" , "-m", "radicale", "--debug", "--config=/etc/radicale/radicale.conf"]
