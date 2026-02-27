// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

// Focus scope management for Glizzy package
// Inline implementations that work standalone

const focusScopes = new Map();

/**
 * Create a focus scope for a container element
 */
export function createFocusScope(containerId) {
  const container = document.getElementById(containerId);
  if (!container) return containerId;

  const scopeId = `focus-scope-${Date.now()}-${Math.random().toString(36).slice(2)}`;
  
  const getFocusableElements = () => {
    if (!container) return [];
    const focusableSelector = [
      "button:not([disabled])",
      "[href]",
      "input:not([disabled])",
      "select:not([disabled])",
      "textarea:not([disabled])",
      '[tabindex]:not([tabindex="-1"])',
    ].join(", ");
    return Array.from(container.querySelectorAll(focusableSelector));
  };

  const focusFirst = () => {
    const elements = getFocusableElements();
    if (elements.length > 0) {
      elements[0].focus();
    }
  };

  const focusLast = () => {
    const elements = getFocusableElements();
    if (elements.length > 0) {
      elements[elements.length - 1].focus();
    }
  };

  const trapFocus = (e) => {
    if (e.key !== "Tab") return;

    const elements = getFocusableElements();
    if (elements.length === 0) return;

    const firstElement = elements[0];
    const lastElement = elements[elements.length - 1];

    if (e.shiftKey) {
      if (document.activeElement === firstElement) {
        e.preventDefault();
        lastElement.focus();
      }
    } else {
      if (document.activeElement === lastElement) {
        e.preventDefault();
        firstElement.focus();
      }
    }
  };

  focusScopes.set(scopeId, { container, focusFirst, focusLast, trapFocus });
  return scopeId;
}

/**
 * Destroy a focus scope
 */
export function destroyFocusScope(scopeId) {
  focusScopes.delete(scopeId);
}

/**
 * Focus the first element in the scope
 */
export function focusScopeFocusFirst(scopeId) {
  const scope = focusScopes.get(scopeId);
  if (scope && scope.focusFirst) {
    scope.focusFirst();
  }
}

/**
 * Focus the last element in the scope
 */
export function focusScopeFocusLast(scopeId) {
  const scope = focusScopes.get(scopeId);
  if (scope && scope.focusLast) {
    scope.focusLast();
  }
}

/**
 * Enable/disable focus trap on a scope
 */
export function focusScopeTrapFocus(scopeId, enabled) {
  const scope = focusScopes.get(scopeId);
  if (!scope || !scope.container) return;

  if (enabled) {
    const handleKeyDown = (e) => {
      scope.trapFocus(e);
    };
    scope.container.addEventListener("keydown", handleKeyDown);
    scope.removeHandler = () => {
      scope.container.removeEventListener("keydown", handleKeyDown);
    };
  } else {
    if (scope.removeHandler) {
      scope.removeHandler();
      scope.removeHandler = null;
    }
  }
}

/**
 * Enable focus trap on a container
 */
export function enableFocusTrap(containerId) {
  createFocusScope(containerId);
  // Enable trap immediately
  setTimeout(() => {
    const scope = Array.from(focusScopes.entries())
      .find(([, s]) => s.container?.id === containerId);
    if (scope) {
      focusScopeTrapFocus(scope[0], true);
    }
  }, 0);
}

/**
 * Disable focus trap on a container
 */
export function disableFocusTrap(containerId) {
  const scope = Array.from(focusScopes.entries())
    .find(([, s]) => s.container?.id === containerId);
  if (scope) {
    focusScopeTrapFocus(scope[0], false);
  }
}

/**
 * Focus an element by ID
 */
export function focusElementById(elementId) {
  const element = document.getElementById(elementId);
  if (element) {
    element.focus();
  }
}

/**
 * Get the currently focused element's ID
 */
export function getFocusedElementId() {
  const element = document.activeElement;
  if (element && element.id) {
    return element.id;
  }
  return null;
}
