from setuptools import setup
from setuptools import find_packages

setup(
    name="deepcytof",
    version="0.0.2",
    description="Deep autoencoders for dimensionality reduction.",
    url="https://github.com/beringresearch/ABC/tree/master/deepflow",
    author="Benjamin Szubert, Ignat Drozdov",
    author_email="bszubert@beringresearch.com, idrozdov@beringresearch.com",
    license="MIT",
    classifiers=[
        # How mature is this project? Common values are
        #   3 - Alpha
        #   4 - Beta
        #   5 - Production/Stable
        'Development Status :: 3 - Alpha',

        # Indicate who your project is intended for
        'Intended Audience :: Developers',
        'Topic :: Software Development :: Build Tools',

        # Pick your license as you wish (should match "license" above)
        'License :: OSI Approved :: MIT License',

        # Specify the Python versions you support here. In particular, ensure
        # that you indicate whether you support Python 2, Python 3 or both.

        'Programming Language :: Python :: 3' 
    ],
    keywords="keras autoencoders deep learning neural networks", 
    install_requires=[
        "Theano",
        "scipy",
        "matplotlib",
        "numpy",
        "pandas",
        "sklearn",
        "h5py",
        "keras",
            ],
    entry_points={
        "console_scripts": [
            "deep-flow=deepcytof.deepflow:main",
            "deep-cluster=deepcytof.deepcluster:main"
        ],
    },
    packages=find_packages(),
    zip_safe=False
)
