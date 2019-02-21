FROM python:2

ADD ./iops /usr/src/iops/
WORKDIR /usr/src/iops/

ENTRYPOINT [ "./iops" ]
