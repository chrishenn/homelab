# toolbox

The project is called toolbx, but the command is 'toolbox' on aurora
- https://containertoolbx.org/
- https://github.com/containers/toolbox/tree/main/doc

```bash
toolbox create --distro ubuntu --release 24.04 -y
toolbox enter ubuntu-toolbox-24.04
sudo apt update && sudo apt install -y apache2-utils
exit
toolbox run --container ubuntu-toolbox-24.04 htpasswd -bBn <user> <pass>
```