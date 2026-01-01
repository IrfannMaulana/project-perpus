// controllers/petugas.controller.js
const PetugasService = require("../services/petugas.service");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs"); // kita pakai bcryptjs
const SECRET = process.env.JWT_SECRET || "secret_default";

module.exports = {
  // POST /petugas/login
  login: async (req, res) => {
    try {
      const { username, password } = req.body || {};

      if (!username || !password) {
        return res
          .status(400)
          .json({ success: false, message: "Username & password wajib" });
      }

      const petugas = await PetugasService.findByUsername(username);

      if (!petugas) {
        return res
          .status(401)
          .json({ success: false, message: "Username atau password salah" });
      }

      // bcryptjs: pakai compareSync supaya simpel
      const match = bcrypt.compareSync(password, petugas.password);
      if (!match) {
        return res
          .status(401)
          .json({ success: false, message: "Username atau password salah" });
      }

      const token = jwt.sign(
        {
          id_petugas: petugas.id_petugas,
          username: petugas.username,
        },
        SECRET,
        { expiresIn: "1d" }
      );

      return res.json({
        success: true,
        message: "Login berhasil",
        token,
        data: {
          id_petugas: petugas.id_petugas,
          nama_petugas: petugas.nama_petugas,
          username: petugas.username,
        },
      });
    } catch (err) {
      console.error("POST /petugas/login error:", err);
      return res
        .status(500)
        .json({ success: false, message: "Internal server error" });
    }
  },

  // OPSIONAL: GET /petugas/me (butuh auth)
  me: async (req, res) => {
    try {
      if (!req.user) {
        return res.status(401).json({ success: false, message: "Belum login" });
      }

      const petugas = req.user;

      return res.json({
        success: true,
        data: {
          id_petugas: petugas.id_petugas,
          nama_petugas: petugas.nama_petugas,
          username: petugas.username,
        },
      });
    } catch (err) {
      console.error("GET /petugas/me error:", err);
      return res
        .status(500)
        .json({ success: false, message: "Internal server error" });
    }
  },
};
