const BukuService = require("../services/buku.service");

module.exports = {
  getAll: async (req, res) => {
    try {
      const q = req.query.q || "";
      const page = req.query.page || 1;
      const limit = req.query.limit || 20;

      const result = await BukuService.getAll({ q, page, limit });
      return res.status(200).json({ success: true, ...result });
    } catch (err) {
      console.error("GET /buku error:", err);
      return res.status(500).json({ success: false, error: err.message });
    }
  },

  getById: async (req, res) => {
    try {
      const id = Number(req.params.id);
      if (!Number.isInteger(id))
        return res
          .status(400)
          .json({ success: false, message: "ID tidak valid" });

      const data = await BukuService.getById(id);
      if (!data)
        return res
          .status(404)
          .json({ success: false, message: "Buku tidak ditemukan" });

      return res.status(200).json({ success: true, data });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ success: false, error: err.message });
    }
  },

  create: async (req, res) => {
    try {
      const payload = {
        judul: req.body.judul,
        pengarang: req.body.pengarang,
        penerbit: req.body.penerbit,
        tahun_terbit: Number(req.body.tahun_terbit),
        kategori: req.body.kategori,
      };
      const data = await BukuService.create(payload);
      return res
        .status(201)
        .json({ success: true, message: "Buku berhasil ditambahkan", data });
    } catch (err) {
      console.error(err);
      return res.status(400).json({ success: false, message: err.message });
    }
  },

  update: async (req, res) => {
    try {
      const id = Number(req.params.id);
      const payload = {
        judul: req.body.judul,
        pengarang: req.body.pengarang,
        penerbit: req.body.penerbit,
        tahun_terbit: Number(req.body.tahun_terbit),
        kategori: req.body.kategori,
      };
      const data = await BukuService.update(id, payload);
      return res
        .status(200)
        .json({ success: true, message: "Buku berhasil diupdate", data });
    } catch (err) {
      console.error(err);
      return res.status(400).json({ success: false, message: err.message });
    }
  },

  remove: async (req, res) => {
    try {
      const id = Number(req.params.id);
      await BukuService.remove(id);
      return res
        .status(200)
        .json({ success: true, message: "Buku berhasil dihapus" });
    } catch (err) {
      console.error(err);
      return res.status(400).json({ success: false, message: err.message });
    }
  },
  edit: async (req, res) => {
    try {
      const id = Number(req.params.id);
      const { id_anggota, id_buku, tanggal_pinjam } = req.body;

      const updated = await PeminjamanService.editActive(id, {
        id_anggota: id_anggota ? Number(id_anggota) : undefined,
        id_buku: id_buku ? Number(id_buku) : undefined,
        tanggal_pinjam,
      });

      res.json({
        success: true,
        message: "Peminjaman diperbarui",
        data: updated,
      });
    } catch (err) {
      res.status(400).json({
        success: false,
        message: err.message,
      });
    }
  },
};
