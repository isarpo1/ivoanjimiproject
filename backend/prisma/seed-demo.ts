/**
 * Demo seed for the Nesti web UI.
 *
 * Creates believable Nigerian listings, a host, the demo customer
 * (customer@example.com / Customer123!), and bookings in every
 * relevant state (PENDING for cancel testing, CONFIRMED for
 * message-host testing, COMPLETED for review testing).
 *
 * Run:  npx tsx prisma/seed-demo.ts
 * Requires DATABASE_URL in .env
 */
import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

const img = (id: string) =>
  `https://images.unsplash.com/${id}?q=80&w=1200&auto=format&fit=crop`;

const AMENITIES = [
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

interface SeedProperty {
  title: string;
  description: string;
  address: string;
  city: string;
  state: string;
  pricePerNight: number;
  bedrooms: number;
  bathrooms: number;
  maxGuests: number;
  images: string[];
  amenities: string[];
}

const PROPERTIES: SeedProperty[] = [
  {
    title: 'Sunset Terrace Duplex',
    description:
      'A bright and airy 4-bedroom duplex in the heart of Lekki Phase 1. ' +
      'Open-plan living area with floor-to-ceiling windows, a fully fitted ' +
      'kitchen, and a private terrace perfect for evening relaxation. ' +
      '24/7 security, backup power, and 10 minutes from Landmark Beach.',
    address: '14 Admiralty Way',
    city: 'Lekki',
    state: 'Lagos',
    pricePerNight: 180000,
    bedrooms: 4,
    bathrooms: 4,
    maxGuests: 8,
    images: [
      'photo-1600596542815-ffad4c1539a9',
      'photo-1600607687939-ce8a6c25118c',
      'photo-1600566753086-00f18fb6b3ea',
      'photo-1600585154340-be6161a56a0c',
    ],
    amenities: ['Wi-Fi', 'Backup Power', 'Air Conditioning', 'Parking', 'Security', 'Kitchen', 'Washer', 'Hot Water', 'Workspace'],
  },
  {
    title: 'Ikoyi Waterfront Apartment',
    description:
      'Stunning 3-bedroom apartment overlooking the Ikoyi lagoon. Floor-to-ceiling ' +
      'glass, designer furniture, smart TV in every room, and a wraparound balcony ' +
      'with water views. Ideal for executives and couples seeking quiet luxury.',
    address: '3 Bourdillon Road',
    city: 'Ikoyi',
    state: 'Lagos',
    pricePerNight: 250000,
    bedrooms: 3,
    bathrooms: 3,
    maxGuests: 6,
    images: [
      'photo-1522708323590-d24dbb6b0267',
      'photo-1502672260266-1c1ef2d93688',
      'photo-1560448204-e02f11c3d0e2',
    ],
    amenities: ['Wi-Fi', 'Backup Power', 'Air Conditioning', 'Parking', 'Security', 'Kitchen', 'Hot Water', 'Workspace'],
  },
  {
    title: 'The Palms Shortlet Studio',
    description:
      'A stylish self-contained studio on Victoria Island, walking distance to ' +
      'restaurants and the Eko Hotel district. Perfect for solo travellers and ' +
      'business trips — fast Wi-Fi, dedicated workspace, and a comfy queen bed.',
    address: '27 Ahmadu Bello Way',
    city: 'Victoria Island',
    state: 'Lagos',
    pricePerNight: 65000,
    bedrooms: 1,
    bathrooms: 1,
    maxGuests: 2,
    images: [
      'photo-1554995207-c18c203602cb',
      'photo-1595526114035-0d45ed16cfbf',
      'photo-1586023492125-27b2c045efd7',
    ],
    amenities: ['Wi-Fi', 'Backup Power', 'Air Conditioning', 'Security', 'Kitchen', 'Hot Water', 'Workspace'],
  },
  {
    title: 'Maitama Garden Villa',
    description:
      'A serene 5-bedroom villa in Maitama with lush gardens, a private pool, ' +
      'and a boys’ quarters. Grand living spaces, a chef-ready kitchen, and ' +
      'ample parking for 6 cars. A favourite for families and retreats.',
    address: '7 Gana Street',
    city: 'Maitama',
    state: 'Abuja',
    pricePerNight: 320000,
    bedrooms: 5,
    bathrooms: 5,
    maxGuests: 10,
    images: [
      'photo-1512917774080-9991f1c4c750',
      'photo-1616486338812-3dadae4b4ace',
      'photo-1616594039964-ae9021a400a0',
      'photo-1600210492486-724fe5c67fb0',
    ],
    amenities: ['Wi-Fi', 'Backup Power', 'Air Conditioning', 'Parking', 'Security', 'Kitchen', 'Swimming Pool', 'Washer', 'Hot Water'],
  },
  {
    title: 'Asokoro Executive Flat',
    description:
      'A tasteful 2-bedroom flat in Asokoro, minutes from the city centre. ' +
      'Quiet street, modern fittings, fully equipped kitchen, and reliable ' +
      'backup power. Great for professionals on medium-term assignments.',
    address: '12 Yakubu Gowon Crescent',
    city: 'Asokoro',
    state: 'Abuja',
    pricePerNight: 120000,
    bedrooms: 2,
    bathrooms: 2,
    maxGuests: 4,
    images: [
      'photo-1560185127-6ed189bf02f4',
      'photo-1567016432779-094069958ea5',
      'photo-1493809842364-78817add7ffb',
    ],
    amenities: ['Wi-Fi', 'Backup Power', 'Air Conditioning', 'Parking', 'Security', 'Kitchen', 'Washer', 'Hot Water', 'Workspace'],
  },
  {
    title: 'GRA Family Duplex',
    description:
      'Spacious 4-bedroom duplex in GRA Phase 2, Port Harcourt. Large compound ' +
      'for kids to play, a family lounge upstairs, and a well-stocked kitchen. ' +
      'Close to major roads yet tucked away from the noise.',
    address: '22 Stadium Road',
    city: 'GRA',
    state: 'Rivers',
    pricePerNight: 95000,
    bedrooms: 4,
    bathrooms: 3,
    maxGuests: 8,
    images: [
      'photo-1570129477492-45c003edd2be',
      'photo-1600047509807-ba8f99d2cdde',
      'photo-1560185009-5bf9f2849488',
    ],
    amenities: ['Wi-Fi', 'Backup Power', 'Air Conditioning', 'Parking', 'Security', 'Kitchen', 'Washer', 'Hot Water'],
  },
  {
    title: 'Bodija Cozy Bungalow',
    description:
      'A charming 3-bedroom bungalow in Bodija, Ibadan. Shady veranda, ' +
      'home-style kitchen, and fast internet — a peaceful base for work or ' +
      'family visits, 15 minutes from the University of Ibadan.',
    address: '5 Awolowo Avenue',
    city: 'Bodija',
    state: 'Oyo',
    pricePerNight: 55000,
    bedrooms: 3,
    bathrooms: 2,
    maxGuests: 6,
    images: [
      'photo-1600573472592-401b489a3cdc',
      'photo-1600566752355-35792bedcfea',
      'photo-1600121848594-d8644e57abab',
    ],
    amenities: ['Wi-Fi', 'Backup Power', 'Air Conditioning', 'Parking', 'Security', 'Kitchen', 'Hot Water', 'Workspace'],
  },
  {
    title: 'Oniru Beach House',
    description:
      'Wake up to the sound of the Atlantic. This 5-bedroom beach house in ' +
      'Oniru features direct beach access, an infinity pool, outdoor lounge ' +
      'decks, and a private chef on request. The ultimate Lagos getaway.',
    address: '1 Water Corporation Drive',
    city: 'Oniru',
    state: 'Lagos',
    pricePerNight: 450000,
    bedrooms: 5,
    bathrooms: 6,
    maxGuests: 12,
    images: [
      'photo-1512917774080-9991f1c4c750',
      'photo-1600596542815-ffad4c1539a9',
      'photo-1600607687939-ce8a6c25118c',
      'photo-1616486338812-3dadae4b4ace',
    ],
    amenities: ['Wi-Fi', 'Backup Power', 'Air Conditioning', 'Parking', 'Security', 'Kitchen', 'Swimming Pool', 'Washer', 'Hot Water'],
  },
];

function daysFromNow(days: number): Date {
  const d = new Date();
  d.setDate(d.getDate() + days);
  d.setHours(12, 0, 0, 0);
  return d;
}

function pricing(nightlyRate: number, nights: number) {
  const subtotal = nightlyRate * nights;
  const serviceFee = Math.round(subtotal * 0.1);
  return { subtotal, serviceFee, total: subtotal + serviceFee };
}

async function main() {
  // Amenities
  for (const a of AMENITIES) {
    await prisma.amenity.upsert({
      where: { name: a.name },
      update: { icon: a.icon },
      create: a,
    });
  }
  const amenityRows = await prisma.amenity.findMany();
  const amenityByName = new Map(amenityRows.map((a) => [a.name, a.id]));

  // Users
  const hostPassword = await bcrypt.hash('Host123!', 10);
  const host = await prisma.user.upsert({
    where: { email: 'host@example.com' },
    update: { isHost: true, isVerified: true },
    create: {
      firstName: 'Adaeze',
      lastName: 'Okonkwo',
      email: 'host@example.com',
      phone: '+2348012345678',
      passwordHash: hostPassword,
      isHost: true,
      isVerified: true,
    },
  });

  const customerPassword = await bcrypt.hash('Customer123!', 10);
  const customer = await prisma.user.upsert({
    where: { email: 'customer@example.com' },
    update: {},
    create: {
      firstName: 'Amara',
      lastName: 'Nwosu',
      email: 'customer@example.com',
      phone: '+2348098765432',
      passwordHash: customerPassword,
      isVerified: true,
    },
  });

  const guest2Password = await bcrypt.hash('Guest123!', 10);
  const guest2 = await prisma.user.upsert({
    where: { email: 'guest2@example.com' },
    update: {},
    create: {
      firstName: 'Tunde',
      lastName: 'Bakare',
      email: 'guest2@example.com',
      passwordHash: guest2Password,
      isVerified: true,
    },
  });

  // Properties (idempotent by title+host)
  const created: { id: string; price: number }[] = [];
  for (const p of PROPERTIES) {
    let property = await prisma.property.findFirst({
      where: { title: p.title, hostId: host.id },
    });
    if (!property) {
      property = await prisma.property.create({
        data: {
          hostId: host.id,
          title: p.title,
          description: p.description,
          address: p.address,
          city: p.city,
          state: p.state,
          country: 'Nigeria',
          pricePerNight: p.pricePerNight,
          bedrooms: p.bedrooms,
          bathrooms: p.bathrooms,
          maxGuests: p.maxGuests,
          status: 'ACTIVE',
          images: {
            create: p.images.map((imageId, i) => ({
              imageUrl: img(imageId),
              displayOrder: i,
              isCover: i === 0,
            })),
          },
          amenities: {
            create: p.amenities
              .map((name) => amenityByName.get(name))
              .filter((id): id is string => !!id)
              .map((amenityId) => ({ amenityId })),
          },
        },
      });
      console.log(`Created property: ${p.title}`);
    }
    created.push({ id: property.id, price: p.pricePerNight });
  }

  const byTitle = async (title: string) =>
    (await prisma.property.findFirst({
      where: { title, hostId: host.id },
    }))!;

  // Bookings for the demo customer
  async function ensureBooking(opts: {
    key: string;
    propertyTitle: string;
    guestId: string;
    checkIn: Date;
    checkOut: Date;
    status: 'PENDING' | 'CONFIRMED' | 'COMPLETED';
  }) {
    const property = await byTitle(opts.propertyTitle);
    const nights = Math.round(
      (opts.checkOut.getTime() - opts.checkIn.getTime()) /
        (1000 * 60 * 60 * 24),
    );
    const nightlyRate = Number(
      (
        await prisma.property.findUnique({
          where: { id: property.id },
          select: { pricePerNight: true },
        })
      )!.pricePerNight,
    );
    const { subtotal, serviceFee, total } = pricing(nightlyRate, nights);

    let booking = await prisma.booking.findFirst({
      where: {
        guestId: opts.guestId,
        propertyId: property.id,
        checkIn: opts.checkIn,
        checkOut: opts.checkOut,
      },
    });

    if (!booking) {
      booking = await prisma.booking.create({
        data: {
          propertyId: property.id,
          guestId: opts.guestId,
          checkIn: opts.checkIn,
          checkOut: opts.checkOut,
          guestCount: 2,
          nightlyRate,
          subtotal,
          serviceFee,
          total,
          currency: 'NGN',
          status: opts.status,
        },
      });
      console.log(
        `Created ${opts.status} booking (${opts.key}) for ${opts.propertyTitle}`,
      );
    }

    if (opts.status !== 'PENDING') {
      await prisma.payment.upsert({
        where: { id: `00000000-0000-4000-8000-${opts.key.padStart(12, '0')}` },
        update: {},
        create: {
          id: `00000000-0000-4000-8000-${opts.key.padStart(12, '0')}`,
          bookingId: booking.id,
          provider: 'MOCK',
          amount: total,
          currency: 'NGN',
          status: 'SUCCESSFUL',
          paidAt: new Date(),
        },
      });
    }
    return booking;
  }

  // 1. COMPLETED stay -> reviewable
  const completed = await ensureBooking({
    key: '000000000001',
    propertyTitle: 'Sunset Terrace Duplex',
    guestId: customer.id,
    checkIn: daysFromNow(-30),
    checkOut: daysFromNow(-27),
    status: 'COMPLETED',
  });

  // 2. PENDING booking -> cancellable
  await ensureBooking({
    key: '000000000002',
    propertyTitle: 'Ikoyi Waterfront Apartment',
    guestId: customer.id,
    checkIn: daysFromNow(14),
    checkOut: daysFromNow(17),
    status: 'PENDING',
  });

  // 3. CONFIRMED booking -> message host
  const confirmed = await ensureBooking({
    key: '000000000003',
    propertyTitle: 'Maitama Garden Villa',
    guestId: customer.id,
    checkIn: daysFromNow(30),
    checkOut: daysFromNow(34),
    status: 'CONFIRMED',
  });

  // 4. Another COMPLETED stay (different guest) so listings show reviews
  const completed2 = await ensureBooking({
    key: '000000000004',
    propertyTitle: 'Sunset Terrace Duplex',
    guestId: guest2.id,
    checkIn: daysFromNow(-60),
    checkOut: daysFromNow(-58),
    status: 'COMPLETED',
  });

  // Reviews
  const existingReviews = await prisma.review.findMany({
    where: { bookingId: { in: [completed.id, completed2.id] } },
  });
  const reviewed = new Set(existingReviews.map((r) => r.bookingId));

  if (!reviewed.has(completed.id)) {
    await prisma.review.create({
      data: {
        bookingId: completed.id,
        propertyId: completed.propertyId,
        userId: customer.id,
        rating: 5,
        comment:
          'Beautiful place! The terrace at sunset is exactly as advertised. ' +
          'Check-in was smooth and Adaeze was very responsive. Would definitely stay again.',
      },
    });
  }
  if (!reviewed.has(completed2.id)) {
    await prisma.review.create({
      data: {
        bookingId: completed2.id,
        propertyId: completed2.propertyId,
        userId: guest2.id,
        rating: 4,
        comment:
          'Great duplex in a lovely area. Power and water were solid throughout. ' +
          'Only minor issue was traffic getting in on Friday evening.',
      },
    });
  }

  // A conversation on the confirmed booking so Messages isn't empty
  const existingConv = await prisma.conversation.findUnique({
    where: { bookingId: confirmed.id },
  });
  if (!existingConv) {
    const villa = await byTitle('Maitama Garden Villa');
    const confBooking = await prisma.booking.findFirst({
      where: {
        guestId: customer.id,
        propertyId: villa.id,
        status: 'CONFIRMED',
      },
    });
    if (confBooking) {
      const conv = await prisma.conversation.create({
        data: {
          propertyId: villa.id,
          bookingId: confBooking.id,
          guestId: customer.id,
          hostId: host.id,
        },
      });
      await prisma.message.createMany({
        data: [
          {
            conversationId: conv.id,
            senderId: customer.id,
            message:
              'Hello Adaeze! Looking forward to our stay next month. Is early check-in possible?',
          },
          {
            conversationId: conv.id,
            senderId: host.id,
            message:
              'Hello Amara! Yes, early check-in from 11am should be fine. Just let me know your arrival time closer to the date.',
          },
        ],
      });
      console.log('Created demo conversation');
    }
  }

  console.log('Demo seed complete');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
