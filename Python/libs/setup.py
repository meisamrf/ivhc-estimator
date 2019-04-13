from distutils.core import setup, Extension

libname = 'ivhc'
if platform.system()=='Darwin':
     libname = 'ivhc.mac'
	 
module = Extension('ivhc',
                    sources = ['ivhcNoiseEst.cpp'],
                    include_dirs = [],
                    libraries = [libname],
                    library_dirs = ['/usr/local/lib', './'],                    
                    extra_compile_args=['-std=c++11'])
 
setup(name = 'ivhc',
      version = '1.0',
      description = 'ivhc for image noise estimation',
      ext_modules = [module])
