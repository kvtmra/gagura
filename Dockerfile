FROM debian:bookworm-slim

ARG XMRIG_VERSION=6.22.2

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates \
 && curl -fsSL "https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/xmrig-${XMRIG_VERSION}-linux-static-x64.tar.gz" \
    | tar xz -C /opt \
 && mv /opt/xmrig-${XMRIG_VERSION}/xmrig /usr/local/bin/xmrig \
 && rm -rf /opt/xmrig-* /var/lib/apt/lists/* \
 && apt-get purge -y curl && apt-get autoremove -y

USER nobody

CMD ["sh", "-c", "xmrig -o ${POOL_URL} -u ${WALLET} -p ${WORKER_NAME} -k --tls --donate-level=0 --cpu-max-threads-hint=${CPU_HINT:-75}"]
