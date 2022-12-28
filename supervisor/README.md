# Supervisor

Install supervisor

```sh
sudo apt update && sudo apt install supervisor
```

For this example, I stored proxy scripts on a .supervisor folder in my HOME directory, but you can use the path you want.

Each configuration executes one script to bring up a different process. Supervisor is used because microk8s takes some time after rebooting to start, and this way we can automatize the proxy commands needed to access services remotely without the need of typing commands in a terminal each time.

Files found in conf should be placed under /etc/supervisor/conf.d

File supervisord.conf is under /etc/supervisor and must be replaced with the ports, credentials and IP you want to use.

## Cheatsheet

To reload supervisor and force it to read new processes and configuration, use this commands:

```sh
sudo supervisorctl reread
```

```sh
sudo supervisorctl update
```
