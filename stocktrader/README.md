# IBM Stock Trader Helm Chart (Beta Version)

## Introduction

This chart installs the IBM Stock Trader microservices.

## Prerequisites

The user must install and configure the following dependencies:
* IBM Db2 Developer-C
* IBM MQ Advanced for Developers
* IBM Operational Decision Manager
* Redis

The user must create and configure the following services in the IBM Cloud:
* Tone Analyzer
* API Connect
* Cloud Functions

The [stocktrader project](../README.md) provides instructions for setting up these dependencies.

## Configuration

The following table lists the configurable parameters of this chart and their default values.
The parameters allow you to:
* change the image of any microservice from the one provided by IBM to one that you build (e.g. if you want to try to modify a service)
* enable the deployment of optional microservices (tradr, notification-slack, notification-twitter)

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| | | |
| portfolio.image.repository | image repository |  ibmstocktrader/portfolio
| portfolio.image.tag | image tag | latest
| portfolio.image.pullPolicy | image pull policy | IfNotPresent
| portfolio.image.pullSecrets | image pull secret (for protected repository) | `nil`
| | | |
| stockQuote.image.repository | image repository | ibmstocktrader/stock-quote
| stockQuote.image.tag | image tag | latest
| stockQuote.image.pullPolicy | image pull policy | IfNotPresent
| stockQuote.image.pullSecrets | image pull secret (for protected repository) | `nil`
| | | |
| trader.enabled | Deploy trader microservice | true
| trader.image.repository | image repository | ibmstocktrader/trader
| trader.image.tag | image tag | basicregistry
| trader.image.pullPolicy | image pull policy | IfNotPresent
| trader.image.pullSecrets | image pull secret (for protected repository) | `nil`
| | | |
| tradr.enabled | Deploy tradr microservice | false
| tradr.image.repository | image repository | ibmstocktrader/tradr
| tradr.image.tag | image tag | latest
| tradr.image.pullPolicy | image pull policy | IfNotPresent
| tradr.image.pullSecrets | image pull secret (for protected repository) | `nil`
| | | |
| messaging.image.repository | image repository | ibmstocktrader/messaging
| messaging.image.tag | image tag | latest
| messaging.image.pullPolicy | image pull policy | IfNotPresent
| messaging.image.pullSecrets | image pull secret (for protected repository) | `nil`
| | | |
| notificationSlack.enabled | Deploy notification-slack microservice | false
| notificationSlack.image.repository | image repository | ibmstocktrader/notification-slack
| notificationSlack.image.tag | image tag | latest
| notificationSlack.image.pullPolicy | image pull policy | IfNotPresent
| notificationSlack.image.pullSecrets | image pull secret (for protected repository) | `nil`
| | | |
| notificationTwitter.enabled | Deploy notification-twitter microservice | false
| notificationTwitter.image.repository | image repository | ibmstocktrader/notification-twitter
| notificationTwitter.image.tag | image tag | latest
| notificationTwitter.image.pullPolicy | image pull policy | IfNotPresent
| notificationTwitter.image.pullSecrets | image pull secret (for protected repository) | `nil`

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.


## Installing the Chart

You can install the chart by setting the current directory to the folder where this chart is located and running the following command:

```console
helm install --tls --name stocktrader --namespace stocktrader . 
```

This sets the Helm release name to `stocktrader` and creates all Kubernetes resources in a namespace called `stocktrader`.

## Uninstalling the Chart

```console
$ helm delete stocktrader --tls
```
