import type { Country, Experience, ExperienceId } from "./types";

const loginFields = ["Record title", "Website or source URL", "Username or email", "Password", "Notes", "Review date"];

export const countries: Country[] = [
  { code: "IN", name: "India", region: "APAC" },
  { code: "PK", name: "Pakistan", region: "APAC" },
  { code: "BD", name: "Bangladesh", region: "APAC" },
  { code: "US", name: "United States", region: "Americas" },
  { code: "GB", name: "United Kingdom", region: "Europe" },
  { code: "DE", name: "Germany", region: "Europe" },
  { code: "AE", name: "United Arab Emirates", region: "Middle East" },
  { code: "SG", name: "Singapore", region: "APAC" }
];

export const experiences: Record<ExperienceId, Experience> = {
  professional: {
    id: "professional",
    label: "Professional / Business",
    heroTitle: "Everything important, in the right place.",
    heroText: "Your role-based workspace shows only the business areas you are authorised to use.",
    categories: [
      { icon: "🌐", name: "Websites & Apps", description: "Customer portals, cloud services and business applications.", recordType: "login", fields: loginFields },
      { icon: "🖥️", name: "Desktop & Laptop", description: "Workstation, laptop and local administrator credentials.", recordType: "login", fields: ["Device name", "Asset tag", "Owner/company", "Country/site", "Hostname or IP", "Username", "Password or recovery key", "Review date"] },
      { icon: "🗄️", name: "Servers & Infrastructure", description: "Server, hosting, database and infrastructure access.", recordType: "login", fields: ["Server/service name", "Environment", "Country/site", "Hostname or IP", "Protocol/port", "Username", "Password or SSH key reference", "Rotation date"] },
      { icon: "📡", name: "Network Devices", description: "Routers, switches, wireless and site devices.", recordType: "login", fields: ["Device name", "Vendor/model", "Country/site", "Management IP", "Management URL", "Username", "Password", "Responsible team", "Rotation date"] },
      { icon: "🛡️", name: "Security Appliances", description: "Firewall, NVR, VPN and security-platform access.", recordType: "login", fields: ["Appliance name", "Vendor/model", "Country/site", "Management address", "Username", "Password", "Support portal", "Owner", "Review date"] },
      { icon: "📋", name: "Compliance & Licences", description: "Licences, recovery codes and controlled compliance notes.", recordType: "note", fields: ["Record title", "Licence/reference", "Source URL", "Owner", "Effective date", "Expiry/review date", "Controlled notes"] },
      { icon: "👤", name: "Personal workspace", description: "Private items visible only to you.", recordType: "note", fields: ["Title", "Encrypted content", "Optional tags"] },
      { icon: "🔑", name: "SSH & Technical Keys", description: "Secure server keys and technical access.", recordType: "ssh-key", fields: ["Key name", "Server/service", "Username", "Private/public key", "Fingerprint", "Owner", "Rotation date"] }
    ]
  },
  home: {
    id: "home",
    label: "Home / Individual",
    heroTitle: "Your digital life, calmly organised.",
    heroText: "Only everyday personal categories are shown—simple, private and easy to find.",
    categories: [
      { icon: "🌍", name: "Websites & Apps", description: "Everyday websites, subscriptions and applications.", recordType: "login", fields: loginFields },
      { icon: "💳", name: "Banking & Payments", description: "Payment accounts and important financial references.", recordType: "card", fields: ["Institution/card name", "Official URL", "Customer identifier", "Masked last four digits", "Dedicated card fields", "Support reference", "Private notes"] },
      { icon: "📱", name: "Phones & Devices", description: "Phones, tablets, computers and home devices.", recordType: "login", fields: ["Device name", "Owner", "Username", "Password/recovery key", "Support URL", "Notes"] },
      { icon: "📶", name: "Home Wi-Fi & VPN", description: "Wi-Fi, router and private network access.", recordType: "login", fields: ["Network name", "Router URL/IP", "Username", "Password", "VPN details", "Notes"] },
      { icon: "🪪", name: "Personal identity", description: "Identity details for safe form filling.", recordType: "identity", fields: ["Name", "Contact details", "Address", "Only required identity details"] },
      { icon: "📝", name: "Private Journal & Goals", description: "Private thoughts, milestones and life goals.", recordType: "note", fields: ["Title", "Entry date", "Theme", "Encrypted reflection or goal", "Target date", "Milestones", "Optional tags"] },
      { icon: "🧰", name: "Recovery kit", description: "Backup, trusted-contact and recovery guidance.", recordType: "note", fields: ["Recovery instructions", "Trusted contact reference", "Offline backup reference", "Last backup date", "Last restore-test date"] }
    ]
  },
  teen: {
    id: "teen",
    label: "Teen",
    heroTitle: "Your accounts, your privacy.",
    heroText: "A modern, uncluttered space with helpful security guidance.",
    categories: [
      { icon: "💬", name: "Social & Apps", description: "Social, messaging and everyday applications.", recordType: "login", fields: loginFields },
      { icon: "🎓", name: "School", description: "Learning platforms and school accounts.", recordType: "login", fields: loginFields },
      { icon: "🎮", name: "Gaming", description: "Game accounts and online profiles.", recordType: "login", fields: loginFields },
      { icon: "📱", name: "My devices", description: "Phone, laptop and personal devices.", recordType: "login", fields: loginFields },
      { icon: "🔐", name: "Personal", description: "Private accounts and recovery details.", recordType: "note", fields: ["Title", "Encrypted content", "Optional tags"] },
      { icon: "📝", name: "Private Journal & Goals", description: "Thoughts and goals private by default.", recordType: "note", fields: ["Title", "Entry date", "Encrypted reflection or goal", "Optional tags"] }
    ]
  },
  family: {
    id: "family",
    label: "Family / Child",
    heroTitle: "Your safe digital space.",
    heroText: "A guardian-managed view with only a few friendly, easy choices.",
    categories: [
      { icon: "🎮", name: "Games & Apps", description: "Approved games and applications.", recordType: "login", fields: loginFields },
      { icon: "📚", name: "School", description: "School and learning accounts.", recordType: "login", fields: loginFields },
      { icon: "🧸", name: "Family devices", description: "Shared tablets, devices and family services.", recordType: "login", fields: loginFields },
      { icon: "📝", name: "Safe notes", description: "Private notes with age-appropriate safety guidance.", recordType: "note", fields: ["Title", "Encrypted note"] }
    ]
  }
};

export const thoughts: Record<ExperienceId, string[]> = {
  professional: ["Protect the essentials, then make progress with confidence.", "Clear access and ownership create trusted work.", "Small security habits prevent large disruptions."],
  home: ["A calm digital space creates room for what matters.", "Protect today’s essentials and tomorrow feels lighter.", "Small, consistent steps build lasting confidence."],
  teen: ["Your privacy matters; protect it with choices you understand.", "Progress is built one thoughtful step at a time.", "Strong choices today create more freedom tomorrow."],
  family: ["Be curious, be kind and ask for help when you need it.", "Every small step is something to be proud of.", "Learning safely makes every adventure better."]
};
