// routes/petugas.route.js
const express = require("express");
const router = express.Router();
const PetugasController = require("../controllers/petugas.controller");
const auth = require("../middlewares/auth");

// login tidak pakai auth
router.post("/login", PetugasController.login);

// opsional: cek profil sendiri
router.get("/me", auth, PetugasController.me);

module.exports = router;
