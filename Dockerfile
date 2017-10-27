FROM 303036157700.dkr.ecr.eu-central-1.amazonaws.com/samsara:dep

ARG DB_HOST
ARG DB_PORT
ARG DB_NAME
ARG DB_USER
ARG DB_PASS
ARG HOST=localhost
ARG ART_NAME

ENV DB_HOST ${DB_HOST}
ENV DB_PORT ${DB_PORT}
ENV DB_NAME ${DB_NAME}
ENV DB_USER ${DB_USER}
ENV DB_PASS ${DB_PASS}
ENV HOST ${HOST}

RUN { \
	echo "driver: org.postgresql.Driver"; \
	echo "url: jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}"; \
	echo "username: ${DB_USER}"; \
	echo "password: ${DB_PASS}"; \
	echo "referenceUrl=hibernate:spring:academy.softserve.aura.core.entity?dialect=org.hibernate.dialect.PostgreSQL9Dialect"; \
	} > /opt/app/liquibase/liquibase.properties 
RUN cd /opt/app/liquibase/ && ./liquibase --classpath=./postgresql-42.1.4.jar --changeLogFile=./changelogs/changelog-main.xml --defaultsFile=./liquibase.properties update
EXPOSE 9000
WORKDIR /opt/app
COPY ${ART_NAME} .
CMD java -jar *.jar