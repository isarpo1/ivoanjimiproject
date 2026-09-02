import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const amenities = [
  { name: 'Wi-Fi', icon: 'wifi' },
  { name: 'Backup Power', icon: 'power' },
  { name: 'Air Conditioning', icon: 'ac' },
  { name: 'Parking', icon: 'parking' },
  { name: 'Security', icon: 'security' },
  { name: 'Kitchen', icon: 'kitchen' },
  { name: 'Swimming Pool', icon: 'pool' },
  { name: 'Washer', icon: 'washer' },
  { name: 'Hot Water', icon: 'hot-water' },
  { name: 'Workspace', icon: 'workspace' },
];

async function main() {
  for (const amenity of amenities) {
    await prisma.amenity.upsert({
      where: {
        name: amenity.name,
      },
      update: {
        icon: amenity.icon,
      },
      create: amenity,
    });
  }

  console.log('Amenities seeded successfully');
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });