import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PaymentsService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async initializeMockPayment(
    bookingId: string,
    guestId: string,
  ) {
    const booking = await this.prisma.booking.findFirst({
      where: {
        id: bookingId,
        guestId,
      },

      include: {
        payments: true,
      },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.status !== 'PENDING') {
      throw new BadRequestException(
        'Only pending bookings can be paid',
      );
    }

    const successfulPayment = booking.payments.find(
      (payment) => payment.status === 'SUCCESSFUL',
    );

    if (successfulPayment) {
      throw new BadRequestException(
        'Booking has already been paid',
      );
    }

    return this.prisma.payment.create({
      data: {
        bookingId: booking.id,
        provider: 'MOCK',
        providerReference: `MOCK-${Date.now()}`,
        amount: booking.total,
        currency: booking.currency,
        status: 'PENDING',
      },
    });
  }

  async simulateSuccess(
    paymentId: string,
    guestId: string,
  ) {
    const payment = await this.prisma.payment.findFirst({
      where: {
        id: paymentId,

        booking: {
          guestId,
        },
      },

      include: {
        booking: {
          include: {
            property: true,
          },
        },
      },
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    if (payment.status !== 'PENDING') {
      throw new BadRequestException(
        'Payment is no longer pending',
      );
    }

    if (payment.booking.status !== 'PENDING') {
      throw new BadRequestException(
        'Booking is no longer awaiting payment',
      );
    }

    return this.prisma.$transaction(async (tx) => {
      const updatedPayment = await tx.payment.update({
        where: {
          id: payment.id,
        },

        data: {
          status: 'SUCCESSFUL',
          paidAt: new Date(),
        },
      });

      const updatedBooking = await tx.booking.update({
        where: {
          id: payment.bookingId,
        },

        data: {
          status: 'AWAITING_HOST',
        },
      });

      const hostEarning = await tx.hostEarning.create({
        data: {
          bookingId: payment.bookingId,
          hostId: payment.booking.property.hostId,
          amount: payment.booking.subtotal,
          currency: payment.booking.currency,
          status: 'PENDING',
        },
      });

      return {
        payment: updatedPayment,
        booking: updatedBooking,
        hostEarning,
      };
    });
  }

  async findMine(guestId: string) {
    return this.prisma.payment.findMany({
      where: {
        booking: {
          guestId,
        },
      },

      orderBy: {
        createdAt: 'desc',
      },

      include: {
        booking: {
          include: {
            property: {
              select: {
                id: true,
                title: true,
              },
            },
          },
        },
      },
    });
  }
}