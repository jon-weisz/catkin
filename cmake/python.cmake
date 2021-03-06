find_package(PythonInterp REQUIRED)
execute_process(COMMAND ${PYTHON_EXECUTABLE} ${catkin_EXTRAS_DIR}/python_version.py
  OUTPUT_VARIABLE PYTHON_VERSION_XDOTY
  OUTPUT_STRIP_TRAILING_WHITESPACE)

set(PYTHON_VERSION_XDOTY ${PYTHON_VERSION_XDOTY} CACHE STRING "Python version")

#This should be resolved automatically one day...
option(SETUPTOOLS_DEB_LAYOUT "ON for debian style python packages layout" ON)

if(APPLE OR MSVC)
  set(SETUPTOOLS_DEB_LAYOUT OFF)
endif()

if(SETUPTOOLS_DEB_LAYOUT)
  set(PYTHON_PACKAGES_DIR dist-packages CACHE STRING "dist-packages or site-packages")
  set(SETUPTOOLS_ARG_EXTRA "--install-layout=deb" CACHE STRING "extra arguments to setuptools")
else()
  set(PYTHON_PACKAGES_DIR site-packages CACHE STRING "dist-packages or site-packages")
  file(TO_NATIVE_PATH ${CMAKE_INSTALL_PREFIX}/bin PYTHON_INSTALL_PREFIX) # setuptools is fussy about windows paths
  set(SETUPTOOLS_ARG_EXTRA "--install-scripts=${PYTHON_INSTALL_PREFIX}" CACHE STRING "extra arguments to setuptools")
endif()

if(NOT MSVC)
  set(PYTHON_INSTALL_DIR lib/python${PYTHON_VERSION_XDOTY}/${PYTHON_PACKAGES_DIR}
    CACHE INTERNAL "This needs to be in PYTHONPATH when setup.py install is called.  And it needs to match.  But setuptools won't tell us where it will install things.")
else()
  # Windows setuptools installs to lib/site-packages not lib/python2.7/site-packages 
  # Or is this SETUPTOOLS_DEB_LAYOUT dependent?
  set(PYTHON_INSTALL_DIR lib/${PYTHON_PACKAGES_DIR}
    CACHE INTERNAL "This needs to be in PYTHONPATH when setup.py install is called.  And it needs to match.  But setuptools won't tell us where it will install things.")
endif()
