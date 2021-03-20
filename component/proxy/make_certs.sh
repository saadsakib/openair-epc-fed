rm -rf demoCA
mkdir demoCA
echo 01 > demoCA/serial
touch demoCA/index.txt

if [ "$#" -lt 2 ]; then
  echo "error provide arguments: host domain [prefix]"
  return
fi
if [ "$#" -gt 3 ]; then
  echo "error provide arguments: host domain [prefix]"
  return
fi

HOST=$1
DOMAIN=$2
# usually /usr/local/etc/oai
if [ "$#" -eq 3 ]; then
  PREFIX=$3
else
  PREFIX="/usr/local/etc/oai"
fi

# CA self certificate
openssl req  -new -batch -x509 -days 3650 -nodes -newkey rsa:1024 -out $HOST.cacert.pem -keyout $HOST.cakey.pem -subj /CN=$HOST.$DOMAIN/C=FR/ST=BdR/L=Aix/O=fD/OU=Tests
#
openssl genrsa -out $HOST.key.pem 1024
openssl req -new -batch -out $HOST.csr.pem -key $HOST.key.pem -subj /CN=$HOST.$DOMAIN/C=FR/ST=BdR/L=Aix/O=fD/OU=Tests

openssl ca -cert $HOST.cacert.pem -keyfile $HOST.cakey.pem -in $HOST.csr.pem -out $HOST.cert.pem -outdir . -batch


SUDO='sudo -S -E'

# $SUDO cp -upv $HOST.cert.pem cacert.pem $HOST.key.pem  $PREFIX/freeDiameter

