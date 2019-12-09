local g = import 'grafonnet/grafana.libsonnet';
local common = import 'common.libsonnet';
local dashboard = g.dashboard;
local row = g.row;
local prometheus = g.prometheus;
local template = g.template;
local singlestat = g.singlestat;
local graphPanel = g.graphPanel;

{
  grafanaDashboards+:: {
    'top-line.json':
      dashboard.new(
        '%(namePrefix)sTop Line' % $._config.dashboard,
        time_from='now-5m',
        uid=($._config.dashboardIDs['top-line.json']),
        tags=($._config.dashboard.tags),
        editable=true,
        schemaVersion=($._config.schemaVersion),
      )
      .addTemplate(
        common.cluster($._config.datasource, $._config.multiCluster.enabled, $._config.multiCluster.label, $._config.multiCluster.labelName),
      )
      .addTemplate(
        common.namespace($._config.datasource, true, $._config.namespace.label),
      )
      .addTemplate(
        common.deployment($._config.datasource, false),
      )
      .addTemplate(
        common.interval(true),
      )
      .addPanel(
        common.branding($._config),
        { h: 3, w: 24, x: 0, y: 0 }
      )
      .addPanel(
        singlestat.new(
          $._config.titles.topLine.globalSuccessRate,
          datasource='%(datasource)s' % $._config.datasource,
          valueName='current',
          valueFontSize='80%',
          thresholds='.9,.99',
          colors=[
            '#d44a3a',
            'rgba(237, 129, 40, 0.89)',
            '#299c46'
          ],
          colorValue=true,
          format='percentunit',
          sparklineShow=true,
          sparklineFillColor='rgba(31, 118, 189, 0.18)',
          sparklineFull=true,
          sparklineLineColor='rgb(31, 120, 193)',
          gaugeShow=true,
          gaugeMinValue=0,
          gaugeMaxValue=1,
          gaugeThresholdMarkers=true,
          gaugeThresholdLabels=false,
        )
        .addTarget(prometheus.target(
          'sum(irate(response_total{classification="success", cluster=~"$cluster", deployment=~"$deployment"}[$interval])) / sum(irate(response_total{cluster=~"$cluster", deployment=~"$deployment"}[$interval]))' % $._config,
          intervalFactor=1,
        )),
        { h: 4, w: 8, x: 0, y: 3 },
      )
      .addPanel(
        singlestat.new(
          $._config.titles.topLine.globalRequestVolume,
          datasource='%(datasource)s' % $._config.datasource,
          valueName='current',
          valueFontSize='80%',
          colors=[
            '#d44a3a',
            'rgba(237, 129, 40, 0.89)',
            '#299c46'
          ],
          format='rps',
          sparklineShow=true,
          sparklineFillColor='rgba(31, 118, 189, 0.18)',
          sparklineFull=true,
          sparklineLineColor='rgb(31, 120, 193)',
        )
        .addTarget(prometheus.target(
          'sum(irate(request_total{cluster=~"$cluster", deployment=~"$deployment"}[$interval]))' % $._config,
          intervalFactor=2,
        )),
        { h: 4, w: 8, x: 8, y: 3 },
      )
      .addPanel(common.namespaceCount($._config), { h: 4, w: 4, x: 16, y: 3 })
      .addPanel(common.deploymentCount($._config), { h: 4, w: 4, x: 20, y: 3 })
      .addPanel(common.header($._config.titles.topLine.topLineHeader), { h: 2, w: 24, x: 0, y: 7 })
      .addPanel(common.successRateGraph(
        $._config,
        'sum(irate(response_total{classification="success", cluster=~"$cluster", namespace=~"$namespace", deployment=~"$deployment", direction="inbound"}[$interval])) by (deployment) / sum(irate(response_total{cluster=~"$cluster", namespace=~"$namespace", deployment=~"$deployment", direction="inbound"}[$interval])) by (deployment)',
        'deployment/$deployment',
        null,
      ), { h: 8, w: 8, x: 0, y: 9 })
      .addPanel(common.requestVolumeGraph(
        $._config,
        {
          query: 'sum(irate(request_total{cluster=~"$cluster", direction="inbound", tls="true"}[$interval])) by (namespace)',
          legend: '🔒ns/{{namespace}}',
        },
        {
          query: 'sum(irate(request_total{cluster=~"$cluster", direction="inbound", tls!="true"}[$interval])) by (namespace)',
          legend: 'ns/{{namespace}}',
        },
      ), { h: 8, w: 8, x: 8, y: 9 })
      .addPanel(common.p95LatencyGraph(
        $._config,
        'histogram_quantile(0.95, sum(irate(response_latency_ms_bucket{cluster=~"$cluster", direction="inbound"}[$interval])) by (le, namespace))',
      ), { h: 8, w: 8, x: 16, y: 9 })
      .addPanel(common.header($._config.titles.topLine.namespacesHeader), { h: 2, w: 24, x: 0, y: 17 })

      .addPanel(
        row.new(
          title='ns/$namespace',
          repeat='namespace',
        ),
        { h: 1, w: 24, x: 0, y: 19 }
      ).addPanel(
        common.successRateGraph(
          $._config,
          'sum(irate(response_total{classification="success", cluster=~"$cluster", namespace="$namespace", direction="inbound"}[$interval])) by (deployment) / sum(irate(response_total{cluster=~"$cluster", namespace="$namespace", direction="inbound"}[$interval])) by (deployment)',
          'deploy/{{deployment}}',
          null,
        ),
        { h: 8, w: 8, x: 0, y: 19 }
      ).addPanel(
        common.requestVolumeGraph(
          $._config,
          {
            query: 'sum(irate(request_total{cluster=~"$cluster", namespace="$namespace", direction="inbound", tls="true"}[$interval])) by (deployment)',
            legend: '🔒deploy/{{deployment}}',
          },
          {
            query: 'sum(irate(request_total{cluster=~"$cluster", namespace="$namespace", direction="inbound", tls!="true"}[$interval])) by (deployment)',
            legend: 'deploy/{{deployment}}',
          },
        ),
        { h: 8, w: 8, x: 8, y: 19 }
      ).addPanel(
        common.p95LatencyGraph(
          $._config,
          'histogram_quantile(0.95, sum(irate(response_latency_ms_bucket{cluster=~"$cluster", namespace="$namespace", direction="inbound"}[$interval])) by (le, deployment))',
        ),
        { h: 8, w: 8, x: 16, y: 19 }
      )
  },
}
