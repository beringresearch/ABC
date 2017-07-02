from setuptools import setup

setup(
        name='deepvis',
        version='0.1',
        py_modules=['deepvis'],
        include_package_data=True,
        install_requires=[
            'Click', 'cefpython3'
            ],
        entry_points='''
        [console_scripts]
        deepvis=deepvis:cli
        ''',
        )
