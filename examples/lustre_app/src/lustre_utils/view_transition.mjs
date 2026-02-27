// View Transitions API wrapper
// Enables smooth page transitions in SPAs
// Falls back gracefully if browser doesn't support it

export function startViewTransition(callback) {
  if (!document.startViewTransition) {
    callback();
    return;
  }
  document.startViewTransition(callback);
}

export function isSupported() {
  return !!document.startViewTransition;
}
