# Proxy 

## Create certificates 
```
./make_certs.sh virtualhss proxy.co

./make_certs.sh virtualmme proxy.co
```

## Run 
```
freeDiameterd -c virtualhss.conf 
freeDiameterd -c virtualmme.conf
```