import { defineConfig } from "astro/config";
import elm from "astro-integration-elm";

export default defineConfig({
  integrations: [elm()],
});
