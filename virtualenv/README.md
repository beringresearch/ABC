# About virtualenv
__virtualenv__ is a dependency management system for R. The package aims to create stand-alone R environments that are:

* Isolated: newly installed packages are allocated to a single active environment.
* Portable: all environments can be exported in a simple YAML format.
* Automated: new environments are easily described using a single configuration file.

# Installing virtualenv

```r
devtools::install_github("beringresearch/ABC", subdir="virtualenv")
```

# Working with virtualenv

Initialise virtualenv library:

```r
library(virtualenv)
```

## Environment configuration

Each environment is described using YAML format. Here's an example of environment **test** with two dependencies and their versions - **ggplot2** and **data.table**.

```yaml
name: test
R: R version 3.3.1 (2016-06-21)
resources:
 - name: Bioconductor
   url: https://bioconductor.org/packages/release/bioc/ 
   packages:
    limma:
 - name: CRAN
   url: https://cran.r-project.org/
   packages:
    data.table: 1.10.4
```

## Setting up a new environment
To initiate an environment from a configuration file, run:

```r
ve_new(config_path="test.yaml")
```

Otherwise, a new environment can be created just by supplying its name:

```r
ve_new("test")
```

All environment files are loaced in ~/.renvironment directory in Unix-like systems. Note that in addition to the two specified packages, __virtualenv__ also downloads and installs their dependencies.

After an environment is created and its requirements are satisfied, R automatically populates the new environment with base packages from the current R version.

To view existing environments enter:

```r
ve_list()
```

## Activating an environment

```r
ve_activate("test")
```

Will activate environment "test". From now on all packages will be installed into this environment and will not clash with other installations.

## Exporting an environment

Environments can be conveniently packaged into a YAML file to be included with any projects that mmay depend on them:

```r
ve_export("copy_of_my_environment")
```

## Deactivating or deleting environments

```r
ve_deactivate()
ve_remove("test")
```

Note that upon deactivation, all attached packages will be unloaded and default R environment restored.
