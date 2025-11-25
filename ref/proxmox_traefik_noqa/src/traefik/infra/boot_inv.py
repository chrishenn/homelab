from data import server_ip, ssh_port, ssh_user
from infra.ssh import ssh_userpass


info = {"ssh_hostname": server_ip(), "ssh_port": ssh_port(), "ssh_user": ssh_user(), "ssh_password": ssh_userpass()}
server = (["server"], info)
