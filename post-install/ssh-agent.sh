#!/usr/bin/env bash
set -e

mkdir -p ~/.config/systemd/user
mkdir -p ~/.config/environment.d

cat <<EOF > ~/.config/systemd/user/ssh-agent.service
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a \$SSH_AUTH_SOCK

[Install]
WantedBy=default.target
EOF

echo 'SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"' > ~/.config/environment.d/ssh_auth_socket.conf

systemctl --user enable --now ssh-agent
