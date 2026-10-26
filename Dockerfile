FROM alpine:3.20 AS build
ARG XMRIG_VERSION=6.22.2

RUN apk add --no-cache git make cmake gcc g++ libstdc++ linux-headers \
    libuv-dev openssl-dev hwloc-dev

RUN git clone --depth 1 --branch v${XMRIG_VERSION} https://github.com/xmrig/xmrig.git /xmrig

WORKDIR /xmrig

# Bağışı koddan sıfırla. Değişmezse derleme hata verip durur.
RUN sed -i 's/kDefaultDonateLevel = 1;/kDefaultDonateLevel = 0;/; s/kMinimumDonateLevel = 1;/kMinimumDonateLevel = 0;/' src/donate.h \
 && grep -q "kDefaultDonateLevel = 0;" src/donate.h \
 && grep -q "kMinimumDonateLevel = 0;" src/donate.h

RUN mkdir build && cd build && cmake .. && make -j$(nproc)

FROM alpine:3.20
RUN apk add --no-cache libstdc++ libgcc libuv openssl hwloc
COPY --from=build /xmrig/build/xmrig /usr/local/bin/xmrig
USER nobody
CMD ["sh", "-c", "xmrig -o ${POOL_URL} -u ${WALLET} -p ${WORKER_NAME} -k --tls --donate-level=0 --cpu-max-threads-hint=${CPU_HINT:-100} --cpu-priority=1 --print-time=60"]
