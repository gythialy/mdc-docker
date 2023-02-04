# mdc-docker
🐳 A docker image to run [MDC](https://github.com/yoshiko2/Movie_Data_Capture) in one step.

## Docker

```bash
docker run -d \
  --name mdc \
  -e UID=1000 \
  -e GID=1000 \
  -e TZ=Asia/Shanghai \
  --restart no \
  -v /path/to/data:/data \
  -v /path/to/data2:/data2 \
  -v $(pwd)/config:/config
  -v $(pwd)/config.ini:/config/mdc.ini
  ghcr.io/gythialy/mdc:latest

```

## Docker-compose 

```yaml
version: "3.5"
services:
  mdc:
    image: ghcr.io/gythialy/mdc:6.5.1
    container_name: mdc
    environment:
      - UID=1000
      - GID=1000
      - TZ=Asia/Shanghai
      - UMASK=002
    volumes:
      - ./config:/config
      - ./config/mdc.ini:/root/.config/mdc/config.ini
      - /mnt/data:/data
    networks:
      - nginx-proxy
    restart: "no"
    logging:
      driver: "json-file"
      options:
        max-size: "10M"
        max-file: "10"
```