const PeminjamanService = require("../services/peminjaman.service");

module.exports = {
  getAll: async (req, res) => {
    try {
      const { status, id_anggota, id_buku, bulan, tahun, start, end } =
        req.query;

      const list = await PeminjamanService.getAll({
        status,
        id_anggota,
        id_buku,
        bulan,
        tahun,
        start,
        end,
      });

      res.status(200).json({ success: true, data: list });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, error: err.message });
    }
  },

  getById: async (req, res) => {
    try {
      const id = Number(req.params.id);
      if (!Number.isInteger(id)) {
        return res
          .status(400)
          .json({ success: false, message: "ID tidak valid" });
      }

      const data = await PeminjamanService.getById(id);
      if (!data) {
        return res
          .status(404)
          .json({ success: false, message: "Peminjaman tidak ditemukan" });
      }

      res.status(200).json({ success: true, data });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, error: err.message });
    }
  },

  create: async (req, res) => {
    try {
      const { id_anggota, id_buku } = req.body;
      const id_petugas = req.user.id_petugas;

      if (!id_anggota || !id_buku) {
        return res
          .status(400)
          .json({ success: false, message: "id_anggota dan id_buku wajib" });
      }

      const created = await PeminjamanService.create({
        id_anggota: Number(id_anggota),
        id_buku: Number(id_buku),
        id_petugas,
      });

      res.status(201).json({
        success: true,
        message: "Peminjaman dicatat",
        data: created,
      });
    } catch (err) {
      console.error(err);
      res.status(400).json({ success: false, message: err.message });
    }
  },

  markReturn: async (req, res) => {
    try {
      const id_peminjaman = Number(req.params.id);
      if (!Number.isInteger(id_peminjaman)) {
        return res
          .status(400)
          .json({ success: false, message: "ID tidak valid" });
      }

      const id_petugas = req.user.id_petugas;
      const tanggal_kembali = req.body?.tanggal_kembali;

      const updated = await PeminjamanService.markReturn(
        id_peminjaman,
        id_petugas,
        tanggal_kembali
      );

      res.status(200).json({
        success: true,
        message: "Peminjaman diperbarui (kembali)",
        data: updated,
      });
    } catch (err) {
      console.error(err);
      res.status(400).json({ success: false, message: err.message });
    }
  },
  edit: async (req, res) => {
    try {
      const id = Number(req.params.id);
      if (!Number.isInteger(id)) {
        return res
          .status(400)
          .json({ success: false, message: "ID tidak valid" });
      }

      const { id_anggota, id_buku, tanggal_pinjam } = req.body;

      const updated = await PeminjamanService.editActive(id, {
        id_anggota: id_anggota ? Number(id_anggota) : undefined,
        id_buku: id_buku ? Number(id_buku) : undefined,
        tanggal_pinjam,
      });

      return res.json({
        success: true,
        message: "Peminjaman berhasil diperbarui",
        data: updated,
      });
    } catch (err) {
      console.error(err);
      return res.status(400).json({
        success: false,
        message: err.message,
      });
    }
  },
};
