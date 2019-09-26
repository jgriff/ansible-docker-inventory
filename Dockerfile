FROM ubuntu:18.04

RUN apt-get update && apt-get install -y openssh-server vim dumb-init
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# support systemctl commands without systemd (see https://github.com/gdraheim/docker-systemctl-replacement)
COPY systemctl3.py /usr/bin/systemctl
RUN chmod 755 /usr/bin/systemctl
RUN test -L /bin/systemctl || ln -sf /usr/bin/systemctl /bin/systemctl

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 8080
EXPOSE 22
CMD ["dumb-init", "/usr/sbin/sshd", "-D"]
