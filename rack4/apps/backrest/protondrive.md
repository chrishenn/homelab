# rclone backup for proton drive

NOTE: Well crap. Proton Drive as an rclone backend is not really supported. Proton Drive using a proprietary api
has also broken a bunch of other clients that wanted to integrate with it. I'm getting like a 50/50 hit rate with basic
rclone ls commands, when auth goes through - also about 50/50.

They have clients for windows and mac, ios and android, but nothing for linux. wah-wah get wrecked

https://github.com/rclone/rclone/issues/8873

---

Connect to protondrive with rclone
(note that ubuntu rclone was too old to have a protondrive adapter atm - needs ~1.64+)

```bash
rclone config
<tui commands>

# use a 2fa code that is valid, but probably will not be by the time you're done configuring
rclone lsd --protondrive-2fa=<2fa> protondrive:

# login keys should be saved into the rclone config file
cat ~/.config/rclone/rclone.conf

# The password must be obscured as below
rclone obscure "password"
rclone obscure "$(op read op://homelab/proton/password)"

# sync pdrive cloud to local disk
# min-size=1b skips proton docs, as rclone protondrive adapter workaround: https://github.com/rclone/rclone/issues/7959
rclone sync \
--min-size 1b \
--protondrive-username "${PDRIVE_USER}" \
--protondrive-password "${PDRIVE_PASS_OBSC}" \
--protondrive-otp-secret-key "${PDRIVE_OTP_OBSC}" \
':protondrive:/' \
'/mnt/h/pdrive' \
&& chown -R 1000:1000 '/mnt/h/pdrive'
```
