// controllers/anggota.controller.js
const AnggotaService = require("../services/anggota.service");

module.exports = {
  // GET /anggota?q=...
  getAll: async (req, res) => {
    try {
      const q = req.query.q || "";
      const data = await AnggotaService.getAll(q);
      return res.json({
        success: true,
        data,
      });
    } catch (err) {
      console.error("GET /anggota error:", err);
      return res
        .status(500)
        .json({ success: false, message: "Internal server error" });
    }
  },

  // GET /anggota/:id
  getById: async (req, res) => {
    try {
      const id = Number(req.params.id);
      const data = await AnggotaService.getById(id);

      if (!data) {
        return res
          .status(404)
          .json({ success: false, message: "Anggota tidak ditemukan" });
      }

      return res.json({
        success: true,
        data,
      });
    } catch (err) {
      console.error("GET /anggota/:id error:", err);
      return res
        .status(500)
        .json({ success: false, message: "Internal server error" });
    }
  },

  // POST /anggota
  create: async (req, res) => {
    try {
      const payload = {
        nis: req.body.nis, // bisa null/undefined
        nama_anggota: req.body.nama_anggota,
        alamat: req.body.alamat,
        no_hp: req.body.no_hp,
      };

      const data = await AnggotaService.create(payload);

      return res.status(201).json({
        success: true,
        message: "Anggota berhasil ditambahkan",
        data,
      });
    } catch (err) {
      console.error("POST /anggota error:", err);
      return res
        .status(500)
        .json({ success: false, message: "Internal server error" });
    }
  },

  // PUT /anggota/:id
  update: async (req, res) => {
    try {
      const id = Number(req.params.id);
      const payload = {
        nis: req.body.nis,
        nama_anggota: req.body.nama_anggota,
        alamat: req.body.alamat,
        no_hp: req.body.no_hp,
      };

      const data = await AnggotaService.update(id, payload);

      return res.json({
        success: true,
        message: "Anggota berhasil diperbarui",
        data,
      });
    } catch (err) {
      console.error("PUT /anggota/:id error:", err);
      return res
        .status(500)
        .json({ success: false, message: "Internal server error" });
    }
  },

  // DELETE /anggota/:id
  remove: async (req, res) => {
    try {
      const id = Number(req.params.id);
      await AnggotaService.remove(id);

      return res.json({
        success: true,
        message: "Anggota berhasil dihapus",
      });
    } catch (err) {
      if (err.message === "ANGGOTA_PUNYA_PEMINJAMAN") {
        return res.status(400).json({
          success: false,
          message: "Anggota tidak bisa dihapus karena pernah meminjam buku",
        });
      }

      return res.status(500).json({
        success: false,
        message: "Internal server error",
      });
    }
  },
};
