# docker rmi iris_edit
# docker build -t iris_edit .
# Warning:
#    Only run this container under rootless docker.
#    Contains non-sandboxed applications being executed
#    Also run without internet access
# docker run -d -it --rm --name iris_edit --memory=8g --network no-internet --gpus "device=0" -p 3390 iris_edit /bin/bash -c "while true; do sleep 10; done"
# docker exec -it -u root iris_edit /bin/bash -c "echo \"ubuntu:ubuntu\" | chpasswd"

# InterSystems ObjectScript 3.8.2 Vsix File Download
# https://www.vsixhub.com/vsix/2297/
# VSCODE Extension InterSystems Language Server
# https://open-vsx.org/extension/intersystems/language-server

# Base image: Ubuntu with XFCE desktop and RDP Server
FROM scottyhardy/docker-remote-desktop
# Override user default shell to facilitate alias on "code" command (automatic no sandbox in docker)
RUN useradd -m -U ubuntu -s /bin/bash

# FOR RDP port
EXPOSE 3390

RUN apt update && apt install -y curl iproute2 && apt-get clean

# Install VSCode Editor
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
RUN install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https
RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y code

# Install Intersystems language pack
# Follow RDP docker base by using default ubuntu user
USER ubuntu
RUN ls -la /home/ubuntu
RUN mkdir -p /home/ubuntu/vscode_ext
RUN mkdir -p /home/ubuntu/.config/Code/User
RUN mkdir -p /home/ubuntu/src
COPY --chown=ubuntu:ubuntu vscode-objectscript-3.8.6-beta.3.vsix /home/ubuntu/vscode_ext/vscode-objectscript-3.8.6-beta.3.vsix
COPY --chown=ubuntu:ubuntu intersystems.language-server-2.8.5.vsix /home/ubuntu/vscode_ext/intersystems.language-server-2.8.5.vsix
RUN code --no-sandbox --install-extension /home/ubuntu/vscode_ext/vscode-objectscript-3.8.6-beta.3.vsix --user-data-dir /home/ubuntu/
RUN code --no-sandbox --install-extension /home/ubuntu/vscode_ext/intersystems.language-server-2.8.5.vsix --user-data-dir /home/ubuntu/
# Add default example connection configuration for InterSystems plugins
COPY --chown=ubuntu:ubuntu settings.json /home/ubuntu/.config/Code/User/settings.json

# Install Desktop launch icon to launch vscode with InterSystems plugins
RUN mkdir -p /home/ubuntu/.config/isc/
COPY --chown=ubuntu:ubuntu favicon.ico /home/ubuntu/.config/isc/favicon.ico
COPY --chown=ubuntu:ubuntu intersystems-iris_editor.desktop /home/ubuntu/Desktop/intersystems-iris_editor.desktop
RUN chmod 770 /home/ubuntu/Desktop/intersystems-iris_editor.desktop

# Install alias to launch vscode from shell with verbose output
COPY --chown=ubuntu:ubuntu bash_aliases /home/ubuntu/.bash_aliases

# ALWAYS End in root context for the base RDP image functionality
USER root
