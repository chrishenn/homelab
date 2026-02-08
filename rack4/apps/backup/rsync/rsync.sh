#!/bin/sh

rsync -a --progress --stats /mnt/q/media_library /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/k/images /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/images /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/datasets /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/windows /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/linux /mnt/f/backup/ || true
rsync -a --progress --stats /mnt/h/porn /mnt/f/backup/ || true
