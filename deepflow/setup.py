from setuptools import setup

setup(
    name="deepflow",
    version="0.1",
    description="Variational autoencoders for dimensionality reduction.",
    url="http://github.com/beringresearch/internship/deepflow",
    author="Bering Limited",
    author_email="idrozdov@beringresearch.com",
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
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.2',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
    ],
    keywords="keras variational autoencoders deep learning neural networks",
    packages=["deepflow"],
    install_requires=[
        "tensorflow", 
        "keras",
        "numpy",
        "pandas",
        "sklearn"
    ],
    entry_points={
        "console_scripts": [
            "deepflow=deepflow:main"
        ],
    },
    zip_safe=False
)