const express = require("express");
const router = express.Router();
const BukuController = require("../controllers/buku.controller");
const auth = require("../middlewares/auth"); // <-- pastikan file ini ada

// READ (public)
router.get("/", BukuController.getAll);
router.get("/:id", BukuController.getById);

// WRITE (protected)
router.post("/", auth, BukuController.create);
router.put("/:id", auth, BukuController.update);
router.delete("/:id", auth, BukuController.remove);

module.exports = router;
