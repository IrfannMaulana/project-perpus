/*
  Warnings:

  - A unique constraint covering the columns `[nis]` on the table `Anggota` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `nis` to the `Anggota` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE `anggota` ADD COLUMN `nis` VARCHAR(191) NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX `Anggota_nis_key` ON `Anggota`(`nis`);
