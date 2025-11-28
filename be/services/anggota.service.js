const prisma = require("../prisma");

module.exports = {
  getAll: () => {
    // kalau ingin exclude anggota yang dinonaktifkan gunakan where: { is_active: true }
    return prisma.anggota.findMany();
  },

  getById: (id) => {
    return prisma.anggota.findUnique({
      where: { id_anggota: id },
    });
  },

  create: (data) => {
    return prisma.anggota.create({
      data: {
        nama_anggota: data.nama_anggota,
        alamat: data.alamat || "",
        no_hp: data.no_hp || "",
        // jika Anda menambahkan field lain (mis. NIS), tambahkan di sini
      },
    });
  },

  update: (id, data) => {
    return prisma.anggota.update({
      where: { id_anggota: id },
      data: {
        nama_anggota: data.nama_anggota,
        alamat: data.alamat,
        no_hp: data.no_hp,
      },
    });
  },

  // contoh soft-delete (opsional)
  deactivate: (id) => {
    // butuh kolom is_active boolean di schema.prisma
    return prisma.anggota.update({
      where: { id_anggota: id },
      data: { is_active: false },
    });
  },
};
