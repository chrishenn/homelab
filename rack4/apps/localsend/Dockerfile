FROM rust:1.83 AS builder

WORKDIR /app

COPY Cargo.* ./
COPY src ./src
RUN touch ./src/main.rs
RUN cargo build --release

FROM debian:bookworm AS runtime

COPY --from=builder /app/target/release/server /server

EXPOSE 3000
ENTRYPOINT ["/server"]
