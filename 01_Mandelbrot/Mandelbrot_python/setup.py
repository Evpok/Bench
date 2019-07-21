from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

extensions = [
    Extension(
        "CMandelbrot",
        ["CMandelbrot.pyx"],
        extra_compile_args=["-O3", "-fopenmp"],
        extra_link_args=["-fopenmp"],
    )
]
setup(ext_modules=cythonize(extensions, language_level=3))
