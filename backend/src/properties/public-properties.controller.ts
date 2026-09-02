import {
  Controller,
  Get,
  Param,
  Query,
} from '@nestjs/common';

import { PropertiesService } from './properties.service';
import { SearchPropertiesDto } from './dto/search-properties.dto';

@Controller('properties')
export class PublicPropertiesController {
  constructor(
    private readonly propertiesService: PropertiesService,
  ) {}

  @Get()
  findAll(
    @Query() query: SearchPropertiesDto,
  ) {
    return this.propertiesService.findPublic(query);
  }

  @Get(':id')
  findOne(
    @Param('id') id: string,
  ) {
    return this.propertiesService.findPublicOne(id);
  }
}