// prisma.config.ts
import "dotenv/config";
import { defineConfig, env } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  // Pastikan Anda menggunakan env("DATABASE_URL") di sini
  datasource: {
    url: env("DATABASE_URL"),
  },
});
