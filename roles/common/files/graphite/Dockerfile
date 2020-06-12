FROM graphiteapp/graphite-statsd:1.1.7-2

ADD 20_fix_graphite_conf.sh /etc/my_init.d/20_fix_graphite_conf.sh
ADD carbon.conf /opt/graphite/conf/carbon.conf
ADD storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
ADD blacklist.conf /opt/graphite/conf/blacklist.conf

