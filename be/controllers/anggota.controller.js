const AnggotaService = require("../services/anggota.service");

module.exports = {
  getAll: async (req, res) => {
    try {
      const list = await AnggotaService.getAll();
      res.status(200).json({ success: true, data: list });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, error: err.message });
    }
  },

  getById: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const data = await AnggotaService.getById(id);
      if (!data)
        return res
          .status(404)
          .json({ success: false, message: "Anggota tidak ditemukan" });
      res.status(200).json({ success: true, data });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, error: err.message });
    }
  },

  create: async (req, res) => {
    try {
      // minimal validation
      const { nama_anggota, alamat, no_hp } = req.body;
      if (!nama_anggota)
        return res
          .status(400)
          .json({ success: false, message: "nama_anggota wajib diisi" });

      const created = await AnggotaService.create(req.body);
      res
        .status(201)
        .json({
          success: true,
          message: "Anggota berhasil ditambahkan",
          data: created,
        });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, error: err.message });
    }
  },

  update: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const updated = await AnggotaService.update(id, req.body);
      res
        .status(200)
        .json({
          success: true,
          message: "Anggota berhasil diupdate",
          data: updated,
        });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, error: err.message });
    }
  },
};
