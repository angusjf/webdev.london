import { defineConfig } from "astro/config";
import elm from "astro-integration-elm";

// https://astro.build/config
export default defineConfig({ integrations: [elm()] });
