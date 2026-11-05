export type ExperienceId = "professional" | "home" | "teen" | "family";

export type RecordType = "login" | "card" | "identity" | "note" | "ssh-key";

export interface Country {
  code: string;
  name: string;
  region: string;
}

export interface Category {
  icon: string;
  name: string;
  description: string;
  recordType: RecordType;
  fields: string[];
}

export interface Experience {
  id: ExperienceId;
  label: string;
  heroTitle: string;
  heroText: string;
  categories: Category[];
}
