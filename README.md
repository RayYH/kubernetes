# Kubernetes

This repo forks from [justmeandopensource's kubernetes](https://github.com/justmeandopensource/kubernetes). Since the existence of GFW, I changed the default mirror to ali cloud mirror for developers live in china's mainland.

## Use Bash Scripts

```bash
# CentOS7 1 master + 2 worker
> cd vagrant-provisioning/
> vagrant up
> vagrant ssh kmaster

$ kubectl get nodes
$ kubectl get cs
```
