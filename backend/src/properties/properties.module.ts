import { Module } from '@nestjs/common';

import { PropertiesController } from './properties.controller';
import { PropertiesService } from './properties.service';
import { HostGuard } from './host.guard';
import { PublicPropertiesController } from './public-properties.controller';
import { AmenitiesController } from './amenities.controller';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    UsersModule,
  ],

 controllers: [
  PropertiesController,
  AmenitiesController,
  PropertiesController,
  AmenitiesController,
  PublicPropertiesController,
],

  providers: [
    PropertiesService,
    HostGuard,
  ],

  exports: [
    PropertiesService,
  ],
})
export class PropertiesModule {}