HIGHLIGHT='\e[33m'	# Highlight
RED='\e[31m'		# Red
GREEN='\e[32m'		# Green
CYAN='\e[36m'		# Cyan
CHECK='\xE2\x9C\x94'	# Checkmark
PLAIN='\e[0m'		# Remove attributes

exit=0;

copy_source_files() {
  # Check for a Contents.swift file first
  if [ -e Contents.swift ]; then
    printf " ${CYAN}Copying Contents.swift to the build directory.${PLAIN}\n"
    cp Contents.swift ${build_dir}/main.swift;
    if [ -e Sources ]; then
       printf " ${CYAN}Copying Sources to the build directory.${PLAIN}\n"
       cp -R Sources ${build_dir}/
    fi
  fi
}

build_and_run_files() {
  printf "${HIGHLIGHT}Compiling ${current_working_playground}${PLAIN}\n";
  if !([ -e Sources/*.swift ] && swiftc -v main.swift Sources/*.swift || swiftc -v main.swift);
  then
    printf "${RED}Failed to compile $file${PLAIN}\n";
    exit=1;
    continue;
  fi;
  printf "${HIGHLIGHT}Running $file${PLAIN}\n";
  if !(./main);
  then
    printf "${RED}Failed to run $file${PLAIN}\n";
    exit=1;
  else
    printf "${GREEN}${CHECK} $file${PLAIN}\n";
  fi;
}

home=$PWD
#Set up our build directory
if !([ -e build ]); then
  mkdir build
fi

build_dir=${home}/build

# Copy our source files into our build directory
current_working_playground=''
for folder in *Unit*; do 
	cd $folder
	for file in *.playground; do 
	  cd "$file";
	  printf " ${CYAN}Working in $file${PLAIN}\n"
	  current_working_playground=$PWD
	  if [ -e Contents.swift ]; then
	    copy_source_files "$current_working_playground"
	    # Jump to the build directory to build this out
	    cd $build_dir
	    build_and_run_files;
	    # Clean up the built resources
	    rm -rf ./Sources
	    rm main
	    rm main.swift
	  else
	    # Now we go looking in Pages directories...
	    if [ -e Pages ]; then
	      for page in Pages/*.xcplaygroundpage; do
	        cd "${page}";
	        current_working_page=$PWD
	        printf " ${CYAN}Working in $page${PLAIN}\n"
	        if [ -e Contents.swift ]; then
	          copy_source_files "$current_working_playground"
	          # Jump to the build directory to build this out
	          cd $build_dir
	          build_and_run_files;
	          # Clean up the built resources
	          rm -rf ./Sources
	          rm main
	          rm main.swift
	          # Get back to our current working page and then back out two directories
	          cd "${current_working_page}/../../"
	        fi
	      done;
	      # Get back to our current working playground
	      cd ../
	    fi
	  fi
	done;
	cd ../
done;
exit $exit;
