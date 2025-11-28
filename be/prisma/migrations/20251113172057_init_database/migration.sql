-- CreateTable
CREATE TABLE `Petugas` (
    `id_petugas` INTEGER NOT NULL AUTO_INCREMENT,
    `nama_petugas` VARCHAR(191) NOT NULL,
    `username` VARCHAR(191) NOT NULL,
    `password` VARCHAR(191) NOT NULL,

    UNIQUE INDEX `Petugas_username_key`(`username`),
    PRIMARY KEY (`id_petugas`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Anggota` (
    `id_anggota` INTEGER NOT NULL AUTO_INCREMENT,
    `nama_anggota` VARCHAR(191) NOT NULL,
    `alamat` VARCHAR(191) NOT NULL,
    `no_hp` VARCHAR(191) NOT NULL,

    PRIMARY KEY (`id_anggota`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Buku` (
    `id_buku` INTEGER NOT NULL AUTO_INCREMENT,
    `judul` VARCHAR(191) NOT NULL,
    `pengarang` VARCHAR(191) NOT NULL,
    `penerbit` VARCHAR(191) NOT NULL,
    `tahun_terbit` INTEGER NOT NULL,
    `kategori` VARCHAR(191) NOT NULL,

    PRIMARY KEY (`id_buku`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Peminjaman` (
    `id_peminjaman` INTEGER NOT NULL AUTO_INCREMENT,
    `id_anggota` INTEGER NOT NULL,
    `id_buku` INTEGER NOT NULL,
    `id_petugas` INTEGER NOT NULL,
    `tanggal_pinjam` DATETIME(3) NOT NULL,
    `tanggal_kembali` DATETIME(3) NOT NULL,
    `status` VARCHAR(191) NOT NULL,

    PRIMARY KEY (`id_peminjaman`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `Peminjaman` ADD CONSTRAINT `Peminjaman_id_anggota_fkey` FOREIGN KEY (`id_anggota`) REFERENCES `Anggota`(`id_anggota`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Peminjaman` ADD CONSTRAINT `Peminjaman_id_buku_fkey` FOREIGN KEY (`id_buku`) REFERENCES `Buku`(`id_buku`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Peminjaman` ADD CONSTRAINT `Peminjaman_id_petugas_fkey` FOREIGN KEY (`id_petugas`) REFERENCES `Petugas`(`id_petugas`) ON DELETE RESTRICT ON UPDATE CASCADE;
