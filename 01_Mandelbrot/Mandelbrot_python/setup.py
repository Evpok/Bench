from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

extensions = [Extension("CMandelbrot", ["CMandelbrot.pyx"])]
setup(ext_modules=cythonize(extensions, language_level=3))
