FROM ubuntu:20.04
RUN apt update -y && apt dist-upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata && \
    apt install -y apt-utils && \
    apt install -y libgtk-3-dev libappindicator3-dev \
        libx11-dev build-essential openssh-server rsync && \
    ssh-keygen -A && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

COPY ./authorized_keys /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

ADD ./sshd_config /etc/ssh/sshd_config
RUN mkdir -p /run/sshd
CMD ["/usr/sbin/sshd", "-D"]

