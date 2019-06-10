Firefox SyncServer
==================
*Simple, lightweight and secure SyncServer container based on Alpine linux.*

![firefox syncserver](sync.png)

### What is Firefox SyncServer ?
This is an all-in-one package for running a self-hosted Firefox Sync server. It bundles the "tokenserver" project for authentication and the "syncstorage" project for storage, produce a single stand-alone webapp.  
You can find the repository of the service [here](https://github.com/mozilla-services/syncserver).  

### Goal of this container
This container should be as simple as possible to set up.  
It does not require any volume since your browser keeps the data during downtime.  
As secure as I can make it.  

### Features
- Based on Alpine linux. As lightweight as possible.
- Does not execute the server as root. As secure as possible.
- No volumes or complex configuration. As simple as possible.

### Run-time variables
- **URL**: The url that your browser sees. For example: https://sync.example.com
- **FORCE_WSGI**: (Optional) Set to "true" to resolve a mismatch between a public url and the application url.
- **UID**: (Optional) The UID executing the server
- **GID**: (Optional) The GID executing the server

### Ports
- 5000

### Setup
Example command to build this image:
```
git clone https://github.com/brantje/docker-firefox-syncserver
cd docker-firefox-syncserver
docker build -t sync .
```
Example command to run this container:
```
docker run -d -p 5000:5000 -e URL=https://sync.example.com --name sync sync
```


You can now open a new tab in firefox, go to about:config, search for the identity.sync.tokenserver.uri preference and change the value to https://sync.example.com:5000/token/1.0/sync/1.5  
Firefox should now sync with your server.
If you're already logged in, log out and back in to make the change effective.



### NGINX proxy example

```
server {

        server_name example.com;
        location / {
             proxy_pass  http://localhost:5000/;
             proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
             proxy_redirect off;
             proxy_buffering off;
             proxy_set_header        Host            $host;
             proxy_set_header        X-Real-IP       $remote_addr;
             proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
             proxy_set_header        X-Forwarded-Proto $scheme;
         }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
```
