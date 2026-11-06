(() => {
  "use strict";

  const mode = new URLSearchParams(window.location.search).get("dv");
  let actionWasRequested = window.location.hash.includes("action=add");
  let redirectPending = false;

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

  function redirectToDashboard(reason) {
    if (redirectPending) return;
    redirectPending = true;
    window.location.replace(`/dashboard/?from=${encodeURIComponent(reason)}`);
  }

  function syncJourney() {
    hideStandardChecklist();
    const hash = window.location.hash;

    if (hash.includes("action=add")) actionWasRequested = true;
    if (mode === "stay") return;

    if (mode === "action") {
      if (actionWasRequested && /^#\/vault\/?(?:\?.*)?$/.test(hash) && !hash.includes("action=add")) {
        redirectToDashboard("credential-complete");
      }
      return;
    }

    if (/^#\/vault\/?$/.test(hash)) {
      window.setTimeout(() => redirectToDashboard("login-complete"), 350);
    }
  }

  window.addEventListener("hashchange", syncJourney);
  const observer = new MutationObserver(syncJourney);
  observer.observe(document.documentElement, { childList: true, subtree: true });
  window.setTimeout(syncJourney, 250);
  window.setTimeout(() => observer.disconnect(), 120000);
})();
