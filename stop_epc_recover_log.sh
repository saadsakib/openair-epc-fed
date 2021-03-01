# Stopping 
docker exec -it prod-oai-hss /bin/bash -c "killall --signal SIGINT oai_hss tshark"
docker exec -it prod-oai-mme /bin/bash -c "killall --signal SIGINT oai_mme tshark"
docker exec -it prod-oai-spgwc /bin/bash -c "killall --signal SIGINT oai_spgwc tshark"
docker exec -it prod-oai-spgwu-tiny /bin/bash -c "killall --signal SIGINT oai_spgwu tshark"
sleep 10
docker exec -it prod-oai-hss /bin/bash -c "killall --signal SIGKILL oai_hss tshark"
docker exec -it prod-oai-mme /bin/bash -c "killall --signal SIGKILL oai_mme tshark"
docker exec -it prod-oai-spgwc /bin/bash -c "killall --signal SIGKILL oai_spgwc tshark"
docker exec -it prod-oai-spgwu-tiny /bin/bash -c "killall --signal SIGKILL oai_spgwu tshark"

# Recovering logs 
date_dir="`date +%F`"
time_dir="`date +%H_%M`"
archive_dir=./archives
#cd $archive_dir
# [ -d $date_dir ] || mkdir $date_dir
# cd $date_dir
# [ -d $time_dir ] || mkdir $time_dir
log_dir=$archive_dir/$date_dir/$time_dir
mkdir -p $log_dir/oai-hss-cfg $log_dir/oai-mme-cfg $log_dir/oai-spgwc-cfg $log_dir/oai-spgwu-cfg

# retrieve the modified configuration files
docker cp prod-oai-hss:/openair-hss/etc/. $log_dir/oai-hss-cfg
docker cp prod-oai-mme:/openair-mme/etc/. $log_dir/oai-mme-cfg
docker cp prod-oai-spgwc:/openair-spgwc/etc/. $log_dir/oai-spgwc-cfg
docker cp prod-oai-spgwu-tiny:/openair-spgwu-tiny/etc/. $log_dir/oai-spgwu-cfg

# Then, the logs
docker cp prod-oai-hss:/openair-hss/hss_check_run.log $log_dir
docker cp prod-oai-mme:/openair-mme/mme_check_run.log $log_dir
docker cp prod-oai-spgwc:/openair-spgwc/spgwc_check_run.log $log_dir
docker cp prod-oai-spgwu-tiny:/openair-spgwu-tiny/spgwu_check_run.log $log_dir

# Finally the PCAP.
docker cp prod-oai-hss:/tmp/hss_check_run.pcap $log_dir
docker cp prod-oai-mme:/tmp/mme_check_run.pcap $log_dir
docker cp prod-oai-spgwc:/tmp/spgwc_check_run.pcap $log_dir
docker cp prod-oai-spgwu-tiny:/tmp/spgwu_check_run.pcap $log_dir

# Stop and remove epc containers
docker stop prod-cassandra prod-oai-hss prod-oai-mme prod-oai-spgwc prod-oai-spgwu-tiny -t 1
docker rm prod-cassandra prod-oai-hss prod-oai-mme prod-oai-spgwc prod-oai-spgwu-tiny