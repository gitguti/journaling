import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { VitePWA } from "vite-plugin-pwa";

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: "autoUpdate",
      includeAssets: ["icons/*.png"],
      manifest: {
        name: "Mi Diario de Aprendizaje",
        short_name: "Mi Diario",
        description: "Learning Journal PWA",
        theme_color: "#3962E0",
        background_color: "#ffffff",
        display: "standalone",
        start_url: "/",
        icons: [
          { src: "icons/icon-192.png", sizes: "192x192", type: "image/png" },
          { src: "icons/icon-512.png", sizes: "512x512", type: "image/png" },
        ],
      },
      workbox: {
        runtimeCaching: [
          {
            urlPattern: /\/entries/,
            handler: "NetworkFirst",
            options: { cacheName: "api-entries" },
          },
          {
            urlPattern: /\/tags/,
            handler: "StaleWhileRevalidate",
            options: { cacheName: "api-tags" },
          },
        ],
      },
    }),
  ],
});
