# Proxy 

## Create certificates 
```
./make_certs.sh hss proxy.co

./make_certs.sh mme proxy.co
```

## Run 
```
freeDiameterd -c virtualhss.conf 
freeDiameterd -c virtualmme.conf
```