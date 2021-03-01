# Remove epc containers
docker stop prod-cassandra prod-oai-hss prod-oai-mme prod-oai-spgwc prod-oai-spgwu-tiny -t 1
docker rm prod-cassandra prod-oai-hss prod-oai-mme prod-oai-spgwc prod-oai-spgwu-tiny

# Config network 
sudo sysctl net.ipv4.conf.all.forwarding=1
sudo iptables -P FORWARD ACCEPT

# Deploy(run) the containers
docker run --name prod-cassandra -d -e CASSANDRA_CLUSTER_NAME="OAI HSS Cluster" \
             -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch cassandra:2.1
sleep 2
docker run --privileged --name prod-oai-hss -d --entrypoint /bin/bash oai-hss:production -c "sleep infinity"
sleep 2
docker network connect prod-oai-public-net prod-oai-hss
sleep 2
docker run --privileged --name prod-oai-mme --network prod-oai-public-net \
             -d --entrypoint /bin/bash oai-mme:production -c "sleep infinity"
sleep 2
docker run --privileged --name prod-oai-spgwc --network prod-oai-public-net \
             -d --entrypoint /bin/bash oai-spgwc:production -c "sleep infinity"
sleep 2
docker run --privileged --name prod-oai-spgwu-tiny --network prod-oai-public-net \
             -d --entrypoint /bin/bash oai-spgwu-tiny:production -c "sleep infinity"
sleep 2

# Configure the containers
## Cassandra
docker cp component/oai-hss/src/hss_rel14/db/oai_db.cql prod-cassandra:/home
docker exec -it prod-cassandra /bin/bash -c "nodetool status"
Cassandra_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-cassandra`
docker exec -it prod-cassandra /bin/bash -c "cqlsh --file /home/oai_db.cql ${Cassandra_IP}"
sleep 2

## HSS
HSS_IP=`docker exec -it prod-oai-hss /bin/bash -c "ifconfig eth1 | grep inet" | sed -f ./ci-scripts/convertIpAddrFromIfconfig.sed`
python3 component/oai-hss/ci-scripts/generateConfigFiles.py --kind=HSS --cassandra=${Cassandra_IP} --hss_s6a=${HSS_IP} --apn1=apn1.carrier.com --apn2=apn2.carrier.com --users=5 --imsi=208931234561000 --ltek=fec86ba6eb707ed08905757b1bb44b8f --op=1006020f0a478bf6b699f15c062e42b3 --nb_mmes=1 --from_docker_file
docker cp ./hss-cfg.sh prod-oai-hss:/openair-hss/scripts
docker exec -it prod-oai-hss /bin/bash -c "cd /openair-hss/scripts && chmod 777 hss-cfg.sh && ./hss-cfg.sh"
sleep 2

## MME
MME_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-oai-mme`
SPGW0_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-oai-spgwc`
python3 component/oai-mme/ci-scripts/generateConfigFiles.py --kind=MME \
          --hss_s6a=${HSS_IP} --mme_s6a=${MME_IP} \
          --mme_s1c_IP=${MME_IP} --mme_s1c_name=eth0 \
          --mme_s10_IP=${MME_IP} --mme_s10_name=eth0 \
          --mme_s11_IP=${MME_IP} --mme_s11_name=eth0 --spgwc0_s11_IP=${SPGW0_IP} \
          --mcc=208 --mnc=93 --tac_list="600 601 602" --from_docker_file
docker cp ./mme-cfg.sh prod-oai-mme:/openair-mme/scripts
docker exec -it prod-oai-mme /bin/bash -c "cd /openair-mme/scripts && chmod 777 mme-cfg.sh && ./mme-cfg.sh"
sleep 2

## SPGW-C
MY_DNS_IP_ADDRESS='127.0.0.53'
A_SECONDARY_DNS_IP_ADDRESS='127.0.0.53'
python3 component/oai-spgwc/ci-scripts/generateConfigFiles.py --kind=SPGW-C \
          --s11c=eth0 --sxc=eth0 --apn=apn1.carrier.com \
          --dns1_ip=${MY_DNS_IP_ADDRESS} --dns2_ip=${A_SECONDARY_DNS_IP_ADDRESS} --from_docker_file
docker cp ./spgwc-cfg.sh prod-oai-spgwc:/openair-spgwc
docker exec -it prod-oai-spgwc /bin/bash -c "cd /openair-spgwc && chmod 777 spgwc-cfg.sh && ./spgwc-cfg.sh"
sleep 2

## SPGW-U
python3 component/oai-spgwu-tiny/ci-scripts/generateConfigFiles.py --kind=SPGW-U \
          --sxc_ip_addr=${SPGW0_IP} --sxu=eth0 --s1u=eth0 --network_ue_nat_option=yes --from_docker_file
docker cp ./spgwu-cfg.sh prod-oai-spgwu-tiny:/openair-spgwu-tiny
docker exec -it prod-oai-spgwu-tiny /bin/bash -c "cd /openair-spgwu-tiny && chmod 777 spgwu-cfg.sh && ./spgwu-cfg.sh"
sleep 2

# Running Network Functions
## Launch tshark
docker exec -d prod-oai-hss /bin/bash -c "nohup tshark -i eth0 -i eth1 -w /tmp/hss_check_run.pcap 2>&1 > /dev/null"
docker exec -d prod-oai-mme /bin/bash -c "nohup tshark -i eth0 -i lo:s10 -w /tmp/mme_check_run.pcap 2>&1 > /dev/null"
docker exec -d prod-oai-spgwc /bin/bash -c "nohup tshark -i eth0 -i lo:p5c -i lo:s5c -w /tmp/spgwc_check_run.pcap 2>&1 > /dev/null"
docker exec -d prod-oai-spgwu-tiny /bin/bash -c "nohup tshark -i eth0 -w /tmp/spgwu_check_run.pcap 2>&1 > /dev/null"
sleep 2

## Launch network functions
docker exec -d prod-oai-hss /bin/bash -c "nohup ./bin/oai_hss -j ./etc/hss_rel14.json --reloadkey true > hss_check_run.log 2>&1"
sleep 2
docker exec -d prod-oai-mme /bin/bash -c "nohup ./bin/oai_mme -c ./etc/mme.conf > mme_check_run.log 2>&1"
sleep 2
docker exec -d prod-oai-spgwc /bin/bash -c "nohup ./bin/oai_spgwc -o -c ./etc/spgw_c.conf > spgwc_check_run.log 2>&1"
sleep 2
docker exec -d prod-oai-spgwu-tiny /bin/bash -c "nohup ./bin/oai_spgwu -o -c ./etc/spgw_u.conf > spgwu_check_run.log 2>&1"

echo "done"