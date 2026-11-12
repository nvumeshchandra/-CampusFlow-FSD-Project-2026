/**
 * CampusFlow - Native SVG Charting Engine
 * Pure vanilla JavaScript rendering responsive SVG Donut, Bar, and Progress visualizers.
 * Zero external libraries or CDNs used.
 */

var CampusFlowCharts = {
  /**
   * Renders a native SVG Donut Chart with legend.
   * data: [{ label: "SUBMITTED", value: 12 }, ...]
   */
  renderDonut: function (containerId, data, colors) {
    var container = document.getElementById(containerId);
    if (!container) return;

    var total = data.reduce(function (sum, item) { return sum + item.value; }, 0);
    if (total === 0) {
      container.innerHTML = '<div class="empty-state" style="padding: 1.5rem;"><p style="font-size:0.85rem;color:#64748b;">No data recorded yet</p></div>';
      return;
    }

    var defaultColors = ["#3b82f6", "#10b981", "#f59e0b", "#8b5cf6", "#ec4899", "#64748b", "#ef4444"];
    var palette = colors || defaultColors;

    var size = 180;
    var radius = 70;
    var strokeWidth = 24;
    var center = size / 2;
    var circumference = 2 * Math.PI * radius;

    var svgHtml = '<div style="display:flex;align-items:center;justify-content:space-around;flex-wrap:wrap;gap:1.5rem;">';
    svgHtml += '<svg width="' + size + '" height="' + size + '" viewBox="0 0 ' + size + ' ' + size + '" style="transform: rotate(-90deg);">';

    var accumulatedPercent = 0;
    data.forEach(function (item, idx) {
      if (item.value <= 0) return;
      var percent = item.value / total;
      var strokeDasharray = (percent * circumference) + ' ' + circumference;
      var strokeDashoffset = -(accumulatedPercent * circumference);
      var color = palette[idx % palette.length];

      svgHtml += '<circle cx="' + center + '" cy="' + center + '" r="' + radius + '" ' +
                 'fill="transparent" stroke="' + color + '" stroke-width="' + strokeWidth + '" ' +
                 'stroke-dasharray="' + strokeDasharray + '" stroke-dashoffset="' + strokeDashoffset + '" ' +
                 'style="transition: stroke-dasharray 0.5s ease;"></circle>';

      accumulatedPercent += percent;
    });

    // Center total label
    svgHtml += '</svg>';

    // Legend
    svgHtml += '<div style="display:flex;flex-direction:column;gap:0.4rem;min-width:140px;">';
    data.forEach(function (item, idx) {
      var color = palette[idx % palette.length];
      var pct = Math.round((item.value / total) * 100);
      svgHtml += '<div style="display:flex;align-items:center;justify-content:space-between;gap:0.75rem;font-size:0.8125rem;">' +
                 '<span style="display:flex;align-items:center;gap:0.4rem;">' +
                 '<span style="width:10px;height:10px;border-radius:2px;background:' + color + ';"></span>' +
                 '<span style="color:#334155;">' + item.label + '</span>' +
                 '</span>' +
                 '<strong style="color:#0f172a;">' + item.value + ' (' + pct + '%)</strong>' +
                 '</div>';
    });
    svgHtml += '</div></div>';

    container.innerHTML = svgHtml;
  },

  /**
   * Renders native horizontal SVG/CSS Bar Progress Chart.
   * data: [{ label: "IT", value: 15 }, ...]
   */
  renderBars: function (containerId, data, barColor) {
    var container = document.getElementById(containerId);
    if (!container) return;

    var max = Math.max.apply(null, data.map(function (d) { return d.value; }));
    if (max <= 0) {
      container.innerHTML = '<div class="empty-state" style="padding: 1.5rem;"><p style="font-size:0.85rem;color:#64748b;">No data recorded yet</p></div>';
      return;
    }

    var color = barColor || "#2563eb";
    var html = '<div style="display:flex;flex-direction:column;gap:0.75rem;">';

    data.forEach(function (item) {
      var pct = Math.round((item.value / max) * 100);
      html += '<div>' +
              '<div style="display:flex;justify-content:space-between;font-size:0.8125rem;margin-bottom:0.25rem;">' +
              '<span style="font-weight:500;color:#334155;">' + item.label + '</span>' +
              '<strong style="color:#0f172a;">' + item.value + '</strong>' +
              '</div>' +
              '<div style="background:#e2e8f0;height:8px;border-radius:4px;overflow:hidden;">' +
              '<div style="background:' + color + ';width:' + pct + '%;height:100%;border-radius:4px;transition:width 0.4s ease;"></div>' +
              '</div>' +
              '</div>';
    });

    html += '</div>';
    container.innerHTML = html;
  }
};
