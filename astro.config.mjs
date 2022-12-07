import { defineConfig } from "astro/config";
import elm from "astro-integration-elm";
import vercel from "@astrojs/vercel/serverless";

export default defineConfig({
  integrations: [elm()],
  output: "server",
  adapter: vercel(),
});
