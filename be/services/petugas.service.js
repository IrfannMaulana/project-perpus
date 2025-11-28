const prisma = require("../prisma");

module.exports = {
  findByUsername: (username) => {
    return prisma.petugas.findUnique({
      where: { username },
    });
  },
};
