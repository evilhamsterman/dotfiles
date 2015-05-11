#!/bin/sh

FILES=files.d/*
BACKUP=backup

for f in $FILES
do
  FILENAME=`basename $f`
  DOTFILE=".$FILENAME"
  DOTPATH="$HOME/$DOTFILE"

  # Check if file currently exists in $HOME and backup if it does
  if [[ -f $DOTPATH ]]; then
    if [[ ! -h $DOTPATH ]]; then
      echo "File $DOTFILE exists backing up"
      mv $DOTPATH $BACKUP/$FILENAME.`date +%Y%m%d%H%M`
    fi
  fi

  # Symlink the file into $HOME
  echo "Symlinking $f"
  ln -sf `pwd`/$f $DOTPATH
done
