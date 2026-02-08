import { BrowserRouter, Routes, Route } from "react-router-dom";
import Layout from "./components/Layout";
import HomePage from "./pages/HomePage";
import EntryDetailPage from "./pages/EntryDetailPage";
import NewEntryPage from "./pages/NewEntryPage";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<HomePage />} />
          <Route path="/entries/:id" element={<EntryDetailPage />} />
          <Route path="/new" element={<NewEntryPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
