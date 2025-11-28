const prisma = require("../prisma");

module.exports = {
  getAll: () => {
    return prisma.buku.findMany();
  },

  getById: (id) => {
    return prisma.buku.findUnique({
      where: { id_buku: id },
    });
  },

  create: (data) => {
    return prisma.buku.create({
      data: {
        judul: data.judul,
        pengarang: data.pengarang,
        penerbit: data.penerbit,
        tahun_terbit: Number(data.tahun_terbit),
        kategori: data.kategori,
      },
    });
  },

  update: (id, data) => {
    return prisma.buku.update({
      where: { id_buku: id },
      data: {
        judul: data.judul,
        pengarang: data.pengarang,
        penerbit: data.penerbit,
        tahun_terbit: Number(data.tahun_terbit),
        kategori: data.kategori,
      },
    });
  },

  remove: (id) => {
    return prisma.buku.delete({
      where: { id_buku: id },
    });
  },
};
