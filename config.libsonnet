{
  _config+:: {

    datasource: 'prometheus',

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
    },

    multiCluster: {
      enabled: true,       // build with multi cluster options
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
      common: {
        successRate: 'SUCCESS RATE',
        requestVolume: 'REQUEST VOLUME',
        p95Latency: 'P95 LATENCY',
      },

      topLine: {
        globalRequestVolume: 'GLOBAL REQUEST VOLUME',
        globalSuccessRate: 'GLOBAL SUCCESS RATE',
        SuccessRate: 'GLOBAL SUCCESS RATE',
        namespacesMonitored: 'NAMESPACES MONITORED',
        deploymentsMonitored: 'DEPLOYMENTS MONITORED',
        topLineHeader: 'TOP LINE',
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

  },
}
