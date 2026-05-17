#!/bin/sh

set -x

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

rsync -a --progress --stats $MEDIA /mnt/f/backup/ || true
