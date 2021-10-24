ARG RUNTIME_VERSION="3.8"

FROM python:${RUNTIME_VERSION}-slim AS builder

# Since we use an official Debian image, we do not need to manually clear cache
# For example 'apt-get clean && rm -rf /var/lib/apt/lists/*' happens automatically
# when we use 'apt-get install'

## Phase 1: Install 'build dependencies'
# Install 'build dependencies': programs that need to exist while we 'build' the code

# Install build-essential that includes c++ compiler tool chain
# Install autoconf automake programs, which are used in autogen.sh

RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    swig \
    python3 \
    python3-dev \
    python3-pip


# Install numpy which is required by command 'make python'
# We install it a newly created python virtual environment, which we 'activate'
RUN pip install virtualenv
ENV PY3_VIRTUALENV /env3
RUN python -m virtualenv ${PY3_VIRTUALENV} --python=python3
ENV PATH ${PY3_VIRTUALENV}/bin:${PATH}
RUN pip install numpy

# Verify that openMP is enabled/supported
RUN echo |cpp -fopenmp -dM |grep -i open

ENV PYTHONUNBUFFERED=1

WORKDIR /somoclu

# COPY . .
COPY data data
COPY m4 m4
COPY autogen.sh autogen.sh
COPY CHANGES CHANGES
COPY CITATION CITATION
COPY LICENSE LICENSE
COPY configure.ac configure.ac
COPY Makefile.in Makefile.in
COPY src src
RUN ls -l


## Generate configuration files
## Run autogen.sh script and generate files:
# aclocal.m4, (autom4te.cache), config.h.in, configure, install-sh
RUN sh autogen.sh
##

## Configure
## Run the generated 'configure' script that generates files:
# Makefile's [in /somoclu (root dir) and in /somoclu/src], config.h, config.log, config.status
RUN /somoclu/configure
##

## Make for Python, using the python binary from the virtual environment
## Copies cpp files into src/Python/somoclu
## Adds directory (with *.cpp, *.h and *.u files, Makefile.in) at src/Python/somoclu/src
## Put build artifacts in src/Python/build
RUN make python


### Phase 2: Compile wheel

WORKDIR /somoclu/src/Python
RUN python setup.py bdist_wheel

ENV SOMOCLU_WHEEL_DIR=/somoclu/src/Python/dist

# RUN pip install dist/somoclu*.whl

## Usage in your docker file
# ENV DIST_DIR=/som-dist
# COPY --from boromir674/somoclu:debian /somoclu/src/Python/dist/ ${DIST_DIR}
# RUN pip install ${DIST_DIR}/somoclu*.whl


# Usage:
# FROM boromir674/python-somoclu-debian
# RUN python3 -m pip install numpy
# RUN cd src/Python && python3 -m pip install .
# CMD ["python3", "-c", "'import somoclu'"]

# python3 -c 'import somoclu' should now work without any warnings
