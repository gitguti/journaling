import { useState } from "react";
import { useTranslation } from "react-i18next";
import { api, getErrorKey } from "../api/client";
import type { EntryOut, TagOut } from "../types";

interface TagEditorModalProps {
  entryId: string;
  currentTags: string[];
  allTags: TagOut[];
  onClose: () => void;
  onSaved: (entry: EntryOut) => void;
}

export default function TagEditorModal({
  entryId,
  currentTags,
  allTags,
  onClose,
  onSaved,
}: TagEditorModalProps) {
  const { t } = useTranslation();
  const [selected, setSelected] = useState<Set<string>>(
    new Set(currentTags)
  );
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const toggle = (name: string) => {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(name)) {
        next.delete(name);
      } else {
        next.add(name);
      }
      return next;
    });
  };

  const save = async () => {
    setSaving(true);
    setError(null);
    try {
      const updated = await api.updateTags(entryId, Array.from(selected));
      onSaved(updated);
    } catch (err) {
      setError(getErrorKey(err));
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h3>{t("edit_tags")}</h3>
          <button className="modal-close" onClick={onClose}>
            ✕
          </button>
        </div>

        <ul className="tag-editor-list">
          {allTags.map((tag) => (
            <li key={tag.id}>
              <button
                className={`tag-editor-row ${selected.has(tag.name) ? "selected" : ""}`}
                onClick={() => toggle(tag.name)}
              >
                <span
                  className="tag-dot"
                  style={{ backgroundColor: tag.color }}
                />
                <span className="tag-name">{tag.name}</span>
                {selected.has(tag.name) && (
                  <span className="tag-check">✓</span>
                )}
              </button>
            </li>
          ))}
        </ul>

        {error && (
          <p className="error-message" style={{ padding: "0 20px" }}>
            {t(error)}
          </p>
        )}

        <div className="modal-actions">
          <button className="btn-secondary" onClick={onClose}>
            {t("cancel")}
          </button>
          <button className="btn-primary" onClick={save} disabled={saving}>
            {saving ? t("saving") : t("save")}
          </button>
        </div>
      </div>
    </div>
  );
}
