import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";
import { api, getErrorKey } from "../api/client";
import TagChip from "../components/TagChip";
import type { EntryListItem, TagOut } from "../types";

export default function HomePage() {
  const { t } = useTranslation();
  const [entries, setEntries] = useState<EntryListItem[]>([]);
  const [tags, setTags] = useState<TagOut[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const [e, tg] = await Promise.all([api.listEntries(), api.listTags()]);
      setEntries(e);
      setTags(tg);
    } catch (err) {
      setError(getErrorKey(err));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const tagColor = (name: string) =>
    tags.find((t) => t.name === name)?.color ?? "#888888";

  const formatDate = (iso: string) =>
    new Date(iso).toLocaleDateString(undefined, {
      year: "numeric",
      month: "long",
      day: "numeric",
    });

  if (loading) {
    return (
      <div className="page center">
        <p>{t("loading")}</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="page center">
        <div className="error-state">
          <p className="error-message">{t(error)}</p>
          <button className="btn-primary" onClick={load}>
            {t("retry")}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="page home-page">
      <div className="home-toolbar">
        <h2>{t("home_title")}</h2>
        <div className="home-actions">
          <button className="icon-btn" onClick={load} title="Refresh">
            ↻
          </button>
          <Link to="/new" className="fab" title={t("new_entry")}>
            +
          </Link>
        </div>
      </div>

      {entries.length === 0 ? (
        <div className="empty-state">
          <p className="empty-title">{t("no_entries")}</p>
          <p className="hint">{t("no_entries_hint")}</p>
        </div>
      ) : (
        <ul className="entry-list">
          {entries.map((entry) => (
            <li key={entry.id}>
              <Link to={`/entries/${entry.id}`} className="entry-row">
                <span className="entry-title">{entry.title}</span>
                <span className="entry-preview">{entry.preview}</span>
                {entry.tags.length > 0 && (
                  <span className="entry-tags">
                    {entry.tags.map((tag) => (
                      <TagChip key={tag} name={tag} color={tagColor(tag)} />
                    ))}
                  </span>
                )}
                <span className="entry-date">{formatDate(entry.date)}</span>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
