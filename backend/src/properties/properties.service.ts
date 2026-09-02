import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreatePropertyDto } from './dto/create-property.dto';
import { UpdatePropertyDto } from './dto/update-property.dto';

@Injectable()
export class PropertiesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(hostId: string, dto: CreatePropertyDto) {
    return this.prisma.property.create({
      data: {
        hostId,

        title: dto.title,
        description: dto.description,

        address: dto.address,
        city: dto.city,
        state: dto.state,

        pricePerNight: dto.pricePerNight,

        bedrooms: dto.bedrooms,
        bathrooms: dto.bathrooms,
        maxGuests: dto.maxGuests,
      },
    });
  }

  async findMine(hostId: string) {
    return this.prisma.property.findMany({
      where: {
        hostId,
      },

      orderBy: {
        createdAt: 'desc',
      },

      include: {
        images: true,
      },
    });
  }

  async findOneForHost(id: string, hostId: string) {
    const property = await this.prisma.property.findFirst({
      where: {
        id,
        hostId,
      },

      include: {
        images: true,
        amenities: {
          include: {
            amenity: true,
          },
        },
      },
    });

    if (!property) {
      throw new NotFoundException('Property not found');
    }

    return property;
  }

  async update(
    id: string,
    hostId: string,
    dto: UpdatePropertyDto,
  ) {
    await this.findOneForHost(id, hostId);

    return this.prisma.property.update({
      where: {
        id,
      },

      data: dto,
    });
  }

  async findAmenities() {
  return this.prisma.amenity.findMany({
    orderBy: {
      name: 'asc',
    },
  });
}

async setAmenities(
  propertyId: string,
  hostId: string,
  amenityIds: string[],
) {
  await this.findOneForHost(propertyId, hostId);

  const amenities = await this.prisma.amenity.findMany({
    where: {
      id: {
        in: amenityIds,
      },
    },
    select: {
      id: true,
    },
  });

  if (amenities.length !== amenityIds.length) {
    throw new BadRequestException(
      'One or more amenities are invalid',
    );
  }

  await this.prisma.$transaction(async (tx) => {
    await tx.propertyAmenity.deleteMany({
      where: {
        propertyId,
      },
    });

    if (amenityIds.length > 0) {
      await tx.propertyAmenity.createMany({
        data: amenityIds.map((amenityId) => ({
          propertyId,
          amenityId,
        })),
      });
    }
  });

  return this.findOneForHost(propertyId, hostId);
}
  async submitForApproval(id: string, hostId: string) {
  const property = await this.findOneForHost(id, hostId);

  if (property.status !== 'DRAFT') {
    throw new BadRequestException(
      'Only draft properties can be submitted for approval',
    );
  }

  return this.prisma.property.update({
    where: {
      id,
    },
    data: {
      status: 'PENDING_APPROVAL',
    },
  });
}

  async deactivate(id: string, hostId: string) {
    await this.findOneForHost(id, hostId);

    return this.prisma.property.update({
      where: {
        id,
      },

      data: {
        status: 'SUSPENDED',
      },
    });
  }
}