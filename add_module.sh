#!/bin/bash

rootpath=/tmp
toolpath=$(pwd)
#where sigma.js distro is unpacked
#sigmapath=$FRONTEND_PATH/framework/sigma
#path to JSON files
jsonpath=$FRONTEND_PATH/JSON
#where the system keeps temporary data
systemdata=$rootpath/systemdata

#removing temporary files from previous modules
rm $systemdata/nodes 2> /dev/null
rm $systemdata/edges 2> /dev/null

if [ $1 == '-l' ] 2> /dev/null; then
  library=$2;
  #find module name for the library
  module=$(grep -B1000 $library $systemdata/analysis/$3/*.xml | grep xmlns | tail -n 1 | cut -d \" -f 4);
elif [ $1 == '-m' ] 2> /dev/null; then
  distdatapath=$systemdata/analysis/$3;
  module=$2;
  rm $distdatapath/dependencies* 2> /dev/null
  rm $distdatapath/temp_allmodules 2> /dev/null
else
    echo "Generates JSON files of dependencies for modules/libraries
usage: $0 -l/-m libname distro_name [-b]
-l for library + distro name
-m for module + distro name
-b for batch (no html generating) (called by admin tools)

Typical libraries for testing:
not many dependencies:
h2-1.3.173.redhat-2.jar
average lib of interest:
commons-collections-3.2.2.redhat-1.jar
server:
wildfly-server-2.0.3.Final-redhat-1.jar
";
    echo "Implemented distros:
$(ls $systemdata/analysis)";
    exit;
fi

echo "Module: $module";

echo $module > $distdatapath/temp_allmodules;

  echo "    {
      \"id\": \"$module\",
      \"label\": \"$module\",
      \"order\": 0,
      \"x\": 150,
      \"y\": 0,
      \"size\": 2,
      \"property\": \"root\",
      \"weight\": 100
    }," >> $systemdata/nodes;

#finding all nodes
sh add_dependency.sh $module 1 $distdatapath $toolpath;
cd $distdatapath

for order in $(ls dependencies* 2> /dev/null | cut -d % -f 3 | sort -u); do
  sameraw=$(cat dependencies*${order} | wc -l);
  count=1;
  for i in $(ls dependencies*${order}); do
    for j in $(cat $i); do
      extension=false;
      if echo $j | grep -q E$; then extension=true; fi
      j=$(echo $j | sed "s/E$//");
      echo "    {
      \"id\": \"$j\",
      \"label\": \"$j\",
      \"order\": $order,
      \"x\": $(($(echo 300 / $sameraw)*$count)),
      \"y\": $(($order*10 + $count*3))," >> $systemdata/nodes;
      if [ $extension == "true" ]; then
      echo "      \"property\": \"extension\"," >> $systemdata/nodes;
      else
      echo "      \"property\": \"ordinary\"," >> $systemdata/nodes;
      fi;
      echo "      \"size\": 2,
      \"weight\": 100
    }," >> $systemdata/nodes;
   echo "    {
      \"id\": \"$(echo $i | cut -d % -f 2) $j\",
      \"source\": \"$j\",
      \"target\": \"$(echo $i | cut -d % -f 2)\",
      \"type\": \"arrow\",
      \"size\": 3
    }," >> $systemdata/edges;
     count=$(($count+1));
    done
  done
done

if [ $4 == '-b' ] 2> /dev/null; then
mkdir -p $jsonpath/$3 2> /dev/null;
mkdir -p $jsonpath/$3/modules/ 2> /dev/null;
mkdir -p $jsonpath/$3/libraries/ 2> /dev/null;
#all these JSON files, for module and library, will have the same graph
graphdatafiles=""
graphdatafiles="$jsonpath/$3/modules/$module.json";
#for html with library lists
touch $distdatapath/libmod.tmp;
echo "<div id=\"$3_$module\" class=\"hidden\">" >> $distdatapath/libmod.tmp;
echo "Libraries in module <b>$module</b> in \"$3\": <br>" >> $distdatapath/libmod.tmp;
 for i in main eap 1.0 1.1 1.2 1.3 2.0 2.1 2.2 2.3 2.4 3.0 3.1 3.2 3.3 3.4 4.0 4.1 4.2 4.3 4.4 5.0 5.1 5.2 5.3 1 2 3 4 5; do
   for j in `grep jar ${module}.$i.module.xml 2> /dev/null | cut -d \" -f 2 | grep '\.jar$'`; do
     graphdatafiles="$graphdatafiles $jsonpath/$3/libraries/$j.json";
#for html with library lists
     echo "$j <br>" >> $distdatapath/libmod.tmp;
   done;
 done
#for html with library lists
echo "</div>" >> $distdatapath/libmod.tmp;

#else - accommodation for not -b
#main html page and graph data JSON file names
#graphdatafile=$FRONTEND_PATH/data.json
#pagefile=$FRONTEND_PATH/page.html
#cat $toolpath/indextemplate.txt | sed "s#%sigmapath%#$sigmapath#" > $pagefile
fi

#echo $graphdatafiles

for i in $graphdatafiles; do
  echo "{
  \"nodes\": [" > $i;
  cat $systemdata/nodes | sed '$s/,$//' >> $i;
  echo " ],
  \"edges\": [" >> $i;
  cat $systemdata/edges 2> /dev/null | sed '$s/,$//' >> $i;
  echo "  ]
     } " >> $i;
done;

cd $toolpath



rm $systemdata/nodes 2> /dev/null
rm $systemdata/edges 2> /dev/null
rm $distdatapath/dependencies* 2> /dev/null
rm $distdatapath/temp_allmodules 2> /dev/null
