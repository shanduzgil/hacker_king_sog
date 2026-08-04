from setuptools import setup, Extension
from Cython.Build import cythonize
import os

os.system("gcc -shared -fPIC hacker_king_sog/libfake.c -o hacker_king_sog/libfake.so")

extensions = [
    Extension(
        "hacker_king_sog.core_secure",
        ["hacker_king_sog/core_cython_wrapper.pyx", "hacker_king_sog/core.c"],
        extra_compile_args=['-O2'],
        extra_link_args=['-ldl']
    )
]

setup(
    name='hacker_king_sog',
    version='1.0.2',
    description='Ultimate Next-Gen Penetration Tool (Fully Operational)',
    author='Abolfazl Soleimani',
    packages=['hacker_king_sog'],
    ext_modules=cythonize(extensions),
    entry_points={
        'console_scripts': ['hacker_king_sog = hacker_king_sog.__init__:main']
    },
    include_package_data=True,
    package_data={
        'hacker_king_sog': ['libfake.so', 'wasm_payload.wat']
    },
    zip_safe=False,
)
