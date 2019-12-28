local g = import 'grafonnet/grafana.libsonnet';
local common = import 'common.libsonnet';
local queries = import 'queries.libsonnet';

local dashboard = g.dashboard;
local q = queries.pods;
local row = g.row;
local template = g.template;

{

  dashboards+:: {
    'pod.json':
      dashboard.new(
        '%(namePrefix)sPod' % $.linkerd.dashboard,
        time_from=($.linkerd.dashboard.timeFrom),
        uid=($.linkerd.dashboardIDs['pod.json']),
        tags=($.linkerd.dashboard.tags),
        editable=($.linkerd.dashboard.editable),
        graphTooltip='shared_crosshair',
      )

      // template
      .addTemplate(
        common.cluster(
          $.linkerd.datasource,
          $.linkerd.multiCluster.enabled,
          $.linkerd.multiCluster.label,
          $.linkerd.multiCluster.labelName,
        ),
      )
      .addTemplate(
        common.namespace(
          $.linkerd.datasource,
          true,
          $.linkerd.namespace.label
        ),
      )
      .addTemplate(
        common.pod(
          $.linkerd.datasource,
          true,
        ),
      )
      .addTemplate(
        common.interval(
          true,
        ),
      )
      .addPanel(
        common.title(
          $.linkerd,
          $.linkerd.titles.pod.title,
        ),
        { h: 2, w: 24, x: 0, y: 0 },
      )

      // topline
      .addPanel(
        common.singleStatWithGuage(
          $.linkerd,
          $.linkerd.titles.common.successRate,
          q.rate.success
        ),
        { h: 4, w: 8, x: 0, y: 2 },
      )
      .addPanel(
        common.singleStatWithSparkLine(
          $.linkerd,
          $.linkerd.titles.common.requestRate,
          q.rate.request
        ),
        { h: 4, w: 8, x: 8, y: 2 },
      )
      .addPanel(
        common.singleStat(
          $.linkerd,
          $.linkerd.titles.pod.pods.inbound,
          '',
          q.count.inbound,
        ),
        { h: 4, w: 4, x: 16, y: 3 },
      )
      .addPanel(
        common.singleStat(
          $.linkerd,
          $.linkerd.titles.pod.pods.outbound,
          '',
          q.count.outbound,
        ),
        { h: 4, w: 4, x: 20, y: 3 },
      )

      // traffic
      .addPanel(
        row.new(
          title=$.linkerd.titles.pod.traffic.title,
        ),
        { h: 1, w: 24, x: 0, y: 7 },
      )

      // inbound traffic
      .addPanel(
        common.successRateGraph(
          $.linkerd,
          '(%(direction)s) %(successRate)s' % [$.linkerd.titles.common.inbound, $.linkerd.titles.common.successRate],
          q.traffic.success % ['inbound', 'inbound'],
          $.linkerd.legends.pods.regular,
          null,
        ),
        { h: 7, w: 8, x: 0, y: 10 },
      )
      .addPanel(
        common.requestVolumeGraph(
          $.linkerd,
          '(%(direction)s) %(requestVolume)s' % [$.linkerd.titles.common.inbound, $.linkerd.titles.common.requestRate],
          {
            tls: {
              query: q.traffic.volume % ['inbound', '='],
              legend: $.linkerd.legends.pods.secure,
            },
            notls: {
              query: q.traffic.volume % ['inbound', '!='],
              legend: $.linkerd.legends.pods.regular,
            },
          },
        ),
        { h: 7, w: 8, x: 8, y: 10 },
      )
      .addPanel(
        common.percentileGraph(
          $.linkerd,
          '(%(direction)s) %(latency)s' % [$.linkerd.titles.common.inbound, $.linkerd.titles.common.latency],
          $.linkerd.legends.pods.regular,
          q.traffic.quantile % ['0.50', 'outbound'],
          q.traffic.quantile % ['0.95', 'outbound'],
          q.traffic.quantile % ['0.99', 'outbound'],
        ),
        { h: 7, w: 8, x: 16, y: 10 },
      )

      // outbound traffic
      .addPanel(
        common.successRateGraph(
          $.linkerd,
          '(%(direction)s) %(successRate)s' % [$.linkerd.titles.common.outbound, $.linkerd.titles.common.successRate],
          q.traffic.success % ['outbound', 'outbound'],
          $.linkerd.legends.pods.regular,
          null,
        ),
        { h: 7, w: 8, x: 0, y: 17 },
      )
      .addPanel(
        common.requestVolumeGraph(
          $.linkerd,
          '(%(direction)s) %(requestVolume)s' % [$.linkerd.titles.common.outbound, $.linkerd.titles.common.requestRate],
          {
            tls: {
              query: q.traffic.volume % ['outbound', '='],
              legend: $.linkerd.legends.pods.secure,
            },
            notls: {
              query: q.traffic.volume % ['outbound', '!='],
              legend: $.linkerd.legends.pods.regular,
            },
          },
        ),
        { h: 7, w: 8, x: 8, y: 17 },
      )
      .addPanel(
        common.percentileGraph(
          $.linkerd,
          '(%(direction)s) %(latency)s' % [$.linkerd.titles.common.outbound, $.linkerd.titles.common.latency],
          $.linkerd.legends.pods.regular,
          q.traffic.quantile % ['0.50', 'outbound'],
          q.traffic.quantile % ['0.95', 'outbound'],
          q.traffic.quantile % ['0.99', 'outbound'],
        ),
        { h: 7, w: 8, x: 16, y: 17 },
      )

      // tcp
      .addPanel(
        row.new(
          title=$.linkerd.titles.pod.tcp.title,
        ),
        { h: 1, w: 24, x: 0, y: 24 },
      )

      // inbound tcp
      .addPanel(
        common.graphPanel(
          $.linkerd,
          '(%(direction)s) %(failures)s' % [$.linkerd.titles.common.inbound, $.linkerd.titles.pod.tcp.failures],
          q.tcp.failures % 'inbound',
          '{{peer}} {{errno}}',
        ),
        { h: 7, w: 8, x: 0, y: 25 },
      )
      .addPanel(
        common.graphPanel(
          $.linkerd,
          '(%(direction)s) %(open)s' % [$.linkerd.titles.common.inbound, $.linkerd.titles.pod.tcp.open],
          q.tcp.open % 'inbound',
          '{{peer}}',
        ),
        { h: 7, w: 8, x: 8, y: 25 },
      )
      .addPanel(
        common.heatmapPanel(
          $.linkerd,
          '(%(direction)s) %(duration)s' % [$.linkerd.titles.common.inbound, $.linkerd.titles.pod.tcp.duration],
          q.tcp.duration % 'inbound',
          '',
        ),
        { h: 7, w: 8, x: 16, y: 25 },
      )

      // outbound tcp
      .addPanel(
        common.graphPanel(
          $.linkerd,
          '(%(direction)s) %(failures)s' % [$.linkerd.titles.common.outbound, $.linkerd.titles.pod.tcp.failures],
          q.tcp.failures % 'outbound',
          '{{peer}} {{errno}}',
        ),
        { h: 7, w: 8, x: 0, y: 47 },
      )
      .addPanel(
        common.graphPanel(
          $.linkerd,
          '(%(direction)s) %(open)s' % [$.linkerd.titles.common.outbound, $.linkerd.titles.pod.tcp.open],
          q.tcp.open % 'outbound',
          '{{peer}}',
        ),
        { h: 7, w: 8, x: 8, y: 47 },
      )
      .addPanel(
        common.heatmapPanel(
          $.linkerd,
          '(%(direction)s) %(duration)s' % [$.linkerd.titles.common.outbound, $.linkerd.titles.pod.tcp.duration],
          q.tcp.duration % 'outbound',
          '',
        ),
        { h: 7, w: 8, x: 16, y: 47 },
      )

      // pods
      .addPanel(
        row.new(
          title=$.linkerd.titles.pod.pods.title,
        ),
        { h: 1, w: 24, x: 0, y: 54 },
      )

      // inbound pods
      .addPanel(
        common.successRateGraph(
          $.linkerd,
          '(%(direction)s) %(title)s' % [$.linkerd.titles.common.inbound, $.linkerd.titles.common.successRate],
          q.pod.success % ['inbound', 'inbound'],
          $.linkerd.legends.pods.regular,
          null,
        ),
        { h: 7, w: 8, x: 0, y: 55 },
      )
      .addPanel(
        common.requestVolumeGraph(
          $.linkerd,
          '(%(direction)s) %(requestVolume)s' % [$.linkerd.titles.common.inbound, $.linkerd.titles.common.requestRate],
          {
            tls: {
              query: q.pod.volume % ['inbound', '='],
              legend: $.linkerd.legends.pods.secure,
            },
            notls: {
              query: q.pod.volume % ['inbound', '!='],
              legend: $.linkerd.legends.pods.regular,
            },
          },
        ),
        { h: 7, w: 8, x: 8, y: 55 },
      )
      .addPanel(
        common.percentileGraph(
          $.linkerd,
          '(%(direction)s) %(latency)s' % [$.linkerd.titles.common.inbound, $.linkerd.titles.common.latency],
          $.linkerd.legends.pods.regular,
          q.pod.quantile % ['0.50', 'outbound'],
          q.pod.quantile % ['0.95', 'outbound'],
          q.pod.quantile % ['0.99', 'outbound'],

        ),
        { h: 7, w: 8, x: 16, y: 55 },
      )

      // outbound pods
      .addPanel(
        common.successRateGraph(
          $.linkerd,
          '(%(direction)s) %(title)s' % [$.linkerd.titles.common.outbound, $.linkerd.titles.common.successRate],
          q.pod.success % ['outbound', 'outbound'],
          $.linkerd.legends.pods.regular,
          null,
        ),
        { h: 7, w: 8, x: 0, y: 55 },
      )
      .addPanel(
        common.requestVolumeGraph(
          $.linkerd,
          '(%(direction)s) %(requestVolume)s' % [$.linkerd.titles.common.outbound, $.linkerd.titles.common.requestRate],
          {
            tls: {
              query: q.pod.volume % ['outbound', '='],
              legend: $.linkerd.legends.pods.secure,
            },
            notls: {
              query: q.pod.volume % ['outbound', '!='],
              legend: $.linkerd.legends.pods.regular,
            },
          },
        ),
        { h: 7, w: 8, x: 8, y: 55 },
      )
      .addPanel(
        common.percentileGraph(
          $.linkerd,
          '(%(direction)s) %(latency)s' % [$.linkerd.titles.common.outbound, $.linkerd.titles.common.latency],
          $.linkerd.legends.pods.regular,
          q.pod.quantile % ['0.50', 'outbound'],
          q.pod.quantile % ['0.95', 'outbound'],
          q.pod.quantile % ['0.99', 'outbound'],

        ),
        { h: 7, w: 8, x: 16, y: 55 },
      )

  },
}


