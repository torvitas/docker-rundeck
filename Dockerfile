FROM centos:centos7

RUN rpm -Uvh http://repo.rundeck.org/latest.rpm && \
    yum -y update && \
    yum -y install \
	    java-1.8.0-openjdk \
		rundeck \
		openssh-clients && \
    yum -y clean all

COPY src/* /usr/local/src/rundeck/
COPY etc/* /etc/rundeck/

EXPOSE 4440
VOLUME ["/etc/rundeck", "/var/rundeck/projects", "/var/lib/rundeck/libext"]
CMD ["rundeckd"]
ENTRYPOINT ["/usr/local/src/rundeck/bin/docker.entrypoint.sh"]
