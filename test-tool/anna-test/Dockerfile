FROM anna-client:latest
MAINTAINER "dev" <dev@xtaotech.com>

ADD xtao.repo /etc/yum.repos.d/
RUN yum clean all
RUN yum makecache

RUN yum install vim -y

# install vjtree
ADD vjtree /usr/sbin/

# install fio
RUN yum install -y fio

# install iozone
ADD iozone /usr/sbin

RUN yum install -y python-pip
ADD pip.conf /etc/pip.conf
RUN pip install docopt

# install mpich
RUN mkdir /tests
WORKDIR /tests
ADD mpich-3.2.tar.gz /tests/
RUN yum install gcc gcc-c++ gcc-gfortran autoconf make automake -y
WORKDIR /tests/mpich-3.2
RUN ./configure
RUN make
RUN make install 

# instal mdtest
WORKDIR /tests
RUN yum install openmpi openmpi-devel git -y
RUN git clone https://github.com/MDTEST-LANL/mdtest.git mdtest-1.9.3
WORKDIR /tests/mdtest-1.9.3/old
RUN MPI_CC=mpicc make
RUN cp mdtest /usr/sbin

# install fsstress
WORKDIR /tests
#RUN yum install wget -y
ADD fsstress /usr/sbin/

# install ior
WORKDIR /tests
ADD ior /tests/ior
WORKDIR /tests/ior
RUN ./bootstrap
RUN ./configure
RUN make
RUN make install
RUN cp /tests/ior/src/ior /usr/sbin/

# install pjd-fstest
RUN yum install -y libacl-devel
WORKDIR /tests
ADD pjd-fstest /tests/pjd-fstest
WORKDIR /tests/pjd-fstest
RUN make clean
RUN make
RUN cp fstest /usr/sbin

# install bonnie++
RUN yum install -y bonnie++

# install smallfile
RUN git clone https://github.com/bengland2/smallfile.git /tests/smallfile

RUN mkdir /test-tools
ADD Dockerfile /test-tools
ADD entrypoint.sh /test-tools/

ADD test_args.py /tests/test_args.py
ADD test.conf /tests/test.conf 


RUN mkdir -p /entrypoint
ADD entrypoint.sh /entrypoint/entrypoint.sh
#ADD entrypoint.sh /usr/bin/entrypoint.sh
WORKDIR /
RUN chmod +x /entrypoint/entrypoint.sh
 
CMD ["/entrypoint/entrypoint.sh"]
