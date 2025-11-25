#!/bin/bash
# service_install.sh

# global paths and names for the bluebubbles install.
# NOTE: Manually sync across files!
bb_imgs="/mnt/k/osx_files"
bb_scripts="/bb_scripts"
bb_container_name="bluebubbles"

#### somewhere on the system to stash these service start/stop scripts
mkdir -p "$bb_scripts"

####
START_SCRIPT_SRC=./bluebubbles_start.sh
START_SCRIPT_DST="$bb_scripts/bluebubbles_start.sh"

cp "$START_SCRIPT_SRC" "$START_SCRIPT_DST"

####
STOP_SCRIPT_SRC=./bluebubbles_stop.sh
STOP_SCRIPT_DST="$bb_scripts/bluebubbles_stop.sh"

cp "$STOP_SCRIPT_SRC" "$STOP_SCRIPT_DST"

#### generate the service file on the fly to reference the start and end script locations
UNIT_SRC=./bluebubbles.service
UNIT_DST=/etc/systemd/system/bluebubbles.service

touch ./bluebubbles.service

tee "$UNIT_SRC" >/dev/null <<-END
	[Unit]
	Description=BlueBubbles iMessage relay server
	Requires=docker.service
	After=docker.service libvirtd.service

	[Service]
	Restart=on-failure
	ExecStart=/bin/bash ${START_SCRIPT_DST}
	ExecStop=/bin/bash ${STOP_SCRIPT_DST}

	[Install]
	WantedBy=multi-user.target
END

sudo cp "$UNIT_SRC" "$UNIT_DST"
sudo chmod 664 "$UNIT_DST"

#### not sure if this is necessary on initial service creation, but can't hurt
sudo systemctl daemon-reload
