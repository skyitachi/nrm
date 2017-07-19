#!/usr/bin/env bash
NRMRC=$HOME/.nrmrc

function nrm_load() {
  registry=$1
  export NPM_CONFIG_REGISTRY=$registry
  echo "npm_config_registry set to ${registry}"
}


function nrm_check() {
  echo `npm config get registry`
}

function nrm_help() {
  echo "Npm Registry Manager"
  echo ""
  echo "Usage:"
  echo "  nrm help                      show help"
  echo "  nrm add <alias> <registry>    add alias for registry"
  echo "  nrm use <alias>               use alias registry"
  echo "  nrm ls                        list all registries"
  echo "  nrm current                   show current registry"
  echo "  nrm default <alias>           make alias default"
  echo "  nrm remove <alias>            remove alias"
  echo "  nrm version                   show version"
  echo ""
}
function nrm_write() {
  local alias=$1
  local registry=$2
  local i=1
  local linenumber=""
  local found=0
  if [ ! -f $NRMRC ];then
    echo "$alias=$registry" >> $NRMRC
    return 0
  fi
  for line in `cat $NRMRC`
  do
    local k=$(echo $line | cut -d"=" -f1)
    local v=$(echo $line | cut -d"=" -f2)
    if [ $k = $alias ]; then
      linenumber="${i}d;$linenumber"
      found=1
    fi
    ((i++))
  done
  if [ $found -gt 0 ];then
    sed -i.bak -e $linenumber $NRMRC
    rm $NRMRC.bak
  fi
  echo "$alias=$registry" >> $NRMRC
}

function nrm_rc_exists() {
  if [ ! -f $NRMRC ]; then
    touch $NRMRC
  fi
}

function nrm_remove() {
  local removed=$1
  local i=1
  local linenumber=""
  local found=0
  nrm_rc_exists
  for line in `cat $NRMRC`
    do
    local k=$(echo $line | cut -d"=" -f1)
    local v=$(echo $line | cut -d"=" -f2)
      if [ $k = $removed ]; then
        linenumber="${i}d;$linenumber"
        found=1
        break
      fi
      ((i++))
    done
  if [ $found -gt 0 ];then
    sed -i.bak -e $linenumber $NRMRC
    rm $NRMRC.bak
  fi
}

function nrm_list() {
  echo "Listing All Registries:"
  for line in `cat $NRMRC`
    do
      local k=$(echo $line | cut -d"=" -f1)
      local v=$(echo $line | cut -d"=" -f2)
      echo "  ${k} -- ${v}"
    done
}

function nrm_use() {
  local registry_alias=$1
  for line in `cat $NRMRC`
  do
    local k=$(echo $line | cut -d"=" -f1)
    local v=$(echo $line | cut -d"=" -f2)
    if [ $k = $registry_alias ]; then
      nrm_load $v
      return 0
    fi
  done
  echo "$registry_alias registry not found, please use 'nrm ls' check"
  return 1
}

function nrm_default() {
  local registry_default=$1
  if [ $registry_default = "default" ];then
    echo "unvalid arguments: please use other alias instead of default"
    return 1
  fi
  for line in `cat $NRMRC`
  do
    local k=$(echo $line | cut -d"=" -f1)
    local v=$(echo $line | cut -d"=" -f2)
    if [ $k = $registry_default ]; then
      nrm_write default $v
      return 0
    fi
  done
  echo "no $registry_default registry, please use 'nrm ls' check"
}

function nrm_autoload() {
  for line in `cat $NRMRC`
  do
    local k=$(echo $line | cut -d"=" -f1)
    local v=$(echo $line | cut -d"=" -f2)
    if [ $k = "default" ]; then
      export NPM_CONFIG_REGISTRY=$v
      return 0
    fi
  done
}

function nrm() {
  COMMAND=${1-}
  case $COMMAND in
  "add" )
    if [ "$#" -ne 3 ]; then
      echo "usage: nrm add <alias> <registry>"
      return 1
    fi
    nrm_write $2 $3
    ;;
  "use" )
    if [ "$#" -ne 2 ]; then
      echo "usage: nrm use alias"
      return 1
    fi
    nrm_use $2
    ;;
  "ls" )
    if [ "$#" -ne 1 ]; then
      echo "usage: nrm ls"
      return 1
    fi
    nrm_list
    ;;
  "default" )
    if [ "$#" -ne 2 ]; then
      echo "usage: nrm default alias"
      return 1
    fi
    nrm_default $2
    ;;
  "current" )
    if [ "$#" -ne 1 ]; then
      echo "usage: nrm ls"
      return 1
    fi
    nrm_check
    ;;
  "remove" )
    if [ "$#" -ne 2 ]; then
      echo "usage: nrm remove <alias>"
      return 1
    fi
    nrm_remove $2
    ;;
  "help" )
    nrm_help
    ;;
  "version" )
    echo "1.0.0"
    ;;
  esac
}

# autoload default registry
nrm_autoload
