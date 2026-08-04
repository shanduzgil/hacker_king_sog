cd ~/hacker_king_sog

# ایجاد MANIFEST.in
echo "include hacker_king_sog/libfake.so" > MANIFEST.in
echo "include hacker_king_sog/wasm_payload.wat" >> MANIFEST.in

# ویرایش setup.py برای اطمینان از جاگذاری
sed -i '/package_data=/d' setup.py
sed -i '/include_package_data=True/d' setup.py
sed -i '/zip_safe=False/d' setup.py
# (به‌جای آن، خطوط زیر را اضافه کنید)
cat >> setup.py.new << 'EOF'
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
EOF
mv setup.py.new setup.py

# ساخت و آپلود نسخه جدید
rm -rf dist build *.egg-info
python3 setup.py bdist_wheel
twine upload dist/*.whl
