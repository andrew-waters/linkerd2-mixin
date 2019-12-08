local g = import 'grafonnet/grafana.libsonnet';
local common = import 'common.libsonnet';
local dashboard = g.dashboard;
local row = g.row;
local prometheus = g.prometheus;
local template = g.template;
local singlestat = g.singlestat;

{
  grafanaDashboards+:: {
    'top-line.json':
      dashboard.new(
        '%(namePrefix)sTop Line' % $._config.dashboard,
        time_from='now-5m',
        uid=($._config.dashboardIDs['top-line.json']),
        tags=($._config.dashboard.tags),
        editable=true,
      )
      .addTemplate(
        common.cluster($._config.datasource, $._config.multiCluster.enabled, $._config.multiCluster.label, $._config.multiCluster.labelName),
      )
      .addTemplate(
        common.namespace($._config.datasource, true, $._config.namespace.label),
      )
      .addTemplate(
        common.deployment($._config.datasource, true),
      )
      .addTemplate(
        common.interval(true),
      )
      .addRow(
        row.new()

        .addPanel(common.branding(), {
          h: 3,
          w: 24,
          x: 0,
          y: 0,
        })

        # Global Success Rate
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
          .addTarget(prometheus.target('sum(irate(response_total{classification="success", cluster=~"$cluster", deployment=~"$deployment"}[$interval])) / sum(irate(response_total{cluster=~"$cluster", deployment=~"$deployment"}[$interval]))' % $._config)),
          {
            h: 4,
            w: 8,
            x: 0,
            y: 3,
          },
        )

        # Global Request Volume
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
            colorValue=true,
            format='rps',
            sparklineShow=true,
            sparklineFillColor='rgba(31, 118, 189, 0.18)',
            sparklineFull=true,
            sparklineLineColor='rgb(31, 120, 193)',
          )
          .addTarget(prometheus.target('sum(irate(request_total{cluster=~"$cluster", deployment=~"$deployment"}[$interval]))' % $._config)),
          {
            h: 4,
            w: 8,
            x: 8,
            y: 3,
          },
        )

        .addPanel(common.namespaceCount($._config), {
          h: 4,
          w: 4,
          x: 16,
          y: 3,
        })
        .addPanel(common.deploymentCount($._config), {
          h: 4,
          w: 4,
          x: 20,
          y: 3,
        })

      ),
  },
}
