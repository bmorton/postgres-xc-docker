FROM ubuntu:14.04
MAINTAINER Brian Morton "brian@xq3.net"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y build-essential libreadline-dev zlib1g-dev flex bison

ENV VERSION 1.0.4
ENV INSTALL_DIR /opt/postgres-xc
ENV DATA_DIR /data
ENV LOG_DIR /var/log/postgresql

ADD http://downloads.sourceforge.net/project/postgres-xc/Version_1.0/pgxc-v$VERSION.tar.gz /tmp/pgxc.tar.gz
RUN cd /tmp && tar -xzvf pgxc.tar.gz
RUN cd /tmp/postgres-xc-$VERSION && ./configure --prefix=$INSTALL_DIR && make && make install

RUN adduser --disabled-password --gecos '' postgres
RUN adduser postgres sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV PATH $INSTALL_DIR/bin:$PATH
RUN mkdir $DATA_DIR && chown -R postgres $DATA_DIR
RUN mkdir $LOG_DIR && chown -R postgres $LOG_DIR

RUN sudo -iu postgres sh -c "cd $DATA_DIR && $INSTALL_DIR/bin/initgtm -Z gtm -D gtm"
RUN sudo -iu postgres sh -c "cd $DATA_DIR && $INSTALL_DIR/bin/initdb -D datanode1 --nodename dn1"
RUN sudo -iu postgres sh -c "cd $DATA_DIR && $INSTALL_DIR/bin/initdb -D datanode2 --nodename dn2"
RUN sudo -iu postgres sh -c "cd $DATA_DIR && $INSTALL_DIR/bin/initdb -D coord1 --nodename co1"

RUN sed -i 's/^#port =.*/port = 15432/' /data/datanode1/postgresql.conf
RUN sed -i 's/^#port =.*/port = 15433/' /data/datanode2/postgresql.conf
RUN sed -i 's/^#port =.*/port = 5432/' /data/coord1/postgresql.conf
RUN sed -i "s/^#listen_addresses =.*/listen_addresses = '*'/" /data/coord1/postgresql.conf
RUN echo "host all all 0.0.0.0/0 trust" >> /data/coord1/pg_hba.conf

ADD script/start /start
ADD script/init_cluster /init_cluster
RUN chmod +x /start && chmod +x /init_cluster

EXPOSE 5432
CMD ["/start"]
