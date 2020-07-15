FROM ubuntu
#FROM centos

# install kubectl
#RUN KUBECTL_VERSION=1.14.9 && curl -vo kubectl http://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/

# install other dependencies
#RUN yum install -y epel-release && yum clean all
#RUN yum install -y jq && yum clean all
RUN apt update
RUN apt install -y curl
RUN apt install -y jq

# install kubectl
RUN KUBECTL_VERSION=1.14.9 && curl -vo kubectl http://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/

# copy collector to container
COPY namespace_reaper.sh ./
RUN chmod +x namespace_reaper.sh

CMD ./namespace_reaper.sh