import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { Link, useParams } from "react-router-dom";
import { api, getErrorKey } from "../api/client";
import TagChip from "../components/TagChip";
import TagEditorModal from "../components/TagEditorModal";
import type { EntryOut, TagOut } from "../types";

export default function EntryDetailPage() {
  const { t } = useTranslation();
  const { id } = useParams<{ id: string }>();
  const [entry, setEntry] = useState<EntryOut | null>(null);
  const [tags, setTags] = useState<TagOut[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showTagEditor, setShowTagEditor] = useState(false);

  const load = () => {
    if (!id) return;
    setLoading(true);
    setError(null);
    Promise.all([api.getEntry(id), api.listTags()])
      .then(([e, tg]) => {
        setEntry(e);
        setTags(tg);
      })
      .catch((err) => setError(getErrorKey(err)))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    load();
  }, [id]);

  const tagColor = (name: string) =>
    tags.find((t) => t.name === name)?.color ?? "#888888";

  const formatDate = (iso: string) =>
    new Date(iso).toLocaleDateString(undefined, {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });

  if (loading) {
    return (
      <div className="page center">
        <p>{t("loading")}</p>
      </div>
    );
  }

  if (error || !entry) {
    return (
      <div className="page">
        <Link to="/" className="back-link">
          ← {t("home_title")}
        </Link>
        <div className="error-state">
          <p className="error-message">{t(error ?? "error_load")}</p>
          <button className="btn-primary" onClick={load}>
            {t("retry")}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="page entry-detail-page">
      <Link to="/" className="back-link">
        ← {t("home_title")}
      </Link>

      <h2 className="detail-title">{entry.title}</h2>

      <p className="detail-date">{formatDate(entry.date)}</p>

      {entry.tags.length > 0 && (
        <div className="detail-tags">
          {entry.tags.map((tag) => (
            <TagChip key={tag} name={tag} color={tagColor(tag)} />
          ))}
        </div>
      )}

      <button
        className="edit-tags-btn"
        onClick={() => setShowTagEditor(true)}
      >
        {t("edit_tags")}
      </button>

      <section className="detail-section">
        <h3>{t("question_1_label")}</h3>
        <p>{entry.question_1}</p>
      </section>

      <section className="detail-section">
        <h3>{t("question_2_label")}</h3>
        <p>{entry.question_2}</p>
      </section>

      <div className="detail-meta">
        <span>
          {t("created")}: {formatDate(entry.created_at)}
        </span>
        <span>
          {t("updated")}: {formatDate(entry.updated_at)}
        </span>
      </div>

      {showTagEditor && (
        <TagEditorModal
          entryId={entry.id}
          currentTags={entry.tags}
          allTags={tags}
          onClose={() => setShowTagEditor(false)}
          onSaved={(updated) => {
            setEntry(updated);
            setShowTagEditor(false);
          }}
        />
      )}
    </div>
  );
}
