# linkerd2 Monitoring Mixin for Grafana

This mixin is a jsonnet package which can be used standalone or as part of your own config.

It generates Grafana dashboards for [linkerd2](https://github.com/linkerd/linkerd2) monitoring and can work in standalone (default) or in [multi cluster](#multi-cluster-support) setups.

## How to use

This mixin is designed to be vendored into the repo with your infrastructure config.

## Generating config files

To manually generate the dashboards, you can - but it requires some additional tooling:

Get the `jsonnet-bundler` and `jsonnet` itself:

```bash
go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
brew install jsonnet
```

Then grab the mixin and any dependencies:

```bash
git clone https://github.com/andrew-waters/linkerd2-mixin
cd linkerd2-mixin
jb install
```

Then you can build the mixin:

```bash
make dashboards
```

## Multi-cluster support

This mixin can support a set of dashboards that can used for multiple clusters (if your metrics are aggregated and cluster labeled).

If you're using [kube-prometheus](https://github.com/coreos/kube-prometheus/), you can label your cluster by adding the following:

```jsonnet
{
  _config+:: {
    clusterName: 'my-cluster-name',
  },
  prometheus+:: {
    prometheus+: {
      spec+: {
        externalLabels: {
          cluster: $._config.clusterName
        },
      },
    },
  },
}
```

Once your metrics are labelled by cluster, they will be available for filtering within PromQL.

You can now take advantage of these labels within the mixin by using the following (replace `<clusterLabel>` with the key of the cluster label, usually `cluster`):

```jsonnet
linkerd2 {
  _config+:: {
    multiCluster: true,
    clusterLabel: '<clusterLabel>,
  },
}
```

## Customising the mixin

The `linkerd2-mixin` also allows you to customise the name and tags for your dashbaords, which is very valuable when you are monitoring more than just `linkerd2`.

```jsonnet
linkerd2 {
  _config+:: {
    multiCluster: true,
    clusterLabel: 'cluster',
    dashboardNamePrefix: 'Linkerd2 / ',
    dashboardTags: ['linkerd', 'infrastucture'],
  },
}
```
