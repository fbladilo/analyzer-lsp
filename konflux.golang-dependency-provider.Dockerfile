FROM registry.redhat.io/ubi9/go-toolset:1.23 AS builder
COPY --chown=1001:0 . /workspace

WORKDIR /workspace/external-providers/golang-dependency-provider
ENV GOEXPERIMENT strictfipsruntime
RUN go mod edit -replace=github.com/konveyor/analyzer-lsp=../../ && CGO_ENABLED=1 go build -tags strictfipsruntime -o golang-dependency-provider main.go

FROM registry.redhat.io/ubi9:latest
RUN dnf -y install openssl && dnf -y clean all

COPY --from=builder /workspace/external-providers/golang-dependency-provider/golang-dependency-provider /usr/local/bin/golang-dependency-provider
COPY --from=builder /workspace/LICENSE /licenses/

ENTRYPOINT ["/usr/local/bin/golang-dependency-provider"]
