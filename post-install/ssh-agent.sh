#!/usr/bin/env bash
set -e

mkdir -p $HOME/.config/systemd/user
cat <<EOF > $HOME/.config/systemd/user/ssh-agent.service
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a \$SSH_AUTH_SOCK

[Install]
WantedBy=default.target
EOF

mkdir -p $HOME/.config/environment.d
echo 'SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"' > $HOME/.config/environment.d/ssh_auth_socket.conf

SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
systemctl --user enable --now ssh-agent
