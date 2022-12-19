# Mosquitto

Set this configuration under /etc/mosquitto/mosquitto.conf

On the latest ubuntu distro (22.04 Jammy) mosquitto only listens on localhost port 1883 by default. Further configuration is needed to use mqtt on different nodes behind a router.

Since my infrastructure has edgenodes behind a router, it is mandatory to NAT ports to specific nodes, and because of that each node has to publish on a different port on mqtt. For this example, edgenode1 publishes on port 1883, while node rpi3 publishes on node 1882.

This is done setting up listeners.
