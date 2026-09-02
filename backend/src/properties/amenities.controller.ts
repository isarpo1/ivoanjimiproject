import {
  Controller,
  Get,
  UseGuards,
} from '@nestjs/common';

import { PropertiesService } from './properties.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { HostGuard } from './host.guard';

@Controller('host/amenities')
@UseGuards(JwtAuthGuard, HostGuard)
export class AmenitiesController {
  constructor(
    private readonly propertiesService: PropertiesService,
  ) {}

  @Get()
  findAll() {
    return this.propertiesService.findAmenities();
  }
}