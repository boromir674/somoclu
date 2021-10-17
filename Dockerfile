FROM gcc:9.4.0-buster as builder

# Verify that openMP is enabled/supported
# RUN echo |cpp -fopenmp -dM |grep -i open


# Layer not cached because we include apt update and apt install together
RUN apt-get update \
    && apt-get install -y python-pip \
    && python -m pip install setuptools numpy \
    && apt-get -y install swig

COPY . /code
WORKDIR /code

RUN ./autogen.sh
RUN ./configure
RUN make python

## Opt1 -> size 1.64GB
WORKDIR /code/src/Python

RUN apt-get update && apt-get install -y python3-pip
RUN python3 -m pip install setuptools \
    && python3 -m pip install numpy \
    && python3 setup.py install

# python3 -c 'import somoclu' should now work without any warnings