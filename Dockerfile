FROM golang:1.21.2-alpine3.18

WORKDIR /app

RUN <<EOR
cat > /entry.sh <<EOF
#!/bin/sh

trap 'kill "\${child_pid}"; wait "\${child_pid}"' 2 15
go test \$@
sleep infinity &
child_pid="\$!"
wait "\$child_pid"

EOF
EOR

COPY ./app/go.mod .
COPY ./app/go.sum .
RUN go mod download

COPY ./app/src /app/src

ENTRYPOINT ["sh", "/entry.sh"]
CMD ["-v", "./..."]
