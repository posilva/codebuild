FROM public.ecr.aws/docker/library/golang:1.21.1-alpine3.18 as builder
ENV CGO_ENABLED=0
WORKDIR /go/src/github.com/posilva/codebuild
COPY . .
RUN  GOOS=linux GOARCH=amd64 go build -a -tags netgo -installsuffix netgo -o bin/codebuild

FROM scratch
COPY --from=builder /go/src/github.com/posilva/codebuild/bin/codebuild /codebuild
 
ENTRYPOINT [ "/codebuild" ]