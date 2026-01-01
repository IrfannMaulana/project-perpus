const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");

const prisma = new PrismaClient();

async function main() {
  const hash = await bcrypt.hash("passwordPerpus123", 10);

  await prisma.petugas.upsert({
    where: { username: "admin" },
    update: {},
    create: {
      nama_petugas: "Admin Perpustakaan",
      username: "admin",
      password: hash,
    },
  });

  console.log("Seed petugas admin selesai");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
