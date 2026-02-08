import { useState } from "react";
import { useTranslation } from "react-i18next";
import { Link, useNavigate } from "react-router-dom";
import { api, getErrorKey } from "../api/client";

export default function NewEntryPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [q1, setQ1] = useState("");
  const [q2, setQ2] = useState("");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const canSave = q1.trim() !== "" || q2.trim() !== "";

  const handleSave = async () => {
    if (!canSave) return;
    setSaving(true);
    setError(null);
    try {
      await api.createEntry({ question_1: q1, question_2: q2 });
      navigate("/");
    } catch (err) {
      setError(getErrorKey(err));
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="page new-entry-page">
      <Link to="/" className="back-link">
        ← {t("cancel")}
      </Link>

      <h2 className="form-title">{t("new_entry")}</h2>

      <div className="form-group">
        <label htmlFor="q1">{t("question_1_label")}</label>
        <textarea
          id="q1"
          value={q1}
          onChange={(e) => setQ1(e.target.value)}
          placeholder={t("question_1_label")}
          rows={5}
          disabled={saving}
        />
      </div>

      <div className="form-group">
        <label htmlFor="q2">{t("question_2_label")}</label>
        <textarea
          id="q2"
          value={q2}
          onChange={(e) => setQ2(e.target.value)}
          placeholder={t("question_2_label")}
          rows={5}
          disabled={saving}
        />
      </div>

      {error && <p className="error-message">{t(error)}</p>}

      <div className="form-actions">
        <Link to="/" className="btn-secondary">
          {t("cancel")}
        </Link>
        <button
          className="btn-primary"
          onClick={handleSave}
          disabled={!canSave || saving}
        >
          {saving ? t("saving") : t("save")}
        </button>
      </div>
    </div>
  );
}
