const BukuService = require("../services/buku.service");

module.exports = {
  getAll: async (req, res) => {
    try {
      const data = await BukuService.getAll();
      res.status(200).json({ success: true, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  },

  getById: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const data = await BukuService.getById(id);

      if (!data)
        return res
          .status(404)
          .json({ success: false, message: "Buku tidak ditemukan" });

      res.status(200).json({ success: true, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  },

  create: async (req, res) => {
    try {
      const data = await BukuService.create(req.body);
      res
        .status(201)
        .json({ success: true, message: "Buku berhasil ditambahkan", data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  },

  update: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const data = await BukuService.update(id, req.body);
      res
        .status(200)
        .json({ success: true, message: "Buku berhasil diupdate", data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  },

  remove: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      await BukuService.remove(id);
      res.status(200).json({ success: true, message: "Buku berhasil dihapus" });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  },
};
