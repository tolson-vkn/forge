# Service account user account

This is generally discouraged. You should use some sort of auth provider from the cloud provider or some OpenID provider.

I still think if you're running on prem, and don't have that. Service account - User accounts is much better than doing certificate based cluster authentication. It's hard with certificate authentication to modify the `CN` `OU` etc of the user and move them to different groups. Additionally, it's very hard to revoke that user's access. With service accounts, they have labels, and can be deleted...

If it still feels janky... just remember this is how PKS provides out of the box user accounts as of PKS 1.5, it's not that bad.

## Script

Run `create-sa-user.sh` which will automatically read the template files and output a kubeconfig file.

`create-sa-user.sh -h` for help text...

## Manual

Create the user account namespace:

```
$ kubectl apply -f user-namespace.yaml 
namespace/user-accounts created
```

Modify `sa.yaml` to have the result user in there

``` bash
$ kubectl apply -f sa.yaml
serviceaccount/tolson created
```

``` bash
$ kubectl describe sa tolson
Name:                tolson
Namespace:           user-accounts
Labels:              <none>
Annotations:         kubectl.kubernetes.io/last-applied-configuration:
                       {"apiVersion":"v1","kind":"ServiceAccount","metadata":{"annotations":{},"name":"tolson","namespace":"user-accounts"}}
                       Image pull secrets:  <none>
                       Mountable secrets:   tolson-token-7gttx
                       Tokens:              tolson-token-7gttx
                       Events:              <none>
```

Fetch that token...

``` bash
$ kubectl describe secret tolson-token-7gttx 
Name:         tolson-token-7gttx
Namespace:    user-accounts
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: tolson
              kubernetes.io/service-account.uid: 6eabf6ab-30f1-11ea-b820-42010a800111

              Type:  kubernetes.io/service-account-token

              Data
              ====
              ca.crt:     1115 bytes
              namespace:  7 bytes
              token:
              eyJhbGciOiJFEkxhr2IsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlaYmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImMyMTE3ZDhZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InRvbHNvbi10b2tlbi03Z3R0eCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJ0b2xzb24iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI2ZWFiZjZhYi0zMGYxLTExZWEtYjgyMC00MjAxMGE4MDAxMTEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDp0b2xzb24ifQ.caY-11y39zmM5-LwyN6lHxWSAq-FBcO6VHQJ8BU_Qh3l8miLQQ71TUNccN7BMX5aM4RHmztpEHOVbElCWXwyhWr3NR1Z1ar9s5ec6iHBqfkp_s8TvxPBLyUdy9OjCWy3iLQ4Lt4qpxsjwE4NE7KioDPX2Snb6NWFK7lvldjYX4tdkpWdQHBNmqaDPq35itsFpk4tUch7yJqnySBjvNlOABMegjExPpZx6aJ1Wlax290Lt_9ZUf1G-0YVUGUeSfnEUQcQeWhZGPfk23AblyvFsXn6wpg2K4ZZ9AE23SWfFdVyph_2A58nGT_fskC_kAJCYgJBmGw9Q6-dREUrHhqkUoL4DAN_03iEM5Snz6YK5EF1nzeRLpKL_0-7BHWs06Gna4Xe-LzlvobjS_kcmeNPWpUxTfqUgK-fpznG4I9ikq1ecjg
```

We want that JWT for our token based authentication...

The next part is sort of hard to automate and do proper but look at the `kubeconfig-tpl.yaml`

```
apiVersion: v1
kind: Config
clusters:
- name: {{ cluster }}
  cluster:
    certificate-authority-data: {{ cert-authority-data }}
    server: {{ server }}
contexts:
- context:
    cluster: {{ cluster }}
    namespace: {{ default_ns }}
    user: {{ username }}
  name: {{ default_ns }}
current-context: {{ default_ns }}
```

Copy the certificate authority from your kubeconfig to the template:

```
    certificate-authority-data: LS0tLS1C...
```

Transfer the name of your cluster like: `homelab-k8s`, `gke_adjective_noun_1432_us-central1-a_standard_cluster-1`, etc.

```
clusters:
- name: homelab-k8s
[ ... ]
- context:
    cluster: homelab-k8s
```

Transfer the server ip from your kubeconfig, this is your apiserver vip:

```
    server: https://k8s.lan.tolson.dev:443
```

Fill our the default namespace, we haven't set those permissions yet so we will want to do that later. Let's call the namespace `python-dev`

```
current-context: python-dev
```

Resulting in something like this:

```
apiVersion: v1
kind: Config
clusters:
- name: homelab-k8s
  cluster:
    certificate-authority-data: LS0tLS1C... (Of course this is longer...)
    server: https://k8s.lan.tolson.dev:443
contexts:
- context:
    cluster: homelab-k8s
    namespace: python-dev
    user: tolson
  name: python-dev
current-context: python-dev
```

Set the role for this user, follow the template in the role-tpl.yaml, you'll end up with a namespace role something like this:

```
apiVerion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: python-dev
  name: python-dev-user
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
  nonResourceURLs:
  - '*'
  verbs:
  - '*'
```

Note this is only a role, we don't need to do this for each user, do this once and tweak it as you need to.

Ok finally, add our service account to the RoleBinding:

```
apiVerion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: python-dev
  name: python-dev-dev-group
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: python-dev-user
subjects:
- kind: ServiceAccount
  name: tolson
  namepace: user-accounts
```

Note a big difference here, the service account is not in the python-dev namespace!

As you add more users to this namespace just simply add 3 more lines like:

```
- kind: ServiceAccount
  name: vfranken
  namepace: user-accounts
```

