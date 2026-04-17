#!/bin/sh

rsync -a --progress --stats /mnt/h/android /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/backup /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/datasets /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/filen /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/github /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/images /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/linux /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/media /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/porn /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/windows /mnt/f/backup/ || true

rsync -a --progress --stats /mnt/k/images /mnt/f/backup/ || true

# we skip media_library/Movies and TV because they're too damn big (~7TiB right now)
# rsync -a --progress --stats /mnt/q/media_library /mnt/f/backup/ || true

rsync -a --progress --stats /mnt/q/media_library/Books /mnt/f/backup/media_library || true
rsync -a --progress --stats /mnt/q/media_library/Custom /mnt/f/backup/media_library || true
rsync -a --progress --stats /mnt/q/media_library/Music /mnt/f/backup/media_library || true
