import { useEffect, useRef } from "react";
import type { Category } from "../types";

interface Props {
  category: Category | null;
  onClose: () => void;
}

export function TemplateDialog({ category, onClose }: Props) {
  const dialogRef = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog) return;
    if (category && !dialog.open) dialog.showModal();
    if (!category && dialog.open) dialog.close();
  }, [category]);

  if (!category) return <dialog ref={dialogRef} />;

  const secureUrl = `/?dv=action#/vault?organizationId=unassigned&type=${category.recordType}&action=add`;

  return (
    <dialog ref={dialogRef} className="template-dialog" onClose={onClose}>
      <header>
        <div><small>Guided secure template</small><h2>{category.name}</h2></div>
        <button aria-label="Close template" onClick={onClose}>×</button>
      </header>
      <div className="template-content">
        <p>Use the <strong>{category.recordType}</strong> record type and select the matching category folder.</p>
        <h3>Recommended information</h3>
        <ul>{category.fields.map(field => <li key={field}>{field}</li>)}</ul>
        <p className="privacy-note"><strong>Privacy:</strong> Information is entered and encrypted in Vaultwarden. This dashboard does not store a second copy.</p>
      </div>
      <footer>
        <button onClick={onClose}>Cancel</button>
        <a href={secureUrl}>Continue in secure vault →</a>
      </footer>
    </dialog>
  );
}
