local g = import 'grafonnet/grafana.libsonnet';
local common = import 'common.libsonnet';
local queries = import 'queries.libsonnet';

local dashboard = g.dashboard;
local q = queries.authority;
local graphPanel = g.graphPanel;
local prometheus = g.prometheus;
local row = g.row;
local singlestat = g.singlestat;
local template = g.template;

{
  dashboards+:: {
    'authority.json':
      dashboard.new(
        '%(namePrefix)sAuthority' % $.linkerd.dashboard,
        time_from=($.linkerd.dashboard.timeFrom),
        uid=($.linkerd.dashboardIDs['authority.json']),
        tags=($.linkerd.dashboard.tags),
        editable=($.linkerd.dashboard.editable),
        schemaVersion=($.linkerd.schemaVersion),
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
        common.authority(
          $.linkerd.datasource,
          true,
          'Authority',
        ),
      )
      .addTemplate(
        common.interval(
          true
        ),
      )

      // title
      .addPanel(
        common.title(
          $.linkerd,
          $.linkerd.titles.authority.title,
        ),
        { h: 2, w: 24, x: 0, y: 0 },
      )

      .addPanel(
        common.singleStatWithGuage(
          $.linkerd,
          $.linkerd.titles.common.successRate,
          q.success,
        ),
        { h: 4, w: 8, x: 0, y: 3 },
      )
      .addPanel(
        common.singleStatWithSparkLine(
          $.linkerd,
          $.linkerd.titles.common.requestRate,
          q.volume,
          'rps',
        ),
        { h: 4, w: 8, x: 8, y: 3 },
      )
      .addPanel(
        common.singleStatWithSparkLine(
          $.linkerd,
          $.linkerd.titles.common.p95Latency,
          q.quantile,
          'ms'
        ),
        { h: 4, w: 8, x: 16, y: 3 },
      )

      .addPanel(
        common.header(
          $.linkerd.titles.authority.topLineTraffic,
        ),
        { h: 2, w: 24, x: 0, y: 7 },
      )
      .addPanel(
        common.successRateGraph(
          $.linkerd,
          $.linkerd.titles.common.successRate,
          q.successByAuthority,
          $.linkerd.legends.authority.regular,
          null,
        ),
        { h: 7, w: 8, x: 0, y: 9 },
      )
      .addPanel(
        common.requestVolumeGraph(
          $.linkerd,
          $.linkerd.titles.common.requestRate,
          {
            tls: {
              query: q.rate % '=',
              legend: $.linkerd.legends.authority.secure,
            },
            notls: {
              query: q.rate % '!=',
              legend: $.linkerd.legends.authority.regular,
            },
          },
        ),
        { h: 7, w: 8, x: 8, y: 9 },
      )
      .addPanel(
        common.percentileGraph(
          $.linkerd,
          $.linkerd.titles.common.latency,
          $.linkerd.legends.authority.regular,
          q.traffic.quantile % ['0.50', 'inbound'],
          q.traffic.quantile % ['0.95', 'inbound'],
          q.traffic.quantile % ['0.99', 'inbound'],
        ),
        { h: 7, w: 8, x: 16, y: 9 },
      )

      .addPanel(
        common.header(
          $.linkerd.titles.authority.inboundTrafficByDeployment,
        ),
        { h: 2, w: 24, x: 0, y: 16 },
      )
      .addPanel(
        common.successRateGraph(
          $.linkerd,
          $.linkerd.titles.common.successRate,
          q.topLineTraffic.success,
          $.linkerd.legends.authority.regular,
          null,
        ),
        { h: 7, w: 8, x: 0, y: 18 },
      )
      .addPanel(
        common.requestVolumeGraph(
          $.linkerd,
          $.linkerd.titles.common.requestRate,
          {
            tls: {
              query: q.topLineTraffic.rate % '=',
              legend: $.linkerd.legends.deployment.secure,
            },
            notls: {
              query: q.topLineTraffic.rate % '!=',
              legend: $.linkerd.legends.deployment.regular,
            },
          },
        ),
        { h: 7, w: 8, x: 8, y: 18 },
      )
      .addPanel(
        common.p95LatencyGraph(
          $.linkerd,
          q.topLineTraffic.quantile % '0.95',
          'p95 deploy/{{deployment}}',
        ),
        { h: 7, w: 8, x: 16, y: 18 },
      )

      .addPanel(
        common.header(
          $.linkerd.titles.authority.inboundTrafficByPod,
        ),
        { h: 2, w: 24, x: 0, y: 25 },
      )
      .addPanel(
        common.successRateGraph(
          $.linkerd,
          $.linkerd.titles.common.successRate,
          q.trafficByPod.success,
          $.linkerd.legends.authority.regular,
          null,
        ),
        { h: 7, w: 8, x: 0, y: 27 },
      )
      .addPanel(
        common.requestVolumeGraph(
          $.linkerd,
          $.linkerd.titles.common.requestRate,
          {
            tls: {
              query: q.trafficByPod.rate % '=',
              legend: $.linkerd.legends.pods.secure,
            },
            notls: {
              query: q.trafficByPod.rate % '!=',
              legend: $.linkerd.legends.pods.regular,
            },
          },
        ),
        { h: 7, w: 8, x: 8, y: 27 },
      )
      .addPanel(
        common.p95LatencyGraph(
          $.linkerd,
          q.trafficByPod.quantile % '0.95',
          'p95 po/{{pod}}',
        ),
        { h: 7, w: 8, x: 16, y: 27 },
      )
  },
}
