https://github.com/vaggeliskls/windows-in-docker-container/

# Username: Administrator, vagrant

# Password: vagrant

I'll use a known-working box for now
wget https://app.vagrantup.com/peru/boxes/windows-server-2022-standard-x64-eval/versions/20231201.01/providers/libvirt.box -O peru-server2022.box

wget https://app.vagrantup.com/debian/boxes/jessie64/versions/8.9.0/providers/virtualbox.box -O debian-jessie64-8.9.0.box

download this to /home/chris/boxes

set docker .env VAGRANTBOX_DIR=/home/chris/boxes
compose mounts volume ${VAGRANTBOX_DIR}:/boxes

compose sets VAGRANT_BOX=peru-server2022.box
startup.sh checks if peru-server2022.box is a box file or a url

startup.sh sets VAGRANT_BOX_ADDR=/boxes/peru-server2022.box
