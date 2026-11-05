import type { Category } from "../types";

interface Props {
  category: Category;
  onOpen: (category: Category) => void;
}

export function CategoryCard({ category, onOpen }: Props) {
  return (
    <button className="category-card" onClick={() => onOpen(category)}>
      <span className="category-icon" aria-hidden="true">{category.icon}</span>
      <h3>{category.name}</h3>
      <p>{category.description}</p>
      <span className="category-link">Open guided template →</span>
    </button>
  );
}
