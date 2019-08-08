FROM debian:buster as builder

ENV GRPC_VER v1.22.0
ENV GRPC_SRC /var/local/grpc

RUN apt-get update && apt-get install -y \
	build-essential autoconf git pkg-config \
	automake libtool curl make g++ unzip \
	&& apt-get clean

RUN echo "--- downloading grpc source code ---" && \
	git clone -b ${GRPC_VER} https://github.com/grpc/grpc ${GRPC_SRC} && \
	cd ${GRPC_SRC} && \
	git submodule update --init --recursive && \
	echo "--- installing protobuf ---" && \
	cd ${GRPC_SRC}/third_party/protobuf && \
	./autogen.sh && ./configure --enable-shared && \
	make -j$(nproc) && make -j$(nproc) check && make install && make clean && ldconfig && \
	echo "--- installing grpc ---" && \
	cd ${GRPC_SRC} && \
	CFLAGS="-Wno-cast-function-type" make -j$(nproc) && make install && make clean && ldconfig

RUN rm -rf ${GRPC_SRC}
