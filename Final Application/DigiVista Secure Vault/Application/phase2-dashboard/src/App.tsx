import { useEffect, useMemo, useState } from "react";
import { CategoryCard } from "./components/CategoryCard";
import { TemplateDialog } from "./components/TemplateDialog";
import { countries, experiences, thoughts } from "./data";
import type { Category, ExperienceId } from "./types";

export default function App() {
  const [experienceId, setExperienceId] = useState<ExperienceId>("professional");
  const [countryCode, setCountryCode] = useState("IN");
  const [company, setCompany] = useState("DigiVista Infotech");
  const [thoughtVisible, setThoughtVisible] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState<Category | null>(null);
  const [installPrompt, setInstallPrompt] = useState<Event | null>(null);

  useEffect(() => {
    const captureInstall = (event: Event) => {
      event.preventDefault();
      setInstallPrompt(event);
    };
    window.addEventListener("beforeinstallprompt", captureInstall);
    return () => window.removeEventListener("beforeinstallprompt", captureInstall);
  }, []);

  useEffect(() => {
    if (window.parent === window) return;

    let lastActivitySent = 0;
    const relayActivity = () => {
      const now = Date.now();
      if (now - lastActivitySent < 1_000) return;
      lastActivitySent = now;
      window.parent.postMessage({ type: "digivista-user-active" }, window.location.origin);
    };

    const activityEvents: Array<keyof WindowEventMap> = ["pointerdown", "keydown", "touchstart", "wheel"];
    activityEvents.forEach(eventName => window.addEventListener(eventName, relayActivity, { passive: true }));
    return () => activityEvents.forEach(eventName => window.removeEventListener(eventName, relayActivity));
  }, []);

  const installApp = async () => {
    if (!installPrompt) {
      window.location.href = "/dashboard/install.html";
      return;
    }
    const promptEvent = installPrompt as Event & { prompt: () => Promise<void> };
    await promptEvent.prompt();
    setInstallPrompt(null);
  };

  const experience = experiences[experienceId];
  const country = countries.find(item => item.code === countryCode) ?? countries[0];
  const dailyThought = useMemo(() => {
    const list = thoughts[experienceId];
    return list[Math.floor(Date.now() / 86_400_000) % list.length];
  }, [experienceId]);

  const openSecureRoute = (url: string, folderName?: string) => {
    if (window.parent !== window) {
      window.parent.postMessage({ type: "digivista-open-secure-route", url, folderName }, window.location.origin);
      return;
    }
    window.location.href = url;
  };

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="logo-panel"><img src="/dashboard/DigiVista_Logo.png" alt="DigiVista Infotech" /></div>
        <section className="profile-panel"><strong>{experience.label} workspace</strong><span>{company} · {country.name}</span></section>
        <nav aria-label="Primary navigation">
          <a className="active" href="/dashboard/" aria-current="page">My dashboard</a>
          <button className="nav-button" type="button" onClick={() => void installApp()}>Install mobile app</button>
          <a href="/?dv=stay#/vault" onClick={event => { if (window.parent !== window) { event.preventDefault(); openSecureRoute("/#/vault"); } }}>Secure vault</a>
          <a href="/#/reports">Security health</a>
          <a href="/help">Help & recovery</a>
          <a href="/dashboard/trust.html">Trust & policies</a>
          {experienceId === "professional" && <a href="/#/organizations">Administration</a>}
        </nav>
        <p className="trust-copy">Private by design<br />DigiVista cannot view your master password or private vault.</p>
      </aside>
      <main>
        <header className="topbar">
          <div><small>DigiVista Secure Vault</small><h1>Good morning, DigiVista Demo</h1><p>Your {experience.label.toLowerCase()} credentials, organised for {country.name}.</p></div>
          <div className="country-badge"><img src={`https://flagcdn.com/${country.code.toLowerCase()}.svg`} alt={`${country.name} flag`} /><div><strong>{country.name}</strong><span>{country.region} · {experience.label}</span></div></div>
        </header>
        <section className="selectors" aria-label="Workspace preferences">
          <label>Experience<select value={experienceId} onChange={event => { setExperienceId(event.target.value as ExperienceId); setThoughtVisible(true); }}>{Object.values(experiences).map(item => <option key={item.id} value={item.id}>{item.label}</option>)}</select></label>
          <label>Country<select value={countryCode} onChange={event => setCountryCode(event.target.value)}>{countries.map(item => <option key={item.code} value={item.code}>{item.name}</option>)}</select></label>
          <label>Company / Household<select value={company} onChange={event => setCompany(event.target.value)}><option>DigiVista Infotech</option><option>Personal workspace</option><option>Family workspace</option></select></label>
        </section>
        {thoughtVisible && <section className="daily-thought"><div><strong>Thought for today</strong> · {dailyThought}</div><button aria-label="Hide thought for today" onClick={() => setThoughtVisible(false)}>Hide</button></section>}
        <section className="summary-grid"><article className="hero"><small>Your secure workspace</small><h2>{experience.heroTitle}</h2><p>{experience.heroText}</p></article><article className="readiness"><h2>Security readiness</h2><p>● Master password protected</p><p>● Recovery kit acknowledged</p><p>● Two-step login enabled</p></article></section>
        <section className="category-section"><header><div><h2>What would you like to manage?</h2><p>Choose a clearly labelled area. You can change this view at any time.</p></div><button onClick={() => openSecureRoute("/#/vault?organizationId=unassigned&type=login&action=add")}>+ Save a credential</button></header><div className="category-grid">{experience.categories.map(category => <CategoryCard key={category.name} category={category} onOpen={setSelectedCategory} />)}</div></section>
        <footer className="page-footer"><span>DigiVista Secure Vault · Customer-controlled encrypted data</span><span>Powered by Vaultwarden · Open-source notices</span></footer>
      </main>
      <TemplateDialog category={selectedCategory} onClose={() => setSelectedCategory(null)} onOpenSecureRoute={openSecureRoute} />
    </div>
  );
}
