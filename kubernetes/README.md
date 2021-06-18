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

## Pod Queries

### Pod UUID Stuff

For when you have something in `/var/lib/kubelet/pods` and you need to look that shizz up.

#### Simple on host

```
$ du -hs /var/lib/kubelet/pods/*
64K     43a5e5c9-8387-40d2-8941-14dfed9cf82e
68K     467451c2-41e7-4967-8ee3-f9f02ac251b7
15G     4ff4e559-2590-486d-9ec0-423d8a4f4ee2
$ docker ps -a | grep 4ff4e559-2590-486d-9ec0-423d8a4f4ee2
# And look at docker name/id...
```

#### Get pods custom columns

```
$ kubectl get pods -o='custom-columns=NAME:.metadata.name,UID:.metadata.uid'
NAME                        UID
env-echo-648b8b85cf-cz6lj   558f917d-5545-4ba2-bbc1-1f157624a24c
env-echo-648b8b85cf-p8hr2   acc00450-66b1-4c75-97cf-f70ea459726d
```

#### JQ

```
$ kubectl get pod --all-namespaces -o json | jq '.items[] | select(.metadata.uid == "99b2fe2a-104d-11e8-baa7-06145aa73a4c")'
```

```
# kubectl get pod my-pod-6f47444666-4nmbr -o json | jq '.status.containerStatuses[] | select(.containerID == "docker://5339636e84de619d65e1f1bd278c5007904e4993bc3972df8628668be6a1f2d6")'
```

## Custom Columns

```
$ kubectl get nodes -o='custom-columns=NAME:.metadata.name,PET-GENERATION:metadata.labels.pet-generation,INSTANCES:spec.providerID'
```

## Drain

Should cordon a node set before doing anything 

```
$ kubectl cordon -l pet-generation=$pet-generation
```

Sensible defaults.

```
$ kubectl drain $node --ignore-daemonsets --delete-local-data $node
```

## Upgrades

### Version Deprecations

Check release notes: https://kubernetes.io/docs/setup/release/notes/
  * Specifically: https://kubernetes.io/docs/setup/release/notes/#deprecation-warnings
CHANGELOG Github: https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG

Check cluster api versions:

```
$ kubectl api-versions
```

## Get node IPs

You may need to change to ExternalIP if on cloud.
```
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
```

Results: `10.5.1.206 10.5.1.207`

## PVC PVs Storage

Can't delete the volume not finalized:

```
kubectl patch pvc prometheus-tsdb -p '{"metadata":{"finalizers":null}}'
```

No really - 

```
kubectl get namespace my-namespace -o json > tmp.json
curl -k -H "Content-Type: application/json" -XPUT --data-binary @tmp.json https://cluster/api/v1/namespaces/my-namespace/finalize
```

Get pods and claims:

```
kubectl get pods --all-namespaces -o=json | jq -c \
'.items[] | {name: .metadata.name, namespace: .metadata.namespace, claimName: .spec.volumes[] | select(has("persistentVolumeClaim")).persistentVolumeClaim.claimName}'
```

## Move a selector around

Janky-AF blue green.

```
kubectl patch svc my-app -p '{"spec":{"selector":{"app":"my-app-blue"}}}'
kubectl patch svc my-app -p '{"spec":{"selector":{"app":"my-app-green"}}}'
```

## List all images

iamge list image get


```
kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" |\
tr -s '[[:space:]]' '\n' |\
sort |\
uniq -c
```
