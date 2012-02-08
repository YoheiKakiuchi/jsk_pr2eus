rosbuild_find_ros_package(genmsg_cpp)
rosbuild_find_ros_package(roseus)

## rule
##  1) generate msg/srv/manifest file, depending on manifest.xml, msg/ srv/.
##     this does not generate generated file under .ros/roseus/<package>
##  2) check if depends packages need genmsg/gensrv...
##     use rospack depends to get list of depend packages
##      for each package...
##       if the package have ROS_NOBUILD file, then ...
##         check generated file if we need to generate manifest,msg,srv
##       else (if the package does not hve ROS_NOBUILD file) do nothing
##

# get roseus script file, all genmsg depend on this
file(GLOB roseus_script_files "${roseus_PACKAGE_PATH}/scripts/[^.]*")
list(SORT roseus_script_files)
set(roshomedir $ENV{ROS_HOME})
if("" STREQUAL "${roshomedir}")
  set(roshomedir "$ENV{HOME}/.ros")
endif("" STREQUAL "${roshomedir}")

# for euslisp ros API. like roslib.load_mafest
macro(genmanifest_eus)
  set(genmanifest_eus_exe ${roseus_PACKAGE_PATH}/scripts/genmanifest_eus)
  set(manifest_eus_target_dir ${roshomedir}/roseus/${PROJECT_NAME})
  set(manifest_eus_target ${manifest_eus_target_dir}/manifest.l)
  set(manifest_xml ${PROJECT_SOURCE_DIR}/manifest.xml)
  message("[roseus.cmake] add custom target ROSBUILD_genmanifest_roseus_${PROJECT_NAME}")
  add_custom_command(OUTPUT ${manifest_eus_target}
    COMMAND ${genmanifest_eus_exe} ${PROJECT_NAME}
    DEPENDS ${manifest_xml} ${roseus_script_files})
  add_custom_target(ROSBUILD_genmanifest_roseus_${PROJECT_NAME} ALL
      DEPENDS ${manifest_eus_target})
endmacro(genmanifest_eus)
genmanifest_eus()

# Message-generation support.
macro(genmsg_eus)
  rosbuild_get_msgs(_msglist)
  set(_autogen "")
  foreach(_msg ${_msglist})
    # Construct the path to the .msg file
    set(_input ${PROJECT_SOURCE_DIR}/msg/${_msg})
    rosbuild_gendeps(${PROJECT_NAME} ${_msg})
    set(genmsg_eus_exe ${roseus_PACKAGE_PATH}/scripts/genmsg_eus)

    set(_output_eus ${roshomedir}/roseus/${PROJECT_NAME}/msg/${_msg})
    string(REPLACE ".msg" ".l" _output_eus ${_output_eus})

    # Add the rule to build the .l the .msg
    add_custom_command(OUTPUT ${_output_eus} ${roshomedir}/roseus/${PROJECT_NAME}/msg
                       COMMAND ${genmsg_eus_exe} ${_input}
                       DEPENDS ${_input} ${gendeps_exe} ${${PROJECT_NAME}_${_msg}_GENDEPS} ${ROS_MANIFEST_LIST} ${roseus_script_files})
    list(APPEND _autogen ${_output_eus})
  endforeach(_msg)
  # Create a target that depends on the union of all the autogenerated
  # files
  message("[roseus.cmake] add custom target ROSBUILD_genmsg_roseus_${PROJECT_NAME}")
  add_custom_target(ROSBUILD_genmsg_roseus_${PROJECT_NAME} DEPENDS ${_autogen})
  # Add our target to the top-level genmsg target, which will be fired if
  # the user calls genmsg()
  add_dependencies(rospack_genmsg ROSBUILD_genmsg_roseus_${PROJECT_NAME})
endmacro(genmsg_eus)

# Call the macro we just defined.
genmsg_eus()

# Service-generation support.
macro(gensrv_eus)
  rosbuild_get_srvs(_srvlist)
  set(_autogen "")
  foreach(_srv ${_srvlist})
    # Construct the path to the .srv file
    set(_input ${PROJECT_SOURCE_DIR}/srv/${_srv})

    rosbuild_gendeps(${PROJECT_NAME} ${_srv})
    set(gensrv_eus_exe ${roseus_PACKAGE_PATH}/scripts/gensrv_eus)

    set(_output_eus ${roshomedir}/roseus/${PROJECT_NAME}/srv/${_srv})
    string(REPLACE ".srv" ".l" _output_eus ${_output_eus})

    # Add the rule to build the .l from the .srv
    add_custom_command(OUTPUT ${_output_eus} ${roshomedir}/roseus/${PROJECT_NAME}/srv
                       COMMAND ${gensrv_eus_exe} ${_input}
                       DEPENDS ${_input} ${gendeps_exe} ${${PROJECT_NAME}_${_srv}_GENDEPS} ${ROS_MANIFEST_LIST} ${roseus_script_files})
    list(APPEND _autogen ${_output_eus})
  endforeach(_srv)
  # Create a target that depends on the union of all the autogenerated
  # files
  message("[roseus.cmake] add custom target ROSBUILD_gensrv_roseus_${PROJECT_NAME}")
  add_custom_target(ROSBUILD_gensrv_roseus_${PROJECT_NAME} DEPENDS ${_autogen})
  # Add our target to the top-level gensrv target, which will be fired if
  # the user calls gensrv()
  add_dependencies(rospack_gensrv ROSBUILD_gensrv_roseus_${PROJECT_NAME})
endmacro(gensrv_eus)

# Call the macro we just defined.
gensrv_eus()

# generate msg for package contains ROS_NOBUILD
macro(generate_ros_nobuild_eus)
  # if euslisp is not compiled, return from
  execute_process(COMMAND rosrun euslisp eus2 "(exit)"
    RESULT_VARIABLE _eus2_failed)
  if(_eus2_failed)
    message("[roseus.cmake] eus2 is not ready yet, try rosmake euslisp")
    return()
  endif(_eus2_failed)

  # use rospack depends for packages needs to generate msg/srv
  execute_process(COMMAND rospack depends ${PROJECT_NAME} OUTPUT_VARIABLE depends_packages OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(depends_packages)
    string(REGEX REPLACE "\n" ";" depends_packages ${depends_packages})
  endif(depends_packages)
  set(_project ${PROJECT_NAME})
  list(APPEND depends_packages "${PROJECT_NAME}")
  list(LENGTH depends_packages depends_length)
  # get roseus/script files
  file(GLOB _roseus_script_files RELATIVE ${roseus_PACKAGE_PATH} "${roseus_PACKAGE_PATH}/scripts/[^.]*")
  list(SORT _roseus_script_files)
  execute_process(COMMAND md5sum ${_roseus_script_files} WORKING_DIRECTORY ${roseus_PACKAGE_PATH} OUTPUT_VARIABLE md5sum_script)
  # for each packages...
  set(depends_counter 1)
  foreach(_package ${depends_packages})
    message("[roseus.cmake] [${depends_counter}/${depends_length}] Check ${_package} for ${PROJECT_NAME}")
    math(EXPR depends_counter "${depends_counter} + 1")
    # check if the package have ROS_NOBUILD
    rosbuild_find_ros_package(${_package})
    set(msggenerated "${roshomedir}/roseus/${_package}/generated")
    set(md5sum_file "")
    if(EXISTS ${msggenerated})
      execute_process(COMMAND cat ${msggenerated} OUTPUT_VARIABLE md5sum_file)
    endif(EXISTS ${msggenerated})
    if(EXISTS ${${_package}_PACKAGE_PATH}/ROS_NOBUILD AND
	NOT "${md5sum_file}" STREQUAL "${md5sum_script}")
      message("[roseus.cmake] need to generate files")
      set(PROJECT_NAME ${_package})
      set(PROJECT_SOURCE_DIR ${${_package}_PACKAGE_PATH})
      genmanifest_eus()
      genmsg_eus()
      gensrv_eus()
      add_custom_target(ROSBUILD_genmsg_roseus_${PROJECT_NAME}_all ALL
	DEPENDS ROSBUILD_genmsg_roseus_${PROJECT_NAME})
      add_dependencies(ROSBUILD_genmsg_roseus_${PROJECT_NAME}_all ROSBUILD_genmsg_roseus_${PROJECT_NAME}_precompile)
      add_dependencies(rosbuild_precompile ROSBUILD_genmsg_roseus_${PROJECT_NAME}_precompile)
      add_custom_target(ROSBUILD_gensrv_roseus_${PROJECT_NAME}_all ALL
	DEPENDS ROSBUILD_gensrv_roseus_${PROJECT_NAME})
      add_dependencies(ROSBUILD_gensrv_roseus_${PROJECT_NAME}_all ROSBUILD_gensrv_roseus_${PROJECT_NAME}_precompile)
      add_dependencies(rosbuild_precompile ROSBUILD_gensrv_roseus_${PROJECT_NAME}_precompile)
      file(WRITE ${msggenerated} ${md5sum_script})
    endif(EXISTS ${${_package}_PACKAGE_PATH}/ROS_NOBUILD AND
      NOT "${md5sum_file}" STREQUAL "${md5sum_script}")
    # check the generated file
  endforeach(_package ${depends_packages})
  set(PROJECT_NAME ${_project})
  set(PROJECT_SOURCE_DIR ${${_project}_PACKAGE_PATH})
endmacro(generate_ros_nobuild_eus)

# call the macro we just defined
generate_ros_nobuild_eus()

