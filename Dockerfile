FROM golang:1.13 as builder

ENV GRPC_VER v1.23.0
ENV GRPC_SRC /var/local/grpc

RUN apt-get update && apt-get install -y \
	build-essential autoconf git pkg-config \
	automake libtool curl make g++ unzip \
	&& apt-get clean && \
	echo "--- downloading grpc source code ---" && \
	git clone -b ${GRPC_VER} https://github.com/grpc/grpc ${GRPC_SRC} && \
	cd ${GRPC_SRC} && \
	git submodule update --init --recursive && \
	echo "--- installing protobuf ---" && \
	cd ${GRPC_SRC}/third_party/protobuf && \
	./autogen.sh && ./configure --enable-shared && \
	make -j$(nproc) && make -j$(nproc) check && make install && make clean && ldconfig && \
	echo "--- installing grpc ---" && \
	cd ${GRPC_SRC} && \
	CFLAGS="-Wno-cast-function-type" make -j$(nproc) && make install && make clean && ldconfig && \
	go get -u -v github.com/gogo/protobuf/proto \
	github.com/gogo/protobuf/gogoproto \
	github.com/gogo/protobuf/jsonpb \
	github.com/gogo/protobuf/protoc-gen-gogo \
	github.com/gogo/protobuf/protoc-gen-gofast \
	github.com/gogo/protobuf/protoc-gen-gogofast \
	github.com/gogo/protobuf/protoc-gen-gogofaster \
	github.com/gogo/protobuf/protoc-gen-gogoslick \
	github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway \
	github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger \
	github.com/mwitkow/go-proto-validators/protoc-gen-govalidators \
	google.golang.org/grpc && \
	rm -rf ${GRPC_SRC}
