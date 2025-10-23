+++
title = "Nix for Reproducible Developer Environments"
author = ["Oliver Pauffley"]
date = 2025-10-23T14:37:00+01:00
draft = false
weight = 2004
+++

## Protobuf {#protobuf}

{{< figure src="/ox-hugo/what_are_protos.png" >}}


## Version Number Wars {#version-number-wars}


### Col left {#col-left}

Everyone loves a PR with 2000+ changes.
![](/ox-hugo/pr_size.png)


### Col right {#col-right}

But drilling down.
![](/ox-hugo/why_big.png)


## The Problem {#the-problem}

Every developer has a different version of the tools used to generate the protos!


## Make - Install everything on my machine {#make-install-everything-on-my-machine}

Lets just include instructions on how to install things

```makefile
PROTOC_VERSION := 3.14.0
.PHONY: install-protoc
install-protoc:
	curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/$(PROTOC_FILE)
	sudo unzip -o $(PROTOC_FILE) -d /usr/local bin/protoc
	sudo unzip -o $(PROTOC_FILE) -d /usr/local 'include/*'
	rm -f $(PROTOC_FILE)
```


## Ahh? {#ahh}

-   Turns out this was already in the repo.
-   I don't really want to have curl installing things.
-   You can just ignore it.


## Install everything on someone else's machine {#install-everything-on-someone-else-s-machine}

-   If only there was a way to build a little mini machine with the binaries I need already on it.
-   Distribute the machine.
-   Docker!


## Docker {#docker}

```dockerfile
FROM cimg/go:1.19-node as build-stage

ENV PROTOC_VERSION=3.18.1

# Install protoc
RUN curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip
RUN unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d $HOME/.local
RUN rm protoc-${PROTOC_VERSION}-linux-x86_64.zip

RUN mkdir -p /home/circleci/project/pkg/generated

# Install go/js tooling
ADD Makefile .
ADD go.mod .
ADD go.sum .
ADD package.json .
ADD yarn.lock .
RUN make install

ADD . .
# Generate code from proto files.
RUN make protos-generate

FROM scratch as export-stage

COPY --from=build-stage /home/circleci/project/pkg/generated /pkg/generated
```


## Docker {#docker}


### Col left {#col-left}

Pros:

-   We can distribute this file and get the same(ish) system for everyone
-   We can use it CI/CD


### Col right {#col-right}

Cons:

-   We have actually only lifted the problem into docker
-   `ADD package.json`
-   This is only as deterministic as the package management we are using within docker.
-   Very slow
-   Doesn't connect well with local tooling for devs


## Nix - Install everything on my machine the same as everyone else's {#nix-install-everything-on-my-machine-the-same-as-everyone-else-s}


## Demo {#demo}


## Is Nix for You? {#is-nix-for-you}


### Col left {#col-left}

Almost definitely no...

-   It's a little complicated to learn (But really not a big barrier to entry).
-   The payoff is complicated to explain.
-   Error messages are difficult to understand.

But

-   It's probably the future?
-   When it's working and setup it's incredibly powerful.
-   You are probably rebuilding it's features yourself.


### Col right {#col-right}

> I’ve been a happy Nix user for about 18 months now, and– well, not happy happy, but satisfied… no… not really satisfied either; perhaps it’s more of a resigned disgruntlement; a feeling that despite its many flaws, it’s still better than anything else out there, and I’ve invested so much time into it already that it would be a shame to give up now, so… am I describing Stockholm syndrome?
> --- Ian Henry


## How to install Nix {#how-to-install-nix}

<https://nixos.org/download/>

-   Works on linux, mac and windows (through wsl)
-   You can use it as well as your other package managers


## Haskell Book Club {#haskell-book-club}

I also run a monthly haskell book club. Meeting on the last Sunday of the month


## Questions? {#questions}
