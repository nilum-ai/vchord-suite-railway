FROM tensorchord/vchord-suite:pg17-latest

COPY init.sql /docker-entrypoint-initdb.d/