// Import dependencies
const express = require("express");
const fs = require("fs");
const YAML = require("yaml");
const swaggerUi = require("swagger-ui-express");

// Inisialisasi express app
const app = express();
const port = 3000;

// Middleware body JSON (WAJIB)
app.use(express.json());

// Register Routes
app.use("/buku", require("./routes/buku.route"));
// nanti bisa tambah:
app.use("/petugas", require("./routes/petugas.route"));
app.use("/anggota", require("./routes/anggota.route"));

// app.use("/peminjaman", require("./routes/peminjaman.route"));

// Baca file YAML (pastikan file doc.yaml ada di folder yang sama)
const file = fs.readFileSync("./doc.yaml", "utf-8");
const swaggerDocument = YAML.parse(file);

// Setup Swagger UI di endpoint /api-docs
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// Jalankan server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
