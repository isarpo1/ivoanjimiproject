import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateReviewDto } from './dto/create-review.dto';

@Injectable()
export class ReviewsService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async create(
    userId: string,
    dto: CreateReviewDto,
  ) {
    const booking = await this.prisma.booking.findFirst({
      where: {
        id: dto.bookingId,
        guestId: userId,
      },

      include: {
        property: true,
        review: true,
      },
    });

    if (!booking) {
      throw new NotFoundException(
        'Booking not found',
      );
    }

    if (booking.status !== 'COMPLETED') {
      throw new BadRequestException(
        'Only completed bookings can be reviewed',
      );
    }

    if (booking.property.hostId === userId) {
      throw new BadRequestException(
        'You cannot review your own property',
      );
    }

    if (booking.review) {
      throw new ConflictException(
        'This booking has already been reviewed',
      );
    }

    const comment =
      dto.comment?.trim() || null;

    return this.prisma.review.create({
      data: {
        bookingId: booking.id,
        propertyId: booking.propertyId,
        userId,
        rating: dto.rating,
        comment,
      },

      include: {
        property: {
          select: {
            id: true,
            title: true,
          },
        },

        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePhotoUrl: true,
          },
        },
      },
    });
  }

  async findPropertyReviews(
    propertyId: string,
  ) {
    const property =
      await this.prisma.property.findUnique({
        where: {
          id: propertyId,
        },

        select: {
          id: true,
          title: true,
        },
      });

    if (!property) {
      throw new NotFoundException(
        'Property not found',
      );
    }

    const [reviews, ratingSummary] =
      await Promise.all([
        this.prisma.review.findMany({
          where: {
            propertyId,
          },

          orderBy: {
            createdAt: 'desc',
          },

          include: {
            user: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                profilePhotoUrl: true,
              },
            },
          },
        }),

        this.prisma.review.aggregate({
          where: {
            propertyId,
          },

          _avg: {
            rating: true,
          },

          _count: {
            rating: true,
          },
        }),
      ]);

    return {
      property,

      summary: {
        averageRating:
          ratingSummary._avg.rating ?? 0,

        reviewCount:
          ratingSummary._count.rating,
      },

      reviews,
    };
  }

  async findMine(userId: string) {
    return this.prisma.review.findMany({
      where: {
        userId,
      },

      orderBy: {
        createdAt: 'desc',
      },

      include: {
        property: {
          select: {
            id: true,
            title: true,
            city: true,
            state: true,

            images: {
              where: {
                isCover: true,
              },

              take: 1,
            },
          },
        },

        booking: {
          select: {
            id: true,
            checkIn: true,
            checkOut: true,
            status: true,
          },
        },
      },
    });
  }
}