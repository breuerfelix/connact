FROM python:3-alpine
WORKDIR /radicale

# bcrypt dependencies
RUN apk add --update musl-dev gcc cargo

COPY auth_plugin auth_plugin
RUN python3 -m pip install ./auth_plugin

COPY radicale.conf /etc/radicale/radicale.conf

EXPOSE 5232
CMD ["python3" , "-m", "radicale", "--debug", "--config=/etc/radicale/radicale.conf"]
