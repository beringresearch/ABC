Installation
============

The latest version can be installed through:

``` r
devtools::install_github("beringresearch/ABC/confused")
```

Example
=======

``` r
library(confused)
library(rpart)
library(mlbench)

data(Soybean)
Soybean$Class <- as.factor(as.numeric(Soybean$Class))
levels(Soybean$Class)
```

    ##  [1] "1"  "2"  "3"  "4"  "5"  "6"  "7"  "8"  "9"  "10" "11" "12" "13" "14"
    ## [15] "15" "16" "17" "18" "19"

``` r
dim(Soybean)
```

    ## [1] 683  36

Let's built a simple Random Forest classifier:

``` r
Y <- Soybean[, 1]

set.seed(123)
trainIndex <- sample(seq_len(nrow(Soybean)), size = round(0.75 * nrow(Soybean)), replace = FALSE)

train <- Soybean[trainIndex, ]
test <- Soybean[-trainIndex, ]

model <- rpart(Class~., data = train)
yh <- predict(model, test)
```

Finally, visualise performance:

``` r
squares(yh, test$Class)
```

![](README_files/figure-markdown_github/squares-vis-1.png)
