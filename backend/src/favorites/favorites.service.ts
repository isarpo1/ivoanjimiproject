import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { SaveStayDto } from './dto/save-stay.dto';

@Injectable()
export class FavoritesService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  private propertyInclude() {
    return {
      images: {
        orderBy: {
          displayOrder: 'asc' as const,
        },
      },
    };
  }

  async findMine(userId: string) {
    return this.prisma.savedStay.findMany({
      where: { userId },

      orderBy: { createdAt: 'desc' },

      include: {
        property: {
          include: this.propertyInclude(),
        },
      },
    });
  }

  async save(userId: string, dto: SaveStayDto) {
    const property =
      await this.prisma.property.findFirst({
        where: {
          id: dto.propertyId,
          status: 'ACTIVE',
        },

        select: { id: true },
      });

    if (!property) {
      throw new NotFoundException(
        'Property not found or unavailable',
      );
    }

    const existing =
      await this.prisma.savedStay.findUnique({
        where: {
          userId_propertyId: {
            userId,
            propertyId: property.id,
          },
        },
      });

    if (existing) {
      throw new ConflictException(
        'This stay is already saved',
      );
    }

    return this.prisma.savedStay.create({
      data: {
        userId,
        propertyId: property.id,
      },

      include: {
        property: {
          include: this.propertyInclude(),
        },
      },
    });
  }

  async remove(userId: string, propertyId: string) {
    const existing =
      await this.prisma.savedStay.findUnique({
        where: {
          userId_propertyId: {
            userId,
            propertyId,
          },
        },
      });

    if (!existing) {
      throw new NotFoundException('Saved stay not found');
    }

    await this.prisma.savedStay.delete({
      where: { id: existing.id },
    });

    return { message: 'Removed from saved stays' };
  }
}
