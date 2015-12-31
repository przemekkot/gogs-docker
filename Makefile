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

SHELL := /bin/bash

ifeq ($(TARGET),0.8.10)
	VERSION := 0.8.10
else ifeq ($(TARGET),0.8.0)
	VERSION := 0.8.0
endif
ifdef NOCACHE
	OPTS := --no-cache
endif

IMAGE_NAME := jubicoy/gogs

container: binary
ifndef VERSION
	$(error TARGET not set or invalid)
endif
	docker build $(OPTS) -t $(IMAGE_NAME):$(VERSION) .

push:
	docker push $(IMAGE_NAME):$(VERSION)

binary: extract-binary

./tmp/gogs_v$(VERSION)_linux_amd64.tar.gz:
ifndef VERSION
	$(error TARGET not set or invalid)
endif
	mkdir -p tmp
	@pushd tmp \
		&& curl -SLO https://dl.gogs.io/gogs_v$(VERSION)_linux_amd64.tar.gz \
		|| popd

extract-binary: ./tmp/gogs_v$(VERSION)_linux_amd64.tar.gz
ifndef VERSION
	$(error TARGET not set or invalid)
endif
	@pushd tmp \
		&& tar -xzf gogs_v$(VERSION)_linux_amd64.tar.gz \
		|| popd

