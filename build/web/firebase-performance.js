// Firebase Performance Monitoring for Planner App

// Initialize Firebase Performance Monitoring
document.addEventListener('DOMContentLoaded', function() {
  if (typeof firebase !== 'undefined' && firebase.performance) {
    console.log('Initializing Firebase Performance Monitoring');
    const perf = firebase.performance();
    
    // Create a custom trace for app initialization
    const appInitTrace = perf.trace('app_initialization');
    appInitTrace.start();
    
    // Listen for the first Flutter frame
    window.addEventListener('flutter-first-frame', () => {
      const initTime = performance.now();
      appInitTrace.putMetric('init_time_ms', Math.floor(initTime));
      appInitTrace.stop();
      console.log('App initialization trace completed:', Math.floor(initTime), 'ms');
    });
    
    // Track First Contentful Paint
    const paintPerformance = window.performance.getEntriesByType('paint');
    const fcpEntry = paintPerformance.find(entry => entry.name === 'first-contentful-paint');
    if (fcpEntry) {
      const fcpTrace = perf.trace('first_contentful_paint');
      fcpTrace.putMetric('duration_ms', Math.floor(fcpEntry.startTime));
      fcpTrace.stop();
      console.log('FCP trace completed:', Math.floor(fcpEntry.startTime), 'ms');
    }
    
    // Track navigation timing
    const navTiming = performance.getEntriesByType('navigation')[0];
    if (navTiming) {
      const navTrace = perf.trace('navigation_timing');
      navTrace.putMetric('dom_interactive_ms', Math.floor(navTiming.domInteractive));
      navTrace.putMetric('dom_complete_ms', Math.floor(navTiming.domComplete));
      navTrace.putMetric('load_event_ms', Math.floor(navTiming.loadEventEnd));
      navTrace.stop();
      console.log('Navigation timing trace completed');
    }
    
    // Create helper functions for custom traces
    window.perfMonitor = {
      // Start a trace for a specific operation
      startTrace: function(traceName) {
        if (!perf) return null;
        const trace = perf.trace(traceName);
        trace.start();
        return trace;
      },
      
      // Stop a trace
      stopTrace: function(trace) {
        if (!trace) return;
        trace.stop();
      },
      
      // Add a metric to a trace
      putTraceMetric: function(trace, metricName, value) {
        if (!trace) return;
        trace.putMetric(metricName, value);
      },
      
      // Add an attribute to a trace
      putTraceAttribute: function(trace, attrName, value) {
        if (!trace) return;
        trace.putAttribute(attrName, value);
      },
      
      // Create an HTTP metric
      startHttpMetric: function(url, httpMethod) {
        if (!perf) return null;
        const metric = perf.newHttpMetric(url, httpMethod);
        metric.start();
        return metric;
      },
      
      // Stop an HTTP metric
      stopHttpMetric: function(metric, options) {
        if (!metric) return;
        
        if (options) {
          if (options.responseCode) {
            metric.httpResponseCode = options.responseCode;
          }
          if (options.requestSize) {
            metric.requestPayloadSize = options.requestSize;
          }
          if (options.responseSize) {
            metric.responsePayloadSize = options.responseSize;
          }
          if (options.contentType) {
            metric.responseContentType = options.contentType;
          }
        }
        
        metric.stop();
      }
    };
    
    // Track resource loading
    const resourceObserver = new PerformanceObserver((list) => {
      list.getEntries().forEach((entry) => {
        // Only track larger resources
        if (entry.transferSize > 50000) {
          const resourceTrace = perf.trace('resource_load');
          resourceTrace.putMetric('duration_ms', Math.floor(entry.duration));
          resourceTrace.putMetric('transfer_size_bytes', entry.transferSize);
          resourceTrace.putAttribute('resource_type', entry.initiatorType);
          resourceTrace.putAttribute('resource_url', entry.name.split('?')[0]); // Remove query params
          resourceTrace.stop();
        }
      });
    });
    
    resourceObserver.observe({ entryTypes: ['resource'] });
    
    // Track long tasks (potential jank)
    const longTaskObserver = new PerformanceObserver((list) => {
      list.getEntries().forEach((entry) => {
        const longTaskTrace = perf.trace('long_task');
        longTaskTrace.putMetric('duration_ms', Math.floor(entry.duration));
        longTaskTrace.putAttribute('task_attribution', JSON.stringify(entry.attribution));
        longTaskTrace.stop();
        console.log('Long task detected:', Math.floor(entry.duration), 'ms');
      });
    });
    
    // Only observe long tasks if the browser supports it
    if (window.PerformanceLongTaskTiming) {
      longTaskObserver.observe({ entryTypes: ['longtask'] });
    }
    
    // Track network status changes
    window.addEventListener('online', () => {
      const networkTrace = perf.trace('network_change');
      networkTrace.putAttribute('status', 'online');
      networkTrace.stop();
      console.log('Network status changed: online');
    });
    
    window.addEventListener('offline', () => {
      const networkTrace = perf.trace('network_change');
      networkTrace.putAttribute('status', 'offline');
      networkTrace.stop();
      console.log('Network status changed: offline');
    });
  } else {
    console.warn('Firebase Performance Monitoring not available');
  }
});

// Expose a function to track route changes
window.trackRouteChange = function(routeName) {
  if (typeof firebase !== 'undefined' && firebase.performance) {
    const perf = firebase.performance();
    const routeTrace = perf.trace('route_change');
    routeTrace.putAttribute('route_name', routeName);
    routeTrace.stop();
    console.log('Route change tracked:', routeName);
  }
};

// Expose a function to track user interactions
window.trackUserInteraction = function(interactionType, details) {
  if (typeof firebase !== 'undefined' && firebase.performance) {
    const perf = firebase.performance();
    const interactionTrace = perf.trace('user_interaction');
    interactionTrace.putAttribute('interaction_type', interactionType);
    
    if (details) {
      Object.keys(details).forEach(key => {
        if (typeof details[key] === 'number') {
          interactionTrace.putMetric(key, details[key]);
        } else {
          interactionTrace.putAttribute(key, String(details[key]));
        }
      });
    }
    
    interactionTrace.stop();
    console.log('User interaction tracked:', interactionType);
  }
};