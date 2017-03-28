# About virtualenv
__virtualenv__ is a dependency management system for R. The package aims to create stand-alone R environments that are:

* Isolated: newly installed packages are allocated to a single active environment.
* Portable: all environments can be exported in a simple YAML format.
* Automated: new environments are easily described using a single configuration file.

# Installing virtualenv

```{r}
devtools::install_github("beringresearch/ABC", subdir="virtualenv")
```
