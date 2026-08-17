FROM alpine:3.18
RUN apk add --no-cache gnu-cobol db-dev gcc musl-dev
WORKDIR /app
COPY . /app
RUN cobc -x -O sistema.cbl -o sistema
CMD ["./sistema"]
