from blocky.data import server_ip, ssh_user
from blocky.infra.ssh import ssh_userpass


server = ["server"], {"ssh_hostname": server_ip(), "ssh_user": ssh_user(), "ssh_password": ssh_userpass()}
