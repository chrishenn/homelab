from data import LocalPath
from inventory import ssh_keyfile, ssh_keypass
from pyinfra import host, local, logger
from pyinfra.facts.files import File


# pyinfra @local keyfile.py -y

if not host.get_fact(File, LocalPath.keyf.posix):
    logger.info("\ngenerating ssh key file on localhost\n")
    local.shell(f"ssh-keygen -t rsa -b 4096 -f {ssh_keyfile()} -P '{ssh_keypass()}'")
else:
    logger.info("\nssh key file already exists\n")
