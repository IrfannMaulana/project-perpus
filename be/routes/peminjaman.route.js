const express = require("express");
const router = express.Router();
const PeminjamanController = require("../controllers/peminjaman.controller");
const auth = require("../middlewares/auth");

// Semua endpoint dilindungi auth
router.use(auth);

// Buat peminjaman baru
router.post("/", PeminjamanController.create);

// Kembalikan buku — hanya endpoint yang direkomendasikan
// PUT /peminjaman/:id/return
router.put("/:id/return", PeminjamanController.markReturn);

//edit buku/anggota peminjaman
router.put("/:id", PeminjamanController.edit);

// Ambil semua peminjaman
router.get("/", PeminjamanController.getAll);

// Ambil peminjaman berdasarkan ID
router.get("/:id", PeminjamanController.getById);

module.exports = router;
