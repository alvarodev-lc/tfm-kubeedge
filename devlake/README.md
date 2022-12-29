# Apache devlake

Apache devlake is a tool that can be used to extract DevOps metrics from git repositories. It provides a Grafana instance with a lot of dashboards with visualizations of the data of the repositories connected.

You can deploy it using the docker-compose.yml file in this folder, having the .env file in the same path.

## Config UI

After deploying, you can access the configuration UI on port 4000. This UI is used to connect repositories with devlake. Choose data connections, and connect any repository you want to use.

After that, create a blueprint adding all the data needed, and after that you should be able to see data on Grafana.

## Grafana

Grafana UI is accessible on port 3002 or clicking the dashboard tab on the config UI.

Check the DORA dashboard or any git related dashboard to see data related.
