#!/bin/bash
DIRECTORY='Kettle/'
KETTLE_HOME=~/.kettle/

if [ -d "$DIRECTORY" ] 
then
	KETTLE_DIR="${DIRECTORY}"
else
	echo "ERROR: No Kettle dir found"
fi


echo "Projects"
echo -e "-----------------------\n"
COUNTER=0
shopt -s nullglob
for d in */ ; do
 	if [ $d != "Kettle/" ] 
	then
		
		let COUNTER=COUNTER+1
		echo "${COUNTER}" : "${d%/}"
		PROJECTS[COUNTER]=$d
	fi

done

echo -e "\nchoose a project :"
read PROJECTNUMBER
echo -e "\n"

cd "${PROJECTS[${PROJECTNUMBER}]}"

#check if there is a config file on the top level else check if there are subprojects
if [ -e "config.cfg" ]
then
	KETTLE_VERSION=`awk -F"=" '/^KETTLE_VERSION/ { print $2 }' config.cfg`
	if [ -z "$KETTLE_VERSION" ]
	then
		echo "ERROR: could not load kettle version from config file"
		exit
	fi
	
	if [ -d "../${KETTLE_DIR}${KETTLE_VERSION}" ] 
	then
		echo "INFO: starting Kettle version ${KETTLE_VERSION}"
	else
		echo "ERROR: can not find specified kettle version"
		exit
	fi

	if [ -e "jdbc.properties" ] 
	then
		cp jdbc.properties "../${KETTLE_DIR}${KETTLE_VERSION}/simple-jndi/"
	else
		echo "INFO: No JDBC file for project: ${PROJECTS[${PROJECTNUMBER}]} creating empty file"
		>"../${KETTLE_DIR}${KETTLE_VERSION}/simple-jndi/jdbc.properties"
	fi 
	if [ -d "./pwd" ]
	then
		rm -r "../${KETTLE_DIR}${KETTLE_VERSION}/pwd"
		cp -R "./pwd" "../${KETTLE_DIR}${KETTLE_VERSION}"
	else
		echo "INFO: No carte configuration found will use what is present in kettle directory"
	fi
	
	export KETTLE_HOME=$PWD
	
	cd ../${KETTLE_DIR}${KETTLE_VERSION}
	./spoon.sh

else
#do the folder loop again to find the subprojects


	echo "Subprojecs/Environment"
	echo -e "-----------------------\n"
	
     	SUBCOUNTER=0
	shopt -s nullglob
      	for dd in */ ; do
			let SUBCOUNTER=SUBCOUNTER+1
			echo "${SUBCOUNTER}" : "${dd%/}"
			SUBPROJECTS[SUBCOUNTER]=$dd
	done

	#check if there are any folders in the array
	if [ -z "${SUBPROJECTS[1]}" ]
	then
		echo "ERROR: this project either contains no subprojects or no config.cfg file"
		exit
	fi




	echo "choose a subproject :"
	read SUBPROJECTNUMBER
	echo -e "\n"

	cd "${SUBPROJECTS[${SUBPROJECTNUMBER}]}"

	#check if the subproject has a config file else fail

	if [ -e "config.cfg" ]
	then
		KETTLE_VERSION=`awk -F"=" '/^KETTLE_VERSION/ { print $2 }' config.cfg`
		if [ -z "$KETTLE_VERSION" ]
		then
			echo "ERROR: could not load kettle version from config file"
			exit
		fi
	
		if [ -d "../../${KETTLE_DIR}${KETTLE_VERSION}" ] 
		then
			echo "INFO: starting Kettle version ${KETTLE_VERSION}"
		else
			echo "ERROR: can not find specified kettle version"
			exit
		fi

		if [ -e "jdbc.properties" ] 
		then
			cp jdbc.properties ../../${KETTLE_DIR}${KETTLE_VERSION}/simple-jndi/
		else
			echo "INFO: No JDBC file for project: ${PROJECTS[${PROJECTNUMBER}]} creating empty file"
			>"../../${KETTLE_DIR}${KETTLE_VERSION}/simple-jndi/jdbc.properties"
		fi
		if [ -d "./pwd" ]
        	then
                	rm -r "../../${KETTLE_DIR}${KETTLE_VERSION}/pwd"
                	cp -R "./pwd" "../../${KETTLE_DIR}${KETTLE_VERSION}"
        	else
                	echo "INFO: No carte configuration found will use what is present in kettle directory"
        	fi

		export KETTLE_HOME=$PWD	

		cd "../../${KETTLE_DIR}${KETTLE_VERSION}"
		./spoon.sh
	else
		echo "ERROR: could not find subproject"
		exit
	fi

fi


