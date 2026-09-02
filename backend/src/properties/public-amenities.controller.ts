import {
  Controller,
  Get,
} from '@nestjs/common';

import { PropertiesService } from './properties.service';

@Controller('amenities')
export class PublicAmenitiesController {
  constructor(
    private readonly propertiesService: PropertiesService,
  ) {}

  @Get()
  findAll() {
    return this.propertiesService.findAmenities();
  }
}