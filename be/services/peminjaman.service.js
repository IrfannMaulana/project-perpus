const prisma = require("../prisma");

module.exports = {
  getAll: async ({
    status,
    id_anggota,
    id_buku,
    bulan,
    tahun,
    start,
    end,
  } = {}) => {
    const where = {};

    // Filter status peminjaman
    if (status) where.status = status;

    // Filter berdasarkan anggota
    if (id_anggota) where.id_anggota = Number(id_anggota);

    // Filter berdasarkan buku
    if (id_buku) where.id_buku = Number(id_buku);

    // Filter berdasarkan bulan & tahun
    if (bulan && tahun) {
      const m = Number(bulan);
      const y = Number(tahun);

      const startDate = new Date(y, m - 1, 1);
      const endDate = new Date(y, m, 0); // last day of the month

      where.tanggal_pinjam = {
        gte: startDate,
        lte: endDate,
      };
    }

    // Filter berdasarkan rentang tanggal (opsional)
    if (start && end) {
      where.tanggal_pinjam = {
        gte: new Date(start),
        lte: new Date(end),
      };
    }

    return prisma.peminjaman.findMany({
      where,
      include: {
        anggota: true,
        buku: true,
        petugas: true,
      },
      orderBy: { tanggal_pinjam: "desc" },
    });
  },

  getById: (id) => {
    return prisma.peminjaman.findUnique({
      where: { id_peminjaman: id },
      include: { anggota: true, buku: true, petugas: true },
    });
  },

  create: async ({ id_anggota, id_buku, id_petugas }) => {
    const anggota = await prisma.anggota.findUnique({ where: { id_anggota } });
    if (!anggota) throw new Error("Anggota tidak ditemukan");

    const buku = await prisma.buku.findUnique({ where: { id_buku } });
    if (!buku) throw new Error("Buku tidak ditemukan");

    const created = await prisma.$transaction(async (tx) => {
      const openLoan = await tx.peminjaman.findFirst({
        where: { id_buku, status: "dipinjam" },
      });
      if (openLoan) throw new Error("Buku sedang dipinjam");

      return tx.peminjaman.create({
        data: {
          id_anggota,
          id_buku,
          id_petugas,
          tanggal_pinjam: new Date(),
          tanggal_kembali: null,
          status: "dipinjam",
        },
      });
    });

    return prisma.peminjaman.findUnique({
      where: { id_peminjaman: created.id_peminjaman },
      include: { anggota: true, buku: true, petugas: true },
    });
  },

  markReturn: async (id_peminjaman, id_petugas, tanggal_kembali) => {
    const loan = await prisma.peminjaman.findUnique({
      where: { id_peminjaman },
    });
    if (!loan) throw new Error("Peminjaman tidak ditemukan");
    if (loan.status !== "dipinjam")
      throw new Error("Peminjaman sudah dikembalikan");

    const updated = await prisma.$transaction(async (tx) => {
      return tx.peminjaman.update({
        where: { id_peminjaman },
        data: {
          status: "kembali",
          tanggal_kembali: tanggal_kembali
            ? new Date(tanggal_kembali)
            : new Date(),
        },
      });
    });

    return prisma.peminjaman.findUnique({
      where: { id_peminjaman: updated.id_peminjaman },
      include: { anggota: true, buku: true, petugas: true },
    });
  },

  update: (id, data) => {
    return prisma.peminjaman.update({
      where: { id_peminjaman: id },
      data,
    });
  },

  remove: (id) => {
    return prisma.peminjaman.delete({
      where: { id_peminjaman: id },
    });
  },
  // EDIT peminjaman aktif (koreksi salah input buku / anggota)
  async editActive(id_peminjaman, { id_anggota, id_buku, tanggal_pinjam }) {
    const loan = await prisma.peminjaman.findUnique({
      where: { id_peminjaman },
    });

    if (!loan) throw new Error("Peminjaman tidak ditemukan");
    if (loan.status !== "dipinjam") throw new Error("Peminjaman sudah selesai");

    // Jika ganti buku, pastikan buku baru tidak sedang dipinjam
    if (id_buku && id_buku !== loan.id_buku) {
      const open = await prisma.peminjaman.findFirst({
        where: { id_buku, status: "dipinjam" },
      });
      if (open) throw new Error("Buku pengganti sedang dipinjam");
    }

    return prisma.peminjaman.update({
      where: { id_peminjaman },
      data: {
        id_anggota: id_anggota ?? loan.id_anggota,
        id_buku: id_buku ?? loan.id_buku,
        tanggal_pinjam: tanggal_pinjam
          ? new Date(tanggal_pinjam)
          : loan.tanggal_pinjam,
      },
    });
  },
};
