# Copyright 2015 Jubic Oy
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# 		http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM debian:jessie
MAINTAINER Vilppu Vuorinen "vilppu.vuorinen@jubic.fi"

# Install deps
ADD common/apt/unstable.pref /etc/apt/preferences.d/unstable.pref
ADD common/apt/unstable.list /etc/apt/sources.list.d/unstable.list
RUN apt-get update \
  && apt-get install -y \
    ca-certificates \
    git \
    socat \
    curl \
    gettext \
    mysql-client \
  && apt-get install -y -t unstable libnss-wrapper \
  && rm -rf /var/lib/apt/lists/*

# Install tini
ENV TINI_SHA 066ad710107dc7ee05d3aa6e4974f01dc98f3888
RUN curl -fL https://github.com/krallin/tini/releases/download/v0.5.0/tini-static -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA /bin/tini" | sha1sum -c -
ENTRYPOINT [ "/bin/tini", "--", "/gogs/entrypoint.sh" ]

ADD common/root /
RUN useradd -u 1001 -d /gogs -m -s /bin/bash git \
  && mkdir -p /gogs
ADD tmp/gogs /gogs
ADD common/scripts /gogs/docker-scripts
ADD common/app.ini.template /gogs/app.ini.template
ADD common/nsswrapper/* /gogs/

RUN mkdir /gogs/volume \
  && /usr/libexec/fix-permissions git /gogs

VOLUME /gogs/volume
EXPOSE 3000

ENV HOME /gogs
USER 1001
ENV USER git
CMD [ "/gogs/docker-scripts/run.sh" ]
