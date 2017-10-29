Installation
============

The latest version can be installed through:

``` r
devtools::install_github("beringresearch/ABC/mlvc")
```

Examples
========

Let's start by building a 100 tree Random Forest model using the Iris dataset and commiting it to MLVC repository.

``` r
library(mlvc)
library(randomForest)

rf <- randomForest(Species~., data = iris, ntree = 100)
rf
```

    ## 
    ## Call:
    ##  randomForest(formula = Species ~ ., data = iris, ntree = 100) 
    ##                Type of random forest: classification
    ##                      Number of trees: 100
    ## No. of variables tried at each split: 2
    ## 
    ##         OOB estimate of  error rate: 4.67%
    ## Confusion matrix:
    ##            setosa versicolor virginica class.error
    ## setosa         50          0         0        0.00
    ## versicolor      0         47         3        0.06
    ## virginica       0          4        46        0.08

``` r
ml_add(model = rf, X = iris, Y = NULL, repo = "iris", comment = "Random Forest model with 100 trees")
```

    ## Storing model and data files...Done

*ml\_add* requires a model, training set, response variable, repository title, and a brief commit message. All variables are serialised and inserted into a local SQLite database.

Let's retrain the Random Forest model, increasing the number of trees.

``` r
rf <- randomForest(Species~., data = iris, ntree = 500)
rf
```

    ## 
    ## Call:
    ##  randomForest(formula = Species ~ ., data = iris, ntree = 500) 
    ##                Type of random forest: classification
    ##                      Number of trees: 500
    ## No. of variables tried at each split: 2
    ## 
    ##         OOB estimate of  error rate: 4%
    ## Confusion matrix:
    ##            setosa versicolor virginica class.error
    ## setosa         50          0         0        0.00
    ## versicolor      0         47         3        0.06
    ## virginica       0          3        47        0.06

``` r
ml_add(model = rf, X = iris, Y = NULL, repo = "iris", comment = "Random Forest model with 500 trees")
```

    ## Storing model and data files...Done

Our **iris** repository should contain two models with 100 and 500 trees respectively:

``` r
ml_list()
```

    ## $iris
    ## 323031372d31302d32392031303a32393a3336 
    ##                  "2017-10-29 10:29:36" 
    ## 323031372d31302d32392031303a32393a3436 
    ##                  "2017-10-29 10:29:46" 
    ## 323031372d31302d32392031303a33343a3032 
    ##                  "2017-10-29 10:34:02" 
    ## 323031372d31302d32392031303a33343a3132 
    ##                  "2017-10-29 10:34:12" 
    ## 323031372d31302d32392031303a33363a3137 
    ##                  "2017-10-29 10:36:17" 
    ## 323031372d31302d32392031303a33363a3237 
    ##                  "2017-10-29 10:36:27"

Each model is has a unique identifier that relates directly to its creation time stamp. To access the model:

``` r
object <- ml_checkout(repo = "iris", version = names(ml_list()$iris)[2])
object
```

    ## MLVC object
    ##  Version:  2017-10-29 10:29:46 
    ##  Comment:  Random Forest model with 500 trees 
    ##  Model accessor: $model
    ##  Data accessor: $X
    ##  Response accessor: $Y
