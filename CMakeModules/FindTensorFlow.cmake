# Locates the tensorFlow library and include directories.

include(FindPackageHandleStandardArgs)

# For tensorflow 2.3 (include)
list(APPEND TensorFlow_INCLUDE_DIR ~/tensorflow/local/include/google/tensorflow) # modify path
list(APPEND TensorFlow_INCLUDE_DIR ~/tensorflow/bazel-tensorflow/external/nsync/public) # modify path
list(APPEND TensorFlow_INCLUDE_DIR ~/tensorflow/tensorflow/lite/tools/make/downloads/absl) # modify path

# For tensorflow 2.3 (libs)
set(TensorFlow_LIBRARIES ~/tensorflow/local/lib/libtensorflow_all.so) # modify path

# set TensorFlow_FOUND
find_package_handle_standard_args(TensorFlow DEFAULT_MSG TensorFlow_INCLUDE_DIR TensorFlow_LIBRARIES)

# set external variables for usage in CMakeLists.txt
if(TENSORFLOW_FOUND)
  set(TensorFlow_LIBRARIES ${TensorFlow_LIBRARIES})
  set(TensorFlow_INCLUDE_DIRS ${TensorFlow_INCLUDE_DIR})
  message(STATUS "TensorFlow found (include: ${TensorFlow_INCLUDE_DIRS})")
  message(STATUS "TensorFlow found (lib: ${TensorFlow_LIBRARIES})")

endif()
