import { useTranslation } from "react-i18next";

export default function LanguageToggle() {
  const { i18n } = useTranslation();
  const current = i18n.language;

  const toggle = () => {
    i18n.changeLanguage(current === "es" ? "en" : "es");
  };

  return (
    <button className="lang-toggle" onClick={toggle}>
      {current === "es" ? "EN" : "ES"}
    </button>
  );
}
