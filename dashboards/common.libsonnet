local g = import 'grafonnet/grafana.libsonnet';
local graph_panel = g.graphPanel;
local prometheus = g.prometheus;
local singlestat = g.singlestat;
local template = g.template;
local text = g.text;

{

  branding:: function(config)
    text.new(
      mode='html',
      transparent=true,
      content='<img src="https://linkerd.io/images/identity/svg/linkerd_primary_color_white.svg" style="height: 30px;">',
    ),

  header(content)::
    text.new(
      mode='html',
      transparent=true,
      content='<div class="text-center dashboard-header"><span>%(content)s</span></div>' % content,
    ),

  cluster(ds, show, name, label)::
    template.new(
      name,
      ds,
      'label_values(process_start_time_seconds, cluster)',
      label=label,
      hide=(if show then '' else 2),
      includeAll=true,
      sort=1,
      refresh=2,
      current='all',
    ),

  namespace(ds, show, label)::
    template.new(
      'namespace',
      ds,
      'label_values(process_start_time_seconds{cluster=~"$cluster"}, namespace)',
      label=label,
      hide=(if show then '' else 2),
      includeAll=true,
      sort=1,
      refresh=2,
      current='all',
    ),

  deployment(ds, show)::
    template.new(
      'deployment',
      ds,
      'label_values(process_start_time_seconds{cluster=~"$cluster", deployment!=""}, deployment)',
      label=null,
      hide=(if show then '' else 2),
      includeAll=true,
      sort=1,
      refresh=2,
      current='all',
    ),

  interval(show)::
    template.interval(
      'interval',
      '30s,1m,2m',
      '1m',
      hide=(if show then ''),
      label='Interval',
    ),

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
    .addTarget(prometheus.target('count(count(request_total{cluster=~"$cluster", namespace=~"$namespace"}) by (namespace))' % config)),

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
    .addTarget(prometheus.target('count(count(request_total{cluster=~"$cluster", namespace=~"$namespace"}) by (namespace, deployment))' % config)),


  successRateGraph(config, query, legend, repeat)::
    graph_panel.new(
      config.titles.common.successRate,
      datasource='%(datasource)s' % config.datasource,
      linewidth=2,
      sort='decreasing',
      legend_show=false,
      format='percentunit',
      min=0,
      max=1,
      value_type='shared',
      repeat=repeat
    )
    .addTarget(prometheus.target(
      query,
      legendFormat=legend,
      intervalFactor=1,
    )),

  requestVolumeGraph(config, tls, notls)::
    graph_panel.new(
      config.titles.common.requestVolume,
      datasource='%(datasource)s' % config.datasource,
      linewidth=2,
      fill=false,
      sort='decreasing',
      legend_show=false,
      format='rps',
      min=0,
      max=null,
      value_type='shared',
    )
    .addTarget(prometheus.target(
      tls.query,
      legendFormat=tls.legend,
      intervalFactor=1,
    ))
    .addTarget(prometheus.target(
      notls.query,
      legendFormat=notls.legend,
      intervalFactor=1,
    )),

  p95LatencyGraph(config, query)::
    graph_panel.new(
      config.titles.common.p95Latency,
      datasource='%(datasource)s' % config.datasource,
      linewidth=2,
      sort='decreasing',
      legend_show=false,
      format='ms',
      min=0,
      max=null,
      value_type='shared',
    )
    .addTarget(prometheus.target(
      query,
      legendFormat='p95 ns/{{namespace}}',
      intervalFactor=1,
    )),

}
