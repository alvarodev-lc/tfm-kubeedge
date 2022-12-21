# Node Red

To create a node red container with persistence, first we need to create a folder so that it has the correct permissions:

```sh
mkdir node-red
```

Then create the docker container using docker run:

```sh
docker run -it -p 1880:1880 -v /home/alvaro/node-red:/data --name nodered nodered/node-red
```

## Dashboard

To install node-red dashboard, go into the web UI and install **node-red-dashboard** as a package.

After it's installed, it should be accessible adding **/ui** to the end of your node-red url.

## IoTHub

To install IoTHub extension, go into the web UI and install **node-red-contrib-azure-iot-hub**.

The messages it receives should have the following format:

```json
{
  "deviceId": "node",
  "key": "secretDeviceAzureKey",
  "protocol": "mqtt",
  "data": "{tem: 25, wind: 20}"
}
```

The **key** parameter is found under your Azure IoTHub devices, you can choose any of the 2 connection strings available. The **data** is the actual message we want to send from our node-red app to the IoTHub.
