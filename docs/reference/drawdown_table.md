# Table of the falls of a coin

A sortable table of the falls of
[`drawdown_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_analysis.md),
the deepest first, with the numbers of the chart of
[`plot_drawdowns()`](https://sedzinfo.github.io/golemcrypto/reference/plot_drawdowns.md).
The fall is shaded red, more strongly the deeper it is, and the current
fall, which has not got back to its high, is in bold.

## Usage

``` r
drawdown_table(analysis)
```

## Arguments

- analysis:

  The result of
  [`drawdown_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_analysis.md).

## Value

A DT datatable.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
drawdown_table(drawdown_analysis(btc))

{"x":{"filter":"none","vertical":false,"data":[[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],["2013-12-04","2017-12-16","2021-11-08","2021-04-13","2025-10-06","2013-04-29","2017-09-01","2017-06-11","2017-01-04","2025-01-21","2017-03-03","2024-03-13","2021-01-08","2021-02-21","2017-11-08"],[1151.1700439453,19497.400390625,67566.8300878775,63503.45793019,124752.5283520974,144.5399932861,4892.009765625,2958.1101074219,1154.7299804688,106146.2630067343,1274.9899902344,73083.50132821289,40797.61071993,57539.9436679,7459.6899414063],["2015-01-14","2018-12-15","2022-11-21","2021-07-20","2026-06-30","2013-07-05","2017-09-14","2017-07-16","2017-01-11","2025-04-08","2017-03-24","2024-09-06","2021-01-27","2021-02-28","2017-11-12"],[178.1029968262,3236.76164502,15787.2840945218,29807.34767271,58558.8584947089,68.4309997559,3154.9499511719,1929.8199462891,777.757019043,76271.95017471341,937.5200195313,53948.7522426374,30432.54707881,45137.77046805,5950.0698242188],[-84.52852402102093,-83.3990092003427,-76.63456451340275,-53.06185104836729,-53.0599826165973,-52.65601014630681,-35.50810193918683,-34.76172704162768,-32.64598371930688,-28.14447912323165,-26.46844079466522,-26.18203662635521,-25.40605554642585,-21.55402388196782,-20.23703570852311],[406,364,378,98,267,67,13,35,7,77,21,177,19,7,4],["2017-01-04","2020-11-30","2024-03-04","2021-10-19",null,"2013-10-15","2017-10-12","2017-08-05","2017-02-23","2025-05-18","2017-04-26","2024-11-06","2021-02-08","2021-03-11","2017-11-16"],[721,716,469,91,null,102,28,20,43,40,33,61,12,11,4],[1127,1080,847,189,395,169,41,55,50,117,54,238,31,18,8],[false,false,false,false,true,false,false,false,false,false,false,false,false,false,false]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>#<\/th>\n      <th>Peak<\/th>\n      <th>High<\/th>\n      <th>Trough<\/th>\n      <th>Low<\/th>\n      <th>Fall<\/th>\n      <th>Days to trough<\/th>\n      <th>Back at high<\/th>\n      <th>Days to recover<\/th>\n      <th>Days in all<\/th>\n      <th>ongoing<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":20,"columnDefs":[{"targets":5,"render":"function(data, type, row, meta) {\n    return type !== 'display' ? data : DTWidget.formatCurrency(data, \"%\", 1, 3, \",\", \".\", false, null);\n  }"},{"targets":[2,4],"render":"function(data, type) {\n  if (type !== 'display' || data === null) return data;\n  var x = Number(data);\n  if (x >= 1000) return '$' + x.toLocaleString('en-US', {maximumFractionDigits: 0});\n  if (x >= 1) return '$' + x.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});\n  return '$' + Number(x.toPrecision(4)).toLocaleString('en-US', {maximumSignificantDigits: 4});\n}"},{"targets":7,"render":"function(data, type) { return type === 'display' && data === null ? 'not yet' : data; }"},{"targets":[6,8,9],"render":"function(data, type) {\n  if (type !== 'display') return data;\n  return data === null ? '\\u2013' : Number(data).toLocaleString('en-US');\n}"},{"targets":10,"visible":false},{"targets":[0,2,4,5,6,8,9],"className":"dt-right"},{"name":"#","targets":0},{"name":"Peak","targets":1},{"name":"High","targets":2},{"name":"Trough","targets":3},{"name":"Low","targets":4},{"name":"Fall","targets":5},{"name":"Days to trough","targets":6},{"name":"Back at high","targets":7},{"name":"Days to recover","targets":8},{"name":"Days in all","targets":9},{"name":"ongoing","targets":10}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,20,25,50,100],"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\nvar value=data[5]; $(this.api().cell(row, 5).node()).css({'background-color':isNaN(parseFloat(value)) ? '' : value <= -90 ? \"rgba(220,53,69,0.750)\" : value <= -80 ? \"rgba(220,53,69,0.675)\" : value <= -70 ? \"rgba(220,53,69,0.600)\" : value <= -60 ? \"rgba(220,53,69,0.525)\" : value <= -50 ? \"rgba(220,53,69,0.450)\" : value <= -40 ? \"rgba(220,53,69,0.375)\" : value <= -30 ? \"rgba(220,53,69,0.300)\" : value <= -20 ? \"rgba(220,53,69,0.225)\" : value <= -10 ? \"rgba(220,53,69,0.150)\" : \"rgba(220,53,69,0.075)\"});\nvar value=data[10]; $(this.api().cell(row, 0).node()).css({'font-weight':value == true ? \"bold\" : null});\nvar value=data[10]; $(this.api().cell(row, 1).node()).css({'font-weight':value == true ? \"bold\" : null});\nvar value=data[10]; $(this.api().cell(row, 2).node()).css({'font-weight':value == true ? \"bold\" : null});\nvar value=data[10]; $(this.api().cell(row, 3).node()).css({'font-weight':value == true ? \"bold\" : null});\nvar value=data[10]; $(this.api().cell(row, 4).node()).css({'font-weight':value == true ? \"bold\" : null});\nvar value=data[10]; $(this.api().cell(row, 5).node()).css({'font-weight':value == true ? \"bold\" : null});\nvar value=data[10]; $(this.api().cell(row, 6).node()).css({'font-weight':value == true ? \"bold\" : null});\nvar value=data[10]; $(this.api().cell(row, 7).node()).css({'font-weight':value == true ? \"bold\" : null});\nvar value=data[10]; $(this.api().cell(row, 8).node()).css({'font-weight':value == true ? \"bold\" : null});\nvar value=data[10]; $(this.api().cell(row, 9).node()).css({'font-weight':value == true ? \"bold\" : null});\nvar value=data[10]; $(this.api().cell(row, 10).node()).css({'font-weight':value == true ? \"bold\" : null});\n}"},"selection":{"mode":"none","selected":null,"target":"row","selectable":null}},"evals":["options.columnDefs.0.render","options.columnDefs.1.render","options.columnDefs.2.render","options.columnDefs.3.render","options.rowCallback"],"jsHooks":[]}
```
