FROM alpine:3.13.6

RUN apk add gcc musl-dev linux-headers g++

# Verify that openMP is enabled/supported
# RUN echo |cpp -fopenmp -dM |grep -i open

RUN apk add autoconf automake
RUN apk add swig

ENV PYTHONUNBUFFERED=1
RUN apk add --update python2
RUN apk add python2-dev
RUN python2 -m ensurepip
RUN python2 -m pip install --upgrade pip setuptools wheel
RUN python2 -m pip install numpy


COPY . /code
WORKDIR /code

# COPY data data
# COPY m4 m4
# COPY autogen.sh autogen.sh
# COPY CHANGES CHANGES
# COPY CITATION CITATION
# COPY LICENSE LICENSE
# COPY configure.ac configure.ac
# COPY Makefile.in Makefile.in
# COPY src src

RUN ./autogen.sh
RUN ./configure

RUN apk add make
RUN make python


RUN apk add --update --no-cache python3
RUN apk add py3-pip
RUN apk add python3-dev
RUN apk add cython
RUN apk add py3-numpy
RUN apk add py3-scipy
RUN apk add py3-numpy-dev
RUN apk add py3-matplotlib
RUN python3 -m pip install setuptools wheel

WORKDIR /code/src/Python
RUN python3 setup.py install

# python3 -c 'import somoclu' should now work without any warnings
