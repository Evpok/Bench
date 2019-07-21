from setuptools import setup, Extension
from Cython.Build import cythonize

extensions = [
    Extension(
        name="CMandelbrot",
        sources=["CMandelbrot.pyx"],
        extra_compile_args=["-O3", "-fopenmp"],
        extra_link_args=["-fopenmp"],
    )
]

setup(
    install_requires=["numba", "numpy", "cython"],
    ext_modules=cythonize(extensions, language_level=3),
)
