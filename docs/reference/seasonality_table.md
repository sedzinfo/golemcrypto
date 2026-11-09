# Table of the seasonality of a coin

A table with a row per group of
[`seasonality_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/seasonality_analysis.md),
in their natural order, with the numbers of the chart of
[`plot_seasonality()`](https://sedzinfo.github.io/golemcrypto/reference/plot_seasonality.md).
The mean and the median are shaded red below 0 and green above it, and
the share up red below 50% and green above it, more strongly the further
they are from the middle.

## Usage

``` r
seasonality_table(analysis)
```

## Arguments

- analysis:

  The result of
  [`seasonality_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/seasonality_analysis.md).

## Value

A DT datatable.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
seasonality_table(seasonality_analysis(btc, "month"))

{"x":{"filter":"none","vertical":false,"data":[["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],[13,13,13,13,14,14,14,14,14,14,13,13],[-0.2909088191362446,6.805846449660859,-0.8480297430204339,9.221027053376085,9.223406294424215,-1.565919620056884,7.716308022667905,2.317409857470751,-2.460353975765613,17.54784571858574,41.82655433933046,4.036600187128578],[0.6910591632103502,11.48109686900345,-2.161946529566094,7.580223349393433,3.373294659515502,-0.5140669551104093,8.125447594578361,-7.187529009366012,-2.409221759993463,12.94185417832879,8.783280807858995,-3.192107890262141],[53.84615384615385,69.23076923076923,46.15384615384615,61.53846153846154,50,50,71.42857142857143,35.71428571428572,42.85714285714285,71.42857142857143,61.53846153846154,38.46153846153847],[39.83556664069985,43.71685551014212,30.53110976195576,34.47789859404755,69.62881891411703,26.71334819167654,23.91633397741146,63.57682892980112,7.392923990426792,53.38345864661653,453.6421831916177,47.77317642078253],[-32.08345930132551,-33.81771483082464,-32.93328919130823,-17.18056365665263,-35.35456442790473,-37.76882985248544,-8.37171977423562,-19.17934140565998,-19.009215898129,-12.56589734150849,-36.41157879134672,-33.23977812630407]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>Month<\/th>\n      <th>Returns<\/th>\n      <th>Mean<\/th>\n      <th>Median<\/th>\n      <th>Up<\/th>\n      <th>Best<\/th>\n      <th>Worst<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":12,"order":[],"columnDefs":[{"targets":4,"render":"function(data, type, row, meta) {\n    return type !== 'display' ? data : DTWidget.formatCurrency(data, \"%\", 0, 3, \",\", \".\", false, null);\n  }"},{"targets":2,"render":"function(data, type, row, meta) {\n    return type !== 'display' ? data : DTWidget.formatCurrency(data, \"%\", 1, 3, \",\", \".\", false, null);\n  }"},{"targets":3,"render":"function(data, type, row, meta) {\n    return type !== 'display' ? data : DTWidget.formatCurrency(data, \"%\", 1, 3, \",\", \".\", false, null);\n  }"},{"targets":5,"render":"function(data, type, row, meta) {\n    return type !== 'display' ? data : DTWidget.formatCurrency(data, \"%\", 1, 3, \",\", \".\", false, null);\n  }"},{"targets":6,"render":"function(data, type, row, meta) {\n    return type !== 'display' ? data : DTWidget.formatCurrency(data, \"%\", 1, 3, \",\", \".\", false, null);\n  }"},{"targets":[1,2,3,4,5,6],"className":"dt-right"},{"name":"Month","targets":0},{"name":"Returns","targets":1},{"name":"Mean","targets":2},{"name":"Median","targets":3},{"name":"Up","targets":4},{"name":"Best","targets":5},{"name":"Worst","targets":6}],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,12,25,50,100],"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\nvar value=data[2]; $(this.api().cell(row, 2).node()).css({'background-color':isNaN(parseFloat(value)) ? '' : value <= -37.6439 ? \"rgba(220,53,69,0.750)\" : value <= -29.2786 ? \"rgba(220,53,69,0.600)\" : value <= -20.9133 ? \"rgba(220,53,69,0.450)\" : value <= -12.548 ? \"rgba(220,53,69,0.300)\" : value <= -4.1827 ? \"rgba(220,53,69,0.150)\" : value <= 4.1827 ? \"rgba(25,135,84,0.000)\" : value <= 12.548 ? \"rgba(25,135,84,0.150)\" : value <= 20.9133 ? \"rgba(25,135,84,0.300)\" : value <= 29.2786 ? \"rgba(25,135,84,0.450)\" : value <= 37.6439 ? \"rgba(25,135,84,0.600)\" : \"rgba(25,135,84,0.750)\"});\nvar value=data[3]; $(this.api().cell(row, 3).node()).css({'background-color':isNaN(parseFloat(value)) ? '' : value <= -37.6439 ? \"rgba(220,53,69,0.750)\" : value <= -29.2786 ? \"rgba(220,53,69,0.600)\" : value <= -20.9133 ? \"rgba(220,53,69,0.450)\" : value <= -12.548 ? \"rgba(220,53,69,0.300)\" : value <= -4.1827 ? \"rgba(220,53,69,0.150)\" : value <= 4.1827 ? \"rgba(25,135,84,0.000)\" : value <= 12.548 ? \"rgba(25,135,84,0.150)\" : value <= 20.9133 ? \"rgba(25,135,84,0.300)\" : value <= 29.2786 ? \"rgba(25,135,84,0.450)\" : value <= 37.6439 ? \"rgba(25,135,84,0.600)\" : \"rgba(25,135,84,0.750)\"});\nvar value=data[4]; $(this.api().cell(row, 4).node()).css({'background-color':isNaN(parseFloat(value)) ? '' : value <= 30.7143 ? \"rgba(220,53,69,0.750)\" : value <= 35 ? \"rgba(220,53,69,0.600)\" : value <= 39.2857 ? \"rgba(220,53,69,0.450)\" : value <= 43.5714 ? \"rgba(220,53,69,0.300)\" : value <= 47.8571 ? \"rgba(220,53,69,0.150)\" : value <= 52.1429 ? \"rgba(25,135,84,0.000)\" : value <= 56.4286 ? \"rgba(25,135,84,0.150)\" : value <= 60.7143 ? \"rgba(25,135,84,0.300)\" : value <= 65 ? \"rgba(25,135,84,0.450)\" : value <= 69.2857 ? \"rgba(25,135,84,0.600)\" : \"rgba(25,135,84,0.750)\"});\n}"},"selection":{"mode":"none","selected":null,"target":"row","selectable":null}},"evals":["options.columnDefs.0.render","options.columnDefs.1.render","options.columnDefs.2.render","options.columnDefs.3.render","options.columnDefs.4.render","options.rowCallback"],"jsHooks":[]}
```
