# Recovering logs 
date_dir="`date +%F`"
time_dir="`date +%H_%M`"
archive_dir=./archives

log_dir=$archive_dir/$date_dir/$time_dir
mkdir -p $log_dir
# mkdir -p $log_dir/oai-hss-cfg $log_dir/oai-mme-cfg $log_dir/oai-spgwc-cfg $log_dir/oai-spgwu-cfg

# retrieve the modified configuration files
docker cp prod-oai-hss:/openair-hss/etc/. $log_dir/oai-hss-cfg
docker cp prod-oai-hss-home:/openair-hss/etc/. $log_dir/oai-home-hss-cfg
docker cp prod-oai-mme:/openair-mme/etc/. $log_dir/oai-mme-cfg
docker cp prod-oai-mme-home:/openair-mme/etc/. $log_dir/oai-home-mme-cfg
docker cp prod-oai-spgwc:/openair-spgwc/etc/. $log_dir/oai-spgwc-cfg
docker cp prod-oai-spgwu-tiny:/openair-spgwu-tiny/etc/. $log_dir/oai-spgwu-cfg

# Then, the logs
docker cp prod-oai-hss:/openair-hss/hss_check_run.log $log_dir
docker cp prod-oai-hss-home:/openair-hss/home_hss_check_run.log $log_dir
docker cp prod-oai-mme:/openair-mme/mme_check_run.log $log_dir
docker cp prod-oai-mme-home:/openair-mme/home_mme_check_run.log $log_dir
docker cp prod-oai-spgwc:/openair-spgwc/spgwc_check_run.log $log_dir
docker cp prod-oai-spgwu-tiny:/openair-spgwu-tiny/spgwu_check_run.log $log_dir

# Finally the PCAP.
docker cp prod-oai-hss:/tmp/hss_check_run.pcap $log_dir
docker cp prod-oai-hss-home:/tmp/home_hss_check_run.pcap $log_dir
docker cp prod-oai-mme:/tmp/mme_check_run.pcap $log_dir
docker cp prod-oai-mme-home:/tmp/home_mme_check_run.pcap $log_dir
docker cp prod-oai-spgwc:/tmp/spgwc_check_run.pcap $log_dir
docker cp prod-oai-spgwu-tiny:/tmp/spgwu_check_run.pcap $log_dir