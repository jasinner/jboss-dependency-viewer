#!/bin/bash

#loading configuration file for frontend path
source visualcatalogue.cfg

toolpath=$(pwd)
rootpath=$(cd ..; pwd)
systemdata=$rootpath/systemdata
analysispath=$systemdata/analysis
indexfile=$frontendpath/index.html
graphfile=$frontendpath/graph.html
jsonpath=$frontendpath/JSON

 
if [ -z "$1" ] || [ $1 == '-h' ] ; then
echo "usage: 

to add product:
$0 product_name download_address

to delete:
$0 product_name 
(also '*' acceptable for all)
if the product exists, it will be overwritten";
  exit;
fi

#add product - two arguments
if [ "$#" == 2 ]; then

if [[ $2 == *".zip" ]]; then
  #download and unzip
  mkdir -p $systemdata/downloads/ 2> /dev/null;
  echo "Downloading $2 with wget";
  wget -O $systemdata/downloads/$1.zip $2;
  mkdir -p $systemdata/unzips/$1 2> /dev/null;
  unzip -d $systemdata/unzips/$1/ $systemdata/downloads/$1.zip 1> /dev/null;
  productpath=$systemdata/unzips/$1;
  echo $productpath;
else 
  #if it is not a zip file, should be a folder with the product already unzipped
  productpath=$2;
fi

#record the download path to file linked from the first page
echo " $1   - >   $2" >> $frontendpath/history.txt;

#collecting module.xml files
rm -r $analysispath/$1 2> /dev/null;
mkdir -p $analysispath/$1 2> /dev/null;
substitute=$(find $productpath -name module.xml | grep org | awk -F 'org' '{print $1}' | head -1)
echo "Modules are in the folder: $substitute";
for i in $(find $productpath -name module.xml);  do
   cp $i $analysispath/$1/$(echo $i | sed "s#^$substitute##g" | sed "s/\//./g");
done

#collecting information about extensions in all configurations
for i in $(find $productpath | grep configuration | grep xml); do (grep extension $i); done | sort -u > $analysispath/$1/extensions;

#removing existing JSON files for this short name
rm -r $jsonpath/$1 2> /dev/null;

#generating JSON files
#xml names sometimes include slot number after module name. Slots are called "eap" or numbers. Passing module names with slots.
#number of all modules
all=$(ls $analysispath/$1 | grep -v extensions | grep -v temp* | grep -v dependencies% | sed "s/\.main\.module.xml$//g" | sed "s/\.eap\.module.xml$//g" | sed 's/\.module.xml$//g' | sort -u | wc -l);
j=1;
#for each of the modules
for i in $(ls $analysispath/$1 | grep -v extensions | grep -v temp* | grep -v dependencies% | sed "s/\.main\.module.xml$//g" | sed "s/\.eap\.module.xml$//g" | sed 's/\.module.xml$//g' |  sort -u); do
  echo "$j/$all";
  #calling next script for module
  ./add_module.sh -m $i $1 -b; # 1> /dev/null;
  j=$(($j+1))
done

#if delete - one argument
elif [ "$#" -eq 1 ]; then
 rm -r -v $jsonpath/$1;
 rm -r $analysispath/$1 2> /dev/null;
 #clean up history.txt
 cat $frontendpath/history.txt | grep -v " $1   - >   " > $systemdata/tmp;
 cat $systemdata/tmp > $frontendpath/history.txt;
 rm $systemdata/tmp;
 exit;
else
 echo "Incorrect arguments"
 exit;
fi

#update html

distro_list=$(for i in `ls $jsonpath`; do echo "<option value=\"$i\">$i</option>"; done)

#write the first template to first page
cat $toolpath/indextemplate1.txt | sed "s#%productoptions%#$(echo $distro_list)#" > $indexfile

#for each product
for j in `ls $jsonpath`; do

#create datalist of libraries
echo "<div id=\"module_${j}_div\" class=\"hidden\">
    Module of $j:<br>
    <input list=\"module_${j}_list\" name=\"mod_${j}\">
    <datalist  id=\"module_${j}_list\">" > temp_list;
for i in `ls $jsonpath/$j/modules | sed "s/\.json$//g"`; do
 echo "<option value=\"$i\">" >> temp_list; 
done
echo "</datalist> </div>" >> temp_list;

#create datalist of modules
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

rm temp_list 2> /dev/null

#write the second template to first page
cat $toolpath/indextemplate2.txt >> $indexfile

#second(graph) page is ready and is just overwritten
cat $toolpath/graph.html > $graphfile


rm -r $systemdata/downloads/$1.zip 2> /dev/null;
rm -r $systemdata/unzips/$1 2> /dev/null;
