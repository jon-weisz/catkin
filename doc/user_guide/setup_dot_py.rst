.. _setup_dot_py_handling:

Handling of ``setup.py``
------------------------

If your ROS package contains python modules and scripts to install,
you need to define the installation process and a way to make
the scripts accessible in the develspace.
The python ecosystem defines installation standards in the
``distutils`` or ``setuputils`` libraries. With those libraries,
packages define the installation files in a file called ``setup.py``
in the project root. The setup.py file uses Python to describe the
Python content of the stack.

We recommend to prefer distutils package over setuptools/distribute,
because with distutils we can avoid the creation of egg-info folders
in the project source folder. The setup.cfg file of distutils2 is not
supported by catkin.

Catkin allows you to specify the installation of your python files in
this setup.py and reuse some of the information in your CMakeLists.txt.

You can do so by including the line::

  catkin_python_setup()

in the CMakeLists.txt of your project.

catkin will execute setup.py with a hot-patched version of distutils
to read the arguments to set up the devel space, and execute setup.py
with suitable arguments to install to the catkin install space under
``CMAKE_INSTALL_PREFIX``.

This means you should not execute your
setup.py using::

  # DO NOT USE
  # python setup.py install

manually, as that would install to a different location, and you would
have multiple installed versions that influence each other. Using
setup.py to create a pypi package of your catkin package currently has
no support for ROS messages and services, and core ROS libraries
(e.g. rospy) are not available on pypi, so this using setup.py for
pypi is not very useful for ROS nodes.

For the develspace, the following setup.py arguments to setup() will
be used by catkin::

  from distutils.core import setup

  setup(
    version=...
    scripts=['bin/myscript']
    packages=['mypkg']
    package_dir={'': 'src'})

This creates relays for all scripts listed in ``scripts`` to a folder
in devel space where they can be found and executed, and also relay
packages for any package listed in ``packages``. The version will be
compared to that declared in package.xml, and raise an error on
mismatch.

Using package.xml in setup.py
=============================

Writing a setup.py file without duplicating information contained in the package.xml is possible using a catkin_pkg convenience function like this::

  from distutils.core import setup
  from catkin_pkg.python_setup import generate_distutils_setup

  d = generate_distutils_setup(
    packages=['mypkg'],
    scripts=['bin/myscript'],
    package_dir={'': 'src'}
  )

  setup(**d)

This will parse the package.xml and also format the fields, such that multiple authors with emails will be set nicely for setup.py, in case one distributes to pypi.

Develspace limitations
======================

For the devel space, catkin currently does not support any of the following distutils arguments:

* py_modules
* data_files
* any extention module features

From setuptools, the following args are not supported for the devel space:

* zip-safe
* entry_points

From distribute, the following args are not supported for the devel space:

* include_package_data
* exclude_package_data
* zip_safe
* entry_points
* setup_requires
* namespace_packages
* use_2to3

Those features will only work correctly for the install space.

genmsg interaction
==================

genmsg is an external catkin package that provideslanguage bindings
for ROS messages. When using the genmsg macro, ordering constraints
exist, in that case you have to invoke the macros in this order::

  project(...)
  ...
  find_package(catkin ...)
  ...
  catkin_python_setup()
  ...
  generate_messages()
  ...
  catkin_package()
