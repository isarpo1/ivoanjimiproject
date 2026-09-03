import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateBookingDto } from './dto/create-booking.dto';

@Injectable()
export class BookingsService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async create(
    guestId: string,
    dto: CreateBookingDto,
  ) {
    const property =
      await this.prisma.property.findFirst({
        where: {
          id: dto.propertyId,
          status: 'ACTIVE',
        },
      });

    if (!property) {
      throw new NotFoundException(
        'Property not found or unavailable',
      );
    }

    if (property.hostId === guestId) {
      throw new BadRequestException(
        'You cannot book your own property',
      );
    }

    if (dto.guestCount > property.maxGuests) {
      throw new BadRequestException(
        `This property allows a maximum of ${property.maxGuests} guests`,
      );
    }

    const checkIn = new Date(dto.checkIn);
    const checkOut = new Date(dto.checkOut);

    if (checkOut <= checkIn) {
      throw new BadRequestException(
        'Check-out must be after check-in',
      );
    }

    const millisecondsPerDay =
      1000 * 60 * 60 * 24;

    const nights = Math.round(
      (checkOut.getTime() - checkIn.getTime()) /
        millisecondsPerDay,
    );

    if (nights < 1) {
      throw new BadRequestException(
        'Booking must be at least one night',
      );
    }

    const conflictingBooking =
      await this.prisma.booking.findFirst({
        where: {
          propertyId: property.id,

          status: {
            in: [
              'PENDING',
              'AWAITING_HOST',
              'CONFIRMED',
            ],
          },

          checkIn: {
            lt: checkOut,
          },

          checkOut: {
            gt: checkIn,
          },
        },
      });

    if (conflictingBooking) {
      throw new ConflictException(
        'Property is not available for the selected dates',
      );
    }

    const nightlyRate =
      Number(property.pricePerNight);

    const subtotal =
      nightlyRate * nights;

    // Temporary MVP service fee: 10%.
    // We can make this configurable later.
    const serviceFee =
      Math.round(subtotal * 0.1);

    const total =
      subtotal + serviceFee;

    return this.prisma.booking.create({
      data: {
        propertyId: property.id,
        guestId,

        checkIn,
        checkOut,
        guestCount: dto.guestCount,

        nightlyRate,
        subtotal,
        serviceFee,
        total,

        currency: 'NGN',
        status: 'PENDING',
      },

      include: {
        property: {
          include: {
            images: {
              orderBy: {
                displayOrder: 'asc',
              },
            },
          },
        },
      },
    });
  }
  async findForHost(hostId: string) {
  return this.prisma.booking.findMany({
    where: {
      property: {
        hostId,
      },
    },

    orderBy: {
      createdAt: 'desc',
    },

    include: {
      property: {
        select: {
          id: true,
          title: true,

          images: {
            where: {
              isCover: true,
            },

            take: 1,
          },
        },
      },

      guest: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
          profilePhotoUrl: true,
        },
      },

      payments: true,
    },
  });
}
async acceptByHost(
  bookingId: string,
  hostId: string,
) {
  const booking = await this.prisma.booking.findFirst({
    where: {
      id: bookingId,

      property: {
        hostId,
      },
    },

    include: {
      payments: true,
      hostEarning: true,
    },
  });

  if (!booking) {
    throw new NotFoundException(
      'Booking not found',
    );
  }

  if (booking.status !== 'AWAITING_HOST') {
    throw new BadRequestException(
      'Only bookings awaiting host approval can be accepted',
    );
  }

  const successfulPayment =
    booking.payments.find(
      (payment) =>
        payment.status === 'SUCCESSFUL',
    );

  if (!successfulPayment) {
    throw new BadRequestException(
      'Booking does not have a successful payment',
    );
  }

  return this.prisma.booking.update({
    where: {
      id: booking.id,
    },

    data: {
      status: 'CONFIRMED',
    },

    include: {
      property: true,
      payments: true,
      hostEarning: true,
    },
  });
}

async declineByHost(
  bookingId: string,
  hostId: string,
) {
  const booking = await this.prisma.booking.findFirst({
    where: {
      id: bookingId,

      property: {
        hostId,
      },
    },

    include: {
      payments: true,
      hostEarning: true,
    },
  });

  if (!booking) {
    throw new NotFoundException(
      'Booking not found',
    );
  }

  if (booking.status !== 'AWAITING_HOST') {
    throw new BadRequestException(
      'Only bookings awaiting host approval can be declined',
    );
  }

  return this.prisma.$transaction(
    async (tx) => {
      const updatedBooking =
        await tx.booking.update({
          where: {
            id: booking.id,
          },

          data: {
            status: 'DECLINED',
          },
        });

      await tx.payment.updateMany({
        where: {
          bookingId: booking.id,
          status: 'SUCCESSFUL',
        },

        data: {
          status: 'REFUNDED',
        },
      });

      await tx.hostEarning.updateMany({
        where: {
          bookingId: booking.id,
        },

        data: {
          status: 'CANCELLED',
        },
      });

      const payments =
        await tx.payment.findMany({
          where: {
            bookingId: booking.id,
          },
        });

      const hostEarning =
        await tx.hostEarning.findUnique({
          where: {
            bookingId: booking.id,
          },
        });

      return {
        booking: updatedBooking,
        payments,
        hostEarning,
      };
    },
  );
}
async findOneForHost(
  id: string,
  hostId: string,
) {
  const booking =
    await this.prisma.booking.findFirst({
      where: {
        id,

        property: {
          hostId,
        },
      },

      include: {
        property: {
          include: {
            images: {
              orderBy: {
                displayOrder: 'asc',
              },
            },
          },
        },

        guest: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePhotoUrl: true,
          },
        },

        payments: true,
      },
    });

  if (!booking) {
    throw new NotFoundException(
      'Reservation not found',
    );
  }

  return booking;
}
  async cancelMine(
  id: string,
  guestId: string,
) {
  const booking =
    await this.prisma.booking.findFirst({
      where: {
        id,
        guestId,
      },
    });

  if (!booking) {
    throw new NotFoundException(
      'Booking not found',
    );
  }

  if (booking.status !== 'PENDING') {
    throw new BadRequestException(
      'Only pending bookings can be cancelled before payment',
    );
  }

  return this.prisma.booking.update({
    where: {
      id,
    },

    data: {
      status: 'CANCELLED',
    },
  });
}

  async findMine(guestId: string) {
    return this.prisma.booking.findMany({
      where: {
        guestId,
      },

      orderBy: {
        createdAt: 'desc',
      },

      include: {
        property: {
          include: {
            images: {
              orderBy: {
                displayOrder: 'asc',
              },
            },
          },
        },
      },
    });
  }

 async findOne(
  id: string,
  guestId: string,
) {
  const booking =
    await this.prisma.booking.findFirst({
      where: {
        id,
        guestId,
      },

      include: {
        property: {
          include: {
            images: {
              orderBy: {
                displayOrder: 'asc',
              },
            },
          },
        },

        payments: true,
      },
    });

  if (!booking) {
    throw new NotFoundException(
      'Booking not found',
    );
  }

  return booking;
}
}