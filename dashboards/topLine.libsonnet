local g = import 'grafonnet/grafana.libsonnet';
local common = import 'common.libsonnet';
local dashboard = g.dashboard;
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
      .addTemplate(
        common.cluster($.linkerd.datasource, $.linkerd.multiCluster.enabled, $.linkerd.multiCluster.label, $.linkerd.multiCluster.labelName),
      )
      .addTemplate(
        common.namespace($.linkerd.datasource, true, $.linkerd.namespace.label),
      )
      .addTemplate(
        common.deployment($.linkerd.datasource, false),
      )
      .addTemplate(
        common.interval(true),
      )
      .addPanel(
        common.branding($.linkerd),
        { h: 3, w: 24, x: 0, y: 0 }
      )
      .addPanel(
        singlestat.new(
          $.linkerd.titles.topLine.globalSuccessRate,
          datasource='%(datasource)s' % $.linkerd.datasource,
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
          transparent=true,
        )
        .addTarget(prometheus.target(
          'sum(irate(response_total{classification="success", cluster=~"$cluster", deployment=~"$deployment"}[$interval])) / sum(irate(response_total{cluster=~"$cluster", deployment=~"$deployment"}[$interval]))' % $.linkerd,
          intervalFactor=1,
        )),
        { h: 4, w: 8, x: 0, y: 3 },
      )
      .addPanel(
        singlestat.new(
          $.linkerd.titles.topLine.globalRequestVolume,
          datasource='%(datasource)s' % $.linkerd.datasource,
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
          transparent=true,
        )
        .addTarget(prometheus.target(
          'sum(irate(request_total{cluster=~"$cluster", deployment=~"$deployment"}[$interval]))' % $.linkerd,
          intervalFactor=2,
        )),
        { h: 4, w: 8, x: 8, y: 3 },
      )
      .addPanel(common.namespaceCount($.linkerd), { h: 4, w: 4, x: 16, y: 3 })
      .addPanel(common.deploymentCount($.linkerd), { h: 4, w: 4, x: 20, y: 3 })
      .addPanel(common.header($.linkerd.titles.topLine.topLineHeader), { h: 2, w: 24, x: 0, y: 7 })
      .addPanel(
        common.successRateGraph(
          $.linkerd,
          '(%(direction)s) %(successRate)s' % [$.linkerd.titles.common.inbound, $.linkerd.titles.common.successRate],
          'sum(irate(response_total{classification="success", cluster=~"$cluster", namespace=~"$namespace", deployment=~"$deployment", direction="inbound"}[$interval])) by (deployment) / sum(irate(response_total{cluster=~"$cluster", namespace=~"$namespace", deployment=~"$deployment", direction="inbound"}[$interval])) by (deployment)',
          'deployment/$deployment',
          null,
        ),
        { h: 8, w: 8, x: 0, y: 9 },
      )
      .addPanel(common.requestVolumeGraph(
        $.linkerd,
        '(%(direction)s) %(requestVolume)s' % [$.linkerd.titles.common.inbound, $.linkerd.titles.common.requestRate],
        {
          tls: {
            query: 'sum(irate(request_total{cluster=~"$cluster", direction="inbound", tls="true"}[$interval])) by (namespace)',
            legend: '🔒ns/{{namespace}}',
          },
          notls: {
            query: 'sum(irate(request_total{cluster=~"$cluster", direction="inbound", tls!="true"}[$interval])) by (namespace)',
            legend: 'ns/{{namespace}}',
          },
        },
      ), { h: 8, w: 8, x: 8, y: 9 })
      .addPanel(common.p95LatencyGraph(
        $.linkerd,
        'histogram_quantile(0.95, sum(irate(response_latency_ms_bucket{cluster=~"$cluster", direction="inbound"}[$interval])) by (le, namespace))',
      ), { h: 8, w: 8, x: 16, y: 9 })
      .addPanel(common.header($.linkerd.titles.topLine.namespacesHeader), { h: 2, w: 24, x: 0, y: 17 })

      .addPanel(
        row.new(
          title='ns/$namespace',
          repeat='namespace',
        ),
        { h: 1, w: 24, x: 0, y: 19 }
      ).addPanel(
        common.successRateGraph(
          $.linkerd,
          '(%(direction)s) %(requestVolume)s' % [$.linkerd.titles.common.inbound, $.linkerd.titles.common.requestRate],
          'sum(irate(response_total{classification="success", cluster=~"$cluster", namespace="$namespace", direction="inbound"}[$interval])) by (deployment) / sum(irate(response_total{cluster=~"$cluster", namespace="$namespace", direction="inbound"}[$interval])) by (deployment)',
          'deploy/{{deployment}}',
          null,
        ),
        { h: 8, w: 8, x: 0, y: 19 }
      ).addPanel(
        common.requestVolumeGraph(
          $.linkerd,
          '(%(direction)s) %(requestVolume)s' % [$.linkerd.titles.common.outbound, $.linkerd.titles.common.requestRate],
          {
            tls: {
              query: 'sum(irate(request_total{cluster=~"$cluster", namespace="$namespace", direction="inbound", tls="true"}[$interval])) by (deployment)',
              legend: '🔒deploy/{{deployment}}',
            },
            notls: {
              query: 'sum(irate(request_total{cluster=~"$cluster", namespace="$namespace", direction="inbound", tls!="true"}[$interval])) by (deployment)',
              legend: 'deploy/{{deployment}}',
            },
          },
        ),
        { h: 8, w: 8, x: 8, y: 19 }
      ).addPanel(
        common.p95LatencyGraph(
          $.linkerd,
          'histogram_quantile(0.95, sum(irate(response_latency_ms_bucket{cluster=~"$cluster", namespace="$namespace", direction="inbound"}[$interval])) by (le, deployment))',
        ),
        { h: 8, w: 8, x: 16, y: 19 }
      )
  },
}
