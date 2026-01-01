// services/anggota.service.js
const prisma = require("../prisma");

class AnggotaService {
  async getAll(q) {
    const where = q
      ? {
          OR: [
            { nis: { contains: q } },
            { nama_anggota: { contains: q } },
            { alamat: { contains: q } },
            { no_hp: { contains: q } },
          ],
        }
      : {};

    return prisma.anggota.findMany({
      where,
      orderBy: { id_anggota: "asc" },
    });
  }

  async getById(id) {
    return prisma.anggota.findUnique({
      where: { id_anggota: id },
    });
  }

  async create(data) {
    return prisma.anggota.create({
      data,
    });
  }

  async update(id, data) {
    return prisma.anggota.update({
      where: { id_anggota: id },
      data,
    });
  }

  async remove(id) {
    // cek apakah anggota pernah meminjam
    const total = await prisma.peminjaman.count({
      where: { id_anggota: id },
    });
    if (total > 0) {
      throw new Error("ANGGOTA_PUNYA_PEMINJAMAN");
    }

    // jika aman → hapus
    return prisma.anggota.delete({
      where: { id_anggota: id },
    });
  }
}

module.exports = new AnggotaService();
