cd ci-scripts
docker build --target trf-gen --tag trf-gen:production --file Dockerfile.traffic.generator.ubuntu18.04 .
sleep 1

docker run --privileged --name prod-trf-gen --network prod-oai-public-net -d trf-gen:production /bin/bash -c "sleep infinity"
sleep 1

SPGWU_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-oai-spgwu-tiny`
docker exec -it prod-trf-gen /bin/bash -c "ip route add 12.1.1.0/24 via ${SPGWU_IP} dev eth0"

docker exec -it prod-trf-gen /bin/bash -c "ping -c 20 12.1.1.2"

