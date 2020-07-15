# k8s-job-reaper
A simple tool to clean up old namespace resources in Kubernetes

## Motivation
As it currently stands in `alpha`, the [TTL feature gate](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/#clean-up-finished-jobs-automatically), which offers the ability to automatically clean up Job resources in Kubernetes based on a configured TTL, is weakly supported in managed Kubernetes offerings. For example, it's [not supported](https://github.com/aws/containers-roadmap/issues/255) at all in EKS. As a result, Job resources can quickly pile up and waste cluster resources.

This tool aims to deliver the same functionality via a script that looks for two annotations on namespace resources called `ttl` and `nsReaper`.


## Example
```YAML
apiVersion: batch/v1
kind: Namespace
metadata:
  name: example-namespace
  annotations:
    ttl: "48 hours"
    nsReaper: "enabled"
  ```
The `nsReaper` value is optional, by setting it to `enabled` the namespace_reaper job will execute against it once an hour. 

The `ttl` annotation can be specified with any value supported by [GNU relative dates](https://www.gnu.org/software/coreutils/manual/html_node/Relative-items-in-date-strings.html#Relative-items-in-date-strings).


## Deployment
### Prerequisites
- `docker`
- `kubectl`

Deploying this tool is as simple as running:
```sh
./build.sh [IMAGE_URL]
```
where `[IMAGE_URL]` is the full URL of the container image you want to build/push/deploy. For example, if your container registry is hosted on `gcr.io/acme-123`, you may run:
```sh
./build.sh gcr.io/acme-123/k8s-namespace-reaper
```