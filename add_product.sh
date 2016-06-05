#!/bin/bash

if [ -z "$1" ] || [ $1 == '-h' ]; then
echo "usage:

to add product:
$0 -p frontend_path product_name download_address OR
export FRONTEND_PATH=your/html/path AND
$0 product_name download_address
Choose arbitrary product name (don't use blanks and avoid underscores)

to delete:
$0 -p frontend_path product_name OR
export FRONTEND_PATH=your/html/path AND
$0 product_name  
if the product exists, it will be overwritten";
  exit;
fi

if  [ "$1" == "-p" ]; then
  export FRONTEND_PATH=$2
fi
if [ -z "$3" ]; then
    prod1=$1
else
    prod1=$3;
fi
if [ -z "$4" ]; then
    path2=$2;
else
    path2=$4;
fi
toolpath=$(pwd)
rootpath=$(cd ..; pwd)
systemdata=$rootpath/systemdata
analysispath=$systemdata/analysis
indexfile=$FRONTEND_PATH/index.html
jsonpath=$FRONTEND_PATH/JSON

#
#**ADD PRODUCT**
#
if [ "$#" == 4 ] || [ "$#" == 2 ]; then

if [[ $path2 == *".zip" ]]; then
  #download and unzip
  mkdir -p $systemdata/downloads/ 2> /dev/null;
  echo "Downloading $path2 with wget";
  wget -O $systemdata/downloads/$prod1.zip $path2;
  mkdir -p $systemdata/unzips/$prod1 2> /dev/null;
  unzip -d $systemdata/unzips/$prod1/ $systemdata/downloads/$prod1.zip 1> /dev/null;
  productpath=$systemdata/unzips/$prod1;
  echo $productpath;
else 
  #if it is not a zip file, should be a folder with the product already unzipped
  productpath=$path2;
fi

#record the download path to file linked from the first page
echo " $prod1   - >   $path2" >> $FRONTEND_PATH/history.txt;

#collecting module.xml files
rm -r $analysispath/$prod1 2> /dev/null;
mkdir -p $analysispath/$prod1 2> /dev/null;
substitute=$(find $productpath -name module.xml | grep org | awk -F 'org' '{print $1}' | head -1)
echo "Modules are in the folder: $substitute";
for i in $(find $productpath -name module.xml);  do
   cp $i $analysispath/$prod1/$(echo $i | sed "s#^$substitute##g" | sed "s/\//./g");
done

#collecting information about extensions in all configurations
for i in $(find $productpath | grep configuration | grep xml); do (grep extension $i); done | sort -u > $analysispath/$prod1/extensions;

#removing existing JSON files for this short name
rm -r $jsonpath/$prod1 2> /dev/null;

#generating start of HTML binding each module to its libraries
#passing product short name and module name
echo "<!DOCTYPE html>
<html>
<head>
<title>JBoss Dependency Viewer </title>
<style type=\"text/css\">
.hidden{
    display: none;
}
</style>
<script src=\"shared.js\"></script>
</head>
<body>" > $FRONTEND_PATH/liblist.html

#generating JSON files
#xml names sometimes include slot number after module name. Slots are called "eap" or numbers. Passing module names with slots.
#number of all modules
all=$(ls $analysispath/$prod1 | grep -v extensions | grep -v temp* | grep -v dependencies% | sed "s/\.main\.module.xml$//g" | sed "s/\.eap\.module.xml$//g" | sed 's/\.module.xml$//g' | sort -u | wc -l);
j=1;
#for each of the modules
for i in $(ls $analysispath/$prod1 | grep -v extensions | grep -v temp* | grep -v dependencies% | sed "s/\.main\.module.xml$//g" | sed "s/\.eap\.module.xml$//g" | sed 's/\.module.xml$//g' |  sort -u); do
  echo "$j/$all";
  #calling next script for module
  ./add_module.sh -m $i $prod1 -b; # 1> /dev/null;
  j=$(($j+1))
done

#
#**DELETE PRODUCT**
#
elif [ "$#" == 3 ] || [ "$#" == 1 ]; then 
 if [ ! -d "$analysispath/$prod1" ] && [ "$prod1" != '*' ]; then
   echo "Product $prod1 does not exist";
   exit;
 fi
 rm -r -v $jsonpath/$prod1;
 rm -r $analysispath/$prod1 2> /dev/null;
 #clean up history.txt
 cat $FRONTEND_PATH/history.txt | grep -v " $prod1   - >   " > $systemdata/tmp;
 cat $systemdata/tmp > $FRONTEND_PATH/history.txt;
 rm $systemdata/tmp;
# exit;
else
 echo "Incorrect arguments"
 exit;
fi

#
#**COMMON PART**
#

#update html
mkdir -p $jsonpath 2> /dev/null;
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

#copy to correspondent page list of corresponding libraries for module
cat $analysispath/$j/libmod.tmp >> $FRONTEND_PATH/liblist.html
done

#generating end of HTML binding each module to its libraries
echo "<script>
var product=parseSecond('product');
var module=parseSecond('module');
document.getElementById(product + \"_\" + module).className = '';
</script>
</body>" >> $FRONTEND_PATH/liblist.html

rm temp_list 2> /dev/null

#write the second template to first page
cat $toolpath/indextemplate2.txt >> $indexfile

#presentation files that are ready and just overwritten
cat $toolpath/graph.html > $FRONTEND_PATH/graph.html
cat $toolpath/shared.js > $FRONTEND_PATH/shared.js

rm -r $systemdata/downloads/$prod1.zip 2> /dev/null;
rm -r $systemdata/unzips/$prod1 2> /dev/null;
