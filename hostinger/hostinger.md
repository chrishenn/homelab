# hostinger

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
echo "chris:$(op read 'op://homelab/nlptoaczq3qtw2fqs6nb2d6r5y/chris_pass')" | \
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

pangolin

```bash
# in the hostinger web console, open firewall ports:
# 80 (TCP), 443 (TCP), 51820 (UDP), and 21820 (UDP for clients)

# in the cloudflare web console, add a DNS A record to point to pangolin VPS

# pangolin installer
mkdir -p ~/pangolin && cd pangolin
curl -fsSL https://static.pangolin.net/get-installer.sh | bash
sudo ./installer
```