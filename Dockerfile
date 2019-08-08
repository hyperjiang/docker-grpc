FROM debian:buster

ENV GRPC_VER v1.22.0
ENV GRPC_SRC /var/local/grpc

RUN apt-get update && apt-get install -y \
	build-essential autoconf git pkg-config \
	automake libtool curl make g++ unzip \
	&& apt-get clean

RUN git clone -b ${GRPC_VER} https://github.com/grpc/grpc ${GRPC_SRC} && \
	cd ${GRPC_SRC} && \
	git submodule update --init --recursive

RUN	echo "--- installing protobuf ---" && \
	cd ${GRPC_SRC}/third_party/protobuf && \
	./autogen.sh && ./configure --enable-shared && \
	make -j$(nproc) && make -j$(nproc) check && make install && make clean && ldconfig

RUN	echo "--- installing grpc ---" && \
	cd ${GRPC_SRC} && \
	make -j$(nproc) && make install && make clean && ldconfig
