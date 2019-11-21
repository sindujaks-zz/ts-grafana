#Dockerfile for Grafana
ARG EIS_VERSION
FROM ia_eisbase:$EIS_VERSION as eisbase

LABEL description="Grafana image"

ENV PYTHONPATH ${PYTHONPATH}:./..

FROM ia_common:$EIS_VERSION as common

FROM eisbase

COPY --from=common ${GO_WORK_DIR}/common/libs ${PY_WORK_DIR}/libs
COPY --from=common ${GO_WORK_DIR}/common/util ${PY_WORK_DIR}/util

ARG GRAFANA_VERSION

RUN apt-get update && \
    apt-get -y --no-install-recommends install libfontconfig curl ca-certificates && \
    apt-get clean && \
    curl https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_amd64.deb > /tmp/grafana.deb && \
    dpkg -i /tmp/grafana.deb && \
    rm /tmp/grafana.deb && \
    apt-get remove -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY ./requirements.txt .

COPY . ./Grafana

#Installing pyyaml from requirements.txt
RUN pip3 install -r requirements.txt && \
    rm -rf requirements.txt

EXPOSE 3000

COPY ./run.sh /run.sh

ARG EIS_UID
RUN chown -R ${EIS_UID} /var/lib/grafana && \
    chown -R ${EIS_UID} /var/log/grafana && \
    chown -R ${EIS_UID} /etc/grafana

ENTRYPOINT [ "/run.sh" ]