(() => {
  "use strict";

  const searchParams = new URLSearchParams(window.location.search);
  const mode = searchParams.get("dv");
  let requestedFolder = searchParams.get("dvFolder");
  let actionWasRequested = window.location.hash.includes("action=add");
  let redirectPending = false;
  let folderApplied = false;
  let dashboardFrame = null;

  function showDashboard() {
    if (dashboardFrame?.isConnected) {
      dashboardFrame.hidden = false;
      return;
    }

    dashboardFrame = document.createElement("iframe");
    dashboardFrame.id = "digivista-dashboard-frame";
    dashboardFrame.title = "DigiVista Secure Vault dashboard";
    dashboardFrame.src = "/dashboard/?embedded=1";
    dashboardFrame.style.cssText = "position:fixed;inset:0;width:100%;height:100%;border:0;background:#f4f8fc;z-index:2147483000";
    document.body.appendChild(dashboardFrame);
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

    if (hash.includes("action=add")) {
      actionWasRequested = true;
      hideDashboard();
    }
    if (mode === "stay") return;

    if (mode === "action") {
      if (actionWasRequested && /^#\/vault\/?(?:\?.*)?$/.test(hash) && !hash.includes("action=add")) {
        redirectToDashboard();
      }
      return;
    }

    if (/^#\/vault\/?$/.test(hash)) {
      window.setTimeout(() => redirectToDashboard(), 350);
    }
  }

  window.addEventListener("message", event => {
    if (event.origin !== window.location.origin || event.data?.type !== "digivista-open-secure-route") return;
    const target = new URL(event.data.url, window.location.origin);
    requestedFolder = typeof event.data.folderName === "string" ? event.data.folderName : null;
    folderApplied = false;
    actionWasRequested = target.hash.includes("action=add");
    hideDashboard();
    window.location.hash = target.hash;
  });

  window.addEventListener("hashchange", syncJourney);
  const observer = new MutationObserver(syncJourney);
  observer.observe(document.documentElement, { childList: true, subtree: true });
  window.setTimeout(syncJourney, 250);
  window.setTimeout(() => observer.disconnect(), 120000);
})();
