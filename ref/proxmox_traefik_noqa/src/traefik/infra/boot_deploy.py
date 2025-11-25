from data import ssh_user
from infra.ssh import ssh_keyfile_pub_content
from pyinfra.operations import server


server.user(name="add ssh key to remote", user=ssh_user(), public_keys=[ssh_keyfile_pub_content()])
