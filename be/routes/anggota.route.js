const express = require("express");
const router = express.Router();
const AnggotaController = require("../controllers/anggota.controller");
const auth = require("../middlewares/auth"); // <-- pastikan file ini ada

// GET /anggota (public)
router.get("/", AnggotaController.getAll);

// GET /anggota/:id (public)
router.get("/:id", AnggotaController.getById);

// POST /anggota (protected)
router.post("/", auth, AnggotaController.create);

// PUT /anggota/:id (protected)
router.put("/:id", auth, AnggotaController.update);

// NOTE: tidak ada route DELETE fisik (sesuai keputusan Anda).

module.exports = router;
