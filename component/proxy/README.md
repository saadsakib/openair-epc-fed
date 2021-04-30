# Proxy

## Architecture

Home HSS -- virtual MME -- relay -- virtual HSS -- foreign MME

## Create certificates

```
./make_certs.sh hss proxy.co

./make_certs.sh mme proxy.co

./make_certs.sh relay proxy.co
```

## Run

```
freeDiameterd -dd -c virtualhss.conf
freeDiameterd -dd -c virtualmme.conf
freeDiameterd -dd -c relay.conf
```
