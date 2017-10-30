FROM openjdk:8

WORKDIR /opt/app
RUN mkdir -p /opt/app/liquibase && cd liquibase && wget https://jdbc.postgresql.org/download/postgresql-42.1.4.jar &&\
	wget https://github.com/liquibase/liquibase/releases/download/liquibase-parent-3.5.3/liquibase-3.5.3-bin.tar.gz &&\
	tar xzf liquibase-3.5.3-bin.tar.gz && rm liquibase-3.5.3-bin.tar.gz
EXPOSE 9000