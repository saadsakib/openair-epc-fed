# Proxy 

## Create certificates 
```
./make_certs.sh hss proxy.co

./make_certs.sh mme proxy.co
```

## Run 
```
freeDiameterd -dd -c virtualhss.conf 
freeDiameterd -dd -c virtualmme.conf
```