# Kubernetes

本库 Fork 自 [kubernetes](https://github.com/justmeandopensource/kubernetes)，因为 GFW 的存在，某些安装命令可能会超时，因此在脚本中将软件的默认镜像调整为阿里云镜像。

## Use Bash Scripts

```bash
# CentOS7 1 master + 2 worker
> cd vagrant-provisioning/
> vagrant up
> vagrant ssh kmaster

$ kubectl get nodes
$ kubectl get cs
```
