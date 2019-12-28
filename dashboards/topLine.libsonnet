local g = import 'grafonnet/grafana.libsonnet';
local common = import 'common.libsonnet';
local queries = import 'queries.libsonnet';

local dashboard = g.dashboard;
local q = queries.topLine;
local graphPanel = g.graphPanel;
local prometheus = g.prometheus;
local row = g.row;
local singlestat = g.singlestat;
local template = g.template;

{
  dashboards+:: {
    'top-line.json':
      dashboard.new(
        '%(namePrefix)sTop Line' % $.linkerd.dashboard,
        time_from=($.linkerd.dashboard.timeFrom),
        uid=($.linkerd.dashboardIDs['top-line.json']),
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
          $.linkerd.multiCluster.labelName),
      )
      .addTemplate(
        common.namespace(
          $.linkerd.datasource,
          true,
          $.linkerd.namespace.label
        ),
      )
      .addTemplate(
        common.deployment(
          $.linkerd.datasource,
          false,
        ),
      )
      .addTemplate(
        common.interval(
          true
        ),
      )

      // title
      .addPanel(
        common.branding(
          $.linkerd
        ),
        { h: 3, w: 24, x: 0, y: 0 }
      )

      .addPanel(
        common.singleStatWithGuage(
          $.linkerd,
          $.linkerd.titles.topLine.globalSuccessRate,
          q.success,
        ),
        { h: 4, w: 8, x: 0, y: 3 },
      )
      .addPanel(
        common.singleStatWithSparkLine(
          $.linkerd,
          $.linkerd.titles.topLine.globalRequestVolume,
          q.volume,
        ),
        { h: 4, w: 8, x: 8, y: 3 },
      )
      .addPanel(
        common.namespaceCount(
          $.linkerd,
        ),
        { h: 4, w: 4, x: 16, y: 3 },
      )
      .addPanel(
        common.deploymentCount(
          $.linkerd,
        ),
        { h: 4, w: 4, x: 20, y: 3 },
        )
      .addPanel(
        common.header(
          $.linkerd.titles.topLine.topLineHeader,
        ),
        { h: 2, w: 24, x: 0, y: 7 },
      )
      .addPanel(
        common.successRateGraph(
          $.linkerd,
          $.linkerd.titles.common.successRate,
          q.successByDeployment,
          $.linkerd.legends.deployment.regular,
          null,
        ),
        { h: 8, w: 8, x: 0, y: 9 },
      )
      .addPanel(
        common.requestVolumeGraph(
          $.linkerd,
          $.linkerd.titles.common.requestRate,
          {
            tls: {
              query: q.rate % '=',
              legend: $.linkerd.legends.namespace.secure,
            },
            notls: {
              query: q.rate % '!=',
              legend: $.linkerd.legends.namespace.regular,
            },
          },
        ),
        { h: 8, w: 8, x: 8, y: 9 },
      )
      .addPanel(
        common.p95LatencyGraph(
          $.linkerd,
          q.quantile % '0.95',
        ),
        { h: 8, w: 8, x: 16, y: 9 },
      )
      .addPanel(
        common.header(
          $.linkerd.titles.topLine.namespacesHeader,
        ),
        { h: 2, w: 24, x: 0, y: 17 },
      )
      .addPanel(
        row.new(
          title=$.linkerd.titles.topLine.namespace.title,
          repeat='namespace',
        ),
        { h: 1, w: 24, x: 0, y: 19 }
      ).addPanel(
        common.successRateGraph(
          $.linkerd,
          $.linkerd.titles.common.successRate,
          q.namespace.success,
          $.linkerd.legends.deployment.regular,
          null,
        ),
        { h: 8, w: 8, x: 0, y: 19 }
      ).addPanel(
        common.requestVolumeGraph(
          $.linkerd,
          $.linkerd.titles.common.requestRate,
          {
            tls: {
              query: q.namespace.rate % '=',
              legend: $.linkerd.legends.deployment.secure,
            },
            notls: {
              query: q.namespace.rate % '!=',
              legend: $.linkerd.legends.deployment.regular,
            },
          },
        ),
        { h: 8, w: 8, x: 8, y: 19 }
      ).addPanel(
        common.p95LatencyGraph(
          $.linkerd,
          q.namespace.quantile % '0.95',
        ),
        { h: 8, w: 8, x: 16, y: 19 }
      )
  },
}
