(() => {
  "use strict";

  const searchParams = new URLSearchParams(window.location.search);
  const mode = searchParams.get("dv");
  const pendingRouteKey = "digivista-pending-secure-route";
  let requestedFolder = searchParams.get("dvFolder");
  let actionWasRequested = window.location.hash.includes("action=add");
  let redirectPending = false;
  let folderApplied = false;
  let dashboardFrame = null;
  let pendingClearTimer = null;

  function getPendingSecureRoute() {
    const value = window.sessionStorage.getItem(pendingRouteKey);
    return value?.startsWith("#/vault") && value.includes("action=add") ? value : null;
  }

  function rememberPendingSecureRoute(hash) {
    if (hash?.startsWith("#/vault") && hash.includes("action=add")) {
      window.sessionStorage.setItem(pendingRouteKey, hash);
    }
  }

  function clearPendingRouteWhenFormIsReady() {
    window.clearTimeout(pendingClearTimer);
    pendingClearTimer = window.setTimeout(() => {
      if (!window.location.hash.includes("action=add")) return;
      const hasFormAction = [...document.querySelectorAll("button")].some(button =>
        /^(save|cancel)$/i.test(button.textContent?.trim() ?? "")
      );
      if (hasFormAction) window.sessionStorage.removeItem(pendingRouteKey);
    }, 800);
  }

  function prepareDashboard() {
    if (dashboardFrame?.isConnected) {
      return dashboardFrame;
    }

    dashboardFrame = document.createElement("iframe");
    dashboardFrame.id = "digivista-dashboard-frame";
    dashboardFrame.title = "DigiVista Secure Vault dashboard";
    dashboardFrame.src = "/dashboard/?embedded=1";
    dashboardFrame.style.cssText = "position:fixed;inset:0;width:100%;height:100%;border:0;background:#f4f8fc;z-index:2147483000";
    dashboardFrame.hidden = true;
    document.body.appendChild(dashboardFrame);
    return dashboardFrame;
  }

  function showDashboard() {
    prepareDashboard().hidden = false;
  }

  function hideDashboard() {
    if (dashboardFrame) dashboardFrame.hidden = true;
  }

  function hideStandardChecklist() {
    const dismiss = [...document.querySelectorAll("button, a")].find(element =>
      element.textContent?.trim().toLowerCase().includes("dismiss this checklist")
    );
    if (!dismiss) return;

    let panel = dismiss.parentElement;
    for (let depth = 0; panel && depth < 8; depth += 1, panel = panel.parentElement) {
      const text = panel.textContent ?? "";
      if (text.includes("Get started with your vault") && text.includes("Import your passwords")) {
        panel.style.display = "none";
        panel.setAttribute("aria-hidden", "true");
        return;
      }
    }
  }

  function redirectToDashboard() {
    if (redirectPending) return;
    redirectPending = true;
    showDashboard();
    window.setTimeout(() => { redirectPending = false; }, 250);
  }

  function applyRequestedFolder() {
    if (!requestedFolder || folderApplied || !window.location.hash.includes("action=add")) return;

    const wanted = requestedFolder.trim().toLowerCase();
    const folderLink = [...document.querySelectorAll('a[href*="folderId="]')].find(link =>
      (link.textContent ?? "").trim().toLowerCase() === wanted
    );
    if (!folderLink) return;

    const match = (folderLink.getAttribute("href") ?? "").match(/[?&]folderId=([^&]+)/);
    if (!match?.[1] || match[1] === "unassigned") return;

    const [route, rawQuery = ""] = window.location.hash.slice(1).split("?");
    const hashParams = new URLSearchParams(rawQuery);
    if (hashParams.get("folderId") === match[1]) {
      folderApplied = true;
      return;
    }

    hashParams.set("folderId", match[1]);
    folderApplied = true;
    window.location.replace(`${window.location.pathname}${window.location.search}#${route}?${hashParams.toString()}`);
  }

  function syncJourney() {
    hideStandardChecklist();
    applyRequestedFolder();
    const hash = window.location.hash;

    // Vaultwarden shows its browser-extension onboarding route after a user's
    // first successful sign-in/unlock. DigiVista has its own guided dashboard,
    // so keep the Vaultwarden SPA (and its unlocked encryption key) alive while
    // skipping only this optional onboarding screen.
    if (/^#\/setup-extension\/?(?:\?.*)?$/.test(hash)) {
      hideDashboard();
      const destination = getPendingSecureRoute() ?? "#/vault";
      window.location.replace(`${window.location.pathname}${window.location.search}${destination}`);
      return;
    }

    if (hash.includes("action=add")) {
      actionWasRequested = true;
      hideDashboard();
      clearPendingRouteWhenFormIsReady();
    }
    if (mode === "stay") return;

    if (mode === "action") {
      if (/^#\/vault\/?(?:\?.*)?$/.test(hash) && !hash.includes("action=add")) {
        redirectToDashboard();
      }
      return;
    }

    if (/^#\/vault\/?$/.test(hash)) {
      const pendingRoute = getPendingSecureRoute();
      if (pendingRoute) {
        hideDashboard();
        window.location.hash = pendingRoute;
        return;
      }
      redirectToDashboard();
    }
  }

  window.addEventListener("message", event => {
    if (event.origin !== window.location.origin || event.data?.type !== "digivista-open-secure-route") return;
    const target = new URL(event.data.url, window.location.origin);
    requestedFolder = typeof event.data.folderName === "string" ? event.data.folderName : null;
    folderApplied = false;
    actionWasRequested = target.hash.includes("action=add");
    rememberPendingSecureRoute(target.hash);
    hideDashboard();
    window.location.hash = target.hash;
  });

  window.addEventListener("hashchange", syncJourney);
  const observer = new MutationObserver(syncJourney);
  observer.observe(document.documentElement, { childList: true, subtree: true });
  prepareDashboard();
  window.setTimeout(syncJourney, 250);
  window.setTimeout(() => observer.disconnect(), 120000);
})();
