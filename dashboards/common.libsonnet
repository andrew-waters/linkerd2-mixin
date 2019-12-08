local g = import 'grafonnet/grafana.libsonnet';
local prometheus = g.prometheus;
local singlestat = g.singlestat;

{

  branding:: function()
    {
      content: '<img src="https://linkerd.io/images/identity/svg/linkerd_primary_color_white.svg" style="height: 30px;">',
      datasource: null,
      height: '1px',
      id: 14,
      links: [],
      mode: 'html',
      options: {},
      title: '',
      transparent: true,
      type: 'text'
    },

  cluster:: function(ds, show, label, name)
    {
      current: {
        text: 'All',
        value: '$__all',
      },
      datasource: ds,
      hide: if show then 0 else 2,
      includeAll: true,
      label: name,
      name: 'cluster',
      options: [],
      query: 'label_values(process_start_time_seconds, cluster)', // $label
      refresh: 2,
      regex: '',
      type: 'query',
      useTags: false,
    },

  namespace:: function(ds, show, label)
    {
      current: {
        text: 'All',
        value: '$__all',
      },
      datasource: ds,
      hide: if show then 0 else 2,
      includeAll: true,
      label: label,
      name: 'namespace',
      options: [],
      query: 'label_values(process_start_time_seconds, namespace)',
      refresh: 2,
      regex: '',
      type: 'query',
      useTags: false,
    },

  deployment:: function(ds, show)
    {
      current: {
        text: 'All',
        value: '$__all',
      },
      datasource: ds,
      hide: if show then 0 else 2,
      includeAll: true,
      label: null,
      name: 'deployment',
      options: [],
      query: 'label_values(process_start_time_seconds{deployment!=""}, deployment)',
      refresh: 2,
      regex: '',
      type: 'query',
      useTags: false,
    },

  interval:: function(show)
    {
      auto: false,
      auto_count: 30,
      auto_min: "10s",
      current: {
        text: "1m",
        value: "1m"
      },
      hide: 0,
      label: "Interval",
      name: "interval",
      options: [
        {
          selected: true,
          text: "30s",
          value: "30s"
        },
        {
          selected: false,
          text: "1m",
          value: "1m"
        },
        {
          selected: false,
          text: "2m",
          value: "2m"
        }
      ],
      query: "30s,1m,2m",
      refresh: 2,
      skipUrlSync: false,
      type: "interval"
    },

  namespaceCount(config)::
    singlestat.new(
      config.titles.topLine.namespacesMonitored,
      datasource='%(datasource)s' % config.datasource,
      span=2,
      valueName='current',
      valueFontSize='200%',
      colors=[
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46'
      ],
    )
    .addTarget(prometheus.target('count(count(request_total{namespace=~"$namespace"}) by (namespace))' % config)),

  deploymentCount(config):: 
    singlestat.new(
      config.titles.topLine.deploymentsMonitored,
      datasource='%(datasource)s' % config.datasource,
      span=2,
      valueName='current',
      valueFontSize='200%',
      colors=[
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46'
      ],
    )
    .addTarget(prometheus.target('count(count(request_total{namespace=~"$namespace"}) by (namespace, deployment))' % config)),

}
