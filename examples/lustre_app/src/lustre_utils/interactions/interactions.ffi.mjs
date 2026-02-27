// FFI bindings for Glizzy interactions
// This file provides the bridge between Gleam and JavaScript

import {
  usePress,
  useHover,
  useFocus,
  useFocusVisible,
  useKeyboard,
  useDialog,
  useFocusTrap,
  setupDialogCloseButton,
} from "./interactions.mjs";

// Import and rename to avoid conflicts
import * as interactions from "./interactions.mjs";

// Local ID generator
let idCounter = 0;
function generateId(prefix) {
  idCounter += 1;
  return `${prefix}-${idCounter}-${Date.now()}`;
}

// ============================================
// PRESS INTERACTIONS
// ============================================

const pressSubscriptions = new Map();

export function subscribePress(elementId, dispatch, config) {
  const element = document.getElementById(elementId);
  if (!element) return "";

  const subscriptionId = generateId("press");

  const cleanup = usePress(element, (e) => {
    dispatch({
      type: "press",
      pointerType: e.pointerType || "mouse",
      shiftKey: e.shiftKey || false,
      ctrlKey: e.ctrlKey || false,
      metaKey: e.metaKey || false,
      altKey: e.altKey || false,
      x: e.clientX || 0,
      y: e.clientY || 0,
    });
  });

  pressSubscriptions.set(subscriptionId, { element, cleanup, config });

  return subscriptionId;
}

export function unsubscribePress(subscriptionId) {
  const subscription = pressSubscriptions.get(subscriptionId);
  if (subscription && subscription.cleanup) {
    subscription.cleanup();
  }
  pressSubscriptions.delete(subscriptionId);
}

export function updatePressConfig(subscriptionId, config) {
  const subscription = pressSubscriptions.get(subscriptionId);
  if (subscription) {
    subscription.config = config;
  }
}

// ============================================
// HOVER INTERACTIONS
// ============================================

const hoverSubscriptions = new Map();

export function subscribeHover(elementId, dispatch, config) {
  const element = document.getElementById(elementId);
  if (!element) return "";

  const subscriptionId = generateId("hover");

  const cleanup = useHover(
    element,
    (e) => {
      dispatch({
        type: "hover_start",
        pointerType: e.pointerType || "mouse",
      });
    },
    (e) => {
      dispatch({
        type: "hover_end",
        pointerType: e.pointerType || "mouse",
      });
    },
  );

  hoverSubscriptions.set(subscriptionId, { element, cleanup, config });

  return subscriptionId;
}

export function unsubscribeHover(subscriptionId) {
  const subscription = hoverSubscriptions.get(subscriptionId);
  if (subscription && subscription.cleanup) {
    subscription.cleanup();
  }
  hoverSubscriptions.delete(subscriptionId);
}

// ============================================
// FOCUS INTERACTIONS
// ============================================

const focusSubscriptions = new Map();

export function subscribeFocus(elementId, dispatch, config) {
  const element = document.getElementById(elementId);
  if (!element) return "";

  const subscriptionId = generateId("focus");

  const cleanup = useFocus(
    element,
    () => {
      dispatch({ type: "focus" });
    },
    () => {
      dispatch({ type: "blur" });
    },
  );

  focusSubscriptions.set(subscriptionId, { element, cleanup, config });

  return subscriptionId;
}

export function unsubscribeFocus(subscriptionId) {
  const subscription = focusSubscriptions.get(subscriptionId);
  if (subscription && subscription.cleanup) {
    subscription.cleanup();
  }
  focusSubscriptions.delete(subscriptionId);
}

// ============================================
// KEYBOARD INTERACTIONS
// ============================================

const keyboardSubscriptions = new Map();

export function subscribeKeyboard(elementId, dispatch, config) {
  const element = document.getElementById(elementId);
  if (!element) return "";

  const subscriptionId = generateId("keyboard");

  const cleanup = useKeyboard(element, {
    ArrowDown: (e) =>
      dispatch({
        type: "key_down",
        key: e.key,
        code: e.code,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        altKey: e.altKey,
        repeat: e.repeat,
      }),
    ArrowUp: (e) =>
      dispatch({
        type: "key_down",
        key: e.key,
        code: e.code,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        altKey: e.altKey,
        repeat: e.repeat,
      }),
    ArrowLeft: (e) =>
      dispatch({
        type: "key_down",
        key: e.key,
        code: e.code,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        altKey: e.altKey,
        repeat: e.repeat,
      }),
    ArrowRight: (e) =>
      dispatch({
        type: "key_down",
        key: e.key,
        code: e.code,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        altKey: e.altKey,
        repeat: e.repeat,
      }),
    Enter: (e) =>
      dispatch({
        type: "key_down",
        key: e.key,
        code: e.code,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        altKey: e.altKey,
        repeat: e.repeat,
      }),
    Space: (e) =>
      dispatch({
        type: "key_down",
        key: e.key,
        code: e.code,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        altKey: e.altKey,
        repeat: e.repeat,
      }),
    Escape: (e) =>
      dispatch({
        type: "key_down",
        key: e.key,
        code: e.code,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        altKey: e.altKey,
        repeat: e.repeat,
      }),
    Tab: (e) =>
      dispatch({
        type: "key_down",
        key: e.key,
        code: e.code,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        altKey: e.altKey,
        repeat: e.repeat,
      }),
    Home: (e) =>
      dispatch({
        type: "key_down",
        key: e.key,
        code: e.code,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        altKey: e.altKey,
        repeat: e.repeat,
      }),
    End: (e) =>
      dispatch({
        type: "key_down",
        key: e.key,
        code: e.code,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        altKey: e.altKey,
        repeat: e.repeat,
      }),
    PageUp: (e) =>
      dispatch({
        type: "key_down",
        key: e.key,
        code: e.code,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        altKey: e.altKey,
        repeat: e.repeat,
      }),
    PageDown: (e) =>
      dispatch({
        type: "key_down",
        key: e.key,
        code: e.code,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        altKey: e.altKey,
        repeat: e.repeat,
      }),
  });

  keyboardSubscriptions.set(subscriptionId, { element, cleanup, config });

  return subscriptionId;
}

export function unsubscribeKeyboard(subscriptionId) {
  const subscription = keyboardSubscriptions.get(subscriptionId);
  if (subscription && subscription.cleanup) {
    subscription.cleanup();
  }
  keyboardSubscriptions.delete(subscriptionId);
}

// ============================================
// LONG PRESS INTERACTIONS
// ============================================

const longPressSubscriptions = new Map();

export function subscribeLongPress(elementId, dispatch, config) {
  const element = document.getElementById(elementId);
  if (!element) return "";

  const subscriptionId = generateId("longpress");
  let timeoutId = null;
  let isPressed = false;

  const duration = config?.durationMs || 500;

  const start = (e) => {
    isPressed = true;
    dispatch({
      type: "long_press_start",
      pointerType: e.pointerType || "mouse",
    });

    timeoutId = setTimeout(() => {
      if (isPressed) {
        dispatch({ type: "long_press_trigger" });
      }
    }, duration);
  };

  const cancel = (e) => {
    if (timeoutId) {
      clearTimeout(timeoutId);
      timeoutId = null;
    }

    if (isPressed) {
      isPressed = false;
      dispatch({
        type: "long_press_end",
        cancelled: e?.type === "mouseleave" || e?.type === "touchcancel",
      });
    }
  };

  element.addEventListener("mousedown", start);
  element.addEventListener("mouseup", cancel);
  element.addEventListener("mouseleave", cancel);
  element.addEventListener("touchstart", start);
  element.addEventListener("touchend", cancel);
  element.addEventListener("touchcancel", cancel);

  const cleanup = () => {
    cancel();
    element.removeEventListener("mousedown", start);
    element.removeEventListener("mouseup", cancel);
    element.removeEventListener("mouseleave", cancel);
    element.removeEventListener("touchstart", start);
    element.removeEventListener("touchend", cancel);
    element.removeEventListener("touchcancel", cancel);
  };

  longPressSubscriptions.set(subscriptionId, { element, cleanup, config });

  return subscriptionId;
}

export function unsubscribeLongPress(subscriptionId) {
  const subscription = longPressSubscriptions.get(subscriptionId);
  if (subscription && subscription.cleanup) {
    subscription.cleanup();
  }
  longPressSubscriptions.delete(subscriptionId);
}

// ============================================
// FOCUS VISIBLE
// ============================================

let focusVisibleState = false;
const focusVisibleSubscriptions = new Map();

export function initFocusVisible() {
  let hadKeyboardEvent = false;

  document.addEventListener("keydown", (e) => {
    if (e.key === "Tab") {
      hadKeyboardEvent = true;
      focusVisibleState = true;
    }
  });

  document.addEventListener("pointerdown", () => {
    hadKeyboardEvent = false;
    focusVisibleState = false;
  });
}

export function getFocusVisibleState() {
  return focusVisibleState;
}

export function subscribeFocusVisible(elementId, dispatch, config) {
  const element = document.getElementById(elementId);
  if (!element) return "";

  const subscriptionId = generateId("focusvisible");

  const cleanup = useFocusVisible(element, (e, isFocusVisible) => {
    dispatch({
      type: "focus_visible_change",
      isFocusVisible: isFocusVisible,
    });
  });

  focusVisibleSubscriptions.set(subscriptionId, { element, cleanup, config });

  return subscriptionId;
}

export function unsubscribeFocusVisible(subscriptionId) {
  const subscription = focusVisibleSubscriptions.get(subscriptionId);
  if (subscription && subscription.cleanup) {
    subscription.cleanup();
  }
  focusVisibleSubscriptions.delete(subscriptionId);
}

// ============================================
// MOVE INTERACTIONS
// ============================================

const moveSubscriptions = new Map();

export function subscribeMove(elementId, dispatch) {
  const element = document.getElementById(elementId);
  if (!element) return "";

  const subscriptionId = generateId("move");
  let isMoving = false;
  let startX = 0;
  let startY = 0;

  function relativeCoords(e) {
    const rect = element.getBoundingClientRect();
    return {
      x: rect.width > 0 ? Math.max(0, Math.min((e.clientX - rect.left) / rect.width, 1.0)) : 0,
      y: rect.height > 0 ? Math.max(0, Math.min((e.clientY - rect.top) / rect.height, 1.0)) : 0,
    };
  }

  const handlePointerDown = (e) => {
    isMoving = true;
    const rel = relativeCoords(e);
    startX = rel.x;
    startY = rel.y;
    element.setPointerCapture(e.pointerId);

    dispatch(JSON.stringify({
      type: "move_start",
      x: rel.x,
      y: rel.y,
    }));
  };

  const handlePointerMove = (e) => {
    if (!isMoving) return;

    const rel = relativeCoords(e);
    const deltaX = rel.x - startX;
    const deltaY = rel.y - startY;

    dispatch(JSON.stringify({
      type: "move",
      x: rel.x,
      y: rel.y,
      deltaX: deltaX,
      deltaY: deltaY,
    }));
  };

  const handlePointerUp = (e) => {
    if (isMoving) {
      isMoving = false;
      const rel = relativeCoords(e);
      dispatch(JSON.stringify({
        type: "move_end",
        x: rel.x,
        y: rel.y,
      }));
    }
    // Cleanup check: if element is no longer in DOM, unsubscribe
    if (!document.contains(element)) {
      unsubscribeMove(subscriptionId);
    }
  };

  element.addEventListener("pointerdown", handlePointerDown);
  element.addEventListener("pointermove", handlePointerMove);
  element.addEventListener("pointerup", handlePointerUp);

  const cleanup = () => {
    element.removeEventListener("pointerdown", handlePointerDown);
    element.removeEventListener("pointermove", handlePointerMove);
    element.removeEventListener("pointerup", handlePointerUp);
  };

  moveSubscriptions.set(subscriptionId, { element, cleanup });

  return subscriptionId;
}

export function unsubscribeMove(subscriptionId) {
  const subscription = moveSubscriptions.get(subscriptionId);
  if (subscription && subscription.cleanup) {
    subscription.cleanup();
  }
  moveSubscriptions.delete(subscriptionId);
}

// ============================================
// FOCUS SCOPE
// ============================================

const focusScopes = new Map();

export function createFocusScope(containerId) {
  const container = document.getElementById(containerId);
  if (!container) return "";

  const scopeId = generateId("focusscope");
  const scope = interactions.createFocusScope(container);
  focusScopes.set(scopeId, { container, scope });

  return scopeId;
}

export function destroyFocusScope(scopeId) {
  focusScopes.delete(scopeId);
}

export function focusScopeFocusFirst(scopeId) {
  const scope = focusScopes.get(scopeId);
  if (scope && scope.scope) {
    scope.scope.focusFirst();
  }
}

export function focusScopeFocusLast(scopeId) {
  const scope = focusScopes.get(scopeId);
  if (scope && scope.scope) {
    scope.scope.focusLast();
  }
}

export function focusScopeTrapFocus(scopeId, enabled) {
  const scope = focusScopes.get(scopeId);
  if (scope && scope.scope) {
    if (enabled) {
      scope.scope.trapFocus({
        key: "Tab",
        shiftKey: false,
        preventDefault: () => {},
      });
    }
  }
}

// ============================================
// DIALOG INTERACTIONS
// ============================================

const dialogs = new Map();

export function initDialog(dialogId, config) {
  const dialog = useDialog(dialogId, config);
  dialogs.set(dialogId, dialog);
  return dialog;
}

export function openDialog(dialogId) {
  const dialog = dialogs.get(dialogId);
  if (dialog) {
    dialog.open();
  }
}

export function closeDialog(dialogId) {
  const dialog = dialogs.get(dialogId);
  if (dialog) {
    dialog.close();
  }
}

export function isDialogOpen(dialogId) {
  const dialog = dialogs.get(dialogId);
  if (dialog) {
    return dialog.isOpen();
  }
  return false;
}

export function setupDialog(dialogId, onOpenChange, onClose) {
  const dialog = useDialog(dialogId, { onOpenChange, onClose });
  dialogs.set(dialogId, dialog);

  // Set up close button handler
  setupDialogCloseButton(dialogId, () => {
    dialog.close();
  });

  return dialog;
}

// ============================================
// CLICK OUTSIDE DETECTION
// ============================================

const clickOutsideSubscriptions = new Map();
let documentClickHandler = null;

/**
 * Handle document clicks and dispatch to all registered subscriptions
 */
function handleDocumentClick(e) {
  const target = e.target;
  
  for (const [subscriptionId, { element, dispatch, config }] of clickOutsideSubscriptions.entries()) {
    if (element && document.contains(element)) {
      const isInside = element.contains(target);
      if (!isInside) {
        // Click was outside - dispatch click outside message
        dispatch(JSON.stringify({
          type: "click_outside",
          targetId: target.id || "",
        }));
      } else {
        // Click was inside - dispatch click inside message (optional)
        if (config?.notifyInside) {
          dispatch(JSON.stringify({
            type: "click_inside",
            targetId: target.id || "",
          }));
        }
      }
    }
  }
}

/**
 * Subscribe to click-outside detection for an element
 * @param {string} elementId - ID of the element to track
 * @param {function(string): void} dispatch - Function to dispatch messages
 * @param {string} configJson - JSON config: { notifyInside: boolean }
 * @returns {string} Subscription ID
 */
export function subscribeClickOutside(elementId, dispatch, configJson) {
  const element = document.getElementById(elementId);
  if (!element) return "";

  const subscriptionId = generateId("clickoutside");
  let config = {};
  try {
    config = JSON.parse(configJson);
  } catch {
    config = {};
  }

  clickOutsideSubscriptions.set(subscriptionId, { element, dispatch, config });

  // Add document listener if this is the first subscription
  if (clickOutsideSubscriptions.size === 1) {
    document.addEventListener("click", handleDocumentClick, true);
    document.addEventListener("mousedown", handleDocumentClick, true);
  }

  return subscriptionId;
}

/**
 * Unsubscribe from click-outside detection
 * @param {string} subscriptionId - Subscription ID to remove
 */
export function unsubscribeClickOutside(subscriptionId) {
  clickOutsideSubscriptions.delete(subscriptionId);
  
  // Remove document listener if no more subscriptions
  if (clickOutsideSubscriptions.size === 0 && documentClickHandler) {
    document.removeEventListener("click", handleDocumentClick, true);
    document.removeEventListener("mousedown", handleDocumentClick, true);
  }
}

/**
 * Update click-outside subscription (e.g., when element changes)
 * @param {string} subscriptionId - Subscription ID
 * @param {string} newElementId - New element ID to track
 */
export function updateClickOutsideElement(subscriptionId, newElementId) {
  const subscription = clickOutsideSubscriptions.get(subscriptionId);
  if (subscription) {
    const newElement = document.getElementById(newElementId);
    if (newElement) {
      subscription.element = newElement;
    }
  }
}

// ============================================
// UTILITIES
// ============================================

/**
 * Focus an element by ID
 * @param {string} elementId - ID of the element to focus
 */
export function focusElementById(elementId) {
  const element = document.getElementById(elementId);
  if (element) {
    element.focus();
  }
}

/**
 * Get the ID of the currently focused element
 * @returns {string} ID of the focused element, or empty string if none
 */
export function getFocusedElementId() {
  const element = document.activeElement;
  if (element && element.id) {
    return element.id;
  }
  return "";
}

// ============================================
// FOCUS TRAP
// ============================================

export function enableFocusTrap(containerId) {
  return useFocusTrap(containerId, true);
}

export function disableFocusTrap(containerId) {
  const cleanup = useFocusTrap(containerId, false);
  if (cleanup) cleanup();
}
