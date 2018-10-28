#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
TARGET_FILE=change_eucalyn.json
TARGET_DIR=~/.config/karabiner/assets/complex_modifications


if [ ! -f ${SCRIPT_DIR}/${TARGET_FILE} ]; then
  echo "NO SUCH FILE";
  exit -1;
fi

if [ ! -d ${TARGET_DIR} ]; then
  mkdir -p ${TARGET_DIR};
fi

cp ${SCRIPT_DIR}/${TARGET_FILE} ${TARGET_DIR}

if [ $? != 0 ]; then
  echo "COPY ERROR";
  exit -1;
fi

echo "COPY FINISHED";
