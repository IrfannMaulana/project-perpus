const express = require("express");
const router = express.Router();
const PetugasController = require("../controllers/petugas.controller");

// login endpoint (public)
router.post("/login", PetugasController.login);

module.exports = router;
