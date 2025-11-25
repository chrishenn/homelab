from pyinfra.operations import server

from blocky.data import ssh_user
from blocky.infra.ssh import ssh_keyfile_pub_content


server.user(name="add ssh key to remote", user=ssh_user(), public_keys=[ssh_keyfile_pub_content()])
