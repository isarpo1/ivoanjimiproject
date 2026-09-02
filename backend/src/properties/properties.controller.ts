import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Put,
  Req,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';

import type { Request } from 'express';

import { PropertiesService } from './properties.service';
import { CreatePropertyDto } from './dto/create-property.dto';
import { UpdatePropertyDto } from './dto/update-property.dto';
import { UpdatePropertyAmenitiesDto } from './dto/update-property-amenities.dto';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ReorderPropertyImagesDto } from './dto/reorder-property-images.dto';
import { diskStorage } from 'multer';
import { extname } from 'path';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { HostGuard } from './host.guard';


@Controller('host/properties')
@UseGuards(JwtAuthGuard, HostGuard)
export class PropertiesController {
  constructor(
    private readonly propertiesService: PropertiesService,
  ) {}

  @Post(':id/images')
@UseInterceptors(
  FilesInterceptor('images', 10, {
    storage: diskStorage({
      destination: './uploads/properties',

      filename: (req, file, callback) => {
        const uniqueName =
          `${Date.now()}-${Math.round(
            Math.random() * 1e9,
          )}${extname(file.originalname)}`;

        callback(null, uniqueName);
      },
    }),

    fileFilter: (req, file, callback) => {
      const allowedTypes = [
        'image/jpeg',
        'image/png',
        'image/webp',
      ];

      if (!allowedTypes.includes(file.mimetype)) {
        return callback(
          new BadRequestException(
            'Only JPEG, PNG, and WebP images are allowed',
          ),
          false,
        );
      }

      callback(null, true);
    },

    limits: {
      fileSize: 5 * 1024 * 1024,
    },
  }),
)
uploadImages(
  @Req() request: Request,
  @Param('id') id: string,
  @UploadedFiles() files: Express.Multer.File[],
) {
  const payload = (request as any).user;

  return this.propertiesService.addImages(
    id,
    payload.sub,
    files,
  );
}
  @Post()
  create(
    @Req() request: Request,
    @Body() dto: CreatePropertyDto,
  ) {
    const payload = (request as any).user;

    return this.propertiesService.create(
      payload.sub,
      dto,
    );
  }

  @Get()
  findMine(@Req() request: Request) {
    const payload = (request as any).user;

    return this.propertiesService.findMine(
      payload.sub,
    );
  }

  @Get(':id')
  findOne(
    @Req() request: Request,
    @Param('id') id: string,
  ) {
    const payload = (request as any).user;

    return this.propertiesService.findOneForHost(
      id,
      payload.sub,
    );
  }
  @Put(':id/amenities')
setAmenities(
  @Req() request: Request,
  @Param('id') id: string,
  @Body() dto: UpdatePropertyAmenitiesDto,
) {
  const payload = (request as any).user;

  return this.propertiesService.setAmenities(
    id,
    payload.sub,
    dto.amenityIds,
  );
}

  @Patch(':id')
  update(
    @Req() request: Request,
    @Param('id') id: string,
    @Body() dto: UpdatePropertyDto,
  ) {
    const payload = (request as any).user;

    return this.propertiesService.update(
      id,
      payload.sub,
      dto,
    );
  }
  @Patch(':id/submit')
submitForApproval(
  @Req() request: Request,
  @Param('id') id: string,
) {
  const payload = (request as any).user;

  return this.propertiesService.submitForApproval(
    id,
    payload.sub,
  );
}

  @Patch(':id/deactivate')
  deactivate(
    @Req() request: Request,
    @Param('id') id: string,
  ) {
    const payload = (request as any).user;

    return this.propertiesService.deactivate(
      id,
      payload.sub,
    );
  }
  @Patch(':id/images/:imageId/cover')
setCoverImage(
  @Req() request: Request,
  @Param('id') id: string,
  @Param('imageId') imageId: string,
) {
  const payload = (request as any).user;

  return this.propertiesService.setCoverImage(
    id,
    payload.sub,
    imageId,
  );
}

@Put(':id/images/reorder')
reorderImages(
  @Req() request: Request,
  @Param('id') id: string,
  @Body() dto: ReorderPropertyImagesDto,
) {
  const payload = (request as any).user;

  return this.propertiesService.reorderImages(
    id,
    payload.sub,
    dto.imageIds,
  );
}

@Delete(':id/images/:imageId')
deleteImage(
  @Req() request: Request,
  @Param('id') id: string,
  @Param('imageId') imageId: string,
) {
  const payload = (request as any).user;

  return this.propertiesService.deleteImage(
    id,
    payload.sub,
    imageId,
  );
}
  
}