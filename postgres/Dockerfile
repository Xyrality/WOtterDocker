FROM postgres:9.4

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ???_*.sql /docker-entrypoint-initdb.d/

CMD ["postgres"]
