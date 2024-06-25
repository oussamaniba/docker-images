

Change Email in compose.yml in this line: 

***> --certificatesresolvers.le.acme.email=

Create network with this command: "docker network create traefik-public"

Run this command "docker-compose up -d"


To use Traefik for as reverse proxy use this label 

labels:
  - "traefik.enable=true"
  - "traefik.docker.network=traefik-public"
  - "traefik.http.routers.SERVICE-NAME.tls.certresolver=le"
  - "traefik.http.routers.SERVICE-NAME.tls=true"
  - "traefik.http.routers.SERVICE-NAME.entrypoints=websecure"
  - "traefik.http.routers.SERVICE-NAME.service=radyy-io-be"
  - "traefik.http.routers.SERVICE-NAME.rule=Host(`URL-HERE-WITHOUT-HTTP`)"
  - "traefik.http.services.SERVICE-NAME.loadbalancer.server.port=8080"


Replace SERVICE-NAME with you service name preferably same as your docker image name

Replace URL-HERE-WITHOUT-HTTP with your URL example : api.website.com or www.website.com >> if you need to use two different urls to point to the same service use something like Host(`URL1-HERE-WITHOUT-HTTP`, `URL2-HERE-WITHOUT-HTTP`)


here's an example of one of my services 



version: "3.8"
services:
  radyy-io:
    container_name: radyy-io-backend
    build: .
    command: [ "java", "-jar", "/app.jar" ]
    restart: unless-stopped
    volumes:
      - ./build/libs:/app
    env_file:
      - environments.env
    networks:
      - traefik-public
    environment:
      JAVA_OPTS: "-Xmx256m"
    logging:
      driver: "json-file"
      options:
        max-file: "5"
        max-size: "10m"
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=traefik-public"
      - "traefik.http.routers.radyy-io-be.tls.certresolver=le"
      - "traefik.http.routers.radyy-io-be.tls=true"
      - "traefik.http.routers.radyy-io-be.entrypoints=websecure"
      - "traefik.http.routers.radyy-io-be.service=radyy-io-be"
      - "traefik.http.routers.radyy-io-be.rule=Host(`radio-api.oussamaniba.com`)"
      - "traefik.http.services.radyy-io-be.loadbalancer.server.port=8080"

networks:
  traefik-public:
    external: true



