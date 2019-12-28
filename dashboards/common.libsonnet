local g = import 'grafonnet/grafana.libsonnet';
local graph_panel = g.graphPanel;
local heatmap_panel = g.heatmapPanel;
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

  title:: function(config, title)
    text.new(
      mode='html',
      transparent=true,
      content='<div style="display: flex; align-items: center">
        <img src="https://linkerd.io/images/identity/favicon/linkerd-favicon.png" style="height: 32px;">&nbsp;
        <span style="font-size: 32px">
          %(title)s
        <span>
      </div>' % title,
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
      multi=true,
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
      multi=true,
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
      multi=true,
    ),

  pod(ds, show)::
    template.new(
      'pod',
      ds,
      'label_values(process_start_time_seconds{cluster=~"$cluster", namespace=~"$namespace", pod!=""}, pod)',
      label=null,
      hide=(if show then '' else 2),
      includeAll=true,
      sort=1,
      refresh=2,
      current='all',
      multi=true,
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
      transparent=true,
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
      transparent=true,
    )
    .addTarget(prometheus.target('count(count(request_total{cluster=~"$cluster", namespace=~"$namespace"}) by (namespace, deployment))' % config)),

  successRateGraph(config, title, query, legend, repeat)::
    graph_panel.new(
      title,
      datasource='%(datasource)s' % config.datasource,
      linewidth=2,
      sort='decreasing',
      legend_show=false,
      format='percentunit',
      min=0,
      max=1,
      value_type='shared',
      repeat=repeat,
    )
    .addTarget(prometheus.target(
      query,
      legendFormat=legend,
      intervalFactor=1,
    )),

  requestVolumeGraph(config, title, q)::
    graph_panel.new(
      title,
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
      q.tls.query,
      legendFormat=q.tls.legend,
      intervalFactor=1,
    ))
    .addTarget(prometheus.target(
      q.notls.query,
      legendFormat=q.notls.legend,
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

  percentileGraph(config, title, legend, q50, q95, q99)::
    graph_panel.new(
      title,
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
      q50,
      legendFormat='p50 %(legend)s' % legend,
      intervalFactor=1,
    ))
    .addTarget(prometheus.target(
      q95,
      legendFormat='p95 %(legend)s' % legend,
      intervalFactor=1,
    ))
    .addTarget(prometheus.target(
      q99,
      legendFormat='p99 %(legend)s' % legend,
      intervalFactor=1,
    )),

  singleStatWithGuage(config, title, query)::
    singlestat.new(
      title,
      datasource='%(datasource)s' % config.datasource,
      valueName='current',
      valueFontSize='80%',
      thresholds='.9,.99',
      colors=config.style.colors,
      colorValue=true,
      format='percentunit',
      sparklineShow=true,
      sparklineFillColor=config.style.spark.fill,
      sparklineFull=true,
      sparklineLineColor=config.style.spark.line,
      gaugeShow=true,
      gaugeMinValue=0,
      gaugeMaxValue=1,
      gaugeThresholdMarkers=true,
      gaugeThresholdLabels=false,
      transparent=true,
    )
    .addTarget(prometheus.target(
      query,
      intervalFactor=1,
    )),

  singleStatWithSparkLine(config, title, query)::
    singlestat.new(
      title,
      datasource='%(datasource)s' % config.datasource,
      valueName='current',
      valueFontSize='80%',
      colors=config.style.colors,
      format='rps',
      sparklineShow=true,
      sparklineFillColor=config.style.spark.fill,
      sparklineFull=true,
      sparklineLineColor=config.style.spark.line,
      transparent=true,
    )
    .addTarget(prometheus.target(
      query,
      intervalFactor=1,
    )),

  singleStat(config, title, format, query)::
    singlestat.new(
      title,
      datasource='%(datasource)s' % config.datasource,
      valueName='current',
      valueFontSize='80%',
      colors=config.style.colors,
      format=format,
      sparklineShow=false,
      transparent=true,
    )
    .addTarget(prometheus.target(
      query,
      intervalFactor=1,
    )),

  graphPanel(config, title, query, legend)::
    graph_panel.new(
      title,
      datasource='%(datasource)s' % config.datasource,
      linewidth=2,
      fill=false,
      sort='decreasing',
      legend_show=false,
      format='none',
      min=0,
      max=null,
      value_type='shared',
    )
    .addTarget(prometheus.target(
      query,
      legendFormat=legend,
      intervalFactor=1,
    )),

  heatmapPanel(config, title, query, legend)::
    heatmap_panel.new(
      title,
      datasource='%(datasource)s' % config.datasource,
      legend_show=false,
      dataFormat='heatmap',
      yAxis_format='ms',
      yAxis_min=0,
      yAxis_max=null,
    )
    .addTarget(prometheus.target(
      query,
      legendFormat=legend,
      intervalFactor=1,
    )),
}
