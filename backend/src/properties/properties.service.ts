import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreatePropertyDto } from './dto/create-property.dto';
import { SearchPropertiesDto } from './dto/search-properties.dto';
import { UpdatePropertyDto } from './dto/update-property.dto';
import { unlink } from 'fs/promises';
import { join } from 'path';

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
async setCoverImage(
  propertyId: string,
  hostId: string,
  imageId: string,
) {
  await this.findOneForHost(propertyId, hostId);

  const image = await this.prisma.propertyImage.findFirst({
    where: {
      id: imageId,
      propertyId,
    },
  });

  if (!image) {
    throw new NotFoundException('Image not found');
  }

  await this.prisma.$transaction([
    this.prisma.propertyImage.updateMany({
      where: {
        propertyId,
      },
      data: {
        isCover: false,
      },
    }),

    this.prisma.propertyImage.update({
      where: {
        id: imageId,
      },
      data: {
        isCover: true,
      },
    }),
  ]);

  return this.prisma.propertyImage.findMany({
    where: {
      propertyId,
    },
    orderBy: {
      displayOrder: 'asc',
    },
  });
}

async reorderImages(
  propertyId: string,
  hostId: string,
  imageIds: string[],
) {
  await this.findOneForHost(propertyId, hostId);

  const currentImages =
    await this.prisma.propertyImage.findMany({
      where: {
        propertyId,
      },
      select: {
        id: true,
      },
    });

  const currentIds = currentImages.map(
    (image) => image.id,
  );

  const allIdsValid =
    imageIds.length === currentIds.length &&
    imageIds.every((id) => currentIds.includes(id));

  if (!allIdsValid) {
    throw new BadRequestException(
      'Image list must contain all property images exactly once',
    );
  }

  await this.prisma.$transaction(
    imageIds.map((imageId, index) =>
      this.prisma.propertyImage.update({
        where: {
          id: imageId,
        },
        data: {
          displayOrder: index,
        },
      }),
    ),
  );

  return this.prisma.propertyImage.findMany({
    where: {
      propertyId,
    },
    orderBy: {
      displayOrder: 'asc',
    },
  });
}

async deleteImage(
  propertyId: string,
  hostId: string,
  imageId: string,
) {
  await this.findOneForHost(propertyId, hostId);

  const image = await this.prisma.propertyImage.findFirst({
    where: {
      id: imageId,
      propertyId,
    },
  });

  if (!image) {
    throw new NotFoundException('Image not found');
  }

  await this.prisma.propertyImage.delete({
    where: {
      id: imageId,
    },
  });

  const remainingImages =
    await this.prisma.propertyImage.findMany({
      where: {
        propertyId,
      },
      orderBy: {
        displayOrder: 'asc',
      },
    });

  if (remainingImages.length > 0) {
    await this.prisma.$transaction(
      remainingImages.map((remainingImage, index) =>
        this.prisma.propertyImage.update({
          where: {
            id: remainingImage.id,
          },
          data: {
            displayOrder: index,

            isCover:
              image.isCover && index === 0
                ? true
                : remainingImage.isCover,
          },
        }),
      ),
    );
  }

  const relativePath =
    image.imageUrl.replace(/^\/+/, '');

  const filePath = join(
    process.cwd(),
    relativePath,
  );

  try {
    await unlink(filePath);
  } catch {
    // File may already be missing locally.
  }

  return {
    message: 'Image deleted successfully',
  };
}
async findPublic(dto: SearchPropertiesDto) {
  const page = dto.page ?? 1;
  const limit = dto.limit ?? 20;

  let checkInDate: Date | undefined;
  let checkOutDate: Date | undefined;

if (dto.checkIn || dto.checkOut) {
  if (!dto.checkIn || !dto.checkOut) {
    throw new BadRequestException(
      'Both check-in and check-out dates are required',
    );
  }

  checkInDate = new Date(dto.checkIn);
  checkOutDate = new Date(dto.checkOut);

  if (checkOutDate <= checkInDate) {
    throw new BadRequestException(
      'Check-out must be after check-in',
    );
  }
}

  const where: any = {
    status: 'ACTIVE',
  };

  if (dto.city) {
    where.city = {
      contains: dto.city,
      mode: 'insensitive',
    };
  }

  if (dto.state) {
    where.state = {
      contains: dto.state,
      mode: 'insensitive',
    };
  }

  if (
    dto.minPrice !== undefined ||
    dto.maxPrice !== undefined
  ) {
    where.pricePerNight = {};

    if (dto.minPrice !== undefined) {
      where.pricePerNight.gte = dto.minPrice;
    }

    if (dto.maxPrice !== undefined) {
      where.pricePerNight.lte = dto.maxPrice;
    }
  }

  if (dto.bedrooms !== undefined) {
    where.bedrooms = {
      gte: dto.bedrooms,
    };
  }

  if (dto.guests !== undefined) {
    where.maxGuests = {
      gte: dto.guests,
    };
  }if (
  dto.amenityIds &&
  dto.amenityIds.length > 0
) {
  where.AND = dto.amenityIds.map(
    (amenityId) => ({
      amenities: {
        some: {
          amenityId,
        },
      },
    }),
  );
}
if (
  dto.amenityIds &&
  dto.amenityIds.length > 0
) {
  where.AND = dto.amenityIds.map(
    (amenityId) => ({
      amenities: {
        some: {
          amenityId,
        },
      },
    }),
  );
}

  let orderBy: any = {
    createdAt: 'desc',
  };

  if (dto.sort === 'price_asc') {
    orderBy = {
      pricePerNight: 'asc',
    };
  }

  if (dto.sort === 'price_desc') {
    orderBy = {
      pricePerNight: 'desc',
    };
  }

  const [total, properties] =
    await this.prisma.$transaction([
      this.prisma.property.count({
        where,
      }),

      this.prisma.property.findMany({
        where,

        orderBy,

        skip: (page - 1) * limit,

        take: limit,

        include: {
          images: {
            orderBy: {
              displayOrder: 'asc',
            },
          },

          amenities: {
            include: {
              amenity: true,
            },
          },

          host: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              isVerified: true,
              profilePhotoUrl: true,
            },
          },
        },
      }),
    ]);

  return {
    data: properties,

    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
}

async findPublicOne(id: string) {
  const property =
    await this.prisma.property.findFirst({
      where: {
        id,
        status: 'ACTIVE',
      },

      include: {
        images: {
          orderBy: {
            displayOrder: 'asc',
          },
        },

        amenities: {
          include: {
            amenity: true,
          },
        },

        host: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            isVerified: true,
            profilePhotoUrl: true,
          },
        },
      },
    });

  if (!property) {
    throw new NotFoundException(
      'Property not found',
    );
  }

  return property;
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
  async addImages(
  propertyId: string,
  hostId: string,
  files: Express.Multer.File[],
) {
  await this.findOneForHost(propertyId, hostId);

  if (!files || files.length === 0) {
    throw new BadRequestException(
      'At least one property image is required',
    );
  }
const existingImageCount =
  await this.prisma.propertyImage.count({
    where: {
      propertyId,
    },
  });

if (existingImageCount + files.length > 10) {
  throw new BadRequestException(
    'A property can have a maximum of 10 images',
  );
}


  const images = await this.prisma.$transaction(
    files.map((file, index) =>
      this.prisma.propertyImage.create({
        data: {
          propertyId,

          imageUrl:
            `/uploads/properties/${file.filename}`,

          displayOrder:
            existingImageCount + index,

          isCover:
            existingImageCount === 0 &&
            index === 0,
        },
      }),
    ),
  );
  

  return images;
}
}