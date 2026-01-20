# Rclone backup for google drive

```bash
rclone sync -P --fast-list --transfers=32 \
--drive-scope 'drive' \
--drive-export-formats txt,docx,ods,odt,odp \
--drive-client-id $GDRIVE_CLIENT_ID \
--drive-client-secret $GDRIVE_CLIENT_SECRET \
--drive-token $GDRIVE_ACCESS_TOKEN \
:drive:/ \
/mnt/h/gdrive \
&& chown -R 1000:1000 /mnt/h/gdrive
```
