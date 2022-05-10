FROM centos:7
RUN yum update -y && \
yum install wget  perl-Digest-SHA -y
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.2.0-linux-x86_64.tar.gz; \
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.2.0-linux-x86_64.tar.gz.sha512; \
shasum -a 512 -c elasticsearch-8.2.0-linux-x86_64.tar.gz.sha512
RUN tar -xzf elasticsearch-8.2.0-linux-x86_64.tar.gz
RUN groupadd elasticsearch; \
useradd elasticsearch -g elasticsearch; \
mkdir /var/lib/data /var/lib/logs /elasticsearch-8.2.0/snapshots; \
chown -R elasticsearch:elasticsearch /elasticsearch-8.2.0; \
chown elasticsearch:elasticsearch /var/lib/data /var/lib/logs
ENV ES_HOME=/elasticsearch-8.2.0
COPY elasticsearch.yml /elasticsearch-8.2.0/config/
WORKDIR /elasticsearch-8.2.0
USER elasticsearch
CMD [ "/elasticsearch-8.2.0/bin/elasticsearch" ]