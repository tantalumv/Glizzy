// Interaction primitives for Glizzy components

export function usePress(element, callback) {
  if (!element) return;

  element.addEventListener("click", callback);
  element.addEventListener("keydown", (e) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      callback(e);
    }
  });

  return () => {
    element.removeEventListener("click", callback);
    element.removeEventListener("keydown", callback);
  };
}

export function useHover(element, onEnter, onLeave) {
  if (!element) return;

  element.addEventListener("mouseenter", onEnter);
  element.addEventListener("mouseleave", onLeave);

  return () => {
    element.removeEventListener("mouseenter", onEnter);
    element.removeEventListener("mouseleave", onLeave);
  };
}

export function useFocus(element, onFocus, onBlur) {
  if (!element) return;

  element.addEventListener("focus", onFocus);
  element.addEventListener("blur", onBlur);

  return () => {
    element.removeEventListener("focus", onFocus);
    element.removeEventListener("blur", onBlur);
  };
}

export function useFocusVisible(element, callback) {
  if (!element) return;

  let hadKeyboardEvent = false;

  const onKeyDown = (e) => {
    if (e.key === "Tab") {
      hadKeyboardEvent = true;
    }
  };

  const onPointerDown = () => {
    hadKeyboardEvent = false;
  };

  const onFocus = (e) => {
    if (hadKeyboardEvent) {
      callback(e, true);
    }
  };

  const onBlur = () => {
    callback(null, false);
  };

  document.addEventListener("keydown", onKeyDown);
  document.addEventListener("pointerdown", onPointerDown);
  element.addEventListener("focus", onFocus);
  element.addEventListener("blur", onBlur);

  return () => {
    document.removeEventListener("keydown", onKeyDown);
    document.removeEventListener("pointerdown", onPointerDown);
    element.removeEventListener("focus", onFocus);
    element.removeEventListener("blur", onBlur);
  };
}

export function useKeyboard(element, handlers) {
  if (!element) return;

  const handleKeyDown = (e) => {
    const handler = handlers[e.key];
    if (handler) {
      e.preventDefault();
      handler(e);
    }
  };

  element.addEventListener("keydown", handleKeyDown);

  return () => {
    element.removeEventListener("keydown", handleKeyDown);
  };
}

export function useLongPress(element, callback, duration = 500) {
  if (!element) return;

  let timeoutId = null;

  const start = () => {
    timeoutId = setTimeout(() => {
      callback();
    }, duration);
  };

  const cancel = () => {
    if (timeoutId) {
      clearTimeout(timeoutId);
      timeoutId = null;
    }
  };

  element.addEventListener("mousedown", start);
  element.addEventListener("mouseup", cancel);
  element.addEventListener("mouseleave", cancel);
  element.addEventListener("touchstart", start);
  element.addEventListener("touchend", cancel);

  return () => {
    cancel();
    element.removeEventListener("mousedown", start);
    element.removeEventListener("mouseup", cancel);
    element.removeEventListener("mouseleave", cancel);
    element.removeEventListener("touchstart", start);
    element.removeEventListener("touchend", cancel);
  };
}

export function useMove(element, onMove) {
  if (!element) return;

  let isMoving = false;

  const handlePointerDown = (e) => {
    isMoving = true;
    element.setPointerCapture(e.pointerId);
  };

  const handlePointerMove = (e) => {
    if (isMoving) {
      onMove(e);
    }
  };

  const handlePointerUp = () => {
    isMoving = false;
  };

  element.addEventListener("pointerdown", handlePointerDown);
  element.addEventListener("pointermove", handlePointerMove);
  element.addEventListener("pointerup", handlePointerUp);

  return () => {
    element.removeEventListener("pointerdown", handlePointerDown);
    element.removeEventListener("pointermove", handlePointerMove);
    element.removeEventListener("pointerup", handlePointerUp);
  };
}

export function createFocusScope(container) {
  const focusableSelector = [
    "button:not([disabled])",
    "[href]",
    "input:not([disabled])",
    "select:not([disabled])",
    "textarea:not([disabled])",
    '[tabindex]:not([tabindex="-1"])',
  ].join(", ");

  const getFocusableElements = () => {
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

  return {
    getFocusableElements,
    focusFirst,
    focusLast,
    trapFocus,
  };
}

// ============================================
// DIALOG INTERACTIONS
// ============================================

const dialogState = new Map();

export function useDialog(dialogId, config) {
  const { onOpenChange, onClose } = config || {};

  const open = () => {
    const dialog = document.querySelector(
      `[data-dialog-content="true"][data-dialog-id="${dialogId}"]`,
    );
    if (!dialog) return;

    dialog.setAttribute("data-state", "open");
    dialog.setAttribute("aria-hidden", "false");

    // Store previous active element for restoration
    dialogState.set(dialogId, {
      previousActiveElement: document.activeElement,
    });

    // Focus first focusable element
    const focusScope = createFocusScope(dialog);
    focusScope.focusFirst();

    // Set up focus trap
    const handleKeyDown = (e) => {
      if (e.key === "Escape") {
        e.preventDefault();
        close(dialogId);
        return;
      }
      focusScope.trapFocus(e);
    };

    dialog.addEventListener("keydown", handleKeyDown);
    dialogState.get(dialogId).keydownHandler = handleKeyDown;

    // Handle backdrop click
    const handleBackdropClick = (e) => {
      if (e.target === dialog.querySelector('[data-dialog-overlay="true"]')) {
        close(dialogId);
      }
    };

    dialog.addEventListener("click", handleBackdropClick);
    dialogState.get(dialogId).backdropClickHandler = handleBackdropClick;

    if (onOpenChange) onOpenChange(true);
  };

  const close = (id) => {
    const state = dialogState.get(id);
    if (!state) return;

    const dialog = document.querySelector(`[data-dialog-content="true"][data-dialog-id="${id}"]`);
    if (!dialog) return;

    dialog.setAttribute("data-state", "closed");
    dialog.setAttribute("aria-hidden", "true");

    // Remove event listeners
    if (state.keydownHandler) {
      dialog.removeEventListener("keydown", state.keydownHandler);
    }
    if (state.backdropClickHandler) {
      dialog.removeEventListener("click", state.backdropClickHandler);
    }

    // Restore focus to previous active element
    if (state.previousActiveElement && typeof state.previousActiveElement.focus === "function") {
      state.previousActiveElement.focus();
    }

    dialogState.delete(id);

    if (onClose) onClose();
    if (onOpenChange) onOpenChange(false);
  };

  const isOpen = () => {
    const dialog = document.querySelector(
      `[data-dialog-content="true"][data-dialog-id="${dialogId}"]`,
    );
    if (!dialog) return false;
    return dialog.getAttribute("data-state") === "open";
  };

  return {
    open,
    close: () => close(dialogId),
    isOpen,
  };
}

export function useFocusTrap(containerId, enabled) {
  const container = document.getElementById(containerId);
  if (!container) return null;

  const focusableSelector = [
    "button:not([disabled])",
    "[href]",
    "input:not([disabled])",
    "select:not([disabled])",
    "textarea:not([disabled])",
    '[tabindex]:not([tabindex="-1"])',
  ].join(", ");

  const getFocusableElements = () => {
    return Array.from(container.querySelectorAll(focusableSelector));
  };

  const handleKeyDown = (e) => {
    if (!enabled || e.key !== "Tab") return;

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

  if (enabled) {
    container.addEventListener("keydown", handleKeyDown);
    // Focus first element
    const elements = getFocusableElements();
    if (elements.length > 0) {
      elements[0].focus();
    }
  }

  return () => {
    container.removeEventListener("keydown", handleKeyDown);
  };
}

export function setupDialogCloseButton(dialogId, onClose) {
  const dialog = document.querySelector(
    `[data-dialog-content="true"][data-dialog-id="${dialogId}"]`,
  );
  if (!dialog) return;

  const closeButton = dialog.querySelector('[data-dialog-close="true"]');
  if (!closeButton) return;

  const handleClick = (e) => {
    e.preventDefault();
    if (onClose) onClose();
  };

  closeButton.addEventListener("click", handleClick);

  return () => {
    closeButton.removeEventListener("click", handleClick);
  };
}
