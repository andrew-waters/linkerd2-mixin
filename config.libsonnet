local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
local configMapList = k.core.v1.configMapList;

{
  linkerd+:: {

    dashboards: configMapList.new($.dashboards),

    datasource: 'prometheus', // datasource name for your metrics
    branded: false,            // enable/disable linkerd header branding
    schemaVersion: 18,        // grafana dashboard schema version

    dashboardIDs: {
      'authority.json': 'AMXeShbu5yvniWYLxst1GXe3a01P66Y2VZSQ2osZ',
      'daemonset.json': 'OviPOt9NV00j4bhLl7lfreI759sSJIgNM2KcTToY',
      'deployment.json': '8zMLFR0psnhq8g341oEgMWgiNq1YmGBN6TWSjN4y',
      'grafana.json': 'QJw0QG3YmMNhKk2AhCzsi0zs8peXB8UuW6bVptRG',
      'health.json': 'u34d1sEuvyl1elCyq4HzxNxe6dsq9AK5atDmWQ0P',
      'job.json': 'pT4xKPfmQQE3xYr0kf8B9CpXs9nWIFpUU9qEnUOe',
      'namespace.json': 'zVg9mFURJOeLzqF2cTgeBLt5mxDJrFa9sxKYdKTX',
      'pod.json': 'kp4zPPCFaTn49I6OITUZvRSR10bGs7fF9XsESc9i',
      'replicationcontroller.json': 'DCtMj7cXDl8OovvDjxgWO7DEkH0Mtmzmrom5ox3T',
      'service.json': '8lEIV1KPVPfpms6Ah7Ptq9vl6VwqdOmBcoAaPq0k',
      'statefulset.json': 'Z7GYPQlbzwYMnWEYthsHQn3uHkDzLR0yA9G4WYCN',
      'top-line.json': 'OOYcndcc6bvkJGmE53ZKFuGeI4ksEZIu6YVdbcHk',
    },

    dashboard: {
      namePrefix: 'Linkerd2 / ',
      tags: ['linkerd', 'mesh', 'ops'],
      editable: true,
      timeFrom: 'now-5m',
    },

    multiCluster: {
      enabled: true,        // build with multi cluster options
      label: 'cluster',     // the prometheus label you use to identify the cluster
      labelName: 'Cluster', // used as the name for the drop down
    },

    namespace: {
      label: 'Namespace'
    },

    loki: {
      enabled: false,
    },

    titles: {
      authority: {
        title: 'au/$authority',
        topLineTraffic: 'TOP-LINE TRAFFIC',
        inboundTrafficByDeployment: 'INBOUND TRAFFIC BY DEPLOYMENT',
        inboundTrafficByPod: 'INBOUND TRAFFIC BY POD',
      },
      common: {
        inbound: 'INBOUND',
        outbound: 'OUTBOUND',
        successRate: 'SUCCESS RATE',
        requestRate: 'REQUEST RATE',
        latency: 'LATENCY',
        p95Latency: 'P95 LATENCY',
      },
      topLine: {
        namespace: {
          title: 'ns/$namespace',
        },
        globalRequestVolume: 'GLOBAL REQUEST VOLUME',
        globalSuccessRate: 'GLOBAL SUCCESS RATE',
        namespacesMonitored: 'NAMESPACES MONITORED',
        deploymentsMonitored: 'DEPLOYMENTS MONITORED',
        topLineHeader: 'TOP LINE',
        namespacesHeader: 'NAMESPACES',
      },
      pod: {
        title: 'po/$pod',
        traffic: {
          title: 'Traffic',
        },
        tcp: {
          title: 'TCP',
          failures: 'TCP CONNECTION FAILURES',
          open: 'TCP CONNECTIONS OPEN',
          duration: 'TCP CONNECTION DURATION',
        },
        panels: {
          inbound: 'INBOUND',
          outbound: 'OUTBOUND',
        },
        pods: {
          title: 'Pods',
          inbound: 'INBOUND',
          outbound: 'OUTBOUND',
        },
      },
      statefulSet: {
        namespacesMonitored: 'NAMESPACES MONITORED',
      },
      service: {
        namespacesMonitored: 'NAMESPACES MONITORED',
      },
      replicationController: {
        namespacesMonitored: 'NAMESPACES MONITORED',
      },
    },

    legends: {
      authority: {
        secure: '🔒au/{{authority}}',
        regular: 'au/{{authority}}',
      },
      deployment: {
        secure: '🔒deploy/{{deployment}}',
        regular: 'deploy/{{deployment}}',
      },
      namespace: {
        secure: '🔒ns/{{namespace}}',
        regular: 'ns/{{namespace}}',
      },
      pods: {
        secure: '🔒po/{{pod}}',
        regular: 'po/{{pod}}',
      },
    },

    style: {
      colors: [
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
      ],
      spark: {
        line: 'rgb(31, 120, 193)',
        fill: 'rgba(31, 118, 189, 0.18)',
      },
    },

  },
}
