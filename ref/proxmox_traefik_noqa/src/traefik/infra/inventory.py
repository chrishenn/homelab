from data import server_ip, ssh_keyfile, ssh_port, ssh_user
from infra.ssh import ssh_keypass


serverinfo = {
    "ssh_hostname": server_ip(),
    "ssh_port": ssh_port(),
    "ssh_user": ssh_user(),
    "ssh_key": str(ssh_keyfile()),
    "ssh_key_password": ssh_keypass(),
}

server = ["server"], serverinfo
