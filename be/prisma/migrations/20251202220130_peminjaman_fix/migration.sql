-- AlterTable
ALTER TABLE `peminjaman` MODIFY `tanggal_pinjam` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    MODIFY `tanggal_kembali` DATETIME(3) NULL,
    MODIFY `status` VARCHAR(191) NOT NULL DEFAULT 'dipinjam';
