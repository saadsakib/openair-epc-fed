# Recovering logs 
date_dir="`date +%F`"
time_dir="`date +%H_%M`"
archive_dir=./archives

log_dir=$archive_dir/$date_dir/$time_dir
mkdir -p $log_dir

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