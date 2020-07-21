# Shell That Saved My Life:

Useful kube commands! File name from: https://en.wikipedia.org/wiki/Songs_That_Saved_My_Life 🤘

## Authenticate with a service account and curl

```
TOKEN=(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)
```

```
curl -X GET $APISERVER/api --header "Authorization: Bearer $TOKEN" --insecure
```

### Get APISERVER

```
kubectl config view -o jsonpath='{"Cluster name\tServer\n"}{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'
export CLUSTER_NAME='foo'
APISERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}")
```

## Get node IPs

You may need to change to ExternalIP if on cloud.
```
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
```

Results: `10.5.1.206 10.5.1.207`
