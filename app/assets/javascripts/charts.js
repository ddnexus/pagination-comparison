google.charts.load('current', { 'packages': ['bar', 'treemap', 'corechart'] });

var sharedOpts = {
  theme:          'material',
  crosshair:      { trigger: 'both', focused: { opacity: 0.5 }, selected: { opacity: 0.8 } },
  titleTextStyle: {
    fontName: 'Roboto',
    fontSize: 16,
    color:    '#707070',
    bold:     false
  }
};

var barOpts = $.extend({}, sharedOpts, {
  chartArea: { left: 80, top: 40, width: '82%' },
  hAxis:     { format: 'short', gridlines: { count: 8 } },
  legend:    { position: "none" }
});

var treeMapOpts = $.extend({}, sharedOpts, {
  chartArea:    { top: 40, height: '70%', width: '100%' },
  maxDepth:     1,
  maxPostDepth: 1,
  headerHeight: 15,
  showScale:    true,
  minColor:     '#93b3dd',
  midColor:     '#5E97F6',
  maxColor:     '#3a6cc1',
  headerColor:  '#315ba7',
  fontColor:    '#FFFFFF'
});

function dataTooltip(data, row, size, value) {
  return '<div style="font-family: Roboto,sans-serif; font-size: 0.7em; color: #707070; font-weight: normal; background:#fff; padding:5px; border:solid 1px #707070">'
         + data.getValue(row, 0)  + '<br>'
         + data.getColumnLabel(2) + ': <b>' + size + '</b></div>';
}

function drawLocChart() {
  var data  = new google.visualization.arrayToDataTable(locChartData);
  var chart = new google.visualization.BarChart(document.getElementById('loc-chart'));
  var opts  = $.extend({}, barOpts, { title: 'Total Lines of Code' });
  chart.draw(data, opts);
};

function drawFilesChart() {
  var data = new google.visualization.arrayToDataTable(filesChartData);
  function tooltip(row, size, value) { return dataTooltip(data, row, size, value) }

  var chart = new google.visualization.TreeMap(document.getElementById('file-chart'));
  var opts  = $.extend({}, treeMapOpts, {
    title: 'Files and LOC',
    generateTooltip: tooltip
  });
  chart.draw(data, opts);
}

function drawMethodsChart() {
  var data  = new google.visualization.arrayToDataTable(methodsChartData);
  var chart = new google.visualization.BarChart(document.getElementById('methods-chart'));
  var opts  = $.extend({}, barOpts, { title: 'Total Methods' });
  chart.draw(data, opts);
}

function drawModulesChart() {
  var data = new google.visualization.arrayToDataTable(modulesChartData);
  function tooltip(row, size, value) { return dataTooltip(data, row, size, value) }
  var chart = new google.visualization.TreeMap(document.getElementById('modules-chart'));
  var opts  = $.extend({}, treeMapOpts, {
    title: 'Modules and Methods',
    generateTooltip: tooltip
  });
  chart.draw(data, opts);
}

function drawMemoryChart() {
  var data  = new google.visualization.arrayToDataTable(memoryChartData);
  var chart = new google.visualization.BarChart(document.getElementById('memory-chart'));
  var opts  = $.extend({}, barOpts, { title: 'Total Memory Usage' });
  chart.draw(data, opts);
}

function drawObjectsChart() {
  var data = new google.visualization.arrayToDataTable(objectsChartData);
  var chart = new google.visualization.BarChart(document.getElementById('objects-chart'));
  var opts  = $.extend({}, barOpts, {
    title:     'Number of Objects Created',
    hAxis:     { format: 'decimal', gridlines: { count: 8 } },
    // legend:    { position: "bottom" },
    legend:    { position: 'top', alignment: 'end' } ,

    isStacked: true
  });
  chart.draw(data, opts);
};

function drawMemoryPagesChart() {
  var data    = new google.visualization.arrayToDataTable(memoryPagesChartData);
  var chart   = new google.visualization.LineChart(document.getElementById('memory-page-chart'));
  var options = $.extend({}, sharedOpts, {
    title:     'Memory usage per page shown',
    chartArea: { left: 80, top: 50, width: '82%', height: '80%' },
    hAxis:     { title: 'Pages',  titleTextStyle: { color: '#707070' }, format: 'short', gridlines: { count: 10 } },
    vAxis:     { title: 'Memory', titleTextStyle: { color: '#707070' }, format: 'short', gridlines: { count: 10 } },
    curveType: 'line',
    legend:    { position: 'top', alignment: 'end' }
  });
  chart.draw(data, options);
}

function drawIpsChart() {
  var data  = new google.visualization.arrayToDataTable(ipsData);
  var chart = new google.visualization.BarChart(document.getElementById('ips-chart'));
  var opts  = $.extend({}, barOpts, {
    title: 'Iterations Per Second',
    hAxis: { format: 'decimal', gridlines: { count: 8 } }
  });
  chart.draw(data, opts);
};

function drawComparisonChart() {
  var data  = google.visualization.arrayToDataTable(comparisonData);
  var chart = new google.visualization.BubbleChart(document.getElementById('comparison-chart'));
  var opts  = $.extend({}, sharedOpts, {
    title:     'Correlation between IPS, LOC, Memory and Complexity',
    chartArea: { left: 80, top: 60, width: '82%', height: '76%' },
    hAxis:     { title: 'IPS (speed)', titleTextStyle: { color: '#707070' }, format: 'decimal', gridlines: { count: 11 }, minValue: -100 },
    vAxis:     { title: 'LOC (lines of code)', titleTextStyle: { color: '#707070' }, gridlines: { count: 7 }, maxValue: 1200 },
    colorAxis: { minValue: 0, colors: ['#78b0ff', '#000000'] },
    sizeAxis:  { maxSize: 70 },
    bubble:    {
      stroke:    '#fff',
      opacity:   0.9,
      textStyle: {
        fontSize:  10,
        bold:      true,
        color:     '#FFFFFF',
        auraColor: 'none'
      }
    }
  });
  chart.draw(data, opts);
}
