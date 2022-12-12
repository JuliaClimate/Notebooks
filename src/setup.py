import setuptools

setuptools.setup(
  name="plutoserver",
  packages=['plutoserver'],
  package_dir={'plutoserver': 'plutoserver'},
  package_data={'plutoserver': ['icons/pluto-logo.svg']},
  entry_points={
      'jupyter_serverproxy_servers': [
          # name = packagename:function_name
          'pluto = plutoserver:setup_plutoserver',
      ]
  },
  install_requires=['jupyter-server-proxy'],
)
