# Copyright (c) 2020 Intel Corporation.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#Dockerfile for Grafana

ARG EII_VERSION
ARG GRAFANA_VERSION

FROM ia_common:$EII_VERSION as common
FROM grafana/grafana:${GRAFANA_VERSION}-ubuntu as runtime
LABEL description="Grafana image"

WORKDIR /app

COPY . ./Grafana
USER root
# Setting python env
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3-distutils python3-minimal

ARG EII_UID
ARG EII_USER_NAME
RUN groupadd $EII_USER_NAME -g $EII_UID && \
    useradd -r -u $EII_UID -g $EII_USER_NAME $EII_USER_NAME


ARG CMAKE_INSTALL_PREFIX
ENV PYTHONPATH $PYTHONPATH:/app/.local/lib/python3.8/site-packages:/app
COPY --from=common ${CMAKE_INSTALL_PREFIX}/lib ${CMAKE_INSTALL_PREFIX}/lib
COPY --from=common /eii/common/util util
COPY --from=common /root/.local/lib .local/lib

RUN chown -R ${EII_UID} .local/lib/python3.8

RUN mkdir /tmp/grafana && \
    chown -R ${EII_UID}:${EII_UID} /tmp/ && \
    chmod -R 760 /tmp/

USER $EII_USER_NAME

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:${CMAKE_INSTALL_PREFIX}/lib
ENV PATH $PATH:/app/.local/bin

HEALTHCHECK NONE
ENTRYPOINT ["./Grafana/run.sh"]
