From nimmis/alpine-glibc
COPY . /go/src/app
WORKDIR /go/src/app
#RUN go test ./... -cover -v
RUN go build -o /go/bin/app .


From nimmis/alpine-glibc:latest
LABEL Author=app
RUN apk --no-cache add ca-certificates bash
COPY --from=0 /go/bin/app .
ADD ./wait.sh /wait.sh
RUN chmod +x /wait.sh
CMD [ "/wait.sh" ]
EXPOSE 80
