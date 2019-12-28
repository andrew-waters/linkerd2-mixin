{
  pods: {
    count: {
      inbound: 'count(count(request_total{cluster=~"$cluster", dst_namespace=~"$namespace", dst_pod!="", dst_pod=~"$pod", direction="outbound"}) by (namespace, pod))',
      outbound: 'count(count(request_total{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod", direction="outbound"}) by (namespace, dst_pod))',
    },
    pod: {
      quantile: 'histogram_quantile(%(quantile)s, sum(irate(response_latency_ms_bucket{cluster=~"$cluster", dst_namespace=~"$namespace", dst_pod!="", dst_pod=~"$pod", direction="%(direction)s"}[$interval])) by (le, pod))',
      success: '
        sum(irate(response_total{cluster=~"$cluster", classification="success", namespace=~"$namespace", pod=~"$pod", direction="%(direction)s"}[$interval])) by (pod)
        /
        sum(irate(response_total{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod", direction="%(direction)s"}[$interval])) by (pod)
      ',
      volume: 'sum(irate(request_total{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod", direction="%(direction)s", tls%(tls)s"true"}[$interval])) by (dst_pod)',
    },
    rate: {
      success: '
        sum(irate(response_total{classification="success", cluster=~"$cluster", pod=~"$pod"}[$interval]))
        /
        sum(irate(response_total{cluster=~"$cluster", pod=~"$pod"}[$interval]))
      ',
      request: 'sum(irate(request_total{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod", direction="inbound"}[$interval]))',
    },
    traffic: {
      quantile: 'histogram_quantile(%(quantile)s, sum(irate(response_latency_ms_bucket{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod", direction="%(direction)s"}[$interval])) by (le, pod))',
      success: '
        sum(irate(response_total{classification="success", cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod", direction="%(direction)s"}[$interval])) by (pod)
        /
        sum(irate(response_total{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod", direction="%(direction)s"}[$interval])) by (pod)
      ',
      volume: 'sum(irate(request_total{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod", direction="%(direction)s", tls%(tls)s"true"}[$interval])) by (pod)',
    },
    tcp: {
      duration: 'tcp_connection_duration_ms_bucket{namespace=~"$namespace", pod=~"$pod", direction="%(direction)s"}',
      failures: 'sum(tcp_close_total{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod", direction="%(direction)s", errno!=""}) by (errno)',
      open: 'tcp_open_connections{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod", direction="%(direction)s"}',
    },
  },
  topLine: {
    success: 'sum(irate(response_total{classification="success", cluster=~"$cluster", deployment=~"$deployment"}[$interval])) / sum(irate(response_total{cluster=~"$cluster", deployment=~"$deployment"}[$interval]))',
    volume: 'sum(irate(request_total{cluster=~"$cluster", deployment=~"$deployment"}[$interval]))',
    successByDeployment: 'sum(irate(response_total{classification="success", cluster=~"$cluster", namespace=~"$namespace", deployment=~"$deployment", direction="inbound"}[$interval])) by (deployment) / sum(irate(response_total{cluster=~"$cluster", namespace=~"$namespace", deployment=~"$deployment", direction="inbound"}[$interval])) by (deployment)',
    rate: 'sum(irate(request_total{cluster=~"$cluster", direction="inbound", tls%(tls)s"true"}[$interval])) by (namespace)',
    quantile: 'histogram_quantile(%(quantile)s, sum(irate(response_latency_ms_bucket{cluster=~"$cluster", direction="inbound"}[$interval])) by (le, namespace))',
    namespace: {
      quantile: 'histogram_quantile(%(quantile)s, sum(irate(response_latency_ms_bucket{cluster=~"$cluster", namespace="$namespace", direction="inbound"}[$interval])) by (le, deployment))',
      rate: 'sum(irate(request_total{cluster=~"$cluster", namespace="$namespace", direction="inbound", tls%(tls)s"true"}[$interval])) by (deployment)',
      success: 'sum(irate(response_total{classification="success", cluster=~"$cluster", namespace=~"$namespace", direction="inbound"}[$interval])) by (deployment) / sum(irate(response_total{cluster=~"$cluster", namespace=~"$namespace", direction="inbound"}[$interval])) by (deployment)',
    },
  },
}
