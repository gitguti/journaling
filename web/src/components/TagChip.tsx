interface TagChipProps {
  name: string;
  color: string;
}

export default function TagChip({ name, color }: TagChipProps) {
  return (
    <span
      className="tag-chip"
      style={{
        backgroundColor: `${color}1F`,
        color: color,
        border: `1px solid ${color}33`,
      }}
    >
      {name}
    </span>
  );
}
