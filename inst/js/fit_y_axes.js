// Fits the vertical axes of the timeseries chart to the days in view. plotly sizes each axis to
// all the data, so in a week of Bitcoin's history since 2013 the candles would be flat lines at the
// top of an axis from 0 to the all-time high. After every change of the days in view (the range buttons,
// the range slider, zooming, a double click back to all) and of the Linear/Log switch, each axis
// runs from the lowest to the highest value in view, with 5% to spare; the panels under the price
// keep 0 in view. Run by htmlwidgets::onRender() with the chart's element.
function(el) {
  // dates as milliseconds, in UTC, from "2026-11-06" or "2026-11-06 12:00:00"
  function toTime(value) {
    var text = String(value).replace(' ', 'T');
    if (text.length <= 10) text += 'T00:00';
    return new Date(text + 'Z').getTime();
  }
  // the dates of each trace, worked out again only when the chart gets new data
  function times() {
    if (el._fitData !== el.data) {
      el._fitTimes = el.data.map(function(trace) { return (trace.x || []).map(toTime); });
      el._fitData = el.data;
    }
    return el._fitTimes;
  }
  function fit(event) {
    var keys = Object.keys(event || {});
    var moved = keys.some(function(key) { return key.indexOf('xaxis') === 0 || /^yaxis[0-9]*\.type$/.test(key); });
    if (!moved) return;
    var axes = Object.keys(el.layout).filter(function(key) { return /^yaxis[0-9]*$/.test(key); });
    var update = {};
    if (el.layout.xaxis.autorange) {
      axes.forEach(function(axis) { update[axis + '.autorange'] = true; });
      Plotly.relayout(el, update);
      return;
    }
    var from = toTime(el.layout.xaxis.range[0]), to = toTime(el.layout.xaxis.range[1]);
    var all = times();
    axes.forEach(function(axis) {
      var id = 'y' + axis.slice(5);
      var low = Infinity, high = -Infinity;
      el.data.forEach(function(trace, i) {
        if ((trace.yaxis || 'y') !== id || trace.visible === 'legendonly') return;
        var lows = trace.type === 'candlestick' ? trace.low : trace.y;
        var highs = trace.type === 'candlestick' ? trace.high : trace.y;
        if (!lows) return;
        all[i].forEach(function(t, j) {
          if (t < from || t > to) return;
          if (lows[j] !== null && isFinite(lows[j])) low = Math.min(low, lows[j]);
          if (highs[j] !== null && isFinite(highs[j])) high = Math.max(high, highs[j]);
        });
      });
      if (!isFinite(low)) return;
      // the volume and the drawdown are measured from 0
      if (id !== 'y') { low = Math.min(low, 0); high = Math.max(high, 0); }
      if (el.layout[axis].type === 'log') {
        if (low <= 0) return;
        low = Math.log10(low); high = Math.log10(high);
      }
      var spare = (high - low) * 0.05 || Math.abs(high) * 0.01 || 1;
      update[axis + '.range'] = [low - spare, high + spare];
    });
    if (Object.keys(update).length > 0) Plotly.relayout(el, update);
  }
  // on every drawing: Shiny draws a new index into the same element, which can drop the
  // listeners, so the one of the drawing before is replaced rather than added to
  if (el._fit) el.removeListener('plotly_relayout', el._fit);
  el._fit = fit;
  el.on('plotly_relayout', fit);
}
