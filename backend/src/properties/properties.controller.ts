import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Put,
  Req,
  UseGuards,
} from '@nestjs/common';

import type { Request } from 'express';

import { PropertiesService } from './properties.service';
import { CreatePropertyDto } from './dto/create-property.dto';
import { UpdatePropertyDto } from './dto/update-property.dto';
import { UpdatePropertyAmenitiesDto } from './dto/update-property-amenities.dto';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { HostGuard } from './host.guard';

@Controller('host/properties')
@UseGuards(JwtAuthGuard, HostGuard)
export class PropertiesController {
  constructor(
    private readonly propertiesService: PropertiesService,
  ) {}

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
}