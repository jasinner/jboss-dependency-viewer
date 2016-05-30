#!/bin/bash

set -e

if [ -z "$1" ] || [ $1 == '-h' ] ; then
  echo "This script is to be called by other script.";
  exit;
fi


#go to distro data path
cd $3;
depfile=dependencies%$1%$2;

#separate slot name on the end, if any
name=$(echo $1 | sed 's/\..$//g' | sed 's/\..$//g');
#slot 
slot=$(echo $1 | sed "s/${name}.//g")
grepstring="<module name=\"$name\"";
if [ "$name" != "$slot" ]; then
  grepstring="$grepstring slot=\"$slot\""
fi
#echo $grepstring

sort -u temp_allmodules > temp_allmodules1; cat temp_allmodules1 > temp_allmodules; rm temp_allmodules1 
  allmodules=$(cat temp_allmodules);

#finding 1st order dependencies for the module of current iteration
for i in $(grep -B1000 "$grepstring" *.xml | grep xmlns | sed "s/ //g"); do
#extract new module and slot
newmodule=$(echo $i | cut -d "=" -f 3 | cut -d \" -f 2)
newslot=$(echo $i | cut -d "=" -f 4 | cut -d \" -f 2)
newfull="${newmodule}"
if [ "$newslot" != "" ]; then
  newfull="${newmodule}.${newslot}"
fi

#breaking out of circular dependencies  
  breakfl=0;
  for j in $allmodules; do
    if [ $newfull == $j ]; then 
      breakfl=1; 
    fi 
  done;
  if [ $breakfl == 1 ]; then 
    break 
  fi

  echo $newfull >> temp_allmodules;
  echo ${newfull}$(if grep -q "<extension module=\"$newfull\"" extensions; then echo E; fi) >> $depfile;
 # echo -n "$2 $i    ";
 # echo $(grep "<extension module=\"$i\"" extensions);
done

#finding n+1-th order dependencies for each of these dependencies
if [ -s $depfile ]; then
  for i in $(cat $depfile); do
  #go to tool path
  cd $4;
  ./add_dependency.sh $i $(($2+1)) $3 $4;
  done
fi

