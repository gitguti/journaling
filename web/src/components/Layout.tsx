import { useTranslation } from "react-i18next";
import { Outlet } from "react-router-dom";
import LanguageToggle from "./LanguageToggle";

export default function Layout() {
  const { t } = useTranslation();

  return (
    <div className="app-layout">
      <header className="app-header">
        <h1>{t("app_title")}</h1>
        <LanguageToggle />
      </header>
      <main className="app-main">
        <Outlet />
      </main>
    </div>
  );
}
