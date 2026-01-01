const prisma = require("../prisma");

module.exports = {
  // params: { q, page, limit }
  getAll: async ({ q = "", page = 1, limit = 20 } = {}) => {
    const take = Number(limit) > 0 ? Number(limit) : 20;
    const skip = Number(page) > 1 ? (Number(page) - 1) * take : 0;

    const where = q
      ? {
          OR: [
            { judul: { contains: q } },
            { pengarang: { contains: q } },
            { penerbit: { contains: q } },
            { kategori: { contains: q } },
          ],
        }
      : {};

    const [data, total] = await Promise.all([
      prisma.buku.findMany({
        where,
        orderBy: { judul: "asc" },
        skip,
        take,
      }),
      prisma.buku.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page: Number(page),
        limit: take,
        totalPages: Math.ceil(total / take) || 1,
      },
    };
  },

  getById: (id) => {
    return prisma.buku.findUnique({ where: { id_buku: id } });
  },

  create: (data) => {
    return prisma.buku.create({ data });
  },

  update: (id, data) => {
    return prisma.buku.update({ where: { id_buku: id }, data });
  },

  remove: (id) => {
    return prisma.buku.delete({ where: { id_buku: id } });
  },
};
