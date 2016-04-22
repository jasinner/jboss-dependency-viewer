#!/bin/bash

source visualcatalogue.cfg

rootpath=$(cd ..; pwd)
#rootpath=$(pwd)

#rootpath=~/Documents/a_working/deliverables;

#collect information from module.xml files
systemdata=$rootpath/systemdata
analysispath=$systemdata/analysis
toolpath=$(pwd)
indexfile=$frontendpath/index.html
graphfile=$frontendpath/graph.html
jsonpath=$frontendpath/JSON

 
if [ -z "$1" ] || [ $1 == '-h' ] ; then
  echo "usage: $0 distro_name distro_path -p/-g/-a
-p - prepare system data only (to upload to server minimal info)
-g - generate JSON files
-a = -p + -g
if the product exists, it will be ";
  exit;
fi

if [ $3 == '-p' ] || [ $3 == '-a' ]; then
#collecting module.xml files
rm -r $analysispath/$1 2> /dev/null;
mkdir -p $analysispath/$1 2> /dev/null;
substitute=$(find $2 -name module.xml | grep org | awk -F 'org' '{print $1}' | head -1)
echo "Modules are in the folder: $substitute";
for i in $(find $2 -name module.xml);  do
   cp $i $analysispath/$1/$(echo $i | sed "s#^$substitute##g" | sed "s/\//./g");
done

#collecting all extensions
for i in $(find $2 | grep configuration | grep xml); do (grep extension $i); done | sort -u > $analysispath/$1/extensions;
fi

if [ $3 == '-g' ] || [ $3 == '-a' ]; then
rm -r $jsonpath/$1 2> /dev/null;
#generating JSON files
all=$(ls $analysispath/$1 | grep -v extensions | grep -v temp* | grep -v dependencies% | sed "s/\.main\.module.xml$//g" | sed "s/\.eap\.module.xml$//g" | sed 's/\.module.xml$//g' | sort -u | wc -l);
j=1;
#xml names sometimes include slot number after module name. Passing module names with slots.
for i in $(ls $analysispath/$1 | grep -v extensions | grep -v temp* | grep -v dependencies% | sed "s/\.main\.module.xml$//g" | sed "s/\.eap\.module.xml$//g" | sed 's/\.module.xml$//g' |  sort -u); do
  echo "$j/$all";
  ./add_module.sh -m $i $1 -b; # 1> /dev/null;
  j=$(($j+1))
done


distro_list=$(for i in `ls $jsonpath`; do echo "<option value=\"$i\">$i</option>"; done)

cat $toolpath/indextemplate1.txt | sed "s#%productoptions%#$(echo $distro_list)#" > $indexfile

for j in `ls $jsonpath`; do

echo "<div id=\"module_${j}_div\" class=\"hidden\">
    Module of $j:<br>
    <input list=\"module_${j}_list\" name=\"mod_${j}\">
    <datalist  id=\"module_${j}_list\">" > temp_list;
for i in `ls $jsonpath/$j/modules | sed "s/\.json$//g"`; do
 echo "<option value=\"$i\">" >> temp_list; 
done
echo "</datalist> </div>" >> temp_list;

echo "<div id=\"library_${j}_div\" class=\"hidden\">
    Library of $j:<br>
    <input list=\"library_${j}_list\" name=\"lib_${j}\">
    <datalist id=\"library_${j}_list\">" >> temp_list;
for i in `ls $jsonpath/$j/libraries | sed "s/\.json$//g"`; do
 echo "<option value=\"$i\">" >> temp_list; 
done
echo "</datalist> </div>" >> temp_list;

cat temp_list >> $indexfile;
done

cat $toolpath/indextemplate2.txt >> $indexfile

cat $toolpath/graph.html > $graphfile

rm temp_list 2> /dev/null

fi




