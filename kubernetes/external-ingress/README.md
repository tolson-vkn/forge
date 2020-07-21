# README

Probably have a reason for adding ingress. Easy SSL termination for an endpoint, i.e. Let's Encrypt + Ingress 443 -> Octoprint 80

If you're going to do this it makes sense to then firewall the port 80, to all but the Kubernetes nodes doing the ingress.

But we wan't to be careful and probably leave open port 22 open for SSH in case we need to change the rules or do normal admin work.

## How

Apply the manifest and test

```
kubectl apply -f external.yaml
```

Get node IPs and save for later (Query might be ExternalIP if cloud)

```
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
```

Pretend result is: `10.5.1.206 10.5.1.207`

SSH onto to be firwalled machine

```
ssh user@server
```

Backup the rules because scary

```
sudo iptables-save > saved-rules.txt
```

Maybe you just want ssh from one server. But it's fine this is the homelab!

```
sudo su - 
iptables -A INPUT -p tcp --dport 80 -s 10.5.1.206 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -s 10.5.1.207 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

If it's a docker host you might need to do this, but if it's a docker host why it not in kube? 😏

```
iptables -F DOCKER
iptables -A DOCKER -p tcp --dport 80 -s 10.5.1.206 -j ACCEPT
iptables -A DOCKER -p tcp --dport 80 -s 10.5.1.207 -j ACCEPT
iptables -A DOCKER -p tcp -j DROP
```

### Screwed up?

```
iptables-restore < /path/to/saved-rules.txt
```
