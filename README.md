# Debug docker image

Contains useful debug tools for running in kubernetes.

A pre-built docker image is available in the packages page:

```sh
docker pull ghcr.io/luisdavim/debug:main
```

## Example usage

To debug a kubernetes node:

```sh
kubectl -n default debug node/management-7c5738e6d2-shbcp-5t947 -it --image=ghcr.io/luisdavim/debug:main -- chroot /host
```

To start a debug pod:

```sh
kubectl run -n default --restart=Never --rm -i --tty debug --image=ghcr.io/luisdavim/debug:main -- sh
```
