# Hostinger Server Setup (Pangolin)

sshd config

```bash
sudo apt install -y sd

function sshd_cfg_clean {
    # file to operate on
    declare file=${1:-'/etc/ssh/sshd_config'}
    shift

    # remove comments
    sudo sd -f gm '^#(.*)\n*' '' "$file"
    # remove lines containing just a newline
    sudo sd -f gm '^\n' '' "$file"
}

function replace_or_append_line {
    # match on this string
    declare match=${1}
    shift
    # replace with this string
    declare replace=${1}
    shift
    # file to operate on
    declare file=${1:-'/etc/ssh/sshd_config'}
    shift

    if ! grep -q "$match" "$file"; then
        echo "$replace" | sudo tee -a "$file"
    else
        sudo sd -f gm -n 1 "^(.*)$match(.*)$" "$replace" "$file"
    fi
}
```

server setup

```bash
# add the hostinger ssh public key into server /home/chris/.ssh/authorized_keys
echo "$(op read 'op://homelab/nlptoaczq3qtw2fqs6nb2d6r5y/public key')" | \
    $SSH_ROOT "mkdir -p /home/chris/.ssh && cat >> /home/chris/.ssh/authorized_keys"

# adduser chris (untested)
$SSH_ROOT "adduser --quiet --disabled-password --comment '' --ingroup sudo chris"
$SSH_ROOT "sudo usermod -aG docker chris"
echo "chris:$(op read 'op://homelab/vps0/chris_pass')" | \
    $SSH_ROOT "chpasswd"

# login as root
$SSH_ROOT

# update
sudo apt update && sudo apt upgrade -y

# ufw
sudo ufw allow 22/tcp
sudo ufw allow 2200/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 51820/udp
sudo ufw allow 21820/udp
sudo ufw allow 10000/udp
sudo ufw enable -y
# sudo ufw status verbose

# sshd config
sshd_cfg_clean
replace_or_append_line 'Port' 'Port 2200'
replace_or_append_line 'PermitRootLogin' 'PermitRootLogin no'
replace_or_append_line 'PasswordAuthentication' 'PasswordAuthentication no'
sudo systemctl daemon-reload
sudo systemctl restart ssh
exit

# In the web console, allow port 2200 for protocol ssh
# accept TCP custom (my ip from `curl ip.me`)

# login as chris
$SSH_CHRIS

# fail2ban
sudo apt install -y fail2ban
# sudo systemctl status fail2ban

# disable ipv6
sudo tee -a /etc/sysctl.d/99-sysctl.conf >/dev/null <<-'END'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
END
sudo sysctl -p /etc/sysctl.d/99-sysctl.conf
# cat /proc/sys/net/ipv6/conf/all/disable_ipv6

# enable ipv6
sudo tee /etc/sysctl.d/99-sysctl.conf >/dev/null <<-'END'
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
END
sudo sysctl -p /etc/sysctl.d/99-sysctl.conf
```

sync dotfiles

```bash
# mise
sudo apt update -y && sudo apt install -y curl
sudo install -dm 755 /etc/apt/keyrings
curl -fSs https://mise.jdx.dev/gpg-key.pub | sudo tee /etc/apt/keyrings/mise-archive-keyring.asc 1> /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
sudo apt update -y && sudo apt install -y mise

# mise should be on path already when installed via apt
eval "$(mise activate bash)"

# opcli
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
sudo tee /etc/apt/sources.list.d/1password.list && \
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg && \
sudo apt update && sudo apt install 1password-cli

# chezmoi (promptDefaults defaults to machine type 'server')
sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

$(op read op://homelab/svc/bash) \
    ; chezmoi init chrishenn -a --force --promptDefaults \
    ; chezmoi update -a --force

mise i
sudo rm /usr/local/bin/chezmoi
```
