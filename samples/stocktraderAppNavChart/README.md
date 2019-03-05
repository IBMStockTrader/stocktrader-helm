# IBM Stock Trader Helm Chart (Beta Version)

* Installs Stock Trader microservices 

Dependencies:
The user is required to prepare their Kubernetes cloud with the following:
- Create "stock-trader" namespace
- Install Db2
- Install MQ
- Install Redis
- Create secrets

## TL;DR;

From stock-trader-helm/ directory, run the following:

```console
$ helm install stocktrader/.  --namespace stock-trader
```


## Configuration

This helm chart has optional parameters to deploy Stock Trader from different locations:

Install from public DockerHub and use the "Basic Security" version with Login/Password:   stock/trader
```console
$ helm install stocktrader/.  --namespace stock-trader
```

Install from public DockerHub and use the "IBMid" version with an IBM ID required
```console
$ helm install stocktrader/.  -f docker-secure.yaml  --namespace stock-trader
```

Install from your private ICP docker registry and use the "IBMid" version with an IBM ID required
```console
$ helm install stocktrader/.  -f icp.yaml  --namespace stock-trader
```

## Secrets
#Redis
This uses the quandl key associated with an API key. Get your own from Quandl.
# Need to enter first one to pull password into an env var.
```console
REDIS_PASSWORD=$(kubectl get secret --namespace default sartorial-quetzal-redis -o jsonpath="{.data.redis-password}" | base64 --decode)
```

```console
kubectl create secret generic redis --from-literal=url=redis://x:$REDIS_PASSWORD@sartorial-quetzal-redis:6379 --from-literal=quandl-key=getYourQuandlKey
```

##MQ-dev
```console
kubectl create secret generic mq --from-literal=id=app  --from-literal=pwd= --from-literal=host=mq-dev-ibm-mqadvanced-se --from-literal=port=1414   --from-literal=channel=DEV.APP.SVRCONN   --from-literal=queue-manager=stocktrader  --from-literal=queue=NotificationQ         
```


##MQ-dev-External
```console
kubectl create secret generic mq --from-literal=id=app  --from-literal=pwd= --from-literal=host=9.42.24.89 --from-literal=port=32569   --from-literal=channel=DEV.APP.SVRCONN   --from-literal=queue-manager=stocktrader  --from-literal=queue=NotificationQ         
```


##DB2-dev
```console
kubectl create secret generic db2 --from-literal=id=db2inst1 --from-literal=pwd=password --from-literal=host=db2-dev-ibm-db2oltp-dev --from-literal=port=50000 --from-literal=db=trader
```


##OpenWhisk and Slack
```console
kubectl create secret generic openwhisk --from-literal=url=https://openwhisk.ng.bluemix.net/api/v1/namespaces/jalcorn%40us.ibm.com_dev/actions/PostLoyaltyLevelToSlack --from-literal=id=bc2b0a37-0554-4658-9ebe-ae068eb1aa22 --from-literal=pwd=45t2FZC1q1bv6OYUztZUjkYFaVNs5klaviHoE6gFvgEedu9akiE1YW6lChOxUgJb
```


##Twitter
```console
kubectl create secret generic twitter --from-literal=consumerKey=TFwa8ifAmxFmns02QEAm3qt2v --from-literal=consumerSecret=7B07ZCGUcM52bdpEuhkZG3EoP85iY69Ie9zUQwVG7Ll6Pvo0Hv --from-literal=accessToken=919153883989073920-vjMloUBKs8UG8O1O1zLQozFtyTQq9tL --from-literal=accessTokenSecret=d6UE1vjs1NKMJMaQ7ofWRElJxWh9ePJQjgOOdZmSf28XQ
```


##JWT
```console
kubectl create secret generic jwt -n stock-trader --from-literal=audience=stock-trader --from-literal=issuer=http://stock-trader.ibm.com
```


##OIDC
```console
kubectl create secret generic oidc -n stock-trader --from-literal=name=IBMid --from-literal=issuer=https://idaas.iam.ibm.com --from-literal=auth=https://idaas.iam.ibm.com/idaas/oidc/endpoint/default/authorize --from-literal=token=https://idaas.iam.ibm.com/idaas/oidc/endpoint/default/token --from-literal=id=ODllNjBlMDgtYzM5NS00 --from-literal=secret=MzhlZTY1ZjItM2IwNC00 --from-literal=key=blueidprod --from-literal=nodeport=https://9.42.84.151:32389
```

##ingress-host
```console
kubectl create secret generic ingress-host --from-literal=host=10.0.0.1:31007 -n stock-trader
```
