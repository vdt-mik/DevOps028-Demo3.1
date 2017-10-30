FROM ubuntu:latest

ARG DB_NAME
ARG DB_USER
ARG DB_PASS

ENV DB_NAME ${DB_NAME}
ENV DB_USER ${DB_USER}
ENV DB_PASS ${DB_PASS}

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8;\
 echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list;\ 
 apt-get update; apt-get install -y postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3; rm -rf /var/lib/apt/lists/*
USER postgres
RUN /etc/init.d/postgresql start && psql --command "CREATE USER ${DB_USER} WITH SUPERUSER PASSWORD '{DB_PASS}';" && createdb -O ${DB_USER} ${DB_NAME}
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf; echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf
EXPOSE 5432
VOLUME  ["/etc/postgresql"]
CMD /usr/lib/postgresql/9.3/bin/postgres -c config_file=/etc/postgresql/9.3/main/postgresql.conf -D /var/lib/postgresql/9.3/main 






















